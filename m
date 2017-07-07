Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE9CA6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 04:20:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v88so6281953wrb.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:20:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v193si2322061wme.197.2017.07.07.01.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 01:20:02 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v678JDml026586
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 04:20:01 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bhwbyrrjj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Jul 2017 04:20:00 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 7 Jul 2017 18:19:58 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v678JspO7143758
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 18:19:54 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v678Js61008806
	for <linux-mm@kvack.org>; Fri, 7 Jul 2017 18:19:54 +1000
Subject: Re: [RFC PATCH 0/1] mm/mremap: add MREMAP_MIRROR flag
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 7 Jul 2017 13:49:46 +0530
MIME-Version: 1.0
In-Reply-To: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6f1460ef-a896-aef4-c0dc-66227232e025@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/06/2017 09:47 PM, Mike Kravetz wrote:
> The mremap system call has the ability to 'mirror' parts of an existing
> mapping.  To do so, it creates a new mapping that maps the same pages as
> the original mapping, just at a different virtual address.  This
> functionality has existed since at least the 2.6 kernel [1].  A comment
> was added to the code to help preserve this feature.


Is this the comment ? If yes, then its not very clear.

	/*
	 * We allow a zero old-len as a special case
	 * for DOS-emu "duplicate shm area" thing. But
	 * a zero new-len is nonsensical.
	 */


> 
> The Oracle JVM team has discovered this feature and used it while
> prototyping a new garbage collection model.  This new model shows promise,
> and they are considering its use in a future release.  However, since
> the only mention of this functionality is a single comment in the kernel,
> they are concerned about its future.
> 
> I propose the addition of a new MREMAP_MIRROR flag to explicitly request
> this functionality.  The flag simply provides the same functionality as
> the existing undocumented 'old_size == 0' interface.  As an alternative,
> we could simply document the 'old_size == 0' interface in the man page.
> In either case, man page modifications would be needed.

Right. Adding MREMAP_MIRROR sounds cleaner from application programming
point of view. But it extends the interface.

> 
> Future Direction
> 
> After more formally adding this to the API (either new flag or documenting
> existing interface), the mremap code could be enhanced to optimize this
> case.  Currently, 'mirroring' only sets up the new mapping.  It does not
> create page table entries for new mapping.  This could be added as an
> enhancement.

Then how it achieves mirroring, both the pointers should see the same
data, that can happen with page table entries pointing to same pages,
right ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
