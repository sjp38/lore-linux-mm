Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D129F8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:25:49 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p2BKPkVN019143
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:25:46 -0800
Received: from vxd2 (vxd2.prod.google.com [10.241.33.194])
	by hpaq1.eem.corp.google.com with ESMTP id p2BKOwQF029668
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:25:45 -0800
Received: by vxd2 with SMTP id 2so3138802vxd.36
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:25:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
References: <20110311020410.GH5641@random.random>
	<AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
Date: Fri, 11 Mar 2011 12:25:42 -0800
Message-ID: <AANLkTi=EWW=uaHZbW95_eqabVHTsMdX5N2h_axqi27nn@mail.gmail.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

Fri, Mar 11, 2011 at 11:44 AM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, Mar 10, 2011 at 6:04 PM, Andrea Arcangeli <aarcange@redhat.com> w=
rote:
>>
>> I've been wondering why mremap is sending one IPI for each page that
>> it moves. I tried to remove that so we send an IPI for each
>> vma/syscall (not for each pte/page).
>
> (It wouldn't usually have been sending an IPI for each page, only if
> the mm were active on another cpu, but...)
>
> That looks like a good optimization to me: I can't think of a good
> reason for it to be the way it was, just it started out like that and
> none of us ever thought to change it before. =C2=A0Plus it's always nice =
to
> see the flush_tlb_range() afterwards complementing the
> flush_cache_range() beforehand, as you now have in move_page_tables().
>
> And don't forget that move_page_tables() is also used by exec's
> shift_arg_pages(): no IPI saving there, but it should be more
> efficient when exec'ing with many arguments.

Perhaps I should qualify that answer: although I still think it's the
right change to make (it matches mprotect, for example), and an
optimization in many cases, it will be a pessimization for anyone who
mremap moves unpopulated areas (I doubt that's common), and for anyone
who moves around single page areas (on x86 and probably some others).
But the exec args case has, I think, few useful tlb entries to lose
from the mm-wide tlb flush.

flush_tlb_range() ought to special case small areas, doing at most one
IPI, but up to some number of flush_tlb_one()s; but that would
certainly have to be another patch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
