Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527B3C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 21:03:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16BE823429
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 21:03:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16BE823429
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7146B0006; Fri, 30 Aug 2019 17:03:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A71A6B0008; Fri, 30 Aug 2019 17:03:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8700E6B000A; Fri, 30 Aug 2019 17:03:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 66ADA6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 17:03:04 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 11251181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:03:04 +0000 (UTC)
X-FDA: 75880319088.14.shade05_8f16bd547df4f
X-HE-Tag: shade05_8f16bd547df4f
X-Filterd-Recvd-Size: 6855
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 21:03:03 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
	by out02.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.87)
	(envelope-from <ebiederm@xmission.com>)
	id 1i3o2v-0000Ro-4X; Fri, 30 Aug 2019 15:03:01 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=x220.xmission.com)
	by in02.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.87)
	(envelope-from <ebiederm@xmission.com>)
	id 1i3o2t-0005hU-RB; Fri, 30 Aug 2019 15:03:00 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Jing Xiangfeng <jingxiangfeng@huawei.com>,  kstewart@linuxfoundation.org,  gregkh@linuxfoundation.org,  gustavo@embeddedor.com,  bhelgaas@google.com,  tglx@linutronix.de,  sakari.ailus@linux.intel.com,  linux-arm-kernel@lists.infradead.org,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
	<20190830133522.GZ13294@shell.armlinux.org.uk>
	<87d0gmwi73.fsf@x220.int.ebiederm.org>
	<20190830203052.GG13294@shell.armlinux.org.uk>
Date: Fri, 30 Aug 2019 16:02:48 -0500
In-Reply-To: <20190830203052.GG13294@shell.armlinux.org.uk> (Russell King's
	message of "Fri, 30 Aug 2019 21:30:52 +0100")
Message-ID: <87y2zav01z.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1i3o2t-0005hU-RB;;;mid=<87y2zav01z.fsf@x220.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+heHAgu8YHz0osGVnQTuDyPwc40LRgIbA=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH] arm: fix page faults in do_alignment
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:

> On Fri, Aug 30, 2019 at 02:45:36PM -0500, Eric W. Biederman wrote:
>> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
>> 
>> > On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
>> >> The function do_alignment can handle misaligned address for user and
>> >> kernel space. If it is a userspace access, do_alignment may fail on
>> >> a low-memory situation, because page faults are disabled in
>> >> probe_kernel_address.
>> >> 
>> >> Fix this by using __copy_from_user stead of probe_kernel_address.
>> >> 
>> >> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
>> >> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
>> >
>> > NAK.
>> >
>> > The "scheduling while atomic warning in alignment handling code" is
>> > caused by fixing up the page fault while trying to handle the
>> > mis-alignment fault generated from an instruction in atomic context.
>> >
>> > Your patch re-introduces that bug.
>> 
>> And the patch that fixed scheduling while atomic apparently introduced a
>> regression.  Admittedly a regression that took 6 years to track down but
>> still.
>
> Right, and given the number of years, we are trading one regression for
> a different regression.  If we revert to the original code where we
> fix up, we will end up with people complaining about a "new" regression
> caused by reverting the previous fix.  Follow this policy and we just
> end up constantly reverting the previous revert.
>
> The window is very small - the page in question will have had to have
> instructions read from it immediately prior to the handler being entered,
> and would have had to be made "old" before subsequently being unmapped.

> Rather than excessively complicating the code and making it even more
> inefficient (as in your patch), we could instead retry executing the
> instruction when we discover that the page is unavailable, which should
> cause the page to be paged back in.

My patch does not introduce any inefficiencies.  It onlys moves the
check for user_mode up a bit.  My patch did duplicate the code.

> If the page really is unavailable, the prefetch abort should cause a
> SEGV to be raised, otherwise the re-execution should replace the page.
>
> The danger to that approach is we page it back in, and it gets paged
> back out before we're able to read the instruction indefinitely.

I would think either a little code duplication or a function that looks
at user_mode(regs) and picks the appropriate kind of copy to do would be
the best way to go.  Because what needs to happen in the two cases for
reading the instruction are almost completely different.

> However, as it's impossible for me to contact the submitter, anything
> I do will be poking about in the dark and without any way to validate
> that it does fix the problem, so I think apart from reviewing of any
> patches, there's not much I can do.

I didn't realize your emails to him were bouncing.  That is odd.  Mine
don't appear to be.

Eric

