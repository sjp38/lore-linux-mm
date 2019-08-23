Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F5EBC3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 15:36:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2076021019
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 15:36:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2076021019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8196B04A6; Fri, 23 Aug 2019 11:36:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A891E6B04A7; Fri, 23 Aug 2019 11:36:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99EFB6B04A8; Fri, 23 Aug 2019 11:36:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0175.hostedemail.com [216.40.44.175])
	by kanga.kvack.org (Postfix) with ESMTP id 793236B04A6
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:36:11 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3FE39824CA3F
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 15:36:11 +0000 (UTC)
X-FDA: 75854093742.28.rat02_52cb34606515d
X-HE-Tag: rat02_52cb34606515d
X-Filterd-Recvd-Size: 3776
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 15:36:08 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B44D528;
	Fri, 23 Aug 2019 08:36:07 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 94E0B3F246;
	Fri, 23 Aug 2019 08:36:06 -0700 (PDT)
Subject: Re: cleanup the walk_page_range interface
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?Q?Thomas_Hellstr=c3=b6m?= <thomas@shipmail.org>,
 Jerome Glisse <jglisse@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190823134308.GH12847@mellanox.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <ad8179e2-f404-1e48-e366-fcd1f139a202@arm.com>
Date: Fri, 23 Aug 2019 16:36:05 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190823134308.GH12847@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/08/2019 14:43, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 11:27:51PM -0700, Christoph Hellwig wrote:
>> On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
>>> On Thu, Aug 8, 2019 at 8:42 AM Christoph Hellwig <hch@lst.de> wrote:
>>>>
>>>> this series is based on a patch from Linus to split the callbacks
>>>> passed to walk_page_range and walk_page_vma into a separate structure
>>>> that can be marked const, with various cleanups from me on top.
>>>
>>> The whole series looks good to me. Ack.
>>>
>>>> Note that both Thomas and Steven have series touching this area pending,
>>>> and there are a couple consumer in flux too - the hmm tree already
>>>> conflicts with this series, and I have potential dma changes on top of
>>>> the consumers in Thomas and Steven's series, so we'll probably need a
>>>> git tree similar to the hmm one to synchronize these updates.
>>>
>>> I'd be willing to just merge this now, if that helps. The conversion
>>> is mechanical, and my only slight worry would be that at least for my
>>> original patch I didn't build-test the (few) non-x86
>>> architecture-specific cases. But I did end up looking at them fairly
>>> closely  (basically using some grep/sed scripts to see that the
>>> conversions I did matched the same patterns). And your changes look
>>> like obvious improvements too where any mistake would have been caught
>>> by the compiler.
>>>
>>> So I'm not all that worried from a functionality standpoint, and if
>>> this will help the next merge window, I'll happily pull now.
>>
>> So what is the plan forward?  Probably a little late for 5.3,
>> so queue it up in -mm for 5.4 and deal with the conflicts in at least
>> hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?
> 
> Did we make a decision on this? Due to travel & LPC I'd like to
> finalize the hmm tree next week.

I was planning on rebasing my series on this and posting it for 5.4 - I
hadn't actually realised this hasn't been picked up yet. I haven't had
much time to look at this recently.

FWIW you can add for the series:

Acked-by: Steven Price <steven.price@arm.com>

Steve

