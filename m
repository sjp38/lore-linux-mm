Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78E366B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:30:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so268575323pfb.6
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:30:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y186si23009733pfy.31.2017.01.25.02.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 02:30:30 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PASlp3012507
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:30:30 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 286q7508pm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:30:28 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 25 Jan 2017 16:00:25 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B39C8E0024
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:01:36 +0530 (IST)
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0PAUMG440632388
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:00:22 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0PAULdo009185
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:00:22 +0530
Subject: Re: [patch] mm, madvise: fail with ENOMEM when splitting vma will hit
 max_map_count
References: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 25 Jan 2017 16:00:13 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701241431120.42507@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4c884355-0753-3b6e-a5a5-27b2a426c88b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com, Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/25/2017 04:02 AM, David Rientjes wrote:
> If madvise(2) advice will result in the underlying vma being split and
> the number of areas mapped by the process will exceed
> /proc/sys/vm/max_map_count as a result, return ENOMEM instead of EAGAIN.
> 
> EAGAIN is returned by madvise(2) when a kernel resource, such as slab,
> is temporarily unavailable.  It indicates that userspace should retry the
> advice in the near future.  This is important for advice such as
> MADV_DONTNEED which is often used by malloc implementations to free
> memory back to the system: we really do want to free memory back when
> madvise(2) returns EAGAIN because slab allocations (for vmas, anon_vmas,
> or mempolicies) cannot be allocated.
> 
> Encountering /proc/sys/vm/max_map_count is not a temporary failure,
> however, so return ENOMEM to indicate this is a more serious issue.  A
> followup patch to the man page will specify this behavior.

But in the due course there might be other changes in number of VMAs of
the process because of unmap() or merge() which could reduce the total
number of VMAs and hence this condition may not exist afterwards. In
that case EAGAIN still makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
