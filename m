Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D33B38D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 14:44:10 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p2BJi5VI013653
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:44:05 -0800
Received: from vxc34 (vxc34.prod.google.com [10.241.33.162])
	by wpaz17.hot.corp.google.com with ESMTP id p2BJi3dp012993
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:44:04 -0800
Received: by vxc34 with SMTP id 34so3270036vxc.13
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:44:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110311020410.GH5641@random.random>
References: <20110311020410.GH5641@random.random>
Date: Fri, 11 Mar 2011 11:44:03 -0800
Message-ID: <AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Mar 10, 2011 at 6:04 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> I've been wondering why mremap is sending one IPI for each page that
> it moves. I tried to remove that so we send an IPI for each
> vma/syscall (not for each pte/page).

(It wouldn't usually have been sending an IPI for each page, only if
the mm were active on another cpu, but...)

That looks like a good optimization to me: I can't think of a good
reason for it to be the way it was, just it started out like that and
none of us ever thought to change it before.  Plus it's always nice to
see the flush_tlb_range() afterwards complementing the
flush_cache_range() beforehand, as you now have in move_page_tables().

And don't forget that move_page_tables() is also used by exec's
shift_arg_pages(): no IPI saving there, but it should be more
efficient when exec'ing with many arguments.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
