Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D76B6B002D
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 05:18:26 -0400 (EDT)
Message-Id: <4EB029DB0200001600008FC0@novprvlin0050.provo.novell.com>
Date: Tue, 01 Nov 2011 03:18:19 -0600
From: "Guan Jun He" <gjhe@suse.com>
Subject: Re: [PATCH][mm/memory.c]: transparent hugepage check condition
 missed
References: <1320049412-12642-1-git-send-email-gjhe@suse.com>
 <1320110288.22361.190.camel@sli10-conroe>
 <4EB01C8F0200001600008FAE@novprvlin0050.provo.novell.com>
 <CANejiEVk41X-P+UyMf96jmPrJJ5-_vbubYtnQgaWXY2FLb41iw@mail.gmail.com>
In-Reply-To: <CANejiEVk41X-P+UyMf96jmPrJJ5-_vbubYtnQgaWXY2FLb41iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



>>> On 11/1/2011 at 04:42 PM, in message
<CANejiEVk41X-P+UyMf96jmPrJJ5-_vbubYtnQgaWXY2FLb41iw@mail.gmail.com>, =
Shaohua
Li <shaohua.li@intel.com> wrote:=20
> 2011/11/1 Guan Jun He <gjhe@suse.com>:
>>
>>
>>>>> On 11/1/2011 at 09:18 AM, in message <1320110288.22361.190.camel@sli1=
0-conroe>,
>> Shaohua Li <shaohua.li@intel.com> wrote:
>>> On Mon, 2011-10-31 at 16:23 +0800, Guanjun He wrote:
>>>> For the transparent hugepage module still does not support
>>>> tmpfs and cache,the check condition should always be checked
>>>> to make sure that it only affect the anonymous maps, the
>>>> original check condition missed this, this patch is to fix this.
>>>> Otherwise,the hugepage may affect the file-backed maps,
>>>> then the cache for the small-size pages will be unuseful,
>>>> and till now there is still no implementation for hugepage's cache.
>>>>
>>>> Signed-off-by: Guanjun He <gjhe@suse.com>
>>>> ---
>>>>  mm/memory.c |    3 ++-
>>>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>> index a56e3ba..79b85fe 100644
>>>> --- a/mm/memory.c
>>>> +++ b/mm/memory.c
>>>> @@ -3475,7 +3475,8 @@ int handle_mm_fault(struct mm_struct *mm, =
struct
>>> vm_area_struct *vma,
>>>>              if (pmd_trans_huge(orig_pmd)) {
>>>>                      if (flags & FAULT_FLAG_WRITE &&
>>>>                          !pmd_write(orig_pmd) &&
>>>> -                        !pmd_trans_splitting(orig_pmd))
>>>> +                        !pmd_trans_splitting(orig_pmd) &&
>>>> +                        !vma->vm_ops)
>>>>                              return do_huge_pmd_wp_page(mm, vma, =
address,
>>>>                                                         pmd, =
orig_pmd);
>>>>                      return 0;
>>> so if vma->vm_ops !=3D NULL, how could the pmd_trans_huge(orig_pmd) be
>>> true? We never enable THP if vma->vm_ops !=3D NULL.
>> acturally, pmd_trans_huge(orig_pmd) only checks the _PAGE_PSE bits,
>> it's only a pagesize, not a flag to identity a hugepage.
>> If I change my default pagesize to PAGE_PSE,
> Not sure what pagesize means here, assume pmd entry bits.
yes, it's  pmd entry bits.
> how could you make the default 'pagesize' to PAGE_PSE?
That requires some work and not so easy and need hardware support... So, =
recently it won't come.
But one can easily create the same pmd entry bits for some special use;
as comment above, it's a pmd entry bits, only mark a size, not a flag;
and adjust the logic to use the flag can perfect avoid this potential =
issuse,
and basically no impact to the current code.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
