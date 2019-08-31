Return-Path: <SRS0=LT00=W3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01DCDC3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 01:50:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C144323429
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 01:50:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C144323429
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59F0B6B0006; Fri, 30 Aug 2019 21:50:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 550B16B0008; Fri, 30 Aug 2019 21:50:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 464976B000A; Fri, 30 Aug 2019 21:50:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9296B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:50:10 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B0EFD180AD804
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 01:50:09 +0000 (UTC)
X-FDA: 75881042538.08.list93_1e5ee4866fb4b
X-HE-Tag: list93_1e5ee4866fb4b
X-Filterd-Recvd-Size: 4623
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 01:50:08 +0000 (UTC)
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 91D7F459F726074383CA;
	Sat, 31 Aug 2019 09:50:03 +0800 (CST)
Received: from [127.0.0.1] (10.184.39.28) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Sat, 31 Aug 2019
 09:50:02 +0800
Subject: Re: [PATCH] arm: fix page faults in do_alignment
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
 <20190830133522.GZ13294@shell.armlinux.org.uk>
CC: <ebiederm@xmission.com>, <kstewart@linuxfoundation.org>,
	<gregkh@linuxfoundation.org>, <gustavo@embeddedor.com>,
	<bhelgaas@google.com>, <tglx@linutronix.de>, <sakari.ailus@linux.intel.com>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
Message-ID: <5D69D239.2080908@huawei.com>
Date: Sat, 31 Aug 2019 09:49:45 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.1.0
MIME-Version: 1.0
In-Reply-To: <20190830133522.GZ13294@shell.armlinux.org.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.39.28]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/8/30 21:35, Russell King - ARM Linux admin wrote:
> On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
>> The function do_alignment can handle misaligned address for user and
>> kernel space. If it is a userspace access, do_alignment may fail on
>> a low-memory situation, because page faults are disabled in
>> probe_kernel_address.
>>
>> Fix this by using __copy_from_user stead of probe_kernel_address.
>>
>> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
>> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> 
> NAK.
> 
> The "scheduling while atomic warning in alignment handling code" is
> caused by fixing up the page fault while trying to handle the
> mis-alignment fault generated from an instruction in atomic context.

__might_sleep is called in the function  __get_user which lead to that bug.
And that bug is triggered in a kernel space. Page fault can not be generated.
Right?

> Your patch re-introduces that bug.
> 
>> ---
>>  arch/arm/mm/alignment.c | 16 +++++++++++++---
>>  1 file changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
>> index 04b3643..2ccabd3 100644
>> --- a/arch/arm/mm/alignment.c
>> +++ b/arch/arm/mm/alignment.c
>> @@ -774,6 +774,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>>  	unsigned long instr = 0, instrptr;
>>  	int (*handler)(unsigned long addr, unsigned long instr, struct pt_regs *regs);
>>  	unsigned int type;
>> +	mm_segment_t fs;
>>  	unsigned int fault;
>>  	u16 tinstr = 0;
>>  	int isize = 4;
>> @@ -784,16 +785,22 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>>  
>>  	instrptr = instruction_pointer(regs);
>>  
>> +	fs = get_fs();
>> +	set_fs(KERNEL_DS);
>>  	if (thumb_mode(regs)) {
>>  		u16 *ptr = (u16 *)(instrptr & ~1);
>> -		fault = probe_kernel_address(ptr, tinstr);
>> +		fault = __copy_from_user(tinstr,
>> +				(__force const void __user *)ptr,
>> +				sizeof(tinstr));
>>  		tinstr = __mem_to_opcode_thumb16(tinstr);
>>  		if (!fault) {
>>  			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
>>  			    IS_T32(tinstr)) {
>>  				/* Thumb-2 32-bit */
>>  				u16 tinst2 = 0;
>> -				fault = probe_kernel_address(ptr + 1, tinst2);
>> +				fault = __copy_from_user(tinst2,
>> +						(__force const void __user *)(ptr+1),
>> +						sizeof(tinst2));
>>  				tinst2 = __mem_to_opcode_thumb16(tinst2);
>>  				instr = __opcode_thumb32_compose(tinstr, tinst2);
>>  				thumb2_32b = 1;
>> @@ -803,10 +810,13 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>>  			}
>>  		}
>>  	} else {
>> -		fault = probe_kernel_address((void *)instrptr, instr);
>> +		fault = __copy_from_user(instr,
>> +				(__force const void __user *)instrptr,
>> +				sizeof(instr));
>>  		instr = __mem_to_opcode_arm(instr);
>>  	}
>>  
>> +	set_fs(fs);
>>  	if (fault) {
>>  		type = TYPE_FAULT;
>>  		goto bad_or_fault;
>> -- 
>> 1.8.3.1
>>
>>
> 



