Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 17234900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:08:50 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so33813qae.22
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:08:49 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0147.outbound.protection.outlook.com. [157.56.111.147])
        by mx.google.com with ESMTPS id b10si1002224qgf.10.2014.10.28.00.08.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Oct 2014 00:08:49 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: Does slow_virt_to_phys() work with vmalloc() in the case of
 32bit-PAE and 2MB page?
Date: Tue, 28 Oct 2014 07:08:04 +0000
Message-ID: <F792CF86EFE20D4AB8064279AFBA51C610567A76@HKNPRD3002MB017.064d.mgd.msft.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, "H.
 Peter Anvin" <hpa@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,
I suspect slow_virt_to_phys() may not work with vmalloc() in
the 32-bit PAE case(when the pa > 4GB), probably due to 2MB page(?)

Is there any known issue with slow_virt_to_phys() + vmalloc() +
32-bit PAE + 2MB page?

>From what I read the code of slow_virt_to_phys(), the variable 'psize' is
assigned with a value but not used at all -- is this a bug?


phys_addr_t slow_virt_to_phys(void *__virt_addr)
{
        unsigned long virt_addr =3D (unsigned long)__virt_addr;
        phys_addr_t phys_addr;
        unsigned long offset;
        enum pg_level level;
        unsigned long psize;
        unsigned long pmask;
        pte_t *pte;

        pte =3D lookup_address(virt_addr, &level);
        BUG_ON(!pte);
        psize =3D page_level_size(level);
        pmask =3D page_level_mask(level);
        offset =3D virt_addr & ~pmask;
        phys_addr =3D pte_pfn(*pte) << PAGE_SHIFT;
        return (phys_addr | offset);
}

Thanks,
-- Dexuan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
