Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 868096B0397
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 22:25:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g2so91481494pge.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 19:25:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 21si5100841pfs.216.2017.03.08.19.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 19:25:52 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v293Oaa2129779
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 22:25:51 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292k8srsvh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 22:25:51 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 13:25:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v293Pcck49676522
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 14:25:46 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v293PEYL017261
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 14:25:14 +1100
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170308193900.GC32070@tassilo.jf.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Mar 2017 08:54:55 +0530
MIME-Version: 1.0
In-Reply-To: <20170308193900.GC32070@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f10aee73-b288-ed21-682d-3d3727fdab2d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On 03/09/2017 01:09 AM, Andi Kleen wrote:
>> One example of the problems with extra layers what this patch fixes:
>> mmap_pgoff() should never be using SHM_HUGE_* logic. This was
>> introduced by:
>>
>>    091d0d55b28 (shm: fix null pointer deref when userspace specifies invalid hugepage size)
>>
>> It is obviously harmless but lets just rip out the whole thing --
>> the shmget.2 manpage will need updating, as it should not be
>> describing kernel internals.
> 
> The SHM_* defines were supposed to be exported to user space,
> but somehow they didn't make it into uapi.

Yeah, its not part of UAPI which it should have been. Now we
need to ilog2(page_size) and shift it before using them in
the user space. BTW, mmap() interface also would want this
encoding should we choose to use non default HugeTLB page
sizes.

> 
> But something like this is useful, it's a much nicer 
> interface for users than to hard code the bit position

Right. But as we need this both for shm and mmap() interface,
we can only have one set of values exported to the UAPI. The
other set needs to be removed IMHO. BTW, we need to add the
encoding for other arch supported HugeTLB supported sizes as
well like 16MB, 16GB etc (on POWER).
 
> 
> So I would rather if you move it to uapi instead of 
> removing. What the kernel uses internally doesn't
> really matter.

Had a sent a clean up patch last year which unfortunately I
forgot to resend though it has got ACK from Michal Hocko
and Balbir Singh.

https://lkml.org/lkml/2016/4/7/43

I had also tried to add POWER HugeTLB size encoding in the
arch specific header files. Probably its time to move all
of them to generic header.

https://lkml.org/lkml/2016/4/7/48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
