Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0F9900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 18:40:13 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p7TMeBDf015635
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 15:40:11 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz21.hot.corp.google.com with ESMTP id p7TMdgG6017811
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 15:40:10 -0700
Received: by qwc9 with SMTP id 9so4212838qwc.41
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 15:40:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110827173421.GA2967@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
	<20110822213347.GF2507@redhat.com>
	<CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
	<20110824000914.GH23870@redhat.com>
	<20110824002717.GI23870@redhat.com>
	<20110824133459.GP23870@redhat.com>
	<20110826062436.GA5847@google.com>
	<20110826161048.GE23870@redhat.com>
	<20110826185430.GA2854@redhat.com>
	<20110827094152.GA16402@google.com>
	<20110827173421.GA2967@redhat.com>
Date: Mon, 29 Aug 2011 15:40:07 -0700
Message-ID: <CANN689G4HowkFC7BG69F-PJMne5Mhs51O=KgmmJUjiXfG-o9BQ@mail.gmail.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #4
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sat, Aug 27, 2011 at 10:34 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Subject: thp: tail page refcounting fix
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> Michel while working on the working set estimation code, noticed that calling
> get_page_unless_zero() on a random pfn_to_page(random_pfn) wasn't safe, if the
> pfn ended up being a tail page of a transparent hugepage under splitting by
> __split_huge_page_refcount(). He then found the problem could also
> theoretically materialize with page_cache_get_speculative() during the
> speculative radix tree lookups that uses get_page_unless_zero() in SMP if the
> radix tree page is freed and reallocated and get_user_pages is called on it
> before page_cache_get_speculative has a chance to call get_page_unless_zero().
>
> So the best way to fix the problem is to keep page_tail->_count zero at all
> times. This will guarantee that get_page_unless_zero() can never succeed on any
> tail page. page_tail->_mapcount is guaranteed zero and is unused for all tail
> pages of a compound page, so we can simply account the tail page references
> there and transfer them to tail_page->_count in __split_huge_page_refcount() (in
> addition to the head_page->_mapcount).
>
> While debugging this s/_count/_mapcount/ change I also noticed get_page is
> called by direct-io.c on pages returned by get_user_pages. That wasn't entirely
> safe because the two atomic_inc in get_page weren't atomic. As opposed other
> get_user_page users like secondary-MMU page fault to establish the shadow
> pagetables would never call any superflous get_page after get_user_page
> returns. It's safer to make get_page universally safe for tail pages and to use
> get_page_foll() within follow_page (inside get_user_pages()). get_page_foll()
> is safe to do the refcounting for tail pages without taking any locks because
> it is run within PT lock protected critical sections (PT lock for pte and
> page_table_lock for pmd_trans_huge). The standard get_page() as invoked by
> direct-io instead will now take the compound_lock but still only for tail
> pages. The direct-io paths are usually I/O bound and the compound_lock is per
> THP so very finegrined, so there's no risk of scalability issues with it. A
> simple direct-io benchmarks with all lockdep prove locking and spinlock
> debugging infrastructure enabled shows identical performance and no overhead.
> So it's worth it. Ideally direct-io should stop calling get_page() on pages
> returned by get_user_pages(). The spinlock in get_page() is already optimized
> away for no-THP builds but doing get_page() on tail pages returned by GUP is
> generally a rare operation and usually only run in I/O paths.
>
> This new refcounting on page_tail->_mapcount in addition to avoiding new RCU
> critical sections will also allow the working set estimation code to work
> without any further complexity associated to the tail page refcounting
> with THP.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Michel Lespinasse <walken@google.com>
> Reviewed-by: Michel Lespinasse <walken@google.com>

Looks great.

I think some page_mapcount call sites would be easier to read if you
took on my tail_page_count() suggestion (so we can casually see it's a
refcount rather than mapcount). But you don't have to do it if you
don't think it helps. I'm happy enough with the code already :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
