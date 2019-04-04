Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C009C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1067A2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:41:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vSTLQ90w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1067A2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5C666B0008; Thu,  4 Apr 2019 11:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6216B000A; Thu,  4 Apr 2019 11:41:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960AB6B000C; Thu,  4 Apr 2019 11:41:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 717376B0008
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:41:10 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id s21so2638218ite.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cgzQn9EzfkAP6A/up1mIigYmfk1uFtWFKeG+11h2cFw=;
        b=tT3RNy9g5QpB5iq2glCTdlK1VIpr1e9XouD5vto/L6XMihO4rAVXhkrwfwfeShzxNm
         nkCk9wxIjlh5K2Xaca069riQ91LGAUsB1N2BotG5kVb6/pvygqEqNxW8GOLxmlUNajCo
         jAVYkm61tFMpZRU1SfW0Tm5iqSEWiuTCHvRuBvgLDcSZCVtkTAPGd015J3+4evwOO6c9
         RHkdPW9eObz1P7xvkIIqUZ0G2NMX97VkhqF2hvKe2wfEXczQa3sWv6FtcrJmCBZ3It1X
         J7PT2y7itUX0QG+rLEGkAAtGf5UvZi7Gtf3KUUsk2+YNP409LNvNxxQPKtHbzdflcOaw
         y45Q==
X-Gm-Message-State: APjAAAWylQT2A15zDndWRt0ynSOml+itOqjK9o1vMDTy2Fki0dDS7Z1a
	MwTbZIrn6n0/cUHUc8i22MncaTSra/tfy7JbcGLaxOdh0F3g2CoPJffR/Pa4XsMmVUv+ItG0cmu
	Bj6zIP1kb3Xf5XtbcrqBTPGa7Uqq83WYXkdUkDisZDht35T2P06U4hqqrSiePjID0zg==
X-Received: by 2002:a05:660c:18b:: with SMTP id v11mr5455673itj.147.1554392470178;
        Thu, 04 Apr 2019 08:41:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIJtj0m3ezLvcpxrCEZLpHJvoUir1wJ137nE0DYk/NdRAvF+1Hbrw/EWPdCFo4DQSfZCB5
X-Received: by 2002:a05:660c:18b:: with SMTP id v11mr5455600itj.147.1554392469087;
        Thu, 04 Apr 2019 08:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554392469; cv=none;
        d=google.com; s=arc-20160816;
        b=tAtp//4mod08GvYgAh7YnwSqQFaZ/BclEtI+Vh0kxD71XuZtqggGrwBhzmSRSTWxN8
         kHUF1QQkrirmyWDW7Y6Eap1xQ9Ik2hOrBENNDB8XyI2cT1Syr/YNPAJbkmPvydFM15b3
         a6Cz/uYz4F8WXUCM5NJonPhgu92Fmo0eCElRkVSsjBKY2E//ZXyezbdjGsK+C7TSsf2i
         DoEPZQ6JE+Kt4tjbsN1T+FhTtIbESAczmQ5DEPNCIdH3FI8E02erYb1rQUqA+Ked1Asz
         n69lizKoHOQfBSbRFYxVsft5C22/dfya+Jnu7rVAOVRIrBrzQ8LOte+sbonYumVhhZSG
         cC+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=cgzQn9EzfkAP6A/up1mIigYmfk1uFtWFKeG+11h2cFw=;
        b=hQ+pVRYgxulNH+bq6FejMlhfxdVi+FbWRLrRbP/vkGjXhCxsIeVW9GbpV2Iw73OMX1
         8GzyL4fg9DbBJ4QjK5fLpJzrrzoAeegY4DbfQR6SLaq4UEwmBYUVVxV/bD/DDXELwDbS
         achCOmO2WFn0Fjm53i+cfPabXOGRDtRRQOcoiYrRM6CkaNWDBcTvGx5ni+FZmoDVgm3y
         ol2nAdlN0WUNx7NjajJ0g77HlQFkF8EguDOD/Zuy88bYxa/whCD4lqq74RYAI2dEOEbz
         LBuPCr/1fR3VfsJcACi/4WTTjyiwNSSw/XHAdDJiwJKDCAN1xOp+62lo+LlXGUOc+G0p
         9ENg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vSTLQ90w;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z14si9425192ioj.131.2019.04.04.08.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 08:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vSTLQ90w;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34FckbM058484;
	Thu, 4 Apr 2019 15:40:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=cgzQn9EzfkAP6A/up1mIigYmfk1uFtWFKeG+11h2cFw=;
 b=vSTLQ90wzUHVMZaC2hckRCwG4RoR1jBhsUuhZjN3IZ6bLfcKGW6+esiqKTkRaU+l29ET
 QO2wHKLIP3Z/J6NmQkeLei5qjAr0p7mKm1pjhNz+Dn8FoIy1Eh6fNnQhC1YSurqTt0Uq
 ypgkRKlTMAkzYCOgJxHouH/N7deSRa7yqH3ih82tz5Y0jvHNxnZ9BS8FyW1Hd+6uhM3W
 AVf6UtylYAG4dXpB4BjKfi0C/BdDb/vkQbww8ZQQLlOc6BnppL8gYETWRes4y0vTmF/4
 7en1uaAeXUzSASVcjO2AZ6x083Vr/QGcTj/vKBGP2QeOHyN/z2zWTBrKLZgf+SwvUQwD RQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2rhyvtfyx0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 15:40:17 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34Fdocr188187;
	Thu, 4 Apr 2019 15:40:17 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rm8f6rer1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 15:40:16 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x34Fe7qF004920;
	Thu, 4 Apr 2019 15:40:08 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 08:40:06 -0700
