Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EE7D76B004A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 19:56:05 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1176048yhr.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 16:56:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F973BF2.4080406@jp.fujitsu.com>
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
 <4F963742.2030607@jp.fujitsu.com> <4F963B8E.9030105@kernel.org>
 <CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com>
 <4F965413.9010305@kernel.org> <CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
 <20120424143015.99fd8d4a.akpm@linux-foundation.org> <4F973BF2.4080406@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 24 Apr 2012 19:55:43 -0400
Message-ID: <CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com>
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 24, 2012 at 7:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/04/25 6:30), Andrew Morton wrote:
>
>> On Tue, 24 Apr 2012 17:48:29 +1000
>> Nick Piggin <npiggin@gmail.com> wrote:
>>
>>>> Hmm, there are several places to use GFP_NOIO and GFP_NOFS even, GFP_A=
TOMIC.
>>>> I believe it's not trivial now.
>>>
>>> They're all buggy then. Unfortunately not through any real fault of the=
ir own.
>>
>> There are gruesome problems in block/blk-throttle.c (thread "mempool,
>> percpu, blkcg: fix percpu stat allocation and remove stats_lock"). =A0It
>> wants to do an alloc_percpu()->vmalloc() from the IO submission path,
>> under GFP_NOIO.
>>
>> Changing vmalloc() to take a gfp_t does make lots of sense, although I
>> worry a bit about making vmalloc() easier to use!
>>
>> I do wonder whether the whole scheme of explicitly passing a gfp_t was
>> a mistake and that the allocation context should be part of the task
>> context. =A0ie: pass the allocation mode via *current.
>
> yes...that's very interesting.

I think GFP_ATOMIC is used non task context too. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
