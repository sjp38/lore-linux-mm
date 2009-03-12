Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AAAB36B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:35:11 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so280654wfa.11
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 17:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090311170207.1795cad9.akpm@linux-foundation.org>
References: <20090311153034.9389.19938.stgit@warthog.procyon.org.uk>
	 <20090311150302.0ae76cf1.akpm@linux-foundation.org>
	 <20090311170207.1795cad9.akpm@linux-foundation.org>
Date: Thu, 12 Mar 2009 09:35:05 +0900
Message-ID: <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may
	get wrongly discarded
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 9:02 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 11 Mar 2009 15:03:02 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> > The problem is that the pages are not marked dirty. =C2=A0Anything tha=
t creates data
>> > in an MMU-based ramfs will cause the pages holding that data will caus=
e the
>> > set_page_dirty() aop to be called.
>> >
>> > For the NOMMU-based mmap, set_page_dirty() may be called by write(), b=
ut it
>> > won't be called by page-writing faults on writable mmaps, and it isn't=
 called
>> > by ramfs_nommu_expand_for_mapping() when a file is being truncated fro=
m nothing
>> > to allocate a contiguous run.
>> >
>> > The solution is to mark the pages dirty at the point of allocation by
>> > the truncation code.
>>
>> Page reclaim shouldn't be even attempting to reclaim or write back
>> ramfs pagecache pages - reclaim can't possibly do anything with these
>> pages!
>>
>> Arguably those pages shouldn't be on the LRU at all, but we haven't
>> done that yet.
>>
>> Now, my problem is that I can't 100% be sure that we _ever_ implemented
>> this properly. =C2=A0I _think_ we did, in which case we later broke it. =
=C2=A0If
>> we've always been (stupidly) trying to pageout these pages then OK, I
>> guess your patch is a suitable 2.6.29 stopgap.
>
> OK, I can't find any code anywhere in which we excluded ramfs pages
> from consideration by page reclaim. =C2=A0How dumb.


The ramfs  considers it in just CONFIG_UNEVICTABLE_LRU case
It that case, ramfs_get_inode calls mapping_set_unevictable.
So,  page reclaim can exclude ramfs pages by page_evictable.
It's problem .


> So I guess that for now the proposed patch is suitable. =C2=A0Longer-term=
 we
> should bale early in shrink_page_list(), or not add these pages to the
> LRU at all.

In future, we have to improve this.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
