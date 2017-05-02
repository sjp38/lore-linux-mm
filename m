Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C68D6B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 06:54:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p9so81568710pfj.8
        for <linux-mm@kvack.org>; Tue, 02 May 2017 03:54:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 188si17563945pgj.71.2017.05.02.03.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 03:54:43 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42As7b5054476
	for <linux-mm@kvack.org>; Tue, 2 May 2017 06:54:42 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a6np1hycm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 06:54:42 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 2 May 2017 20:54:39 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v42AsUBm49545442
	for <linux-mm@kvack.org>; Tue, 2 May 2017 20:54:38 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v42As66V007694
	for <linux-mm@kvack.org>; Tue, 2 May 2017 20:54:06 +1000
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 2 May 2017 16:23:48 +0530
MIME-Version: 1.0
In-Reply-To: <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <06c4eb97-1545-7958-7694-3645d317666b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/01/2017 11:30 PM, Prakash Sangappa wrote:
> Some applications like a database use hugetblfs for performance
> reasons. Files on hugetlbfs filesystem are created and huge pages
> allocated using fallocate() API. Pages are deallocated/freed using
> fallocate() hole punching support that has been added to hugetlbfs.
> These files are mmapped and accessed by many processes as shared memory.
> Such applications keep track of which offsets in the hugetlbfs file have
> pages allocated.
> 
> Any access to mapped address over holes in the file, which can occur due

s/mapped/unmapped/ ^ ?

> to bugs in the application, is considered invalid and expect the process
> to simply receive a SIGBUS.  However, currently when a hole in the file is
> accessed via the mapped address, kernel/mm attempts to automatically
> allocate a page at page fault time, resulting in implicitly filling the
> hole

But this is expected when you try to control the file allocation from
a mapped address. Any changes while walking past or writing the range
in the memory mapped should reflect exactly in the file on the disk.
Why its not a valid behavior ?

> in the file. This may not be the desired behavior for applications like the
> database that want to explicitly manage page allocations of hugetlbfs
> files.
> 
> This patch adds a new hugetlbfs mount option 'noautofill', to indicate that
> pages should not be allocated at page fault time when accessed thru mmapped
> address.

When the page should be allocated for mapping ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
