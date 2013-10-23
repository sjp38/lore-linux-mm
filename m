Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7143B6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 12:26:56 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1457318pab.25
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 09:26:56 -0700 (PDT)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id je1si2507307pbb.60.2013.10.23.09.26.54
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 09:26:55 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 24 Oct 2013 02:26:49 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1C10D2BB0056
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:26:45 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9NG9UH162652572
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:09:31 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9NGQhFI000496
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:26:44 +1100
Message-ID: <5267F7B7.5060203@linux.vnet.ibm.com>
Date: Wed, 23 Oct 2013 21:52:15 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 16/40] mm: Introduce a "Region Allocator" to manage
 entire memory regions
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <20130925231730.26184.19552.stgit@srivatsabhat.in.ibm.com> <20131023101012.GB2043@cmpxchg.org>
In-Reply-To: <20131023101012.GB2043@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.gross@intel.com

On 10/23/2013 03:40 PM, Johannes Weiner wrote:
> On Thu, Sep 26, 2013 at 04:47:34AM +0530, Srivatsa S. Bhat wrote:
>> Today, the MM subsystem uses the buddy 'Page Allocator' to manage memory
>> at a 'page' granularity. But this allocator has no notion of the physical
>> topology of the underlying memory hardware, and hence it is hard to
>> influence memory allocation decisions keeping the platform constraints
>> in mind.
> 
> This is no longer true after patches 1-15 introduce regions and have
> the allocator try to stay within the lowest possible region (patch
> 15).

Sorry, the changelog is indeed misleading. What I really meant to say
here is that there is no way to keep an entire region homogeneous with
respect to allocation types: ie., have only a single type of allocations
(like movable). Patches 1-15 don't address that problem. The later ones
do.

>  Which leaves the question what the following patches are for.
> 

The region allocator is meant to help in keeping entire memory regions
homogeneous with respect to allocations. This helps in increasing the
success rate of targeted region evacuation. For example, if we know
that the region has only unmovable allocations, we can completely skip
compaction/evac on that region. And this can be determined just by looking
at the pageblock migratetype of *one* of the pages of that region; thus
its very cheap. Similarly, if we know that the region has only movable
allocations, we can try compaction on that when its lightly allocated.
And we won't have horrible scenarios where we moved say 15 pages and then
found out that there is an unmovable page stuck in that region, making
all that previous work go waste.

> This patch only adds a data structure and I gave up finding where
> among the helpers, statistics, and optimization patches an actual
> implementation is.
> 

I hope the patch-wise explanation that I gave in the other mail will
help make this understandable. Please do let me know if you need any
other clarifications.

> Again, please try to make every single a patch a complete logical
> change to the code base.

Sure, I'll strive for that in the next postings.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
