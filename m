Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 50005900113
	for <linux-mm@kvack.org>; Sun,  1 May 2011 11:29:12 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3364818qyk.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 08:29:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110501224844.75EC.A69D9226@jp.fujitsu.com>
References: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
	<20110428110623.GU4658@suse.de>
	<20110501224844.75EC.A69D9226@jp.fujitsu.com>
Date: Mon, 2 May 2011 00:29:10 +0900
Message-ID: <BANLkTikHf+3vhnXFu3ubWXOXkCkD4j206Q@mail.gmail.com>
Subject: Re: [RFC 6/8] In order putback lru core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Sun, May 1, 2011 at 10:47 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > +/* This structure is used for keeping LRU ordering of isolated page *=
/
>> > +struct pages_lru {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page; =C2=A0 =C2=A0 =C2=A0/*=
 isolated page */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *prev_page; /* previous page =
of isolate page as LRU order */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *next_page; /* next page of i=
solate page as LRU order */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head lru;
>> > +};
>> > =C2=A0/*
>>
>> So this thing has to be allocated from somewhere. We can't put it
>> on the stack as we're already in danger there so we must be using
>> kmalloc. In the reclaim paths, this should be avoided obviously.
>> For compaction, we might hurt the compaction success rates if pages
>> are pinned with control structures. It's something to be wary of.
>>
>> At LSF/MM, I stated a preference for swapping the source and
>> destination pages in the LRU. This unfortunately means that the LRU
>> now contains a page in the process of being migrated to and the backout
>> paths for migration failure become a lot more complex. Reclaim should
>> be ok as it'll should fail to lock the page and recycle it in the list.
>> This avoids allocations but I freely admit that I'm not in the position
>> to implement such a thing right now :(
>
> I like swaping to fake page. one way pointer might become dangerous. vmsc=
an can
> detect fake page and ignore it.


I guess it means swapping between migrated-from page and migrated-to page.
Right? If so, migrated-from page is already removed from LRU list and
migrated-to page isn't LRU as it's page allocated newly so they don't
have any LRU information. How can we swap them? We need space keeps
LRU information before removing the page from LRU list. :(

Could you explain in detail about swapping if I miss something?

About one way pointer, I think it's no problem. Worst case I imagine
is to put the page in head of LRU list. It means it's same issue now.
So it doesn't make worse than now.

>
> ie,
> is_fake_page(page)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (is_stack_addr((void*)page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
> }
>
> Also, I like to use stack rather than kmalloc in compaction.
>

Compaction is a procedure of reclaim. As you know, we had a problem
about using of stack during reclaim path.
I admit kmalloc-thing isn't good.
I will try to solve the issue as TODO.

Thanks for the review, KOSAKI.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
