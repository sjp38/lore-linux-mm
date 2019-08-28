Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C081C3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CECE42077B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:24:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CECE42077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 651F26B0005; Wed, 28 Aug 2019 09:24:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 602806B000E; Wed, 28 Aug 2019 09:24:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F12F6B0010; Wed, 28 Aug 2019 09:24:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD876B0005
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 09:24:02 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D273E181AC9AE
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:24:01 +0000 (UTC)
X-FDA: 75871904682.04.glass58_5d4388cfca463
X-HE-Tag: glass58_5d4388cfca463
X-Filterd-Recvd-Size: 3936
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:24:00 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8DBF928;
	Wed, 28 Aug 2019 06:23:59 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 61DF03F246;
	Wed, 28 Aug 2019 06:23:58 -0700 (PDT)
Subject: Re: cleanup the walk_page_range interface
To: Jason Gunthorpe <jgg@mellanox.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Christoph Hellwig <hch@lst.de>, =?UTF-8?Q?Thomas_Hellstr=c3=b6m?=
 <thomas@shipmail.org>, Jerome Glisse <jglisse@redhat.com>,
 Linux-MM <linux-mm@kvack.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190823134308.GH12847@mellanox.com>
 <20190824222654.GA28766@infradead.org> <20190827013408.GC31766@mellanox.com>
 <20190827163431.65a284b295004d1ed258fbd5@linux-foundation.org>
 <20190827233619.GB28814@mellanox.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <1a0e8f03-d1c6-9325-1db3-2c3e2fd0f7d5@arm.com>
Date: Wed, 28 Aug 2019 14:23:57 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190827233619.GB28814@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/08/2019 00:36, Jason Gunthorpe wrote:
> On Tue, Aug 27, 2019 at 04:34:31PM -0700, Andrew Morton wrote:
>> On Tue, 27 Aug 2019 01:34:13 +0000 Jason Gunthorpe <jgg@mellanox.com> wrote:
>>
>>> On Sat, Aug 24, 2019 at 03:26:55PM -0700, Christoph Hellwig wrote:
>>>> On Fri, Aug 23, 2019 at 01:43:12PM +0000, Jason Gunthorpe wrote:
>>>>>> So what is the plan forward?  Probably a little late for 5.3,
>>>>>> so queue it up in -mm for 5.4 and deal with the conflicts in at least
>>>>>> hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?
>>>>>
>>>>> Did we make a decision on this? Due to travel & LPC I'd like to
>>>>> finalize the hmm tree next week.
>>>>
>>>> I don't think we've made any decision.  I'd still love to see this
>>>> in hmm.git.  It has a minor conflict, but I can resend a rebased
>>>> version.
>>>
>>> I'm looking at this.. The hmm conflict is easy enough to fix.
>>>
>>> But the compile conflict with these two patches in -mm requires some
>>> action from Andrew:
>>>
>>> commit 027b9b8fd9ee3be6b7440462102ec03a2d593213
>>> Author: Minchan Kim <minchan@kernel.org>
>>> Date:   Sun Aug 25 11:49:27 2019 +1000
>>>
>>>     mm: introduce MADV_PAGEOUT
>>>
>>> commit f227453a14cadd4727dd159782531d617f257001
>>> Author: Minchan Kim <minchan@kernel.org>
>>> Date:   Sun Aug 25 11:49:27 2019 +1000
>>>
>>>     mm: introduce MADV_COLD
>>>     
>>>     Patch series "Introduce MADV_COLD and MADV_PAGEOUT", v7.
>>>
>>> I'm inclined to suggest you send this series in the 2nd half of the
>>> merge window after this MADV stuff lands for least disruption? 
>>
>> Just merge it, I'll figure it out.  Probably by staging Minchan's
>> patches after linux-next.
> 
> Okay, I'll get it on a branch and merge it toward hmm.git tomorrow
> 
> Steven, do you need the branch as well for your patch series? Let me know

Since my series is (mostly) just refactoring I'm planning on rebasing it
after -rc1 and aim for v5.4 - I don't really have the time just now to
do that.

But please keep me in the loop because it'll reduce the surprises when I
do do the rebase.

Thanks,

Steve

