Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 1D5456B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:57:53 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:57:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130319105748.GH2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <5146FC86.2080107@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5146FC86.2080107@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 18, 2013 at 07:37:42PM +0800, Simon Jeons wrote:
> On 03/17/2013 09:04 PM, Mel Gorman wrote:
> >Historically, kswapd used to congestion_wait() at higher priorities if it
> >was not making forward progress. This made no sense as the failure to make
> >progress could be completely independent of IO. It was later replaced by
> >wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
> >wait on congested zones in balance_pgdat()) as it was duplicating logic
> >in shrink_inactive_list().
> >
> >This is problematic. If kswapd encounters many pages under writeback and
> >it continues to scan until it reaches the high watermark then it will
> >quickly skip over the pages under writeback and reclaim clean young
> >pages or push applications out to swap.
> >
> >The use of wait_iff_congested() is not suited to kswapd as it will only
> >stall if the underlying BDI is really congested or a direct reclaimer was
> >unable to write to the underlying BDI. kswapd bypasses the BDI congestion
> >as it sets PF_SWAPWRITE but even if this was taken into account then it
> 
> Where will check this flag?
> 

may_write_to_queue

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
