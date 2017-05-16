Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D17926B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 19:52:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p29so148921135pgn.3
        for <linux-mm@kvack.org>; Tue, 16 May 2017 16:52:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o12si320438plg.124.2017.05.16.16.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 16:52:06 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GNoTsT095591
	for <linux-mm@kvack.org>; Tue, 16 May 2017 19:52:05 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ag8xpwhpt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 19:52:05 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <benh@au1.ibm.com>;
	Wed, 17 May 2017 09:51:55 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4GNphXv4981224
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:51:51 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4GNpJAF026012
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:51:19 +1000
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Reply-To: benh@au1.ibm.com
Date: Wed, 17 May 2017 09:50:57 +1000
In-Reply-To: <20170512.133742.2144484253675877904.davem@davemloft.net>
References: <65b8a658-76d1-0617-ece8-ff7a3c1c4046@oracle.com>
	 <20170512.125708.475573831936972365.davem@davemloft.net>
	 <6da8d4a6-3332-8331-c329-b05efd88a70d@oracle.com>
	 <20170512.133742.2144484253675877904.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <1494978657.21847.74.camel@au1.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, pasha.tatashin@oracle.com
Cc: linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, 2017-05-12 at 13:37 -0400, David Miller wrote:
> > Right now it is larger, but what I suggested is to add a new optimized
> > routine just for this case, which would do STBI for 64-bytes but
> > without membar (do membar at the end of memmap_init_zone() and
> > deferred_init_memmap()
> > 
> > #define struct_page_clear(page)A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  \
> > A A A A A A A A  __asm__ __volatile__(A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  \
> > A A A A A A A A  "stxaA A  %%g0, [%0]%2\n"A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  \
> > A A A A A A A A  "stxaA A  %%xg0, [%0 + %1]%2\n"A A A A A A A A A A A A A A A A A A A A A A A A A A  \
> > A A A A A A A A  : /* No output */A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  \
> > A A A A A A A A  : "r" (page), "r" (0x20), "i"(ASI_BLK_INIT_QUAD_LDD_P))
> > 
> > And insert it into __init_single_page() instead of memset()
> > 
> > The final result is 4.01s/T which is even faster compared to current
> > 4.97s/T
> 
> Ok, indeed, that would work.

On ppc64, that might not. We have a dcbz instruction that clears an
entire cache line at once. That's what we use for memset's and page
clearing. However, 64 bytes is half a cache line on modern processors
so we can't use it with that semantic and would have to fallback to the
slower stores.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
