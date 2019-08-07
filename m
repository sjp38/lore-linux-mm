Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BDD8C32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:32:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 366EA22296
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:32:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 366EA22296
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963916B0003; Wed,  7 Aug 2019 11:32:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914BC6B0006; Wed,  7 Aug 2019 11:32:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B5E36B0007; Wed,  7 Aug 2019 11:32:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCC06B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:32:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so56332161edx.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:32:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zxf6XN/biAMtxrk5NqSSYToLgatnIlo8JOgL2S7Co70=;
        b=sl7xk3DIIlhaF0jRWrWKT5AMYJ4WB79JwwFKQyqfwfe8oiJtUP4WDZK7aoNlEAAu73
         wEWvwaXSVVAA4gT86/gCTEQQVMP+OrB98flushMARyG4jYvnlFOe68ilOsme5cHgk6I3
         TPL+TsdjE4VQJI4CzdY6aucLO437ERWfN5kZT8Dh4JFK3Tuy3/z9NTFwcf9WbNrjjwFM
         r7TyV1yL5ar4UrQK1ifsn7hDFmPBcBDC9Y9iVF1XvjZpI/Jd+Q7AgVWKMFfs6p0TU7EH
         zrE+Iu8KKbpjYXsRmBDHKbt5MGEFwdecWd6Y9gvwEzbgAra5lMvgIhWQbBuET6NZdwRa
         pRnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXk7SrBk97y3B0s+urVqh2dnvlkqAa7OBXc/TKHRNFabMmYsBao
	ctTS964IERrkrBs6HG5Js3+J4y3NpkW6mmgeAgwreWPd4J6ArvLam5bftzSdvTZ9bLjcYgt67cQ
	uTMaZJFDO+JPGFMVq+9Vas83RgX1Grxhf9TFJKTaWfSpPjaZXSNcgkD5h99klIDBoxQ==
X-Received: by 2002:a17:906:1997:: with SMTP id g23mr2525033ejd.197.1565191976714;
        Wed, 07 Aug 2019 08:32:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF2hqOel4dCNxhXv435OKkRHswdCK34QwDJ5PNGCdmfUp+z4Qs+qbT32y+c2iNrc6DIru7
X-Received: by 2002:a17:906:1997:: with SMTP id g23mr2524949ejd.197.1565191975741;
        Wed, 07 Aug 2019 08:32:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565191975; cv=none;
        d=google.com; s=arc-20160816;
        b=lYLJ6vcqG5vujBN7lzOZsCop0N3wItJMhiCj1g/p51IplBJCJmf1gbQh31ArvNWo2G
         HYZZ9XXM2vlmSGfPzBlY5YHPETXK9VI7fuji2LOwirDz7La+kYeKyu91DE0bne4t9W3o
         jIt2Oo14WuX7X16hkO9949LRsWuTE8qduu2ahFpOgdghc3F/LFMNPgKwcUCbFaUgXUAQ
         YjKQ2d6tTqP+e7TR00aadrOuGU8x/2Bh2RgncEiKdfU0snshL10gpUROkgK1Z7fpkkGk
         FGGkSEXHGRYm8k2nHFnNeiDVkpyKXb/wQJVDPsVIbRt08+kdpmRgfxHDIQcTONj4uevN
         SZjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zxf6XN/biAMtxrk5NqSSYToLgatnIlo8JOgL2S7Co70=;
        b=RXT7DWgpYKk1Wdvk7ibvSCPOvxy4xM7p0h5r3N4a+LHNNVCzCJkHDmH1uftI7NZ2Wu
         SJ9i+CWOYlKulx1PjoP5rvEpVPG4f9fLYPW/GwQYxL9kYLVh3733O63g8XfJSgvV08Ik
         69T8G9lmvcl894ZtBL0pdN8kVz0nZfy9rlLyGV9szqcBz2l43zM/zronLI+rrMS7bNiP
         +KZXhhXYevNa6Hcf+O7vWwhfuleYb+wbHegCMbaYx+bj643q7zkQa/Jj95fJEofjlPoD
         66MWL4nVFy0odRFlbPV/of2+KT52Zj1BNMkjdy4JcAXeyDULA8gJwMqpYffHsuiUwTTw
         1VGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id s18si34896997edd.291.2019.08.07.08.32.55
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 08:32:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B7905344;
	Wed,  7 Aug 2019 08:32:54 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2C9A53F706;
	Wed,  7 Aug 2019 08:32:53 -0700 (PDT)
