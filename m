Return-Path: <SRS0=LT00=W3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42556C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 09:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E46AB23426
	for <linux-mm@archiver.kernel.org>; Sat, 31 Aug 2019 09:16:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E46AB23426
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5118F6B0006; Sat, 31 Aug 2019 05:16:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3BA6B0008; Sat, 31 Aug 2019 05:16:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9276B000A; Sat, 31 Aug 2019 05:16:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6A56B0006
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 05:16:50 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id AB894181AC9B4
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 09:16:49 +0000 (UTC)
X-FDA: 75882168138.13.sign95_149279eb902a
X-HE-Tag: sign95_149279eb902a
X-Filterd-Recvd-Size: 3768
Received: from huawei.com (szxga03-in.huawei.com [45.249.212.189])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 09:16:48 +0000 (UTC)
Received: from DGGEMM401-HUB.china.huawei.com (unknown [172.30.72.55])
	by Forcepoint Email with ESMTP id 9EF652CB9F286DE110CA;
	Sat, 31 Aug 2019 17:16:39 +0800 (CST)
Received: from dggeme764-chm.china.huawei.com (10.3.19.110) by
 DGGEMM401-HUB.china.huawei.com (10.3.20.209) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Sat, 31 Aug 2019 17:16:39 +0800
Received: from [127.0.0.1] (10.184.39.28) by dggeme764-chm.china.huawei.com
 (10.3.19.110) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.1591.10; Sat, 31
 Aug 2019 17:16:38 +0800
Subject: Re: [PATCH] arm: fix page faults in do_alignment
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
 <20190830133522.GZ13294@shell.armlinux.org.uk> <5D69D239.2080908@huawei.com>
 <20190831075524.GI13294@shell.armlinux.org.uk>
CC: <ebiederm@xmission.com>, <kstewart@linuxfoundation.org>,
	<gregkh@linuxfoundation.org>, <gustavo@embeddedor.com>,
	<bhelgaas@google.com>, <tglx@linutronix.de>, <sakari.ailus@linux.intel.com>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
Message-ID: <5D6A3AEC.7030709@huawei.com>
Date: Sat, 31 Aug 2019 17:16:28 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.1.0
MIME-Version: 1.0
In-Reply-To: <20190831075524.GI13294@shell.armlinux.org.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.39.28]
X-ClientProxiedBy: dggeme713-chm.china.huawei.com (10.1.199.109) To
 dggeme764-chm.china.huawei.com (10.3.19.110)
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/8/31 15:55, Russell King - ARM Linux admin wrote:
> On Sat, Aug 31, 2019 at 09:49:45AM +0800, Jing Xiangfeng wrote:
>> On 2019/8/30 21:35, Russell King - ARM Linux admin wrote:
>>> On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
>>>> The function do_alignment can handle misaligned address for user and
>>>> kernel space. If it is a userspace access, do_alignment may fail on
>>>> a low-memory situation, because page faults are disabled in
>>>> probe_kernel_address.
>>>>
>>>> Fix this by using __copy_from_user stead of probe_kernel_address.
>>>>
>>>> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
>>>> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
>>>
>>> NAK.
>>>
>>> The "scheduling while atomic warning in alignment handling code" is
>>> caused by fixing up the page fault while trying to handle the
>>> mis-alignment fault generated from an instruction in atomic context.
>>
>> __might_sleep is called in the function  __get_user which lead to that bug.
>> And that bug is triggered in a kernel space. Page fault can not be generated.
>> Right?
> 
> Your email is now fixed?

Yeah, I just checked the mailbox, it is normal now.

> 
> All of get_user(), __get_user(), copy_from_user() and __copy_from_user()
> _can_ cause a page fault, which might need to fetch the page from disk.
> All these four functions are equivalent as far as that goes - and indeed
> as are their versions that write as well.
> 
> If the page needs to come from disk, all of these functions _will_
> sleep.  If they are called from an atomic context, and the page fault
> handler needs to fetch data from disk, they will attempt to sleep,
> which will issue a warning.
> 
 I understand.

	Thanks


