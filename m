Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74E846B04B3
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:29:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x23so28805402wrb.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 21:29:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t206si555423wmt.160.2017.07.10.21.28.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 21:29:00 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6B4SiTn017982
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:28:58 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bma0p4kt6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:28:58 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 11 Jul 2017 14:28:54 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6B4Sp5L13369576
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:28:51 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6B4Soha003047
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:28:50 +1000
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 11 Jul 2017 09:58:42 +0530
MIME-Version: 1.0
In-Reply-To: <20170710134917.GB19645@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/10/2017 07:19 PM, Michal Hocko wrote:
> On Mon 10-07-17 16:40:59, Anshuman Khandual wrote:
>> As 'delta' is an unsigned long, 'end' (vma->vm_end + delta) cannot
>> be less than 'vma->vm_end'.
> 
> This just doesn't make any sense. This is exactly what the overflow
> check is for. Maybe vm_end + delta can never overflow because of
> (old_len == vma->vm_end - addr) and guarantee old_len < new_len
> in mremap but I haven't checked that too deeply.

Irrespective of that, just looking at the variables inside this
particular function where delta is an 'unsigned long', 'end' cannot
be less than vma->vm_end. Is not that true ?

> 
>> Checking for availability of virtual
>> address range at the end of the VMA for the incremental size is
>> also reduntant at this point. Hence drop them both.
> 
> OK, this seems to be the case due the above (comment says "old_len
> exactly to the end of the area..").

yeah but is the check necessary ?

> 
> But I am wondering what led you to the patch because you do not say so

As can be seen in the test program, was trying to measure the speed
of VMA expansion and contraction inside an address space and then
figured out that dropping this check improves the speed prima facie.


> here. This is hardly something that would save many cycles in a
> relatively cold path.

Though I have not done any detailed instruction level measurement,
there is a reduction in real and system amount of time to execute
the test with and without the patch.

Without the patch

real	0m2.100s
user	0m0.162s
sys	0m1.937s

With this patch

real	0m0.928s
user	0m0.161s
sys	0m0.756s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
