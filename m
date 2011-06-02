Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D4F306B00E8
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 13:29:57 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p52HTpx0022811
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:29:52 -0700
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by wpaz24.hot.corp.google.com with ESMTP id p52HTKP2027454
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:29:50 -0700
Received: by pxi13 with SMTP id 13so562434pxi.11
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 10:29:50 -0700 (PDT)
Date: Thu, 2 Jun 2011 10:29:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
In-Reply-To: <20110602164841.GK23047@sequoia.sous-sol.org>
Message-ID: <alpine.LSU.2.00.1106021011300.1277@sister.anvils>
References: <20110601222032.GA2858@thinkpad> <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <20110602141927.GA2011@thinkpad> <20110602164841.GK23047@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Righi <andrea@betterlinux.com>, CAI Qian <caiqian@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2 Jun 2011, Chris Wright wrote:
> * Andrea Righi (andrea@betterlinux.com) wrote:
> > mmh.. I can reproduce the bug also with the standard ubuntu (11.04)
> > kernel. Could you post your .config?
> 
> Andrea (Righi), can you tell me if this WARN fires?  This looks
> like a pure race between removing from list and checking list, i.e.
> insufficient locking.
> 
> ksm_scan.mm_slot == the only registered mm
> 
> CPU 1 (bug program)		CPU 2 (ksmd)
> 				list_empty() is false
> lock
> ksm_scan.mm_slot
> list_del
> unlock
> 				slot == &ksm_mm_head (but list is now empty_)
> 
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 942dfc7..ab79a92 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1301,6 +1301,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
>  		ksm_scan.mm_slot = slot;
>  		spin_unlock(&ksm_mmlist_lock);
> +		WARN_ON(slot == &ksm_mm_head);
>  next_mm:
>  		ksm_scan.address = 0;
>  		ksm_scan.rmap_list = &slot->rmap_list;

AndreaR, good find, many thanks for discovering and reporting it.
I couldn't look at it until last night, and even then, it was not
obvious to me exactly where my assumptions were going wrong.

Even now it's unclear what role the SIGSEGV plays, as opposed to an
normal exit: I guess it just happens to change the timing enough to
make the race dangerous.

Your patch was not wrong, but I do prefer a patch that plugs the
exact hole; and I needed to understand what was going on - without
understanding it, there was a danger we might leak memory instead.

AndreaA, I didn't study the patch you posted half an hour ago,
since by that time I'd worked it out and was preparing patch below.
I think your patch would be for a different bug, hopefully one we
don't have, it looks more complicated than we should need for this.

ChrisW, yes, your WARN_ON is spot on, matches what I saw exactly.

I'll fill in the patch description later, must dash now, probably
offline until late tonight.  Or if you're satisfied and don't want to
wait, you guys fill that in and send off to Linus & Andrew - thanks.

[PATCH] ksm: fix easily reproduced NULL pointer dereference

Reported-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/ksm.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- 3.0-rc1/mm/ksm.c	2011-05-29 18:42:37.429882601 -0700
+++ linux/mm/ksm.c	2011-06-02 09:55:31.729702490 -0700
@@ -1302,6 +1302,13 @@ static struct rmap_item *scan_get_next_r
 		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
 		ksm_scan.mm_slot = slot;
 		spin_unlock(&ksm_mmlist_lock);
+
+		/*
+		 * Although we tested list_empty() above, a racing __ksm_exit
+		 * of the last mm on the list may have removed it since then.
+		 */
+		if (slot == &ksm_mm_head)
+			return NULL;
 next_mm:
 		ksm_scan.address = 0;
 		ksm_scan.rmap_list = &slot->rmap_list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
