Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEFB6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:58:33 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c80so140978594iod.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:58:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a2si9530251itd.61.2017.01.16.04.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 04:58:32 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GCuPm3069428
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:58:32 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 280sw73gek-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:58:31 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 22:58:29 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 75A9E3578057
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:58:27 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GCwTHQ56164510
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:58:29 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GCwRgH001925
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:58:27 +1100
Subject: Re: [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of
 struct page
References: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 18:28:21 +0530
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <729bbe0c-d305-f4bd-7fed-b937dafd16ef@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

On 01/13/2017 04:13 AM, Dan Williams wrote:
> Back when we were first attempting to support DMA for DAX mappings of
> persistent memory the plan was to forgo 'struct page' completely and
> develop a pfn-to-scatterlist capability for the dma-mapping-api. That
> effort died in this thread:
> 
>     https://lkml.org/lkml/2015/8/14/3
> 
> ...where we learned that the dependencies on struct page for dma
> mapping are deeper than a PFN_PHYS() conversion for some
> architectures. That was the moment we pivoted to ZONE_DEVICE and
> arranged for a 'struct page' to be available for any persistent memory
> range that needs to be the target of DMA. ZONE_DEVICE enables any
> device-driver that can target "System RAM" to also be able to target
> persistent memory through a DAX mapping.
> 
> Since that time the "page-less" DAX path has continued to mature [1]
> without growing new dependencies on struct page, but at the same time
> continuing to rely on ZONE_DEVICE to satisfy get_user_pages().
> 
> Peer-to-peer DMA appears to be evolving from a niche embedded use case
> to something general purpose platforms will need to comprehend. The
> "map_peer_resource" [2] approach looks to be headed to the same
> destination as the pfn-to-scatterlist effort. It's difficult to avoid
> 'struct page' for describing DMA operations without custom driver
> code.
> 
> With that background, a statement and a question to discuss at LSF/MM:
> 
> General purpose DMA, i.e. any DMA setup through the dma-mapping-api,
> requires pfn_to_page() support across the entire physical address
> range mapped.
> 
> Is ZONE_DEVICE the proper vehicle for this? We've already seen that it
> collides with platform alignment assumptions [3], and if there's a
> wider effort to rework memory hotplug [4] it seems DMA support should
> be part of the discussion.

I had experimented with ZONE_DEVICE representation from migration point of
view. Tried migration of both anonymous pages as well as file cache pages
into and away from ZONE_DEVICE memory. Learned that the lack of 'page->lru'
element in the struct page of the ZONE_DEVICE memory makes it difficult
for it to represent file backed mapping in it's present form. But given
that ZONE_DEVICE was created to enable direct mapping (DAX) bypassing page
cache, it came as no surprise. My objective has been how ZONE_DEVICE can
accommodate movable coherent device memory. In our HMM discussions I had
brought to the attention how ZONE_DEVICE going forward should evolve to
represent all these three types of device memory.

* Unmovable addressable device memory   (persistent memory)
* Movable addressable device memory     (similar memory represented as CDM)
* Movable un-addressable device memory  (similar memory represented as HMM)

I would like to attend to discuss on the road map for ZONE_DEVICE, struct
pages and device memory in general. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
