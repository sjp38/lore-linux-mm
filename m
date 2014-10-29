Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE27900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 04:15:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so2474230pdb.41
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:15:19 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0141.outbound.protection.outlook.com. [207.46.100.141])
        by mx.google.com with ESMTPS id xm6si3441141pab.111.2014.10.29.01.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Oct 2014 01:15:17 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: RE: Does slow_virt_to_phys() work with vmalloc() in the case of
 32bit-PAE and 2MB page?
Date: Wed, 29 Oct 2014 08:14:42 +0000
Message-ID: <F792CF86EFE20D4AB8064279AFBA51C61056FE3F@HKNPRD3002MB017.064d.mgd.msft.net>
References: <F792CF86EFE20D4AB8064279AFBA51C610567A76@HKNPRD3002MB017.064d.mgd.msft.net>
 <F792CF86EFE20D4AB8064279AFBA51C610568754@HKNPRD3002MB017.064d.mgd.msft.net>
In-Reply-To: <F792CF86EFE20D4AB8064279AFBA51C610568754@HKNPRD3002MB017.064d.mgd.msft.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dave.hansen@intel.com" <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KY Srinivasan <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Dexuan Cui
> Sent: Tuesday, October 28, 2014 16:51 PM
> To: dave.hansen@intel.com; Rik van Riel; H. Peter Anvin
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: RE: Does slow_virt_to_phys() work with vmalloc() in the case of
> 32bit-PAE and 2MB page?
>=20
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Dexuan Cui
> > Sent: Tuesday, October 28, 2014 15:08 PM
> > To: Dave Hansen; Rik van Riel; H. Peter Anvin
> > Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> > Subject: Does slow_virt_to_phys() work with vmalloc() in the case of 32=
bit-
> > PAE and 2MB page?
> >
> > Hi all,
> > I suspect slow_virt_to_phys() may not work with vmalloc() in
> > the 32-bit PAE case(when the pa > 4GB), probably due to 2MB page(?)
> >
> > Is there any known issue with slow_virt_to_phys() + vmalloc() +
> > 32-bit PAE + 2MB page?
> >
> > From what I read the code of slow_virt_to_phys(), the variable 'psize' =
is
> > assigned with a value but not used at all -- is this a bug?
> After reading through the code, I think there is no issue here, though th=
e
> assignment of 'psize'  should be unnecessary, I think.

Hi all,
Finally it turns out there is a left-shift-overflow bug for 32-PAE here!

pte_pfn() returns a PFN of long (32bits in 32-PAE), then "long << PAGE_SHIF=
T"
will overflow for PFNs above 4GB.

I'm going to post the below fix in another mail:

@@ -409,7 +409,7 @@ phys_addr_t slow_virt_to_phys(void *__virt_addr)
        psize =3D page_level_size(level);
        pmask =3D page_level_mask(level);
        offset =3D virt_addr & ~pmask;
-       phys_addr =3D pte_pfn(*pte) << PAGE_SHIFT;
+       phys_addr =3D (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
        return (phys_addr | offset);
 }

Thanks,
-- Dexuan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
