Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DFEFC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BBD023405
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:48:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="SWf/M74K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BBD023405
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E70046B0006; Fri, 30 Aug 2019 09:48:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E21216B0008; Fri, 30 Aug 2019 09:48:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D35966B000A; Fri, 30 Aug 2019 09:48:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id B2CBE6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:48:51 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4F54382437CF
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:48:51 +0000 (UTC)
X-FDA: 75879224862.04.space67_876b06175a75c
X-HE-Tag: space67_876b06175a75c
X-Filterd-Recvd-Size: 6456
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk [78.32.30.218])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:48:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3eifwY/5zE6nCnZ1a23bExwsvLi8xvyrQfUlmgCq+N4=; b=SWf/M74KjJGQ+0qWoqQqqcu/w
	FdcY9GuJkV90qZPrxiZiQbScX4eNkPxI/XUimR/iQAEKiTTRHRyftu5Aw4GEeang1af1Gjr63bPv3
	VCTseUldgs7tZ8IQM+7kHxg0HCnZhfEq4mLuZpFfVo9fcDQIQBj1vDGa8ZEQoJWP6PR5AqO7Vmy6k
	0RHCdl4ZYHq+GAcpvpCywSCYWwwamwfooWieT9BSAJB3CtIvcZWh9IQgfeDuy50iRy/atY/PMg4Cf
	TsdL2hglDBsMbYD7IeIyHnsvTyYLIa+l8Sf2QW01GvtTHwh4jw4S4Y2HLnArfOD4hwy/LCIroRIZT
	cNA3Kv3ng==;
Received: from shell.armlinux.org.uk ([2002:4e20:1eda:1:5054:ff:fe00:4ec]:35310)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1i3hGR-00079z-DU; Fri, 30 Aug 2019 14:48:31 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1i3hGP-0000BO-2I; Fri, 30 Aug 2019 14:48:29 +0100
Date: Fri, 30 Aug 2019 14:48:29 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Jing Xiangfeng <jingxiangfeng@huawei.com>
Cc: kstewart@linuxfoundation.org, gustavo@embeddedor.com,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, ebiederm@xmission.com,
	sakari.ailus@linux.intel.com, bhelgaas@google.com,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] arm: fix page faults in do_alignment
Message-ID: <20190830134828.GC13294@shell.armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
 <20190830133522.GZ13294@shell.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830133522.GZ13294@shell.armlinux.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please fix your email.

  jingxiangfeng@huawei.com
      host mx7.huawei.com [168.195.93.46]
      SMTP error from remote mail server after pipelined DATA:
      554 5.7.1 spf check result is none

SPF is *not* required for email.

If you wish to impose such restrictions on email, then I reserve the
right to ignore your patches until this issue is resolved! ;)

On Fri, Aug 30, 2019 at 02:35:22PM +0100, Russell King - ARM Linux admin wrote:
> On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
> > The function do_alignment can handle misaligned address for user and
> > kernel space. If it is a userspace access, do_alignment may fail on
> > a low-memory situation, because page faults are disabled in
> > probe_kernel_address.
> > 
> > Fix this by using __copy_from_user stead of probe_kernel_address.
> > 
> > Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
> > Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> 
> NAK.
> 
> The "scheduling while atomic warning in alignment handling code" is
> caused by fixing up the page fault while trying to handle the
> mis-alignment fault generated from an instruction in atomic context.
> 
> Your patch re-introduces that bug.
> 
> > ---
> >  arch/arm/mm/alignment.c | 16 +++++++++++++---
> >  1 file changed, 13 insertions(+), 3 deletions(-)
> > 
> > diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
> > index 04b3643..2ccabd3 100644
> > --- a/arch/arm/mm/alignment.c
> > +++ b/arch/arm/mm/alignment.c
> > @@ -774,6 +774,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
> >  	unsigned long instr = 0, instrptr;
> >  	int (*handler)(unsigned long addr, unsigned long instr, struct pt_regs *regs);
> >  	unsigned int type;
> > +	mm_segment_t fs;
> >  	unsigned int fault;
> >  	u16 tinstr = 0;
> >  	int isize = 4;
> > @@ -784,16 +785,22 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
> >  
> >  	instrptr = instruction_pointer(regs);
> >  
> > +	fs = get_fs();
> > +	set_fs(KERNEL_DS);
> >  	if (thumb_mode(regs)) {
> >  		u16 *ptr = (u16 *)(instrptr & ~1);
> > -		fault = probe_kernel_address(ptr, tinstr);
> > +		fault = __copy_from_user(tinstr,
> > +				(__force const void __user *)ptr,
> > +				sizeof(tinstr));
> >  		tinstr = __mem_to_opcode_thumb16(tinstr);
> >  		if (!fault) {
> >  			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
> >  			    IS_T32(tinstr)) {
> >  				/* Thumb-2 32-bit */
> >  				u16 tinst2 = 0;
> > -				fault = probe_kernel_address(ptr + 1, tinst2);
> > +				fault = __copy_from_user(tinst2,
> > +						(__force const void __user *)(ptr+1),
> > +						sizeof(tinst2));
> >  				tinst2 = __mem_to_opcode_thumb16(tinst2);
> >  				instr = __opcode_thumb32_compose(tinstr, tinst2);
> >  				thumb2_32b = 1;
> > @@ -803,10 +810,13 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
> >  			}
> >  		}
> >  	} else {
> > -		fault = probe_kernel_address((void *)instrptr, instr);
> > +		fault = __copy_from_user(instr,
> > +				(__force const void __user *)instrptr,
> > +				sizeof(instr));
> >  		instr = __mem_to_opcode_arm(instr);
> >  	}
> >  
> > +	set_fs(fs);
> >  	if (fault) {
> >  		type = TYPE_FAULT;
> >  		goto bad_or_fault;
> > -- 
> > 1.8.3.1
> > 
> > 
> 
> -- 
> RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

