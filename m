Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C87526B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 02:25:21 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f20-v6so19227136ioc.8
        for <linux-mm@kvack.org>; Thu, 03 May 2018 23:25:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z85-v6sor629493ita.74.2018.05.03.23.25.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 23:25:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9e7ab02c-a9af-71ed-afda-108e3b26b2ef@linux.vnet.ibm.com>
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
 <1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com> <9e7ab02c-a9af-71ed-afda-108e3b26b2ef@linux.vnet.ibm.com>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Fri, 4 May 2018 14:25:19 +0800
Message-ID: <CADAEsF-9+EBjn9nMj1qc7R9RbOTZTMc0GhZ9XbgHJB6zXQzsGg@mail.gmail.com>
Subject: Re: [PATCH 2/2] arm64/mm: add speculative page fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Punit Agrawal <punitagrawal@gmail.com>

2018-05-02 17:07 GMT+08:00 Laurent Dufour <ldufour@linux.vnet.ibm.com>:
> On 02/05/2018 09:54, Ganesh Mahendran wrote:
>> This patch enables the speculative page fault on the arm64
>> architecture.
>>
>> I completed spf porting in 4.9. From the test result,
>> we can see app launching time improved by about 10% in average.
>> For the apps which have more than 50 threads, 15% or even more
>> improvement can be got.
>
> Thanks Ganesh,
>
> That's a great improvement, could you please provide details about the apps and
> the hardware you used ?

We run spf on Qcom SDM845(kernel 4.9). Below is app(popular in China)
list we tested:
------
com.tencent.mobileqq
com.tencent.qqmusic
com.tencent.mtt
com.UCMobile
com.qiyi.video
com.baidu.searchbox
com.baidu.BaiduMap
tv.danmaku.bili
com.sdu.didi.psnger
com.ss.android.ugc.aweme
air.tv.douyu.android
me.ele
com.autonavi.minimap
com.duowan.kiwi
com.v.study
com.qqgame.hlddz
com.ss.android.article.lite
com.jingdong.app.mall
com.tencent.tmgp.pubgmhd
com.kugou.android
com.kuaikan.comic
com.hunantv.imgo.activity
com.mt.mtxx.mtxx
com.sankuai.meituan
com.sankuai.meituan.takeoutnew
com.tencent.karaoke
com.taobao.taobao
com.tencent.qqlive
com.tmall.wireless
com.tencent.tmgp.sgame
com.netease.cloudmusic
com.sina.weibo
com.tencent.mm
com.immomo.momo
com.xiaomi.hm.health
com.youku.phone
com.eg.android.AlipayGphone
com.meituan.qcs.c.android
------

We will do more test of the V10 spf.

>
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> ---
>> This patch is on top of Laurent's v10 spf
>> ---
>>  arch/arm64/mm/fault.c | 38 +++++++++++++++++++++++++++++++++++---
>>  1 file changed, 35 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
>> index 4165485..e7992a3 100644
>> --- a/arch/arm64/mm/fault.c
>> +++ b/arch/arm64/mm/fault.c
>> @@ -322,11 +322,13 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
>>
>>  static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
>>                          unsigned int mm_flags, unsigned long vm_flags,
>> -                        struct task_struct *tsk)
>> +                        struct task_struct *tsk, struct vm_area_struct *vma)
>>  {
>> -     struct vm_area_struct *vma;
>>       int fault;
>>
>> +     if (!vma || !can_reuse_spf_vma(vma, addr))
>> +             vma = find_vma(mm, addr);
>> +
>>       vma = find_vma(mm, addr);
>>       fault = VM_FAULT_BADMAP;
>>       if (unlikely(!vma))
>> @@ -371,6 +373,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>       int fault, major = 0;
>>       unsigned long vm_flags = VM_READ | VM_WRITE;
>>       unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
>> +     struct vm_area_struct *vma;
>>
>>       if (notify_page_fault(regs, esr))
>>               return 0;
>> @@ -409,6 +412,25 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>
>>       perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
>>
>> +     if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
>
> As suggested by Punit in his v10's review, the test on
> CONFIG_SPECULATIVE_PAGE_FAULT is not needed as handle_speculative_fault() is
> defined to return VM_FAULT_RETRY is the config is not set.

Thanks, will fix.

>
>> +             fault = handle_speculative_fault(mm, addr, mm_flags, &vma);
>> +             /*
>> +              * Page fault is done if VM_FAULT_RETRY is not returned.
>> +              * But if the memory protection keys are active, we don't know
>> +              * if the fault is due to key mistmatch or due to a
>> +              * classic protection check.
>> +              * To differentiate that, we will need the VMA we no
>> +              * more have, so let's retry with the mmap_sem held.
>> +              */
>
> The check of VM_FAULT_SIGSEGV was needed on ppc64 because of the memory
> protection key support, but as far as I know, this is not the case on arm64.
> Isn't it ?

Yes, wil fix.

>
>> +             if (fault != VM_FAULT_RETRY &&
>> +                      fault != VM_FAULT_SIGSEGV) {
>> +                     perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
>> +                     goto done;
>> +             }
>> +     } else {
>> +             vma = NULL;
>> +     }
>> +
>>       /*
>>        * As per x86, we may deadlock here. However, since the kernel only
>>        * validly references user space from well defined areas of the code,
>> @@ -431,7 +453,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>  #endif
>>       }
>>
>> -     fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
>> +     fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, vma);
>>       major |= fault & VM_FAULT_MAJOR;
>>
>>       if (fault & VM_FAULT_RETRY) {
>> @@ -454,11 +476,21 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>>               if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
>>                       mm_flags &= ~FAULT_FLAG_ALLOW_RETRY;
>>                       mm_flags |= FAULT_FLAG_TRIED;
>> +
>> +                     /*
>> +                      * Do not try to reuse this vma and fetch it
>> +                      * again since we will release the mmap_sem.
>> +                      */
>> +                     if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
>> +                             vma = NULL;
>> +
>>                       goto retry;
>>               }
>>       }
>>       up_read(&mm->mmap_sem);
>>
>> +done:
>> +
>>       /*
>>        * Handle the "normal" (no error) case first.
>>        */
>>
>
