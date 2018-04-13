Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 479BC6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:59:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37so4585205wrd.21
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 02:59:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t7si5572177edc.474.2018.04.13.02.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 02:59:53 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3D9xUMW037018
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:59:52 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2has87u0rb-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:59:52 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 13 Apr 2018 10:59:49 +0100
Subject: Re: [PATCH] mm: vmalloc: Remove double execution of vunmap_page_range
References: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 13 Apr 2018 15:29:41 +0530
MIME-Version: 1.0
In-Reply-To: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/13/2018 02:46 PM, Chintan Pandya wrote:
> Unmap legs do call vunmap_page_range() irrespective of
> debug_pagealloc_enabled() is enabled or not. So, remove
> redundant check and optional vunmap_page_range() routines.

vunmap_page_range() tears down the page table entries and does
not really flush related TLB entries normally unless page alloc
debug is enabled where it wants to make sure no stale mapping is
still around for debug purpose. Deferring TLB flush improves
performance. This patch will force TLB flush during each page
table tear down and hence not desirable.
