Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F1EC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 23:50:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E7AE2183E
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 23:50:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="aoPsBJ3H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E7AE2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F16D6B0003; Sat, 23 Mar 2019 19:50:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A18D6B0006; Sat, 23 Mar 2019 19:50:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 569586B0007; Sat, 23 Mar 2019 19:50:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 302C06B0003
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 19:50:19 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x18so5425576qkf.8
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 16:50:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KE7DlPfHZP9lYhu4pJMVJZKXfpGzerCGiEw6d7YHA7E=;
        b=VFIw6FfaelzbaS03kFMQf7K0C99udNyaul+hKuMFqG5XoDgXEGhbSXso/x3ssFTjhS
         mH23VU0ZbkekGEEvc8e2B8Ljb5Dw5+toJEWj843ZYjnJPFHpTPr9XA9ni1Mq74AtGGbE
         bPhQl2PbWemA0x0fXybI6mA03V6o0kACg5mWkztHX7BW3FyeTDSSsF5uQ6ea7U1wcJxk
         eyX0V89zOjKuCPQn75sh2xfqRpoLMV+mdWUVJzUzdYHop2yvtxjAhtApWhzBINl7bblK
         NQWL4yr3dsS6iViBH9q/wa5KU74vNIv20kZ6T5ydgZf6mSqXKcuPT7dYhPiVLdo8Htza
         J0Tg==
X-Gm-Message-State: APjAAAUjeno/YP14gaRAAjaUymdac5fhsoslG1cFpDb3S+ty4NzPwCq4
	yzWxb4vG8EHONVjMolA2SRyouUV7QKYbZo5oJaXSwmAvPFS0JeZC4BZwjZRebgy1fc9QDI2dbQf
	dyepIasoXIJpkogBsdpCA8ykpKsCzgZyqF+pxhC22Bmm8aa1/NrKof23zqsYmfVMwrg==
X-Received: by 2002:a0c:b6d1:: with SMTP id h17mr14594357qve.135.1553385018779;
        Sat, 23 Mar 2019 16:50:18 -0700 (PDT)
X-Received: by 2002:a0c:b6d1:: with SMTP id h17mr14594323qve.135.1553385017929;
        Sat, 23 Mar 2019 16:50:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553385017; cv=none;
        d=google.com; s=arc-20160816;
        b=C4shXR901SKaln/wVaWY4538HOuu0VjLXaU6YSNh3X+STsxdPIsB2vTDPxwgydg6Uc
         dYoNLFBqSCSkNegmz2SfQhHOC/L5mUZPqohU6qIPr57yFEE514cI/OyWBbt8YDi52c/z
         OlwatD0nXd89CDkcxPy0ZUyDZJ+Pe3EIo3wfa7XyJttTUAiCboDA83SlWmKVv2BWEpGh
         C1cNqzLYgap7SXGiovXvBSTj1XtUhKgMTpltbFn5olzpjSynZ+T/JoCtw5L4dWvQQBcj
         JhpLoFqrU3BnTBKmaCVd6foWexPFz/K+GPGpPExiK7f1ykxSUfT6DLuopR5hwgO+tcxT
         XsPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=KE7DlPfHZP9lYhu4pJMVJZKXfpGzerCGiEw6d7YHA7E=;
        b=XbToAmAaLnIG/7vSFOlA3P5nwcV4OK7FJJIX1y66kqNWh77mrGsQpPgGHdRW8Y0Y9X
         Si1YDZXiZPqTDRB9eVQX5+w/igOVkpUbqW4Jow+jY3drWvb8vHJUn4U2T/nlsNBrB4l9
         e6rOkZz09HH47V57k4lf5Gd6lOXbPRvIwX1sucsMxOS/vcCWg9QODdLx0PicUcK+hurb
         jrzulkLtL1w3nGd+GpRuQjQStShu0DNqQnKksxV2RN6+lIhPVtFGRAzUo9sLNQpU7vq5
         f/9EKGSXJbMiasEra+W2pdw/KFrDFCyatpVfomizB7krfja2eW6LNEx4BwsBQxOBUb4o
         Virw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aoPsBJ3H;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w26sor1138206qkf.5.2019.03.23.16.50.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Mar 2019 16:50:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aoPsBJ3H;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=KE7DlPfHZP9lYhu4pJMVJZKXfpGzerCGiEw6d7YHA7E=;
        b=aoPsBJ3HboqFKl1Zy4tfDYlTA9S+KQNIRne06mVr+NGg9mHym5dRM7LkrgKA/5mWaf
         vFnyQNWp4bX63HRW1N5otL5ESU/7VEyxjgqI0vR7SkqMpB7Is1ezg2v76bswYN+2uWif
         UQ2MZB8+M/Ci218KiHg9sUtU6ddYhJ7blFujuqqiCw/Fw/Qmq08TSx/aOFIzon64nJs4
         h/27wi+HnFAI2SFlKOM02rOdQ9amtKXe62cASRGmcGqh6jt7CwLetWHl9HoCtJWq2Jtp
         NCBtO7E0B4310Ueri2mmnmBWS1YHGncqEbmx8Ar9ibGgbzWl41nKxUkbsiTO8FXYdIc8
         dilA==
X-Google-Smtp-Source: APXvYqyzWi/tn/TA3xHiE+lN/n0tde7ctFZUYuPPXxfLZZMZH/ozzvjjfCd9vyw1Vwwm2qwgl3X4Mw==
X-Received: by 2002:a37:c15:: with SMTP id 21mr13642963qkm.50.1553385017465;
        Sat, 23 Mar 2019 16:50:17 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id a75sm6417706qkg.84.2019.03.23.16.50.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Mar 2019 16:50:16 -0700 (PDT)
Subject: Re: page cache: Store only head pages in i_pages
To: Matthew Wilcox <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
Date: Sat, 23 Mar 2019 19:50:15 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190323033852.GC10344@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/22/19 11:38 PM, Matthew Wilcox wrote:
> On Fri, Mar 22, 2019 at 04:12:48PM -0400, Qian Cai wrote:
>> FYI, every thing involve swapping seems triggered a panic now since this patch.
> 
> Thanks for the report!  Does this fix it?
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 41858a3744b4..975aea9a49a5 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -335,6 +335,8 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> +	if (unlikely(PageSwapCache(page)))
> +		return page;
>  	VM_BUG_ON_PAGE(page->index > offset, page);
>  	VM_BUG_ON_PAGE(page->index + compound_nr(page) <= offset, page);
>  	return page - page->index + offset;

Yes, it works.

