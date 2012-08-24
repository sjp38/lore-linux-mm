Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 235096B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:06:59 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 24 Aug 2012 09:06:57 +0100
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7O86mua19529836
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 08:06:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7O86s4s018183
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 02:06:54 -0600
Date: Fri, 24 Aug 2012 10:07:00 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC patch 7/7] thp, s390: architecture backend for thp on
 System z
Message-ID: <20120824080700.GC3533@osiris.de.ibm.com>
References: <20120823171733.595087166@de.ibm.com>
 <20120823171855.006932817@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120823171855.006932817@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com

On Thu, Aug 23, 2012 at 07:17:40PM +0200, Gerald Schaefer wrote:
> +#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
> +static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> +					    unsigned long address,
> +					    pmd_t *pmdp)
> +{
> +	int rc = 0;
> +	int counter = PTRS_PER_PTE;
> +	unsigned long pmd_addr = pmd_val(*pmdp) & HPAGE_MASK;
> +
> +	asm volatile(
> +		"0:	rrbe	0,%2\n"
> +		"	la	%2,0(%3,%2)\n"
> +		"	brc	12,1f\n"
> +		"	lhi	%0,1\n"
> +		"1:	brct	%1,0b\n"
> +		: "+d" (rc), "+d" (counter), "+a" (pmd_addr)
> +		: "a" (4096UL): "cc" );
> +	return rc;
> +}

Just a small side note: given that rrbe is very expensive you probably
should extend this function so it makes use of the rrbm instruction
if available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
