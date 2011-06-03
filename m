Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9ADF6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 13:06:25 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p53H6L66024166
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 10:06:22 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by kpbe16.cbf.corp.google.com with ESMTP id p53H56Nh011207
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 10:06:19 -0700
Received: by pzk26 with SMTP id 26so1061610pzk.24
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 10:06:19 -0700 (PDT)
Date: Fri, 3 Jun 2011 10:06:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
In-Reply-To: <20110602174305.GH19505@random.random>
Message-ID: <alpine.LSU.2.00.1106030957090.1901@sister.anvils>
References: <20110601222032.GA2858@thinkpad> <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <20110602141927.GA2011@thinkpad> <20110602164841.GK23047@sequoia.sous-sol.org> <alpine.LSU.2.00.1106021011300.1277@sister.anvils>
 <20110602174305.GH19505@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@sous-sol.org>, Andrea Righi <andrea@betterlinux.com>, CAI Qian <caiqian@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2 Jun 2011, Andrea Arcangeli wrote:
> On Thu, Jun 02, 2011 at 10:29:39AM -0700, Hugh Dickins wrote:
> > AndreaA, I didn't study the patch you posted half an hour ago,
> > since by that time I'd worked it out and was preparing patch below.
> > I think your patch would be for a different bug, hopefully one we
> > don't have, it looks more complicated than we should need for this.
> 
> I didn't expect two different bugs leading to double free.

There wasn't a double free there, just failure to cope with race
emptying the list, so accessing head when expecting a full entry.

> 
> If you've time please review my other patch too because mmput runs
> with no mmap_sem hold and I think the ksm scan code runs under the
> assumption that __ksm_exit is waiting in down_write() when
> ksm_mmlist_lock is released (before freeing the mm_slot), and that
> assumption is wrong. ksm_test_exit may very well be true despite
> __ksm_exit didn't run yet, and ksm scan will proceed freeing after
> changing the mm_slot and ksm_exit will be free to run and free again
> immediately after the ksm scan releases the ksm_mmlist_lock and before
> it clears the MMF_VM_MERGEABLE (because the mm_slot has been changed
> before releasing the ksm_mmlist_lock).
> 
> The rmap_list being null will kind of hide it, the fact there's so
> little time between the unlock of the ksm_mmlist_lock and the clearing
> of MMF_VM_MERGEABLE (that will stop ksm_exit from calling __ksm_exit
> at all) will also hide it. At least in
> unmerge_and_remove_all_rmap_items remove_trailing_rmap_items will nuke
> the rmap_list just before this race runs so making it more likely
> possible.

You'll see from the "beware" comment in scan_get_next_rmap_item()
that this case is expected, that it sometimes reaches freeing the
slots before the exiting task reaches __ksm_exit().

That race should already be handled.  I believe your patch is unnecessary,
because get_mm_slot() is a hashlist lookup, and will return NULL once
either end has done the hlist_del(&mm_slot->link).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
