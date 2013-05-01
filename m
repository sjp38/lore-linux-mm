Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 712486B0173
	for <linux-mm@kvack.org>; Wed,  1 May 2013 04:31:45 -0400 (EDT)
Date: Wed, 1 May 2013 09:31:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: Ensure that mark_page_accessed moves pages to
 the active list
Message-ID: <20130501083139.GH11497@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
 <1367253119-6461-3-git-send-email-mgorman@suse.de>
 <5180AB0E.6030407@gmail.com>
 <20130501080644.GE11497@suse.de>
 <5180CED8.9040505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5180CED8.9040505@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Sam Ben <sam.bennn@gmail.com>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 01, 2013 at 04:14:16PM +0800, Ric Mason wrote:
> On 05/01/2013 04:06 PM, Mel Gorman wrote:
> >On Wed, May 01, 2013 at 01:41:34PM +0800, Sam Ben wrote:
> >>Hi Mel,
> >>On 04/30/2013 12:31 AM, Mel Gorman wrote:
> >>>If a page is on a pagevec then it is !PageLRU and mark_page_accessed()
> >>>may fail to move a page to the active list as expected. Now that the
> >>>LRU is selected at LRU drain time, mark pages PageActive if they are
> >>>on a pagevec so it gets moved to the correct list at LRU drain time.
> >>>Using a debugging patch it was found that for a simple git checkout
> >>>based workload that pages were never added to the active file list in
> >>Could you show us the details of your workload?
> >>
> >The workload is git checkouts of a fixed number of commits for the
> 
> Is there script which you used?
> 

mmtests with config-global-dhp__io-gitcheckout-randread-starvation . Parallel
randread was to see if the random file read would push the metadata blocks
out or not. I expected it would not be enough to trigger the reported
problem but it would be enough to determine if file pages were getting
added to the active lists or not.

> >kernel git tree. It starts with a warm-up run that is not timed and then
> >records the time for a number of iterations.
> 
> How to record the time for a number of iterations? Is the iteration
> here means lru scan?
> 

/usr/bin/time

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
