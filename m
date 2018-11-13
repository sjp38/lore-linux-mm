Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24DFA6B000E
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:02:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so1388018plr.8
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:02:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13-v6si20205608pgp.145.2018.11.13.00.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 00:02:37 -0800 (PST)
Date: Tue, 13 Nov 2018 09:02:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/5] mm, memory_hotplug: print reason for the
 offlining failure
Message-ID: <20181113080234.GI15120@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-5-mhocko@kernel.org>
 <20181107140413.2c0061e440123be76bf419bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107140413.2c0061e440123be76bf419bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-18 14:04:13, Andrew Morton wrote:
> On Wed,  7 Nov 2018 11:18:29 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > The memory offlining failure reporting is inconsistent and insufficient.
> > Some error paths simply do not report the failure to the log at all.
> > When we do report there are no details about the reason of the failure
> > and there are several of them which makes memory offlining failures
> > hard to debug.
> > 
> > Make sure that the
> > 	memory offlining [mem %#010llx-%#010llx] failed
> > message is printed for all failures and also provide a short textual
> > reason for the failure e.g.
> > 
> > [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> > 
> > this tells us that the offlining has failed because of a signal pending
> > aka user intervention.
> > 
> > ...
> 
> Some of these messages will come out looking a bit odd.
> 
> > @@ -1573,7 +1576,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  				       MIGRATE_MOVABLE, true);
> >  	if (ret) {
> >  		mem_hotplug_done();
> > -		return ret;
> > +		reason = "failed to isolate range";
> 
> "memory offlining [mem ...] failed due to failed to isolate range"
> 
> > +		goto failed_removal
> >  	}
> >  
> >  	arg.start_pfn = start_pfn;
> > @@ -1582,15 +1586,19 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  
> >  	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
> >  	ret = notifier_to_errno(ret);
> > -	if (ret)
> > -		goto failed_removal;
> > +	if (ret) {
> > +		reason = "notifiers failure";
> 
> "memory offlining [mem ...] failed due to notifiers failure"
> 
> > @@ -1607,8 +1615,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
> >  	 * actually in order to make hugetlbfs's object counting consistent.
> >  	 */
> >  	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> > -	if (ret)
> > -		goto failed_removal;
> > +	if (ret) {
> > +		reason = "fails to disolve hugetlb pages";
> 
> "memory offlining [mem ...] failed due to fails to disolve hugetlb pages"
> 
> 
> Fix:
> 
> --- a/mm/memory_hotplug.c~mm-memory_hotplug-print-reason-for-the-offlining-failure-fix
> +++ a/mm/memory_hotplug.c
> @@ -1576,7 +1576,7 @@ static int __ref __offline_pages(unsigne
>  				       MIGRATE_MOVABLE, true);
>  	if (ret) {
>  		mem_hotplug_done();
> -		reason = "failed to isolate range";
> +		reason = "failure to isolate range";
>  		goto failed_removal
>  	}

0day has noticed the missing ; here.

Andrew, could you pick up the follow up fix please?


commit 614212af5c20126aea1edaceb78aa586e19802cf
Author: Michal Hocko <mhocko@suse.com>
Date:   Tue Nov 13 09:01:50 2018 +0100

    fold me "mm, memory_hotplug: print reason for the offlining failure"

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f5f1b2a27cb3..c82193db4be6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1581,7 +1581,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (ret) {
 		mem_hotplug_done();
 		reason = "failure to isolate range";
-		goto failed_removal
+		goto failed_removal;
 	}
 
 	arg.start_pfn = start_pfn;
-- 
Michal Hocko
SUSE Labs