Subject: Re: drm pull for v5.3-rc1
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?= <thomas@shipmail.org>,
 Dave Airlie <airlied@gmail.com>, Thomas Hellstrom <thellstrom@vmware.com>,
 Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>,
 dri-devel <dri-devel@lists.freedesktop.org>,
 Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
References: <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
 <20190807064000.GC6002@infradead.org>
 <20190807141517.GA5482@bombadil.infradead.org>
 <62cbe523-e8a4-cdfd-90c2-80260cefa5de@arm.com>
 <20190807145601.GB5482@bombadil.infradead.org>
From: Steven Price <steven.price@arm.com>
Message-ID: <4b9ea419-571b-93ab-ee52-811e52c0ae91@arm.com>
Date: Wed, 7 Aug 2019 16:32:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807145601.GB5482@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/08/2019 15:56, Matthew Wilcox wrote:
> On Wed, Aug 07, 2019 at 03:30:38PM +0100, Steven Price wrote:
>> On 07/08/2019 15:15, Matthew Wilcox wrote:
>>> On Tue, Aug 06, 2019 at 11:40:00PM -0700, Christoph Hellwig wrote:
>>>> On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
>>>>> Has anyone looked at turning the interface inside-out?  ie something like:
>>>>>
>>>>> 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
>>>>>
>>>>> 	for_each_page_range(&state, page) {
>>>>> 		... do something with page ...
>>>>> 	}
>>>>>
>>>>> with appropriate macrology along the lines of:
>>>>>
>>>>> #define for_each_page_range(state, page)				\
>>>>> 	while ((page = page_range_walk_next(state)))
>>>>>
>>>>> Then you don't need to package anything up into structs that are shared
>>>>> between the caller and the iterated function.
>>>>
>>>> I'm not an all that huge fan of super magic macro loops.  But in this
>>>> case I don't see how it could even work, as we get special callbacks
>>>> for huge pages and holes, and people are trying to add a few more ops
>>>> as well.
>>>
>>> We could have bits in the mm_walk_state which indicate what things to return
>>> and what things to skip.  We could (and probably should) also use different
>>> iterator names if people actually want to iterate different things.  eg
>>> for_each_pte_range(&state, pte) as well as for_each_page_range().
>>>
>>
>> The iterator approach could be awkward for the likes of my generic
>> ptdump implementation[1]. It would require an iterator which returns all
>> levels and allows skipping levels when required (to prevent KASAN
>> slowing things down too much). So something like:
>>
>> start_walk_range(&state);
>> for_each_page_range(&state, page) {
>> 	switch(page->level) {
>> 	case PTE:
>> 		...
>> 	case PMD:
>> 		if (...)
>> 			skip_pmd(&state);
>> 		...
>> 	case HOLE:
>> 		....
>> 	...
>> 	}
>> }
>> end_walk_range(&state);
>>
>> It seems a little fragile - e.g. we wouldn't (easily) get type checking
>> that you are actually treating a PTE as a pte_t. The state mutators like
>> skip_pmd() also seem a bit clumsy.
> 
> Once you're on-board with using a state structure, you can use it in all
> kinds of fun ways.  For example:
> 
> struct mm_walk_state {
> 	struct mm_struct *mm;
> 	unsigned long start;
> 	unsigned long end;
> 	unsigned long curr;
> 	p4d_t p4d;
> 	pud_t pud;
> 	pmd_t pmd;
> 	pte_t pte;
> 	enum page_entry_size size;
> 	int flags;
> };
> 
> For this user, I'd expect something like ...
> 
> 	DECLARE_MM_WALK_FLAGS(state, mm, start, end,
> 				MM_WALK_HOLES | MM_WALK_ALL_SIZES);
> 
> 	walk_each_pte(state) {
> 		switch (state->size) {
> 		case PE_SIZE_PTE:
> 			... 
> 		case PE_SIZE_PMD:
> 			if (...(state->pmd))
> 				continue;

You need to be able to signal whether you want to descend into the PMD
or skip the entire part of the tree. This was my skip_pmd() function above.

> 		...
> 		}
> 	}
> 
> There's no need to have start / end walk function calls.
> 

You've got a start walk function (it's your DECLARE_MM_WALK_FLAGS
above). The end walk I agree I think you don't actually need it since
struct mm_walk_state contains all the state.

Steve

