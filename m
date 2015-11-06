Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id BABCF82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 14:12:01 -0500 (EST)
Received: by ioll68 with SMTP id l68so133146796iol.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 11:12:01 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id c16si371277igo.99.2015.11.06.11.12.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 11:12:01 -0800 (PST)
Received: by igbhv6 with SMTP id hv6so41728784igb.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 11:12:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
Date: Fri, 6 Nov 2015 11:12:00 -0800
Message-ID: <CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@linaro.org>, info@kernelci.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>

On Fri, Nov 6, 2015 at 11:08 AM, Kees Cook <keescook@chromium.org> wrote:
> On Fri, Nov 6, 2015 at 10:44 AM, Laura Abbott <labbott@redhat.com> wrote:
>> On 11/05/2015 05:15 PM, Kees Cook wrote:
>>>
>>> On Thu, Nov 5, 2015 at 5:05 PM, Laura Abbott <labbott@redhat.com> wrote:
>>>>
>>>> On 11/05/2015 08:27 AM, Russell King - ARM Linux wrote:
>>>>>
>>>>>
>>>>> On Thu, Nov 05, 2015 at 08:20:42AM -0800, Laura Abbott wrote:
>>>>>>
>>>>>>
>>>>>> On 11/05/2015 01:46 AM, Russell King - ARM Linux wrote:
>>>>>>>
>>>>>>>
>>>>>>> On Wed, Nov 04, 2015 at 05:00:39PM -0800, Laura Abbott wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>> Currently, read only permissions are not being applied even
>>>>>>>> when CONFIG_DEBUG_RODATA is set. This is because section_update
>>>>>>>> uses current->mm for adjusting the page tables. current->mm
>>>>>>>> need not be equivalent to the kernel version. Use pgd_offset_k
>>>>>>>> to get the proper page directory for updating.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> What are you trying to achieve here?  You can't use these functions
>>>>>>> at run time (after the first thread has been spawned) to change
>>>>>>> permissions, because there will be multiple copies of the kernel
>>>>>>> section mappings, and those copies will not get updated.
>>>>>>>
>>>>>>> In any case, this change will probably break kexec and ftrace, as
>>>>>>> the running thread will no longer see the updated page tables.
>>>>>>>
>>>>>>
>>>>>> I think I was hitting that exact problem with multiple copies
>>>>>> not getting updated. The section_update code was being called
>>>>>> and I was seeing the tables get updated but nothing was being
>>>>>> applied when I tried to write to text or check the debugfs
>>>>>> page table. The current flow is:
>>>>>>
>>>>>> rest_init -> kernel_thread(kernel_init) and from that thread
>>>>>> mark_rodata_ro. So mark_rodata_ro is always going to happen
>>>>>> in a thread.
>>>>>>
>>>>>> Do we need to update for both init_mm and the first running
>>>>>> thread?
>>>>>
>>>>>
>>>>>
>>>>> The "first running thread" is merely coincidental for things like kexec.
>>>>>
>>>>> Hmm.  Actually, I think the existing code _should_ be fine.  At the
>>>>> point where mark_rodata_ro() is, we should still be using init_mm, so
>>>>> updating the current threads page tables should actually be updating
>>>>> the swapper_pg_dir.
>>>>
>>>>
>>>>
>>>> That doesn't seem to hold true. Based on what I'm seeing, we lose
>>>> the the guarantee of init_mm after the first exec. If usermodehelper
>>>> gets called to load a module, that triggers an exec and the kernel
>>>> thread is no longer using init_mm after that. I'm testing with the
>>>> multi-v7 defconfig which uses the smsc911x driver which loads a
>>>> module during initcall. That gets called before mark_rodata_ro so
>>>> the init_mm is never updated. I verified that disabling smsc911x
>>>> makes things work as expected. I suspect the testing was never done
>>>> with a driver that tried to call usermodehelper during init time.
>>>
>>>
>>> Ooooh. Nice catch. Yeah, my testing didn't include that case.
>>>
>>>> I got as far as narrowing it down that it happens after the
>>>> usermodehelper
>>>> but I wasn't able to pinpoint where exactly the switch happened. It seems
>>>> like we need to have the page tables set up before any initcalls
>>>> happen otherwise we risk having an exec create stray processes which we
>>>> can't update.
>>>
>>>
>>> Can we just make mark_rodata_ro() a no-op and do the RO setting
>>> earlier when we do the NX setting?
>>>
>>
>> Unfortunately no. The time we are doing the nx setting is before we've
>> finished
>> with the initmem so we need the initmem to be finished and freed before we
>> can
>> mark anything RO.
>>
>> More importantly, the NX settings are also not getting set. Compare before:
>>
>> ---[ Kernel Mapping ]---
>> 0xc0000000-0xc0300000           3M     RW NX
>> 0xc0300000-0xc1300000          16M     RW x
>> 0xc1300000-0xcc000000         173M     RW NX
>> 0xcc000000-0xcc040000         256K     RW NX     MEM/BUFFERABLE/WC
>> 0xcc040000-0xcc100000         768K     RW NX     MEM/CACHED/WBRA
>> 0xcc100000-0xcc280000        1536K     RW NX     MEM/BUFFERABLE/WC
>> 0xcc280000-0xd0000000       62976K     RW NX     MEM/CACHED/WBRA
>> 0xd0000000-0xd0200000           2M     RW NX
>>
>> and after
>>
>> ---[ Kernel Mapping ]---
>> 0xc0000000-0xc0300000           3M     RW NX
>> 0xc0300000-0xc0c00000           9M     ro x
>> 0xc0c00000-0xc1100000           5M     ro NX
>> 0xc1100000-0xcc000000         175M     RW NX
>> 0xcc000000-0xcc040000         256K     RW NX     MEM/BUFFERABLE/WC
>> 0xcc040000-0xcc100000         768K     RW NX     MEM/CACHED/WBRA
>> 0xcc100000-0xcc280000        1536K     RW NX     MEM/BUFFERABLE/WC
>> 0xcc280000-0xd0000000       62976K     RW NX     MEM/CACHED/WBRA
>> 0xd0000000-0xd0200000           2M     RW NX
>>
>>
>> with my test patch. I think setting both current->active_mm and &init_mm
>> is sufficient. Maybe explicitly setting swapper_pg_dir would be cleaner?
>>
>> Is there a test that should be running in a CI somewhere to catch cases like
>> this where the permissions are not working as expected
>
> I wrote these for lkdtm -- actually just mentioned it here:
> http://lwn.net/Articles/663531/
>
> EXEC_DATA
> EXEC_STACK
> EXEC_KMALLOC
> EXEC_VMALLOC
> EXEC_USERSPACE
> ACCESS_USERSPACE
> WRITE_RO
> WRITE_KERN
>
> Each of those should Oops the kernel if things are working correctly.
> I'm not aware of a public CI that currently handles checking for
> expected Oops via lkdtm.
>
> The other tests I ran when building this were to turn ftrace on and
> off. If that works for you, then this patch seems fine. (AIUI, the
> code would be unchanged from original when running ftrace, so I would
> expect this to work.)

