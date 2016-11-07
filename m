Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0C1C6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 12:27:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so53642300pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 09:27:53 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0136.outbound.protection.outlook.com. [104.47.1.136])
        by mx.google.com with ESMTPS id vy10si3699313pac.129.2016.11.07.09.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 09:19:56 -0800 (PST)
Subject: Re: [PATCH] arm/vdso: introduce vdso_mremap hook
References: <20161101172214.2938-1-dsafonov@virtuozzo.com>
 <0b41c28b-20ef-332f-d8d6-e381e05b8252@codeaurora.org>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <714d2aea-ed4c-6272-89c1-e1d0e037855e@virtuozzo.com>
Date: Mon, 7 Nov 2016 20:16:58 +0300
MIME-Version: 1.0
In-Reply-To: <0b41c28b-20ef-332f-d8d6-e381e05b8252@codeaurora.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>, linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Kevin Brodsky <kevin.brodsky@arm.com>, Andy
 Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, Russell
 King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, Nathan Lynch <nathan_lynch@mentor.com>, Michael Ellerman <mpe@ellerman.id.au>

On 11/07/2016 08:00 PM, Christopher Covington wrote:
> Hi Dmitry,
>
> On 11/01/2016 01:22 PM, Dmitry Safonov wrote:
>>   Add vdso_mremap hook which will fix context.vdso pointer after mremap()
>> on vDSO vma. This is needed for correct landing after syscall execution.
>> Primary goal of this is for CRIU on arm - we need to restore vDSO image
>> at the exactly same place where the vma was in dumped application. With
>> the help of this hook we'll move vDSO at the new position.
>>   The CRIU code handles situations like when vDSO of dumped application
>> was different from vDSO on restoring system. This usally happens when
>> some new symbols are being added to vDSO. In these situations CRIU
>> inserts jump trampolines from old vDSO blob to new vDSO on restore.
>> By that reason even if on restore vDSO blob lies on the same address as
>> blob in dumped application - we still need to move it if it differs.
>>
>>   There was previously attempt to add this functionality for arm64 by
>> arch_mremap hook [1], while this patch introduces this with minimal
>> effort - the same way I've added it to x86:
>> commit b059a453b1cf ("x86/vdso: Add mremap hook to vm_special_mapping")
>>
>>   At this moment, vdso restoring code is disabled for arm/arm64 arch
>> in CRIU [2], so C/R is only working for !CONFIG_VDSO kernels. This patch
>> is aimed to fix that.
>>   The same hook may be introduced for arm64 kernel, but at this moment
>> arm64 vdso code is actively reworked by Kevin, so we can do it on top.
>>   Separately, I've refactored arch_remap hook out from ppc64 [3].
>>
>> [1]: https://marc.info/?i=1448455781-26660-1-git-send-email-cov@codeaurora.org
>> [2]: https://github.com/xemul/criu/blob/master/Makefile#L39
>> [3]: https://marc.info/?i=20161027170948.8279-1-dsafonov@virtuozzo.com
>>
>> Cc: Kevin Brodsky <kevin.brodsky@arm.com>
>> Cc: Christopher Covington <cov@codeaurora.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Oleg Nesterov <oleg@redhat.com>
>> Cc: Russell King <linux@armlinux.org.uk>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-mm@kvack.org
>> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
>> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>>  arch/arm/kernel/vdso.c | 21 +++++++++++++++++++++
>>  1 file changed, 21 insertions(+)
>>
>> diff --git a/arch/arm/kernel/vdso.c b/arch/arm/kernel/vdso.c
>> index 53cf86cf2d1a..d1001f87c2f6 100644
>> --- a/arch/arm/kernel/vdso.c
>> +++ b/arch/arm/kernel/vdso.c
>> @@ -54,8 +54,11 @@ static const struct vm_special_mapping vdso_data_mapping = {
>>  	.pages = &vdso_data_page,
>>  };
>>
>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>> +		struct vm_area_struct *new_vma);
>>  static struct vm_special_mapping vdso_text_mapping __ro_after_init = {
>>  	.name = "[vdso]",
>> +	.mremap = vdso_mremap,
>>  };
>>
>>  struct elfinfo {
>> @@ -254,6 +257,24 @@ void arm_install_vdso(struct mm_struct *mm, unsigned long addr)
>>  		mm->context.vdso = addr;
>>  }
>>
>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>> +		struct vm_area_struct *new_vma)
>> +{
>> +	unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
>> +	unsigned long vdso_size = (vdso_total_pages - 1) << PAGE_SHIFT;
>> +
>> +	/* Disallow partial vDSO blob remap */
>> +	if (vdso_size != new_size)
>> +		return -EINVAL;
>> +
>> +	if (WARN_ON_ONCE(current->mm != new_vma->vm_mm))
>> +		return -EFAULT;
>> +
>> +	current->mm->context.vdso = new_vma->vm_start;
>> +
>> +	return 0;
>> +}
>> +
>>  static void vdso_write_begin(struct vdso_data *vdata)
>>  {
>>  	++vdso_data->seq_count;
>>
>
> What do you think about putting this code somewhere generic (not under
> arch/*), so that powerpc and arm64 can reuse it once the cosmetic changes
> to make them compatible are made? My thought was that it could be defined
> underneath CONFIG_GENERIC_VDSO, which architectures could select as they
> became compatible.

Hi Chistopher,

Well, I don't think we won something out of generalization of simple 
assignment for context.vdso pointer accross arches. And a need to rename
vdso over arches for saving one single line?
Also I don't like a bit this arch_mremap hook and need to nullify
vdso pointer.

But, anyway, I don't mind if your patches got applied instead - this
unability to move vdso prevent's to support vdso vma C/R, as you know ;)

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
