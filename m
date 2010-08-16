Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9E06B01F1
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 22:08:57 -0400 (EDT)
Date: Mon, 16 Aug 2010 11:07:37 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC] [PATCH 2/4] dio: add page locking for direct I/O
Message-ID: <20100816020737.GA19531@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
 <20100812075941.GD6112@spritzera.linux.bs1.fc.nec.co.jp>
 <x49aaos3q2q.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <x49aaos3q2q.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 12, 2010 at 09:42:21AM -0400, Jeff Moyer wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > Basically it is user's responsibility to take care of race condition
> > related to direct I/O, but some events which are out of user's control
> > (such as memory failure) can happen at any time. So we need to lock and
> > set/clear PG_writeback flags in dierct I/O code to protect from data loss.
> 
> Did you do any performance testing of this?  If not, please do and
> report back.  I'm betting users won't be pleased with the results.

Here is the result of my direct I/O benchmarck, which mesures the time
it takes to do direct I/O for 20000 pages on 2MB buffer for four types
of I/O. Each I/O is issued for one page unit and each number below is
the average of 25 runs.

                                  with patchset          2.6.35-rc3
   Buffer      I/O type        average(s)  STD(s)   average(s)  STD(s)   diff(s)
  hugepage   Sequential Read      3.87      0.16       3.88      0.20    -0.01
             Sequential Write     7.69      0.43       7.69      0.43     0.00
             Random Read          5.93      1.58       6.49      1.45    -0.55
             Random Write        13.50      0.28      13.41      0.30     0.09
  anonymous  Sequential Read      3.88      0.21       3.89      0.23    -0.01
             Sequential Write     7.86      0.39       7.80      0.34     0.05
             Random Read          7.67      1.60       6.86      1.27     0.80
             Random Write        13.50      0.25      13.52      0.31    -0.01

>From this result, although fluctuation is relatively large for random read,
differences between vanilla kernel and patched one are within the deviations and
it seems that adding direct I/O lock makes little or no impact on performance.

And I know the workload of this benchmark can be too simple,
so please let me know if you think we have another workload to be looked into.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
