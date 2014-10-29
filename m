Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0405F900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 05:51:06 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id r5so2018807qcx.33
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 02:51:06 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0143.outbound.protection.outlook.com. [157.56.110.143])
        by mx.google.com with ESMTPS id y9si6641852qab.10.2014.10.29.02.51.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Oct 2014 02:51:06 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] x86, pageattr: fix slow_virt_to_phys() for X86_PAE
Date: Wed, 29 Oct 2014 09:50:23 +0000
Message-ID: <F792CF86EFE20D4AB8064279AFBA51C6105705CD@HKNPRD3002MB017.064d.mgd.msft.net>
References: <1414580033-27484-1-git-send-email-decui@microsoft.com>
In-Reply-To: <1414580033-27484-1-git-send-email-decui@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "riel@redhat.com" <riel@redhat.com>
Cc: KY Srinivasan <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Dexuan Cui
> Sent: Wednesday, October 29, 2014 18:54 PM
> To: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org; x86@kernel.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; tglx@linutronix.de; mingo@redhat.com;
> hpa@zytor.com; dave.hansen@intel.com; riel@redhat.com
> Cc: KY Srinivasan; Haiyang Zhang
> Subject: [PATCH] x86, pageattr: fix slow_virt_to_phys() for X86_PAE
>=20
> pte_pfn() returns a PFN of long (32 bits in 32-PAE), then
> "long << PAGE_SHIFT" will overflow for PFNs above 4GB.
>=20
> Due to this issue, some Linux 32-PAE distros, running as guests on Hyper-=
V,
> with 5GB memory assigned, can't load the netvsc driver successfully and
> hence the synthetic network device can't work (we can use the kernel
> parameter
> mem=3D3000M to work around the issue).
>=20
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> ---
>  arch/x86/mm/pageattr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index ae242a7..36de293 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -409,7 +409,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
>  	psize =3D page_level_size(level);
>  	pmask =3D page_level_mask(level);
>  	offset =3D virt_addr & ~pmask;
> -	phys_addr =3D pte_pfn(*pte) << PAGE_SHIFT;
> +	phys_addr =3D (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
>  	return (phys_addr | offset);
>  }
>  EXPORT_SYMBOL_GPL(slow_virt_to_phys);

Sorry for sending the same patch twice due to my silly typing!

Thanks,
-- Dexuan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
