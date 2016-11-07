Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88A4F6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 13:08:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so54238285pfx.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 10:08:34 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id p18si27140289pag.47.2016.11.07.10.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 10:08:33 -0800 (PST)
Subject: Re: [PATCH] arm/vdso: introduce vdso_mremap hook
References: <20161101172214.2938-1-dsafonov@virtuozzo.com>
 <0b41c28b-20ef-332f-d8d6-e381e05b8252@codeaurora.org>
 <714d2aea-ed4c-6272-89c1-e1d0e037855e@virtuozzo.com>
From: Christopher Covington <cov@codeaurora.org>
Message-ID: <d1aa8bec-a53e-cd30-e66a-39bebb6a400a@codeaurora.org>
Date: Mon, 7 Nov 2016 13:08:29 -0500
MIME-Version: 1.0
In-Reply-To: <714d2aea-ed4c-6272-89c1-e1d0e037855e@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Kevin Brodsky <kevin.brodsky@arm.com>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, Nathan Lynch <nathan_lynch@mentor.com>, Michael Ellerman <mpe@ellerman.id.au>

On 11/07/2016 12:16 PM, Dmitry Safonov wrote:
> On 11/07/2016 08:00 PM, Christopher Covington wrote:
>> Hi Dmitry,
>>
>> On 11/01/2016 01:22 PM, Dmitry Safonov wrote:
>>>   Add vdso_mremap hook which will fix context.vdso pointer after mremap()
>>> on vDSO vma. This is needed for correct landing after syscall execution.
>>> Primary goal of this is for CRIU on arm - we need to restore vDSO image
>>> at the exactly same place where the vma was in dumped application. With
>>> the help of this hook we'll move vDSO at the new position.
>>>   The CRIU code handles situations like when vDSO of dumped application
>>> was different from vDSO on restoring system. This usally happens when
>>> some new symbols are being added to vDSO. In these situations CRIU
>>> inserts jump trampolines from old vDSO blob to new vDSO on restore.
>>> By that reason even if on restore vDSO blob lies on the same address as
>>> blob in dumped application - we still need to move it if it differs.
>>>
>>>   There was previously attempt to add this functionality for arm64 by
>>> arch_mremap hook [1], while this patch introduces this with minimal
>>> effort - the same way I've added it to x86:
>>> commit b059a453b1cf ("x86/vdso: Add mremap hook to vm_special_mapping")
>>>
>>>   At this moment, vdso restoring code is disabled for arm/arm64 arch
>>> in CRIU [2], so C/R is only working for !CONFIG_VDSO kernels. This patch
>>> is aimed to fix that.
>>>   The same hook may be introduced for arm64 kernel, but at this moment
>>> arm64 vdso code is actively reworked by Kevin, so we can do it on top.
>>>   Separately, I've refactored arch_remap hook out from ppc64 [3].
>>>
>>> [1]: https://marc.info/?i=1448455781-26660-1-git-send-email-cov@codeaurora.org
>>> [2]: https://github.com/xemul/criu/blob/master/Makefile#L39
>>> [3]: https://marc.info/?i=20161027170948.8279-1-dsafonov@virtuozzo.com
>>>
>>> Cc: Kevin Brodsky <kevin.brodsky@arm.com>
>>> Cc: Christopher Covington <cov@codeaurora.org>
>>> Cc: Andy Lutomirski <luto@amacapital.net>
>>> Cc: Oleg Nesterov <oleg@redhat.com>
>>> Cc: Russell King <linux@armlinux.org.uk>
>>> Cc: Will Deacon <will.deacon@arm.com>
>>> Cc: linux-arm-kernel@lists.infradead.org
>>> Cc: linux-mm@kvack.org
>>> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
>>> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
>>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>>> ---
>>>  arch/arm/kernel/vdso.c | 21 +++++++++++++++++++++
>>>  1 file changed, 21 insertions(+)
>>>
>>> diff --git a/arch/arm/kernel/vdso.c b/arch/arm/kernel/vdso.c
>>> index 53cf86cf2d1a..d1001f87c2f6 100644
>>> --- a/arch/arm/kernel/vdso.c
>>> +++ b/arch/arm/kernel/vdso.c
>>> @@ -54,8 +54,11 @@ static const struct vm_special_mapping vdso_data_mapping = {
>>>      .pages = &vdso_data_page,
>>>  };
>>>
>>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>>> +        struct vm_area_struct *new_vma);
>>>  static struct vm_special_mapping vdso_text_mapping __ro_after_init = {
>>>      .name = "[vdso]",
>>> +    .mremap = vdso_mremap,
>>>  };
>>>
>>>  struct elfinfo {
>>> @@ -254,6 +257,24 @@ void arm_install_vdso(struct mm_struct *mm, unsigned long addr)
>>>          mm->context.vdso = addr;
>>>  }
>>>
>>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>>> +        struct vm_area_struct *new_vma)
>>> +{
>>> +    unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
>>> +    unsigned long vdso_size = (vdso_total_pages - 1) << PAGE_SHIFT;
>>> +
>>> +    /* Disallow partial vDSO blob remap */
>>> +    if (vdso_size != new_size)
>>> +        return -EINVAL;
>>> +
>>> +    if (WARN_ON_ONCE(current->mm != new_vma->vm_mm))
>>> +        return -EFAULT;
>>> +
>>> +    current->mm->context.vdso = new_vma->vm_start;
>>> +
>>> +    return 0;
>>> +}
>>> +
>>>  static void vdso_write_begin(struct vdso_data *vdata)
>>>  {
>>>      ++vdso_data->seq_count;
>>>
>>
>> What do you think about putting this code somewhere generic (not under
>> arch/*), so that powerpc and arm64 can reuse it once the cosmetic changes
>> to make them compatible are made? My thought was that it could be defined
>> underneath CONFIG_GENERIC_VDSO, which architectures could select as they
>> became compatible.
> 
> Hi Chistopher,
> 
> Well, I don't think we won something out of generalization of simple assignment for context.vdso pointer accross arches. And a need to rename
> vdso over arches for saving one single line?

I count 17 lines, which duplicated across 3 architectures becomes 51 lines.
Presumable in the future other architectures will want CRIU support as well.
Additionally, should fixes ever be required, fixing one implementation instead
of 3+ is preferred.

> Also I don't like a bit this arch_mremap hook and need to nullify
> vdso pointer.

I'm sorry for the confusion but I in no way meant to imply that the
arch_mremap hook should be carried forward. I fully  agree that the function
pointer in struct vm_special_mapping is the better way to go.

If you don't want to implement a version with vdso_mremap defined in a
generic location (using it from struct vm_special_mapping), do you mind if I
propose such a version?

Thanks,
Cov

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc. Qualcomm Technologies, Inc. is a member of the Code
Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
