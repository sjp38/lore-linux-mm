Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3316B003C
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 05:52:53 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so3684752pad.21
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 02:52:53 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id qy5si5697686pab.21.2014.03.15.02.52.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 02:52:52 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 15 Mar 2014 19:52:44 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 556232BB0047
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 20:52:39 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2F9WXKU3866976
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 20:32:33 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2F9qbq4024511
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 20:52:38 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] numa: Use LAST_CPUPID_SHIFT to calculate LAST_CPUPID_MASK
In-Reply-To: <20140314115556.GA10406@linux.vnet.ibm.com>
References: <20140314115556.GA10406@linux.vnet.ibm.com>
Date: Sat, 15 Mar 2014 15:22:26 +0530
Message-ID: <87zjkr6b6t.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Liu Ping Fan <qemulist@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

> LAST_CPUPID_MASK is calculated using LAST_CPUPID_WIDTH.  However
> LAST_CPUPID_WIDTH itself can be 0. (when LAST_CPUPID_NOT_IN_PAGE_FLAGS
> is set). In such a case LAST_CPUPID_MASK turns out to be 0.
>
> But with recent commit 1ae71d0319: (mm: numa: bugfix for
> LAST_CPUPID_NOT_IN_PAGE_FLAGS) if LAST_CPUPID_MASK is 0,
> page_cpupid_xchg_last() and page_cpupid_reset_last() causes
> page->_last_cpupid to be set to 0.
>
> This causes performance regression. Its almost as if numa_balancing is
> off.
>
> Fix LAST_CPUPID_MASK by using LAST_CPUPID_SHIFT instead of
> LAST_CPUPID_WIDTH.
>
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c1b7414..b9765bf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -684,7 +684,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
>  #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
>  #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
> -#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_WIDTH) - 1)
> +#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_SHIFT) - 1)
>  #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
>
>  static inline enum zone_type page_zonenum(const struct page *page)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
