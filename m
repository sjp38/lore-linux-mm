Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA226B0407
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 05:46:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m28so30870215pgn.14
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:46:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b5si1330483pgg.25.2017.04.06.02.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 02:46:08 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v369hwtr075410
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 05:46:07 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29ngxq8esa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Apr 2017 05:46:07 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 6 Apr 2017 19:46:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v369jtFQ35717126
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 19:46:03 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v369jQRK007367
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 19:45:27 +1000
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-2-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 6 Apr 2017 15:15:09 +0530
MIME-Version: 1.0
In-Reply-To: <20170405204026.3940-2-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <8b5cbc13-7abe-f090-5485-8990d9a837ac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 5f84433..0933261 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -126,14 +126,31 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
>  	return -ENODEV;
>  }
>  
> -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> +int arch_add_memory(int nid, u64 start, u64 size, enum memory_type type)
>  {
>  	struct pglist_data *pgdata;
> -	struct zone *zone;
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	bool for_device = false;
> +	struct zone *zone;
>  	int rc;
>  
> +	/*
> +	 * Each memory_type needs special handling, so error out on an
> +	 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
> +	 * is not supported on this architecture.

The concept of MEMORY_DEVICE_UNADDRESSABLE has not been
introduced yet in this patch if I read correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
