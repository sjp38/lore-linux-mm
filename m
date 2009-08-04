Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DBF16B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 08:24:16 -0400 (EDT)
Message-ID: <4A782FDF.40908@redhat.com>
Date: Tue, 04 Aug 2009 15:55:59 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/12] ksm: fix endless loop on oom
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031315200.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031315200.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> break_ksm has been looping endlessly ignoring VM_FAULT_OOM: that should
> only be a problem for ksmd when a memory control group imposes limits
> (normally the OOM killer will kill others with an mm until it succeeds);
> but in general (especially for MADV_UNMERGEABLE and KSM_RUN_UNMERGE) we
> do need to route the error (or kill) back to the caller (or sighandling).
>
> Test signal_pending in unmerge_ksm_pages, which could be a lengthy
> procedure if it has to spill into swap: returning -ERESTARTSYS so that
> trivial signals will restart but fatals will terminate (is that right?
> we do different things in different places in mm, none exactly this).
>
> unmerge_and_remove_all_rmap_items was forgetting to lock when going
> down the mm_list: fix that.  Whether it's successful or not, reset
> ksm_scan cursor to head; but only if it's successful, reset seqnr
> (shown in full_scans) - page counts will have gone down to zero.
>
> This patch leaves a significant OOM deadlock, but it's a good step
> on the way, and that deadlock is fixed in a subsequent patch.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>
>   
Better than before for sure, And I dont have in mind better and yet 
simple solution for the "failing to break the pages" then to just wait 
and catch them in the next scan, so ACK.

Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
