Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9EF56B0038
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 01:10:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so265321725pge.7
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 22:10:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b26si16170585pgf.332.2017.03.19.22.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 22:10:30 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2K58uLx069613
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 01:10:29 -0400
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com [125.16.236.5])
	by mx0a-001b2d01.pphosted.com with ESMTP id 298y7dk2v3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 01:10:29 -0400
Received: from localhost
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Mar 2017 10:40:26 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2K5AMCG9896058
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 10:40:22 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2K5ALLT007236
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 10:40:22 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above 47-bits
In-Reply-To: <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com> <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
Date: Mon, 20 Mar 2017 10:40:20 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8760j4sfcz.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
 @@ -168,6 +182,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	unsigned long addr = addr0;
>  	struct vm_unmapped_area_info info;
>  
> +	addr = mpx_unmapped_area_check(addr, len, flags);
> +	if (IS_ERR_VALUE(addr))
> +		return addr;
> +
>  	/* requested length too big for entire address space */
>  	if (len > TASK_SIZE)
>  		return -ENOMEM;
> @@ -192,6 +210,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	info.length = len;
>  	info.low_limit = PAGE_SIZE;
>  	info.high_limit = mm->mmap_base;
> +
> +	/*
> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
> +	 * in the full address space.
> +	 */
> +	if (addr > DEFAULT_MAP_WINDOW)
> +		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
> +

Is this ok for 32 bit application ?


>  	info.align_mask = 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;
>  	if (filp) {


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