Subject: Re: [RFC PATCH v9 04/13] xpfo, x86: Add support for XPFO for x86-64
To: Peter Zijlstra <peterz@infradead.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
        amir73il@gmail.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        bigeasy@linutronix.de, bp@alien8.de, brgl@bgdev.pl,
        catalin.marinas@arm.com, corbet@lwn.net, dan.j.williams@intel.com,
        gregkh@linuxfoundation.org, guro@fb.com, hannes@cmpxchg.org,
        hpa@zytor.com, iamjoonsoo.kim@lge.com, james.morse@arm.com,
        jannh@google.com, jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khlebnikov@yandex-team.ru, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        pavel.tatashin@microsoft.com, rdunlap@infradead.org,
        richard.weiyang@gmail.com, riel@surriel.com, rientjes@google.com,
        rostedt@goodmis.org, rppt@linux.vnet.ibm.com, will.deacon@arm.com,
        willy@infradead.org, yaojun8558363@gmail.com, ying.huang@intel.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <c15e7d09dfe3dfdb9947d39ed0ddd6573ff86dbf.1554248002.git.khalid.aziz@oracle.com>
 <20190404075206.GP4038@hirez.programming.kicks-ass.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <d526e3bb-ba83-afe5-5db9-bd0112e26fea@oracle.com>
Date: Thu, 4 Apr 2019 09:40:01 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190404075206.GP4038@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040101
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040101
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[trimmed To: and Cc: It was too large]

On 4/4/19 1:52 AM, Peter Zijlstra wrote:
> On Wed, Apr 03, 2019 at 11:34:05AM -0600, Khalid Aziz wrote:
>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgt=
able.h
>> index 2779ace16d23..5c0e1581fa56 100644
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -1437,6 +1437,32 @@ static inline bool arch_has_pfn_modify_check(vo=
id)
>>  	return boot_cpu_has_bug(X86_BUG_L1TF);
>>  }
>> =20
>> +/*
>> + * The current flushing context - we pass it instead of 5 arguments:
>> + */
>> +struct cpa_data {
>> +	unsigned long	*vaddr;
>> +	pgd_t		*pgd;
>> +	pgprot_t	mask_set;
>> +	pgprot_t	mask_clr;
>> +	unsigned long	numpages;
>> +	unsigned long	curpage;
>> +	unsigned long	pfn;
>> +	unsigned int	flags;
>> +	unsigned int	force_split		: 1,
>> +			force_static_prot	: 1;
>> +	struct page	**pages;
>> +};
>> +
>> +
>> +int
>> +should_split_large_page(pte_t *kpte, unsigned long address,
>> +			struct cpa_data *cpa);
>> +extern spinlock_t cpa_lock;
>> +int
>> +__split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long a=
ddress,
>> +		   struct page *base);
>> +
>=20
> I really hate exposing all that.

I believe this was done so set_kpte() could split large pages if needed.
I will look into creating a helper function instead so this does not
have to be exposed.

