Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8580E6B0572
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 17:04:18 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g15-v6so10490127plq.4
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 14:04:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e92-v6si1939912pld.45.2018.11.07.14.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 14:04:17 -0800 (PST)
Date: Wed, 7 Nov 2018 14:04:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 4/5] mm, memory_hotplug: print reason for the
 offlining failure
Message-Id: <20181107140413.2c0061e440123be76bf419bf@linux-foundation.org>
In-Reply-To: <20181107101830.17405-5-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
	<20181107101830.17405-5-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed,  7 Nov 2018 11:18:29 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> The memory offlining failure reporting is inconsistent and insufficient.
> Some error paths simply do not report the failure to the log at all.
> When we do report there are no details about the reason of the failure
> and there are several of them which makes memory offlining failures
> hard to debug.
> 
> Make sure that the
> 	memory offlining [mem %#010llx-%#010llx] failed
> message is printed for all failures and also provide a short textual
> reason for the failure e.g.
> 
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> 
> this tells us that the offlining has failed because of a signal pending
> aka user intervention.
> 
> ...

Some of these messages will come out looking a bit odd.

> @@ -1573,7 +1576,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  				       MIGRATE_MOVABLE, true);
>  	if (ret) {
>  		mem_hotplug_done();
> -		return ret;
> +		reason = "failed to isolate range";

"memory offlining [mem ...] failed due to failed to isolate range"

> +		goto failed_removal
>  	}
>  
>  	arg.start_pfn = start_pfn;
> @@ -1582,15 +1586,19 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
>  	ret = notifier_to_errno(ret);
> -	if (ret)
> -		goto failed_removal;
> +	if (ret) {
> +		reason = "notifiers failure";

"memory offlining [mem ...] failed due to notifiers failure"

> @@ -1607,8 +1615,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	 * actually in order to make hugetlbfs's object counting consistent.
>  	 */
>  	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
> -	if (ret)
> -		goto failed_removal;
> +	if (ret) {
> +		reason = "fails to disolve hugetlb pages";

"memory offlining [mem ...] failed due to fails to disolve hugetlb pages"


Fix:

--- a/mm/memory_hotplug.c~mm-memory_hotplug-print-reason-for-the-offlining-failure-fix
+++ a/mm/memory_hotplug.c
@@ -1576,7 +1576,7 @@ static int __ref __offline_pages(unsigne
 				       MIGRATE_MOVABLE, true);
 	if (ret) {
 		mem_hotplug_done();
-		reason = "failed to isolate range";
+		reason = "failure to isolate range";
 		goto failed_removal
 	}
 
@@ -1587,7 +1587,7 @@ static int __ref __offline_pages(unsigne
 	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
 	ret = notifier_to_errno(ret);
 	if (ret) {
-		reason = "notifiers failure";
+		reason = "notifier failure";
 		goto failed_removal_isolated;
 	}
 
@@ -1616,7 +1616,7 @@ repeat:
 	 */
 	ret = dissolve_free_huge_pages(start_pfn, end_pfn);
 	if (ret) {
-		reason = "fails to disolve hugetlb pages";
+		reason = "failure to dissolve huge pages";
 		goto failed_removal_isolated;
 	}
 	/* check again */
_
