Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6BF82F65
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 06:10:51 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so24516241pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 03:10:51 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id jj8si1350594pac.213.2015.10.09.03.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 03:10:50 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v2 09/12] mm,thp: reduce ifdef'ery for THP in generic
 code
Date: Fri, 9 Oct 2015 10:10:45 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781BE15@IN01WEMBXB.internal.synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
 <1442918096-17454-10-git-send-email-vgupta@synopsys.com>
 <20151009095359.GA7971@node>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Friday 09 October 2015 03:24 PM, Kirill A. Shutemov wrote:=0A=
> On Tue, Sep 22, 2015 at 04:04:53PM +0530, Vineet Gupta wrote:=0A=
>> - pgtable-generic.c: Fold individual #ifdef for each helper into a top=
=0A=
>>   level #ifdef. Makes code more readable=0A=
> Makes sense.=0A=
>=0A=
>> - Per Andrew's suggestion removed the dummy implementations for !THP=0A=
>>   in asm-generic/page-table.h to have build time failures vs. runtime.=
=0A=
> I'm not sure it's a good idea. This can lead to unnecessary #ifdefs where=
=0A=
> otherwise call to helper would be eliminated by compiler as dead code.=0A=
>=0A=
> What about dummy helpers with BUILD_BUG()?=0A=
=0A=
Not really. With this patch, if arch doesn't define __HAVR_ARCH_xyz - we pi=
ck the=0A=
default implementation. What I changed is if arch defines the __HAVE but do=
esn't=0A=
define the function, then instead of pickign a stub with runtime or buildti=
me bug=0A=
on, we simply fail the build ?=0A=
=0A=
Maybe I can add this to changelog to make it more explicit.=0A=
=0A=
>=0A=
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>=0A=
>> ---=0A=
>>  include/asm-generic/pgtable.h | 49 ++++++++++++++++--------------------=
-------=0A=
>>  mm/pgtable-generic.c          | 24 +++------------------=0A=
>>  2 files changed, 21 insertions(+), 52 deletions(-)=0A=
>>=0A=
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable=
.h=0A=
>> index 29c57b2cb344..2112f4147816 100644=0A=
>> --- a/include/asm-generic/pgtable.h=0A=
>> +++ b/include/asm-generic/pgtable.h=0A=
>> @@ -30,9 +30,12 @@ extern int ptep_set_access_flags(struct vm_area_struc=
t *vma,=0A=
>>  #endif=0A=
>>  =0A=
>>  #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS=0A=
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE=0A=
>>  extern int pmdp_set_access_flags(struct vm_area_struct *vma,=0A=
>>  				 unsigned long address, pmd_t *pmdp,=0A=
>>  				 pmd_t entry, int dirty);=0A=
>> +=0A=
>> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */=0A=
>>  #endif=0A=
>>  =0A=
>>  #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG=0A=
>> @@ -64,14 +67,6 @@ static inline int pmdp_test_and_clear_young(struct vm=
_area_struct *vma,=0A=
>>  		set_pmd_at(vma->vm_mm, address, pmdp, pmd_mkold(pmd));=0A=
>>  	return r;=0A=
>>  }=0A=
>> -#else /* CONFIG_TRANSPARENT_HUGEPAGE */=0A=
>> -static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,=
=0A=
>> -					    unsigned long address,=0A=
>> -					    pmd_t *pmdp)=0A=
>> -{=0A=
>> -	BUG();=0A=
>> -	return 0;=0A=
>> -}=0A=
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */=0A=
>>  #endif=0A=
>>  =0A=
>> @@ -81,8 +76,21 @@ int ptep_clear_flush_young(struct vm_area_struct *vma=
,=0A=
>>  #endif=0A=
>>  =0A=
>>  #ifndef __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH=0A=
>> -int pmdp_clear_flush_young(struct vm_area_struct *vma,=0A=
>> -			   unsigned long address, pmd_t *pmdp);=0A=
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE=0A=
>> +extern int pmdp_clear_flush_young(struct vm_area_struct *vma,=0A=
>> +				  unsigned long address, pmd_t *pmdp);=0A=
>> +#else=0A=
>> +/*=0A=
>> + * Despite relevant to THP only, this API is called from generic rmap c=
ode=0A=
>> + * under PageTransHuge(), hence needs a dummy implementation for !THP=
=0A=
>> + */=0A=
> Looks like a case I described above. BUILD_BUG_ON() should work fine here=
.=0A=
=0A=
Indeed BUILD_BUG_ON is better here.=0A=
=0A=
>=0A=
>> +static inline int pmdp_clear_flush_young(struct vm_area_struct *vma,=0A=
>> +					 unsigned long address, pmd_t *pmdp)=0A=
>> +{=0A=
>> +	BUG();=0A=
>> +	return 0;=0A=
>> +}=0A=
>> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */=0A=
>>  #endif=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
