Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 786016B0253
	for <linux-mm@kvack.org>; Tue, 17 May 2016 21:27:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so66845282pfb.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 18:27:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id aj1si8280310pad.84.2016.05.17.18.27.08
        for <linux-mm@kvack.org>;
        Tue, 17 May 2016 18:27:09 -0700 (PDT)
Date: Wed, 18 May 2016 10:27:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: make faultaround produce old ptes
Message-ID: <20160518012713.GA21538@bbox>
References: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160518012259.GA21490@bbox>
MIME-Version: 1.0
In-Reply-To: <20160518012259.GA21490@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>

On Wed, May 18, 2016 at 10:22:59AM +0900, Minchan Kim wrote:
> On Tue, May 17, 2016 at 03:32:46PM +0300, Kirill A. Shutemov wrote:
> > Currently, faultaround code produces young pte. This can screw up vmscan
> > behaviour[1], as it makes vmscan think that these pages are hot and not
> > push them out on first round.
> > 
> > Let modify faultaround to produce old pte, so they can easily be
> > reclaimed under memory pressure.
> > 
> > This can to some extend defeat purpose of faultaround on machines
> > without hardware accessed bit as it will not help up with reducing
> > number of minor page faults.
> > 
> > We may want to disable faultaround on such machines altogether, but
> > that's subject for separate patchset.
> > 
> > [1] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vinayak Menon <vinmenon@codeaurora.org>
> > Cc: Minchan Kim <minchan@kernel.org>
> 
> I tested 512M mmap sequential word read test on non-HW access bit system
> (i.e., ARM) and confirmed it doesn't increase minor fault any more.
> 
> = old =
> minor fault: 131291
> elapsed time: 6747645 usec
> 
> = new =
> minor fault: 131291
> elapsed time: 6709263 usec
> 
> 0.56% benefit
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

Oops, label was wrong.

I meant

old : 4096 fault_around
new : 65536 fault_around

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