Hi Kevin and Kernel CI folks,

Could lkdtm get added to the kernel-CI workflows? Extracting and
validating Oops details when poking lkdtm would be extremely valuable
for these cases. :)

-Kees

>
> -Kees
>
>>
>> My test patch that seems to be working:
>>
>> ----8<-----
>>
>> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
>> index 8a63b4c..6276b234 100644
>> --- a/arch/arm/mm/init.c
>> +++ b/arch/arm/mm/init.c
>> @@ -627,12 +627,10 @@ static struct section_perm ro_perms[] = {
>>   * safe to be called with preemption disabled, as under stop_machine().
>>   */
>>  static inline void section_update(unsigned long addr, pmdval_t mask,
>> -                                 pmdval_t prot)
>> +                                 pmdval_t prot, struct mm_struct *mm)
>>  {
>> -       struct mm_struct *mm;
>>         pmd_t *pmd;
>>  -      mm = current->active_mm;
>>         pmd = pmd_offset(pud_offset(pgd_offset(mm, addr), addr), addr);
>>   #ifdef CONFIG_ARM_LPAE
>> @@ -656,7 +654,7 @@ static inline bool arch_has_strict_perms(void)
>>         return !!(get_cr() & CR_XP);
>>  }
>>  -#define set_section_perms(perms, field)       {
>> \
>> +#define set_section_perms(perms, field, all)   {                       \
>>         size_t i;                                                       \
>>         unsigned long addr;                                             \
>>                                                                         \
>> @@ -674,31 +672,35 @@ static inline bool arch_has_strict_perms(void)
>>                                                                         \
>>                 for (addr = perms[i].start;                             \
>>                      addr < perms[i].end;                               \
>> -                    addr += SECTION_SIZE)                              \
>> +                    addr += SECTION_SIZE) {                            \
>>                         section_update(addr, perms[i].mask,             \
>> -                                      perms[i].field);                 \
>> +                                      perms[i].field, current->active_mm);
>> \
>> +                       if (all)                                        \
>> +                               section_update(addr, perms[i].mask,     \
>> +                                       perms[i].field, &init_mm);      \
>> +               }                                                       \
>>         }                                                               \
>>  }
>>  -static inline void fix_kernmem_perms(void)
>> +void fix_kernmem_perms(void)
>>  {
>> -       set_section_perms(nx_perms, prot);
>> +       set_section_perms(nx_perms, prot, true);
>>  }
>>   #ifdef CONFIG_DEBUG_RODATA
>>  void mark_rodata_ro(void)
>>  {
>> -       set_section_perms(ro_perms, prot);
>> +       set_section_perms(ro_perms, prot, true);
>>  }
>>   void set_kernel_text_rw(void)
>>  {
>> -       set_section_perms(ro_perms, clear);
>> +       set_section_perms(ro_perms, clear, false);
>>  }
>>   void set_kernel_text_ro(void)
>>  {
>> -       set_section_perms(ro_perms, prot);
>> +       set_section_perms(ro_perms, prot, false);
>>  }
>>  #endif /* CONFIG_DEBUG_RODATA */
>>
>>
>>
>>
>>
>
>
>
> --
> Kees Cook
> Chrome OS Security



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