>=20
>>  #include <asm-generic/pgtable.h>
>>  #endif	/* __ASSEMBLY__ */
>> =20
>=20
>> diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
>> new file mode 100644
>> index 000000000000..3045bb7e4659
>> --- /dev/null
>> +++ b/arch/x86/mm/xpfo.c
>> @@ -0,0 +1,123 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +/*
>> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
>> + * Copyright (C) 2016 Brown University. All rights reserved.
>> + *
>> + * Authors:
>> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
>> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
>> + *
>> + * This program is free software; you can redistribute it and/or modi=
fy it
>> + * under the terms of the GNU General Public License version 2 as pub=
lished by
>> + * the Free Software Foundation.
>> + */
>> +
>> +#include <linux/mm.h>
>> +
>> +#include <asm/tlbflush.h>
>> +
>> +extern spinlock_t cpa_lock;
>> +
>> +/* Update a single kernel page table entry */
>> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
>> +{
>> +	unsigned int level;
>> +	pgprot_t msk_clr;
>> +	pte_t *pte =3D lookup_address((unsigned long)kaddr, &level);
>> +
>> +	if (unlikely(!pte)) {
>> +		WARN(1, "xpfo: invalid address %p\n", kaddr);
>> +		return;
>> +	}
>> +
>> +	switch (level) {
>> +	case PG_LEVEL_4K:
>> +		set_pte_atomic(pte, pfn_pte(page_to_pfn(page),
>> +			       canon_pgprot(prot)));
>=20
> (sorry, do we also need a nikon_pgprot() ? :-)

Are we trying to encourage nikon as well to sponsor this patch :)

>=20
>> +		break;
>> +	case PG_LEVEL_2M:
>> +	case PG_LEVEL_1G: {
>> +		struct cpa_data cpa =3D { };
>> +		int do_split;
>> +
>> +		if (level =3D=3D PG_LEVEL_2M)
>> +			msk_clr =3D pmd_pgprot(*(pmd_t *)pte);
>> +		else
>> +			msk_clr =3D pud_pgprot(*(pud_t *)pte);
>> +
>> +		cpa.vaddr =3D kaddr;
>> +		cpa.pages =3D &page;
>> +		cpa.mask_set =3D prot;
>> +		cpa.mask_clr =3D msk_clr;
>> +		cpa.numpages =3D 1;
>> +		cpa.flags =3D 0;
>> +		cpa.curpage =3D 0;
>> +		cpa.force_split =3D 0;
>> +
>> +
>> +		do_split =3D should_split_large_page(pte, (unsigned long)kaddr,
>> +						   &cpa);
>> +		if (do_split) {
>> +			struct page *base;
>> +
>> +			base =3D alloc_pages(GFP_ATOMIC, 0);
>> +			if (!base) {
>> +				WARN(1, "xpfo: failed to split large page\n");
>=20
> You have to be fcking kidding right? A WARN when a GFP_ATOMIC allocatio=
n
> fails?!
>=20

Not sure what the reasoning was for this WARN in original patch, but I
think this is trying to warn about failure to split the large page in
order to unmap this single page as opposed to warning about allocation
failure. Nevertheless this could be done better.

>> +				break;
>> +			}
>> +
>> +			if (!debug_pagealloc_enabled())
>> +				spin_lock(&cpa_lock);
>> +			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr,
>> +						base) < 0) {
>> +				__free_page(base);
>> +				WARN(1, "xpfo: failed to split large page\n");
>> +			}
>> +			if (!debug_pagealloc_enabled())
>> +				spin_unlock(&cpa_lock);
>> +		}
>> +
>> +		break;
>=20
> Ever heard of helper functions?

Good idea. I will see if this all can be done in a helper function instea=
d.

>=20
>> +	}
>> +	case PG_LEVEL_512G:
>> +		/* fallthrough, splitting infrastructure doesn't
>> +		 * support 512G pages.
>> +		 */
>=20
> Broken coment style.

Slipped by me. Thanks, I will fix that.

>=20
>> +	default:
>> +		WARN(1, "xpfo: unsupported page level %x\n", level);
>> +	}
>> +
>> +}
>> +EXPORT_SYMBOL_GPL(set_kpte);
>> +
>> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
>> +{
>> +	int level;
>> +	unsigned long size, kaddr;
>> +
>> +	kaddr =3D (unsigned long)page_address(page);
>> +
>> +	if (unlikely(!lookup_address(kaddr, &level))) {
>> +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr,
>> +		     level);
>> +		return;
>> +	}
>> +
>> +	switch (level) {
>> +	case PG_LEVEL_4K:
>> +		size =3D PAGE_SIZE;
>> +		break;
>> +	case PG_LEVEL_2M:
>> +		size =3D PMD_SIZE;
>> +		break;
>> +	case PG_LEVEL_1G:
>> +		size =3D PUD_SIZE;
>> +		break;
>> +	default:
>> +		WARN(1, "xpfo: unsupported page level %x\n", level);
>> +		return;
>> +	}
>> +
>> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
>> +}
>=20
> You call this from IRQ/IRQ-disabled context... that _CANNOT_ be right.
>=20

Another reason why current implementation of xpfo_kmap/xpfo_kunmap does
not look right. I am leaning more and more towards rewriting this to be
similar to kmap_high while taking into account your input on fixmap
kmap_atomic.

Side note: jsteckli@amazon.de is bouncing. Julian wrote quite a bit of
code in these patches. If anyone has Julian's current email, it would be
appreciated. Getting his feedback on these discussions will be useful.

Thanks,
Khalid

