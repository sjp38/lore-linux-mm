Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB976B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 00:34:26 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id 18so100652035ybc.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 21:34:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si9265064pag.201.2016.09.01.21.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 21:34:25 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u824XVEn011563
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 00:34:25 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 256b4fapw3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Sep 2016 00:34:24 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 2 Sep 2016 14:34:22 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B79A32CE8046
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 14:34:18 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u824YIWk47120548
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 14:34:18 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u824YIc1006005
	for <linux-mm@kvack.org>; Fri, 2 Sep 2016 14:34:18 +1000
Date: Fri, 02 Sep 2016 10:04:11 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com> <1472613950-16867-2-git-send-email-khandual@linux.vnet.ibm.com> <20160831141239.9624b38201796007c2735029@linux-foundation.org>
In-Reply-To: <20160831141239.9624b38201796007c2735029@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57C90143.2030403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/01/2016 02:42 AM, Andrew Morton wrote:
> On Wed, 31 Aug 2016 08:55:50 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
>> Each individual node in the system has a ZONELIST_FALLBACK zonelist
>> and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
>> order of zones during memory allocations. Sometimes it helps to dump
>> these zonelists to see the priority order of various zones in them.
>> This change just adds a sysfs interface for doing the same.
>>
>> Example zonelist information from a KVM guest.
>>
>> [NODE (0)]
>>         ZONELIST_FALLBACK
>>         (0) (node 0) (zone DMA c00000000140c000)
>>         (1) (node 1) (zone DMA c000000100000000)
>>         (2) (node 2) (zone DMA c000000200000000)
>>         (3) (node 3) (zone DMA c000000300000000)
>>         ZONELIST_NOFALLBACK
>>         (0) (node 0) (zone DMA c00000000140c000)
>> [NODE (1)]
>>         ZONELIST_FALLBACK
>>         (0) (node 1) (zone DMA c000000100000000)
>>         (1) (node 2) (zone DMA c000000200000000)
>>         (2) (node 3) (zone DMA c000000300000000)
>>         (3) (node 0) (zone DMA c00000000140c000)
>>         ZONELIST_NOFALLBACK
>>         (0) (node 1) (zone DMA c000000100000000)
>> [NODE (2)]
>>         ZONELIST_FALLBACK
>>         (0) (node 2) (zone DMA c000000200000000)
>>         (1) (node 3) (zone DMA c000000300000000)
>>         (2) (node 0) (zone DMA c00000000140c000)
>>         (3) (node 1) (zone DMA c000000100000000)
>>         ZONELIST_NOFALLBACK
>>         (0) (node 2) (zone DMA c000000200000000)
>> [NODE (3)]
>>         ZONELIST_FALLBACK
>>         (0) (node 3) (zone DMA c000000300000000)
>>         (1) (node 0) (zone DMA c00000000140c000)
>>         (2) (node 1) (zone DMA c000000100000000)
>>         (3) (node 2) (zone DMA c000000200000000)
>>         ZONELIST_NOFALLBACK
>>         (0) (node 3) (zone DMA c000000300000000)
> 
> Can you please sell this a bit better?  Why does it "sometimes help"?
> Why does the benefit of this patch to our users justify the overhead
> and cost?

On platforms which support memory hotplug into previously non existing
(at boot) zones, this interface helps in visualizing which zonelists
of the system, the new hot added memory ends up in. POWER is such a
platform where all the memory detected during boot time remains with
ZONE_DMA for good but then hot plug process can actually get new memory
into ZONE_MOVABLE. So having a way to get the snapshot of the zonelists
on the system after memory or node hot[un]plug is a good thing, IMHO.

> 
> Please document the full path to the sysfs file(s) within the changelog.

Sure, will do.

> 
> Please find somewhere in Documentation/ to document the new interface.
> 

Sure, will create this following file describing the interface.

Documentation/ABI/testing/sysfs-system-zone-details

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
