Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E6056B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 00:53:09 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Tue, 12 Jan 2010 13:51:15 +0800
Subject: RE: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860316C002A@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
 <20100108124851.GB6153@localhost>
 <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
 <20100111124303.GA21408@localhost>
In-Reply-To: <20100111124303.GA21408@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > +	/* if add to low memory, update max_low_pfn */
> > +	if (unlikely(start_pfn < limit_low_pfn)) {
> > +		if (end_pfn <=3D limit_low_pfn)
> > +			max_low_pfn =3D end_pfn;
> > +		else
> > +			max_low_pfn =3D limit_low_pfn;
>=20
> X86_64 actually always set max_low_pfn=3Dmax_pfn, in setup_arch():
> [Zheng, Shaohui] there should be some misunderstanding, I read the
> code carefully, if the total memory is under 4G, it always
> max_low_pfn=3Dmax_pfn. If the total memory is larger than 4G,
> max_low_pfn means the end of low ram. It set

> max_low_pfn =3D e820_end_of_low_ram_pfn();.

The above line is very misleading.. In setup_arch(), it will be
overrode by the following block.
[Zheng, Shaohui] yes, I misunderstand it because of this code. It seems tha=
t max_low_pfn =3D=3D max_pfn is always true on x86_32 and x86_64.  Thanks f=
engguang to point it out.

>  899 #ifdef CONFIG_X86_64
>  900         if (max_pfn > max_low_pfn) {
>  901                 max_pfn_mapped =3D init_memory_mapping(1UL<<32,
>  902                                                      max_pfn<<PAGE_S=
HIFT);
>  903                 /* can we preseve max_low_pfn ?*/
>  904                 max_low_pfn =3D max_pfn;
>  905         }
>  906 #endif
=20
Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
