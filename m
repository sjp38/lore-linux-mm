Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6C42B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 04:23:35 -0400 (EDT)
Date: Tue, 19 Mar 2013 09:23:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130319082330.GA7869@dhcp22.suse.cz>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <5147D6A7.5060008@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5147D6A7.5060008@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 19-03-13 11:08:23, Simon Jeons wrote:
> Hi Mel,
> On 03/17/2013 09:04 PM, Mel Gorman wrote:
> >kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
> >pages have been reclaimed or the pgdat is considered balanced. It then
> >rechecks if it needs to restart at DEF_PRIORITY and whether high-order
> >reclaim needs to be reset. This is not wrong per-se but it is confusing
> 
> per-se is short for what?
> 
> >to follow and forcing kswapd to stay at DEF_PRIORITY may require several
> >restarts before it has scanned enough pages to meet the high watermark even
> >at 100% efficiency. This patch irons out the logic a bit by controlling
> >when priority is raised and removing the "goto loop_again".
> >
> >This patch has kswapd raise the scanning priority until it is scanningmm: vmscan: Flatten kswapd priority loop
> >enough pages that it could meet the high watermark in one shrink of the
> >LRU lists if it is able to reclaim at 100% efficiency. It will not raise
> 
> Which kind of reclaim can be treated as 100% efficiency?

nr_scanned == nr_reclaimed
 
> >the scanning prioirty higher unless it is failing to reclaim any pages.
> >
> >To avoid infinite looping for high-order allocation requests kswapd will
> >not reclaim for high-order allocations when it has reclaimed at least
> >twice the number of pages as the allocation request.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
