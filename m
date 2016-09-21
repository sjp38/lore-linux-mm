Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08E9E6B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:30:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y6so6744803lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 03:30:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z7si32659319wmd.147.2016.09.21.03.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 03:30:42 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8LARpLw044863
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:30:41 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25khh8sfsd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:30:41 -0400
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 21 Sep 2016 11:30:39 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 41D872190056
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:29:57 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8LAUbpk11731404
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:30:37 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8LAUaL5030584
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:30:36 -0600
Date: Wed, 21 Sep 2016 12:30:35 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
In-Reply-To: <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160921123035.02ac4a2a@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, 20 Sep 2016 10:37:04 -0700
Mike Kravetz <mike.kravetz@oracle.com> wrote:

> 
> Cc'ed Rui Teng and Dave Hansen as they were discussing the issue in
> this thread:
> https://lkml.org/lkml/2016/9/13/146

Ah, thanks, I didn't see that.

> 
> Their approach (I believe) would be to fail the offline operation in
> this case.  However, I could argue that failing the operation, or
> dissolving the unused huge page containing the area to be offlined is
> the right thing to do.
> 
> I never thought too much about the VM_BUG_ON(), but you are correct in
> that it should be removed in either case.
> 
> The other thing that needs to be changed is the locking in
> dissolve_free_huge_page().  I believe the lock only needs to be held if
> we are removing the huge page from the pool.  It is not a correctness
> but performance issue.
> 

Yes, that looks odd, that's why in my patch I moved the PageHuge() check
out from dissolve_free_huge_page(), up into the loop in
dissolve_free_huge_pages(). This way dissolve_free_huge_page() with its
locking should only be called once per memory block, in the case where
this memory block is part of a gigantic hugepage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
