Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4A8B6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:59:22 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id d184so155193511ybh.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:59:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y67si5844894ywc.7.2017.01.16.02.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 02:59:22 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GAwfqQ019470
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:59:21 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 280u3mmc7w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:59:20 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 20:59:18 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4673B2BB0057
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:59:15 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GAxFKS7733710
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:59:15 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GAxFl6011100
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:59:15 +1100
Subject: Re: [LSF/MM TOPIC/ATTEND] Memory Types
References: <9a0ae921-34df-db23-a25e-022f189608f4@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 16:29:10 +0530
MIME-Version: 1.0
In-Reply-To: <9a0ae921-34df-db23-a25e-022f189608f4@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <22fbcb9f-f69a-6532-691f-c0f757cf6b8b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>

On 01/16/2017 10:59 AM, Dave Hansen wrote:
> Historically, computers have sped up memory accesses by either adding
> cache (or cache layers), or by moving to faster memory technologies
> (like the DDR3 to DDR4 transition).  Today we are seeing new types of
> memory being exposed not as caches, but as RAM [1].
> 
> I'd like to discuss how the NUMA APIs are being reused to manage not
> just the physical locality of memory, but the various types.  I'd also
> like to discuss the parts of the NUMA API that are a bit lacking to
> manage these types, like the inability to have fallback lists based on
> memory type instead of location.
> 
> I believe this needs to be a distinct discussion from Jerome's HMM
> topic.  All of the cases we care about are cache-coherent and can be
> treated as "normal" RAM by the VM.  The HMM model is for on-device
> memory and is largely managed outside the core VM.

Agreed. In future core VM should be able to deal with these type of
coherent memory directly as part of the generic NUMA API and page
allocator framework. The type of the coherent memory must be a factor
other than NUMA distances while dealing with it from a NUMA perspective
as well from page allocation fallback sequence perspective. I have been
working on a very similar solution called CDM (Coherent Device Memory)
where we change the zonelist building process as well mbind() interface
to accommodate a different type of coherent memory other than existing
normal system RAM. Here are the related postings and discussions.

https://lkml.org/lkml/2016/10/24/19 (CDM with modified zonelists)
https://lkml.org/lkml/2016/11/22/339 (CDM with modified cpusets)

Though named as "device" for now, it can very well evolve into a generic
solution to accommodate all kinds of coherent memory (which warrants
them to be treated at par with system RAM in the core VM in the first
place). I would like to attend to discuss this topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
