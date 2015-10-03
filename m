Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9301A680DC6
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 06:19:35 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so129519992pac.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 03:19:35 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id fc2si9045032pbd.137.2015.10.03.03.19.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Oct 2015 03:19:34 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH] mm: optimize PageHighMem() check
Date: Sat, 3 Oct 2015 10:19:28 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781A2B7@IN01WEMBXB.internal.synopsys.com>
References: <1443513260-14598-1-git-send-email-vgupta@synopsys.com>
 <20151001162528.32c5338efdff2bdea838befd@linux-foundation.org>
 <560E2F29.5070807@synopsys.com>
 <20151002135315.7ae22edce0bf54e38f69b1b0@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Jennifer Herbert <jennifer.herbert@citrix.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Saturday 03 October 2015 02:23 AM, Andrew Morton wrote:=0A=
> On Fri, 2 Oct 2015 12:45:53 +0530 Vineet Gupta <vgupta@synopsys.com> wrot=
e:=0A=
>=0A=
>> On Friday 02 October 2015 04:55 AM, Andrew Morton wrote:=0A=
>>> On Tue, 29 Sep 2015 13:24:20 +0530 Vineet Gupta <Vineet.Gupta1@synopsys=
.com> wrote:=0A=
>>>=0A=
>>>>> This came up when implementing HIHGMEM/PAE40 for ARC.=0A=
>>>>> The kmap() / kmap_atomic() generated code seemed needlessly bloated d=
ue=0A=
>>>>> to the way PageHighMem() macro is implemented.=0A=
>>>>> It derives the exact zone for page and then does pointer subtraction=
=0A=
>>>>> with first zone to infer the zone_type.=0A=
>>>>> The pointer arithmatic in turn generates the code bloat.=0A=
>>>>>=0A=
>>>>> PageHighMem(page)=0A=
>>>>>   is_highmem(page_zone(page))=0A=
>>>>>      zone_off =3D (char *)zone - (char *)zone->zone_pgdat->node_zones=
=0A=
>>>>>=0A=
>>>>> Instead use is_highmem_idx() to work on zone_type available in page f=
lags=0A=
>>>>>=0A=
>>>>>    ----- Before -----=0A=
>>>>> 80756348:	mov_s      r13,r0=0A=
>>>>> 8075634a:	ld_s       r2,[r13,0]=0A=
>>>>> 8075634c:	lsr_s      r2,r2,30=0A=
>>>>> 8075634e:	mpy        r2,r2,0x2a4=0A=
>>>>> 80756352:	add_s      r2,r2,0x80aef880=0A=
>>>>> 80756358:	ld_s       r3,[r2,28]=0A=
>>>>> 8075635a:	sub_s      r2,r2,r3=0A=
>>>>> 8075635c:	breq       r2,0x2a4,80756378 <kmap+0x48>=0A=
>>>>> 80756364:	breq       r2,0x548,80756378 <kmap+0x48>=0A=
>>>>>=0A=
>>>>>    ----- After  -----=0A=
>>>>> 80756330:	mov_s      r13,r0=0A=
>>>>> 80756332:	ld_s       r2,[r13,0]=0A=
>>>>> 80756334:	lsr_s      r2,r2,30=0A=
>>>>> 80756336:	sub_s      r2,r2,1=0A=
>>>>> 80756338:	brlo       r2,2,80756348 <kmap+0x30>=0A=
>>>>>=0A=
>>>>> For x86 defconfig build (32 bit only) it saves around 900 bytes.=0A=
>>>>> For ARC defconfig with HIGHMEM, it saved around 2K bytes.=0A=
>>>>>=0A=
>>>>>    ---->8-------=0A=
>>>>> ./scripts/bloat-o-meter x86/vmlinux-defconfig-pre x86/vmlinux-defconf=
ig-post=0A=
>>>>> add/remove: 0/0 grow/shrink: 0/36 up/down: 0/-934 (-934)=0A=
>>>>> function                                     old     new   delta=0A=
>>>>> saveable_page                                162     154      -8=0A=
>>>>> saveable_highmem_page                        154     146      -8=0A=
>>>>> skb_gro_reset_offset                         147     131     -16=0A=
>>>>> ...=0A=
>>>>> ...=0A=
>>>>> __change_page_attr_set_clr                  1715    1678     -37=0A=
>>>>> setup_data_read                              434     394     -40=0A=
>>>>> mon_bin_event                               1967    1927     -40=0A=
>>>>> swsusp_save                                 1148    1105     -43=0A=
>>>>> _set_pages_array                             549     493     -56=0A=
>>>>>    ---->8-------=0A=
>>>>>=0A=
>>>>> e.g. For ARC kmap()=0A=
>>>>>=0A=
>>> is_highmem() is deranged.  Can't we use a bit in zone->flags or=0A=
>>> something?=0A=
>> It won't be "a" bit since zone_type is an enum.=0A=
> Yes it will!=0A=
>=0A=
> static inline int is_highmem(struct zone *zone)=0A=
> {=0A=
> 	return test_bit(ZONE_HIGHMEM, &zone->flags);=0A=
> }=0A=
=0A=
Point is do we want to fix this specific case, or do we want to improve zon=
e_idx()=0A=
in general.=0A=
=0A=
#define zone_idx(zone)        ((zone) - (zone)->zone_pgdat->node_zones=0A=
=0A=
If former, I can split up zone->flags into 31:1 bit-field. Otherwise I will=
 split=0A=
it into 24:8 to hold both zone_flags and zone_type=0A=
=0A=
>> ...=0A=
>>=0A=
>> However this patch still is independent of that since we have struct pag=
e as=0A=
>> starting point and zone_type is available from there directly w/o monkey=
ing around=0A=
>> with any zone structs.=0A=
> yup.=0A=
=0A=
Do u want me to carry this as part of the the ARC HIGHMEM/PAE40 patchset or=
 would=0A=
you rather prefer merging it via mm tree.=0A=
=0A=
Thx,=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
