Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53481C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14DF021E70
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:30:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14DF021E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C776B0007; Wed,  7 Aug 2019 10:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7959C6B0008; Wed,  7 Aug 2019 10:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65D616B000A; Wed,  7 Aug 2019 10:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 161AA6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 10:30:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so45127580edv.18
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 07:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OmNZf17ZKGN6g8JA/2I7YchHz7R0kl+zAp4OE7QfRr8=;
        b=s7uM+lA0LaNT5RGHCG0RQGMHuHTUx4RrZX6l8eUdJ8FpWBjbxqpY7V0Lt+VxibSpzQ
         TIsBJ4tW3jPDk3e+rfQd4GJViUoeKQATo+guN7GpHsUcywdpu6wrbpn+nbX1j7CckZsU
         5sdBusz28lcUs8ebUNvfU7mR9C4fMtyfj5jv2GOkWf4P71sdQ40/xAQLYiH6E4lGPhSs
         hnuDWpljFgJYTplMxD1cgur81Mat0oIJQnhpYK1ELfhyV3LiQgjbmvXT4GnqWXcDK2vG
         QogCwouTp8E5pb99fkGdSqjS+iHg1OnjmBjqrmZvf/XNgeKxqNiHe6FhUDR29fRt+3gE
         pk8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVaEBX91cbnjjL/9unvPTGs0ofiU+ik1EhzSzYWu0JU+NrS907M
	PgJ6+V6TsZfWbfX6pZo+h09vavqi4XFqniWAuQh6YIxm06c5gb5UGaxbmKNcekBIH83lIx0Daek
	kg9+Tx+96zNm2s1ISBIivVF1RHUvL1t5heKb1lOs69giVQpwRb9Dx/KuWnfYkSP/rZw==
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr10183861edy.160.1565188243669;
        Wed, 07 Aug 2019 07:30:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaKgzbxBbO/VeFhFLzg4DmK5c9eXRM5XnNWbQ51sBYPDQUeEu1YgA6kpvbJ6YV5UG1rOiI
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr10183760edy.160.1565188242764;
        Wed, 07 Aug 2019 07:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565188242; cv=none;
        d=google.com; s=arc-20160816;
        b=pO5lDijxt5Dws2W2y2e7V8SuYtInnNPJ4nSkH34uZJliIERcB1uqW75q6jsVghRqnM
         iJdOgsbYNCwgausP5ji2KAfMNt1v81R68AZDpp8yZEQocavLiO/SmvkpNhbGk6RTyhm6
         om6uw3syHjOCpJs6dPEred3IIlxndYgYKBhA6O4//uAnylPYFfVIfFGrDvpR0vqzMiEJ
         BP+ddeWRN7V2WcOaG0WI/jsjwlRVDv4FLBAp2+9/vdBj2T4aYeAj0NN1B9sThSpGcGQs
         mDsZBl0RBjVaVFKF0/N5l+geAlwyebm38cpKQhU0bfxL/9/GvGXT6kCauLrv2CWKTpfW
         jWnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=OmNZf17ZKGN6g8JA/2I7YchHz7R0kl+zAp4OE7QfRr8=;
        b=CP1JfVHfRBgPciJmhSFvVWrM3JRD4vAD/MtLian2xw1txIkoHmb48/FeKfUGFosCr5
         69Y9donaE5WaYJeaEhE5bSCIe8DYhzM8S0K8vsdBq7MFKEUHXvqSlFcmJicPWMQjM4n7
         c6j6GqWEJxSw3IY+amIjq83oTqTv/VyztntXaP7y5FVBxn4rWOw9ixsK7bd1VlLi2yeI
         yei3WtFfkEqAXVzxNGZI0wUXYecqwWWDZE8XcLeVTOT1OLIKn+DcQXFwvaPwOHa+taNZ
         zw/N8FG/O+1Ql0ZaNqMf3TUmp7q7B8nWa+Xcq+sZPZ3nd1vW0nkNAAJcd+8VSof9AOwb
         9VBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y9si32063552edb.262.2019.08.07.07.30.41
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 07:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5B8EE344;
	Wed,  7 Aug 2019 07:30:41 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C3CB23F706;
	Wed,  7 Aug 2019 07:30:39 -0700 (PDT)
Subject: Re: drm pull for v5.3-rc1
To: Matthew Wilcox <willy@infradead.org>,
 Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?= <thomas@shipmail.org>,
 Dave Airlie <airlied@gmail.com>, Thomas Hellstrom <thellstrom@vmware.com>,
 Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>,
 dri-devel <dri-devel@lists.freedesktop.org>,
 Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
References: <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
 <20190807064000.GC6002@infradead.org>
 <20190807141517.GA5482@bombadil.infradead.org>
From: Steven Price <steven.price@arm.com>
Message-ID: <62cbe523-e8a4-cdfd-90c2-80260cefa5de@arm.com>
Date: Wed, 7 Aug 2019 15:30:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807141517.GA5482@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/08/2019 15:15, Matthew Wilcox wrote:
> On Tue, Aug 06, 2019 at 11:40:00PM -0700, Christoph Hellwig wrote:
>> On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
>>> Has anyone looked at turning the interface inside-out?  ie something like:
>>>
>>> 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
>>>
>>> 	for_each_page_range(&state, page) {
>>> 		... do something with page ...
>>> 	}
>>>
>>> with appropriate macrology along the lines of:
>>>
>>> #define for_each_page_range(state, page)				\
>>> 	while ((page = page_range_walk_next(state)))
>>>
>>> Then you don't need to package anything up into structs that are shared
>>> between the caller and the iterated function.
>>
>> I'm not an all that huge fan of super magic macro loops.  But in this
>> case I don't see how it could even work, as we get special callbacks
>> for huge pages and holes, and people are trying to add a few more ops
>> as well.
> 
> We could have bits in the mm_walk_state which indicate what things to return
> and what things to skip.  We could (and probably should) also use different
> iterator names if people actually want to iterate different things.  eg
> for_each_pte_range(&state, pte) as well as for_each_page_range().
> 

The iterator approach could be awkward for the likes of my generic
ptdump implementation[1]. It would require an iterator which returns all
levels and allows skipping levels when required (to prevent KASAN
slowing things down too much). So something like:

start_walk_range(&state);
for_each_page_range(&state, page) {
	switch(page->level) {
	case PTE:
		...
	case PMD:
		if (...)
			skip_pmd(&state);
		...
	case HOLE:
		....
	...
	}
}
end_walk_range(&state);

It seems a little fragile - e.g. we wouldn't (easily) get type checking
that you are actually treating a PTE as a pte_t. The state mutators like
skip_pmd() also seem a bit clumsy.

Steve

[1]
https://lore.kernel.org/lkml/20190731154603.41797-20-steven.price@arm.com/

