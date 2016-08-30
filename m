Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98C9782F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:14:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so19580126pab.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 22:14:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 68si43241941pfr.68.2016.08.29.22.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 22:14:57 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7U53u5l043930
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:14:57 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 255363s7nv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:14:56 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 30 Aug 2016 10:44:52 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id A36D8E0040
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:43:52 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7U5EofQ18677934
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:44:50 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7U5Eni4021697
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 10:44:50 +0530
Date: Tue, 30 Aug 2016 10:44:21 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com> <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
In-Reply-To: <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57C5162D.80405@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/30/2016 04:20 AM, Andrew Morton wrote:
> On Mon, 29 Aug 2016 14:31:20 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> 
>> > 
>> > The global zero page is used to satisfy an anonymous read fault. If
>> > THP(Transparent HugePage) is enabled then the global huge zero page is used.
>> > The global huge zero page uses an atomic counter for reference counting
>> > and is allocated/freed dynamically according to its counter value.
>> > 
>> > CPU time spent on that counter will greatly increase if there are
>> > a lot of processes doing anonymous read faults. This patch proposes a
>> > way to reduce the access to the global counter so that the CPU load
>> > can be reduced accordingly.
>> > 
>> > To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
>> > With this flag, the process only need to touch the global counter in
>> > two cases:
>> > 1 The first time it uses the global huge zero page;
>> > 2 The time when mm_user of its mm_struct reaches zero.
>> > 
>> > Note that right now, the huge zero page is eligible to be freed as soon
>> > as its last use goes away.  With this patch, the page will not be
>> > eligible to be freed until the exit of the last process from which it
>> > was ever used.
>> > 
>> > And with the use of mm_user, the kthread is not eligible to use huge
>> > zero page either. Since no kthread is using huge zero page today, there
>> > is no difference after applying this patch. But if that is not desired,
>> > I can change it to when mm_count reaches zero.

> I suppose we could simply never free the zero huge page - if some
> process has used it in the past, others will probably use it in the
> future.  One wonders how useful this optimization is...

Yeah, what prevents us from doing away with this lock altogether and
keep one zero filled huge page (after a process has used it once) for
ever to be mapped across all the read faults ? A 16MB / 2MB huge page
is too much of memory loss on a THP enabled system ? We can also save
on allocation time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
