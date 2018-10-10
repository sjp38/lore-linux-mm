Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C15D36B0010
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 06:51:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d69-v6so3223617pgc.22
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:51:18 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id l36-v6si25409695plg.289.2018.10.10.03.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 03:51:17 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Oct 2018 16:21:16 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
In-Reply-To: <20181010080724.GA20338@techadventures.net>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <20181010080724.GA20338@techadventures.net>
Message-ID: <f18b87a0762c4379b78e9b5e09ff4840@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-10-10 13:37, Oscar Salvador wrote:
> On Fri, Oct 05, 2018 at 01:40:05PM +0530, Arun KS wrote:
>> When free pages are done with higher order, time spend on
>> coalescing pages by buddy allocator can be reduced. With
>> section size of 256MB, hot add latency of a single section
>> shows improvement from 50-60 ms to less than 1 ms, hence
>> improving the hot add latency by 60%. Modify external
>> providers of online callback to align with the change.
> 
> Hi Arun, out of curiosity:
> 
> could you please explain how exactly did you mesure the speed
> improvement?

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e379e85..2416136 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -690,9 +690,13 @@ static int online_pages_range(unsigned long 
start_pfn, unsigned long nr_pages,
                         void *arg)
  {
         unsigned long onlined_pages = *(unsigned long *)arg;
+       u64 t1, t2;

+       t1 = local_clock();
         if (PageReserved(pfn_to_page(start_pfn)))
                 onlined_pages = online_pages_blocks(start_pfn, 
nr_pages);
+       t2 = local_clock();
+       trace_printk("time spend = %llu us\n", (t2-t1)/(1000));

         online_mem_sections(start_pfn, start_pfn + nr_pages);


Regards,
Arun

> 
> Thanks
