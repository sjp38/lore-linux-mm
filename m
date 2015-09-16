Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 64FE66B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 19:45:51 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so4689574ioi.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 16:45:51 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id x10si714101pas.107.2015.09.16.16.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 16:45:50 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 08/11] mm,thp: reduce ifdef'ery for THP in generic code
Date: Wed, 16 Sep 2015 23:45:46 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D7817CCA@IN01WEMBXB.internal.synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
 <1440666194-21478-9-git-send-email-vgupta@synopsys.com>
 <20150916152540.b19aebc9f7a0889685867f1a@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>

On Wednesday 16 September 2015 03:25 PM, Andrew Morton wrote:=0A=
> On Thu, 27 Aug 2015 14:33:11 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.c=
om> wrote:=0A=
>=0A=
>> This is purely cosmetic, just makes code more readable=0A=
>>=0A=
>> ...=0A=
>>=0A=
>> --- a/include/asm-generic/pgtable.h=0A=
>> +++ b/include/asm-generic/pgtable.h=0A=
>> @@ -30,9 +30,20 @@ extern int ptep_set_access_flags(struct vm_area_struc=
t *vma,=0A=
>>  #endif=0A=
>>  =0A=
>>  #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS=0A=
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE=0A=
>>  extern int pmdp_set_access_flags(struct vm_area_struct *vma,=0A=
>>  				 unsigned long address, pmd_t *pmdp,=0A=
>>  				 pmd_t entry, int dirty);=0A=
>> +#else /* CONFIG_TRANSPARENT_HUGEPAGE */=0A=
>> +static inline int pmdp_set_access_flags(struct vm_area_struct *vma,=0A=
>> +					unsigned long address, pmd_t *pmdp,=0A=
>> +					pmd_t entry, int dirty)=0A=
>> +{=0A=
>> +	BUG();=0A=
>> +	return 0;=0A=
>> +}=0A=
> Is it possible to simply leave this undefined?  So the kernel fails at=0A=
> link time?=0A=
=0A=
Sure ! There's quite a few in there which could be changed in same way ! I'=
ll do=0A=
that in v2=0A=
=0A=
Thx for reviewing.=0A=
=0A=
-Vineet=0A=
=0A=
>=0A=
>> --- a/mm/pgtable-generic.c=0A=
>> +++ b/mm/pgtable-generic.c=0A=
> Good heavens that file is a mess.  Your patch does improve it.=0A=
>=0A=
>=0A=
>=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
