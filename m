Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF966B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 02:49:20 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p15so13602564qtp.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 23:49:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s52si750661qta.417.2017.10.05.23.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 23:49:19 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v966mxHL049867
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 02:49:18 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2de3rh3g3n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Oct 2017 02:49:18 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 6 Oct 2017 07:49:16 +0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v966nBUC29360206
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 06:49:12 GMT
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v966nBJb016894
	for <linux-mm@kvack.org>; Fri, 6 Oct 2017 17:49:12 +1100
Subject: Re: [PATCH] mm: deferred_init_memmap improvements
References: <20171004152902.17300-1-pasha.tatashin@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 6 Oct 2017 12:18:31 +0530
MIME-Version: 1.0
In-Reply-To: <20171004152902.17300-1-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <071d574f-1d8c-5be9-ec92-6227db01bbd3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/04/2017 08:59 PM, Pavel Tatashin wrote:
> This patch fixes another existing issue on systems that have holes in
> zones i.e CONFIG_HOLES_IN_ZONE is defined.
> 
> In for_each_mem_pfn_range() we have code like this:
> 
> if (!pfn_valid_within(pfn)
> 	goto free_range;
> 
> Note: 'page' is not set to NULL and is not incremented but 'pfn' advances.

page is initialized to NULL at the beginning of the function.
PFN advances but we dont proceed unless pfn_valid_within(pfn)
holds true which basically should have checked with arch call
back if the PFN is valid in presence of memory holes as well.
Is not this correct ?

> Thus means if deferred struct pages are enabled on systems with these kind
> of holes, linux would get memory corruptions. I have fixed this issue by
> defining a new macro that performs all the necessary operations when we
> free the current set of pages.

If we bail out in case PFN is not valid, then how corruption
can happen ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
