Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE1A1830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:48:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so306120341pfx.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:48:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x190si39244408pfd.105.2016.08.29.06.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:48:15 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7TDdXh7049437
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:48:14 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 253713h6pw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:48:14 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 23:48:10 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 5D28F3578057
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:48:07 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7TDm7Zd42860600
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:48:07 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7TDm6vP029342
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:48:07 +1000
Date: Mon, 29 Aug 2016 19:17:58 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com> <57C3F72C.6030405@linux.vnet.ibm.com> <3b8deaf7-2e7b-ff22-be72-31b1a7ebb3eb@intel.com>
In-Reply-To: <3b8deaf7-2e7b-ff22-be72-31b1a7ebb3eb@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <57C43D0E.8060802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On 08/29/2016 02:23 PM, Aaron Lu wrote:
> On 08/29/2016 04:49 PM, Anshuman Khandual wrote:
>> > On 08/29/2016 12:01 PM, Aaron Lu wrote:
>>> >> The global zero page is used to satisfy an anonymous read fault. If
>>> >> THP(Transparent HugePage) is enabled then the global huge zero page is used.
>>> >> The global huge zero page uses an atomic counter for reference counting
>>> >> and is allocated/freed dynamically according to its counter value.
>>> >>
>>> >> CPU time spent on that counter will greatly increase if there are
>>> >> a lot of processes doing anonymous read faults. This patch proposes a
>>> >> way to reduce the access to the global counter so that the CPU load
>>> >> can be reduced accordingly.
>>> >>
>>> >> To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
>>> >> With this flag, the process only need to touch the global counter in
>>> >> two cases:
>>> >> 1 The first time it uses the global huge zero page;
>>> >> 2 The time when mm_user of its mm_struct reaches zero.
>>> >>
>>> >> Note that right now, the huge zero page is eligible to be freed as soon
>>> >> as its last use goes away.  With this patch, the page will not be
>>> >> eligible to be freed until the exit of the last process from which it
>>> >> was ever used.
>>> >>
>>> >> And with the use of mm_user, the kthread is not eligible to use huge
>>> >> zero page either. Since no kthread is using huge zero page today, there
>>> >> is no difference after applying this patch. But if that is not desired,
>>> >> I can change it to when mm_count reaches zero.
>>> >>
>>> >> Case used for test on Haswell EP:
>>> >> usemem -n 72 --readonly -j 0x200000 100G
>> > 
>> > Is this benchmark publicly available ? Does not seem to be this one
>> > https://github.com/gnubert/usemem.git, Does it ?
> Sorry, forgot to attach its link.
> It's this one:
> https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git
> 
> And the above mentioned usemem is:
> https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/usemem.c

Hey Aaron,

Thanks for pointing out. I did ran similar test on a POWER8 box using 16M
steps (huge page size is 16MB on it) instead of 2MB. But the perf profile
looked different. The perf command line was like this on a 32 CPU system.

perf record ./usemem -n 256 --readonly -j 0x1000000 100G

But the relative weight of the above mentioned function came out to be
pretty less compared to what you have reported from your experiment
which is around 54.03%.

0.07%  usemem  [kernel.vmlinux]  [k] get_huge_zero_page

Seems way out of the mark. Can you please confirm your exact perf record
command line and how many CPUs you have on the system.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
