Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8A9596B007E
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 03:49:44 -0400 (EDT)
Message-ID: <4F71714E.9080803@mprc.pku.edu.cn>
Date: Tue, 27 Mar 2012 15:50:38 +0800
From: Guan Xuetao <gxt@mprc.pku.edu.cn>
MIME-Version: 1.0
Subject: Re: [PATCH 08/16] mm/unicore32: use vm_flags_t for vma flags
References: <20120321065140.13852.52315.stgit@zurg> <20120321065645.13852.83925.stgit@zurg> <4F71361E.1000802@mprc.pku.edu.cn> <4F71570D.4060507@openvz.org>
In-Reply-To: <4F71570D.4060507@openvz.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 03/27/2012 01:58 PM, Konstantin Khlebnikov wrote:
> Guan Xuetao wrote:
>> On 03/21/2012 02:56 PM, Konstantin Khlebnikov wrote:
>>> The same magic like in arm: assembler code wants to test VM_EXEC,
>>> but for big-endian we should get upper word for this.
>>>
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> Cc: Guan Xuetao<gxt@mprc.pku.edu.cn>
>>> ---
>>>    arch/unicore32/kernel/asm-offsets.c |    6 +++++-
>>>    arch/unicore32/mm/fault.c           |    2 +-
>>>    2 files changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/unicore32/kernel/asm-offsets.c 
>>> b/arch/unicore32/kernel/asm-offsets.c
>>> index ffcbe75..e3199b5 100644
>>> --- a/arch/unicore32/kernel/asm-offsets.c
>>> +++ b/arch/unicore32/kernel/asm-offsets.c
>>> @@ -87,9 +87,13 @@ int main(void)
>>>        DEFINE(S_FRAME_SIZE,    sizeof(struct pt_regs));
>>>        BLANK();
>>>        DEFINE(VMA_VM_MM,    offsetof(struct vm_area_struct, vm_mm));
>>> +#if defined(CONFIG_CPU_BIG_ENDIAN)&&   (NR_VMA_FLAGS>   32)
>>> +    DEFINE(VMA_VM_FLAGS,    offsetof(struct vm_area_struct, 
>>> vm_flags) + 4);
>>> +#else
>> CONFIG_CPU_BIG/LITTLE_ENDIAN is defined only in some archs, and not
>> supported by unicore32.
>
> Ok, I'll drop this in v2
>
>>
>>>        DEFINE(VMA_VM_FLAGS,    offsetof(struct vm_area_struct, 
>>> vm_flags));
>>> +#endif
>>>        BLANK();
>>> -    DEFINE(VM_EXEC,        VM_EXEC);
>>> +    DEFINE(VM_EXEC,        (__force unsigned int)VM_EXEC);
>
>> Is this check useful for asm-offsets.h?
>
> this forced-typecast to make sparse happy, because  we use here only 
> (int) part of vma->vm_flags.
Perhaps,  vm_flags_t,  not unsigned int is more proper.

>
>>
>>>        BLANK();
>>>        DEFINE(PAGE_SZ,        PAGE_SIZE);
>>>        BLANK();
>>> diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
>>> index 283aa4b..9137996 100644
>>> --- a/arch/unicore32/mm/fault.c
>>> +++ b/arch/unicore32/mm/fault.c
>>> @@ -158,7 +158,7 @@ void do_bad_area(unsigned long addr, unsigned 
>>> int fsr, struct pt_regs *regs)
>>>     */
>>>    static inline bool access_error(unsigned int fsr, struct 
>>> vm_area_struct *vma)
>>>    {
>>> -    unsigned int mask = VM_READ | VM_WRITE | VM_EXEC;
>>> +    vm_flags_t mask = VM_READ | VM_WRITE | VM_EXEC;
>>
>> I am confused  for the type of vm_flags in vm_area_struct being
>> 'unsigned long',  not vm_flags_t.
>
> Second patch in this patchset changes it.
> vm_flags_t will be unsigned long or or unsigned long long depending on 
> vma flags count.
> But more likely it will be unsigned int, because I have another 
> patchset in work,
> which currently drop four bits in vm_flags, so we can postpone its 
> expansion.
I see. Thanks for your explanation.

Regards,
Guan Xuetao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
