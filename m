Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA336B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:39:10 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x6so276843446vkf.1
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 15:39:10 -0700 (PDT)
Received: from nm23-vm1.bullet.mail.bf1.yahoo.com (nm23-vm1.bullet.mail.bf1.yahoo.com. [98.139.213.141])
        by mx.google.com with ESMTPS id i64si41741775qhc.61.2016.04.16.15.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 15:39:09 -0700 (PDT)
Date: Sat, 16 Apr 2016 22:38:51 +0000 (UTC)
From: Paul Sturm <paul_a_sturm@yahoo.com>
Reply-To: Paul Sturm <paul_a_sturm@yahoo.com>
Message-ID: <35076262.1844599.1460846331092.JavaMail.yahoo@mail.yahoo.com>
Subject: pmd_set_huge failure and ACPI warning (resending in plain text)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
References: <35076262.1844599.1460846331092.JavaMail.yahoo.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

(resending in plain text)

Not sure if this is the right place to post. If it is not please direct me to where I should go. 

I am running x86_64 kernel 4.4.6 on an Intel Xeon D system. This is an SOC system that includes dual 10G ethernet using the ixgbe driver. 
I have also tested this on kernels 4.2 through 4.6rc3 with the same result. 

When the ixgbe driver loads, I get the following two warnings: 

[ 5453.184701] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.2.1-k 
[ 5453.184704] ixgbe: Copyright (c) 1999-2015 Intel Corporation. 
[ 5453.184767] ACPI Warning: \_SB_.PCI0.BR2C._PRT: Return Package has no elements (empty) (20150930/nsprepkg-126) 
[ 5453.184891] pmd_set_huge: Cannot satisfy [mem 0x383fffa00000-0x383fffc00000] with a huge-page mapping due to MTRR override. 

BIOS is set to enable 64-bit DMA above 4GB. 
cat proc/mtrr looks like this: 
reg00: base=0x080000000 ( 2048MB ), size= 2048MB, count=1: uncachable 
reg01: base=0x380000000000 (58720256MB ), size=262144MB, count=1: uncachable 
reg02: base=0x383fff800000 (58982392MB ), size= 8MB, count=1: write-through 
reg03: base=0x383ffff00000 (58982399MB ), size= 1MB, count=1: uncachable 

When I change the BIOS setting to disable DMA above 4GB (no other BIOS changes I tried had any effect on the MTRR ranges) 
cat /proc/mtrr looks like this: 
reg00: base=0x080000000 ( 2048MB ), size= 2048MB, count=1: uncachable 
reg01: base=0x380000000000 (58720256MB ), size=262144MB, count=1: uncachable 
reg02: base=0x0f9800000 ( 3992MB ), size= 8MB, count=1: write-through 
reg03: base=0x0f9f00000 ( 3999MB ), size= 1MB, count=1: uncachable 

and the pmd_set_huge warning indicates a memory range in the 0x0fxxxx uncacheable range. 

So the result is that ixgbe seems to always try to get it's hugepage from the uncacheable range. 

I can post the full dmesg if requested, but in the meantime, here are the TLB-related entries: 
[ 0.027925] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8 
[ 0.027931] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4 

[ 0.325307] HugeTLB registered 1 GB page size, pre-allocated 0 pages 
[ 0.325315] HugeTLB registered 2 MB page size, pre-allocated 0 pages 
I tried to pre-allocate both 1GB and 2MB pages via the kernel command line and it had no effect. 

I have tried both compiling the driver in the kernel and loading it as a module. Same results. 

I first reported this on the e1000 sourceforge list and they directed me here. 

In addition to the pmd_set_huge warning, there is also that ACPI warning. I am not sure if it is related or not, but I can say it only appears when the IXGBE driver is loaded and it always loads right before the pmd_set_huge warning. 

Please advise. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
