Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F76C3A5A2
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 02:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7DC206BB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 02:18:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7DC206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A52FF6B0003; Tue,  3 Sep 2019 22:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A029A6B0006; Tue,  3 Sep 2019 22:18:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9192F6B0007; Tue,  3 Sep 2019 22:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB346B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 22:18:24 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1DE72180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:18:24 +0000 (UTC)
X-FDA: 75895628928.21.hope54_4934e6583054f
X-HE-Tag: hope54_4934e6583054f
X-Filterd-Recvd-Size: 8189
Received: from huawei.com (szxga08-in.huawei.com [45.249.212.255])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:18:22 +0000 (UTC)
Received: from DGGEMM403-HUB.china.huawei.com (unknown [172.30.72.56])
	by Forcepoint Email with ESMTP id BC21340E4231C3AB44ED;
	Wed,  4 Sep 2019 10:18:19 +0800 (CST)
Received: from dggeme764-chm.china.huawei.com (10.3.19.110) by
 DGGEMM403-HUB.china.huawei.com (10.3.20.211) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 10:18:11 +0800
Received: from [127.0.0.1] (10.184.39.28) by dggeme764-chm.china.huawei.com
 (10.3.19.110) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.1591.10; Wed, 4
 Sep 2019 10:18:11 +0800
Subject: Re: [PATCH] arm: fix page faults in do_alignment
To: "Eric W. Biederman" <ebiederm@xmission.com>, "Russell King - ARM Linux
 admin" <linux@armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
 <20190830133522.GZ13294@shell.armlinux.org.uk>
 <87d0gmwi73.fsf@x220.int.ebiederm.org>
 <20190830203052.GG13294@shell.armlinux.org.uk>
 <87y2zav01z.fsf@x220.int.ebiederm.org>
 <20190830222906.GH13294@shell.armlinux.org.uk>
 <87mufmioqv.fsf@x220.int.ebiederm.org>
CC: <kstewart@linuxfoundation.org>, <gregkh@linuxfoundation.org>,
	<gustavo@embeddedor.com>, <bhelgaas@google.com>, <tglx@linutronix.de>,
	<sakari.ailus@linux.intel.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
Message-ID: <5D6F1EC9.5070909@huawei.com>
Date: Wed, 4 Sep 2019 10:17:45 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.1.0
MIME-Version: 1.0
In-Reply-To: <87mufmioqv.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.39.28]
X-ClientProxiedBy: dggeme718-chm.china.huawei.com (10.1.199.114) To
 dggeme764-chm.china.huawei.com (10.3.19.110)
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/9/3 1:36, Eric W. Biederman wrote:
> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
> 
>> On Fri, Aug 30, 2019 at 04:02:48PM -0500, Eric W. Biederman wrote:
>>> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
>>>
>>>> On Fri, Aug 30, 2019 at 02:45:36PM -0500, Eric W. Biederman wrote:
>>>>> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
>>>>>
>>>>>> On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
>>>>>>> The function do_alignment can handle misaligned address for user and
>>>>>>> kernel space. If it is a userspace access, do_alignment may fail on
>>>>>>> a low-memory situation, because page faults are disabled in
>>>>>>> probe_kernel_address.
>>>>>>>
>>>>>>> Fix this by using __copy_from_user stead of probe_kernel_address.
>>>>>>>
>>>>>>> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
>>>>>>> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
>>>>>>
>>>>>> NAK.
>>>>>>
>>>>>> The "scheduling while atomic warning in alignment handling code" is
>>>>>> caused by fixing up the page fault while trying to handle the
>>>>>> mis-alignment fault generated from an instruction in atomic context.
>>>>>>
>>>>>> Your patch re-introduces that bug.
>>>>>
>>>>> And the patch that fixed scheduling while atomic apparently introduced a
>>>>> regression.  Admittedly a regression that took 6 years to track down but
>>>>> still.
>>>>
>>>> Right, and given the number of years, we are trading one regression for
>>>> a different regression.  If we revert to the original code where we
>>>> fix up, we will end up with people complaining about a "new" regression
>>>> caused by reverting the previous fix.  Follow this policy and we just
>>>> end up constantly reverting the previous revert.
>>>>
>>>> The window is very small - the page in question will have had to have
>>>> instructions read from it immediately prior to the handler being entered,
>>>> and would have had to be made "old" before subsequently being unmapped.
>>>
>>>> Rather than excessively complicating the code and making it even more
>>>> inefficient (as in your patch), we could instead retry executing the
>>>> instruction when we discover that the page is unavailable, which should
>>>> cause the page to be paged back in.
>>>
>>> My patch does not introduce any inefficiencies.  It onlys moves the
>>> check for user_mode up a bit.  My patch did duplicate the code.
>>>
>>>> If the page really is unavailable, the prefetch abort should cause a
>>>> SEGV to be raised, otherwise the re-execution should replace the page.
>>>>
>>>> The danger to that approach is we page it back in, and it gets paged
>>>> back out before we're able to read the instruction indefinitely.
>>>
>>> I would think either a little code duplication or a function that looks
>>> at user_mode(regs) and picks the appropriate kind of copy to do would be
>>> the best way to go.  Because what needs to happen in the two cases for
>>> reading the instruction are almost completely different.
>>
>> That is what I mean.  I'd prefer to avoid that with the large chunk of
>> code.  How about instead adding a local replacement for
>> probe_kernel_address() that just sorts out the reading, rather than
>> duplicating all the code to deal with thumb fixup.
> 
> So something like this should be fine?
> 
> Jing Xiangfeng can you test this please?  I think this fixes your issue
> but I don't currently have an arm development box where I could test this.
> 
Yes, I have tested and it can fix my issue in kernel 4.19.

> diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
> index 04b36436cbc0..b07d17ca0ae5 100644
> --- a/arch/arm/mm/alignment.c
> +++ b/arch/arm/mm/alignment.c
> @@ -767,6 +767,23 @@ do_alignment_t32_to_handler(unsigned long *pinstr, struct pt_regs *regs,
>  	return NULL;
>  }
>  
> +static inline unsigned long
> +copy_instr(bool umode, void *dst, unsigned long instrptr, size_t size)
> +{
> +	unsigned long result;
> +	if (umode) {
> +		void __user *src = (void *)instrptr;
> +		result = copy_from_user(dst, src, size);
> +	} else {
> +		void *src = (void *)instrptr;
> +		result = probe_kernel_read(dst, src, size);
> +	}
> +	/* Convert short reads into -EFAULT */
> +	if ((result >= 0) && (result < size))
> +		result = -EFAULT;
> +	return result;
> +}
> +
>  static int
>  do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  {
> @@ -778,22 +795,24 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  	u16 tinstr = 0;
>  	int isize = 4;
>  	int thumb2_32b = 0;
> +	bool umode;
>  
>  	if (interrupts_enabled(regs))
>  		local_irq_enable();
>  
>  	instrptr = instruction_pointer(regs);
> +	umode = user_mode(regs);
>  
>  	if (thumb_mode(regs)) {
> -		u16 *ptr = (u16 *)(instrptr & ~1);
> -		fault = probe_kernel_address(ptr, tinstr);
> +		unsigned long tinstrptr = instrptr & ~1;
> +		fault = copy_instr(umode, &tinstr, tinstrptr, 2);
>  		tinstr = __mem_to_opcode_thumb16(tinstr);
>  		if (!fault) {
>  			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
>  			    IS_T32(tinstr)) {
>  				/* Thumb-2 32-bit */
>  				u16 tinst2 = 0;
> -				fault = probe_kernel_address(ptr + 1, tinst2);
> +				fault = copy_instr(umode, &tinst2, tinstrptr + 2, 2);
>  				tinst2 = __mem_to_opcode_thumb16(tinst2);
>  				instr = __opcode_thumb32_compose(tinstr, tinst2);
>  				thumb2_32b = 1;
> @@ -803,7 +822,7 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  			}
>  		}
>  	} else {
> -		fault = probe_kernel_address((void *)instrptr, instr);
> +		fault = copy_instr(umode, &instr, instrptr, 4);
>  		instr = __mem_to_opcode_arm(instr);
>  	}
>  
> @@ -812,7 +831,7 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
>  		goto bad_or_fault;
>  	}
>  
> -	if (user_mode(regs))
> +	if (umode)
>  		goto user;
>  
>  	ai_sys += 1;
> 
> .
> 



