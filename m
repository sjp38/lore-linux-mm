Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9908DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:05:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40BE52082C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:05:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="0cz3WNC1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40BE52082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85AA26B000A; Fri, 14 Jun 2019 07:05:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80B126B000D; Fri, 14 Jun 2019 07:05:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D2836B000E; Fri, 14 Jun 2019 07:05:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4056B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:05:14 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t141so420973wmt.7
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:05:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=E87CowIp+htiYTGS6CsPTPTEGv8n2gNXy2U9+KLGIFs=;
        b=GH1/hKY0vu1nS18jZE4KTh1uTY0qWQxVJvdVcTuZ6Q8IneUUP9Lzdiqn/N+0Myj4r2
         RDYs54a8NIZGP7MjXFIaNsUYhpXzU7rYYI42Xq9D2gmwkZ8s6wrXaD0Sj9m4edRR+7M2
         UnP+6NIUsp3NmMyzWGx5I7C3dITKNcDkv7O4iOtB5D37CBcNiIc4cVE9t5/hduu/nCJC
         nCHDD91OThqQCrzylZ+rYDeyiNmTOwXajRstxQLN62t+nFQwjV55lyfUjqhMHp2FQirm
         nWOsMnbNmKWWG2qtUrnUgIDNlHo4lGnFxy7M5xs1DY91gaAa3hfGdOEdbeo1rtQtiMt0
         NK2A==
X-Gm-Message-State: APjAAAV5jjuhI48gJa9Pa4TSes+DeaHrxKGgcoOBAbuI9GYwU13bJ7lI
	KChx8yhTM5mCtntOT1hU0IROl6nqP+C+zCL28DqQxb0caNOgDk08KCzF+oEI6H4SDDhI2hxaEli
	nQJfYYUkTW4JwMuyJDrnm6uPP6CuRvbqkWP/XnnNNf/6ebU7Aiu5bagNM1xXb2GXupA==
X-Received: by 2002:a1c:9696:: with SMTP id y144mr7516882wmd.73.1560510313296;
        Fri, 14 Jun 2019 04:05:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqgSPGaGWC5jMD2LKvJ12LWjIML9jVWQDlQ5JUq0vl+SDiJIKX4yQ/27REWLhRiyp33BVa
X-Received: by 2002:a1c:9696:: with SMTP id y144mr7516807wmd.73.1560510312462;
        Fri, 14 Jun 2019 04:05:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560510312; cv=none;
        d=google.com; s=arc-20160816;
        b=YxB0gudL0FZLdSyUMJSR3Jev3iTIRXHEaiQqw5mhqIg+9mkKx8SlXR+T6EmFKkGqe6
         9WpiQt+3i2FJ8evn+WDo2SWRWI+FCd/RLQpYQXOjOlufOWZT+/Ejw9/eDyqBBVIPp6Sf
         POSA10e+KDI4KRyhn9StDCcPeUIcShLocutOBkuz5aenyelT1IPDp8NblE/GQ/StSO3H
         AMwriI8v8FIBowRLmBgvf5jfqB2NYfwSGXQzQ9TSgiwCMrIxu0W2nT4SqPMxBHVDlTZ8
         WvAWJXrq2ydp4bKeaiyM8r+MdM11q0R7sRYr5qfYIaWRX6NA5l1ADK2M0etzcJHjTJQV
         fpSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=E87CowIp+htiYTGS6CsPTPTEGv8n2gNXy2U9+KLGIFs=;
        b=Infpwi4P/aiOpbFIXw/dLnK1Uhd7V82s57LTKYLQxCHCzG0O5LT3sEjcAx6B8LxNva
         7DvWCznuZ/xoCX+rjvmWKZODiZqQ0FHvYRiehlZ+/83CacMv0YIWPgymUOvo/l2xZ+64
         OMuJpcbktoZa5sleIqo5ajhmWYH7a/Ng0g9uJ7kzBwYa0yOYkhVET7+M0NHI2cDsW6R5
         rJaXUGQiyuk2E6rf923ZnMJkGfT9U4ySzmxgKrp6LSiPhz0bcMrlvCg5aTLSIvyZ5sFu
         BaWp44ym5+JoP35//B+fPuUsrn947o/CrmknxuRh388WXX8rWZFId560XTrZerKzn2GI
         3udg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0cz3WNC1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m6si2109965wrv.224.2019.06.14.04.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:05:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0cz3WNC1;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=E87CowIp+htiYTGS6CsPTPTEGv8n2gNXy2U9+KLGIFs=; b=0cz3WNC1WoJh9tx/1EngoYVrj
	5upJl14QfanK6cDpB5fCGNRv5B3ME4jKW4uShU0mPxNf1ByhA3yS71ZijaxYowR3yVkRJuwr+r13z
	DPrnvz8ByacVbE+PhTrPw2kEhfxMZ0twHAlKKHBsllzQLb/xHv5SaUUk4BdaxVuH3XlzTbUqW5+v6
	Bu6c90dPPkaM+lRb5Xy8hVVkgkHjzqFA8tSogeh10XgLVxB0x0/43FodCOEDqtjTn/+Za5VcuOzl4
	fRaZ/IhRtLbrICoDIv2pYyqBtKLXX5G6XVYDsIaUAvPPZ9KTtqC9MPOQDESxPDCUnrg749HYny8zZ
	X5CGE4h7g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbk0z-000724-Gu; Fri, 14 Jun 2019 11:05:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 1AD9B20A29B4F; Fri, 14 Jun 2019 13:04:58 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:04:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190614110458.GN3463@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614093409.GX3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:34:09AM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:
> 
> > +		lookup_page_ext(page)->keyid = keyid;

> > +		lookup_page_ext(page)->keyid = 0;

Also, perhaps paranoid; but do we want something like:

static inline void page_set_keyid(struct page *page, int keyid)
{
	/* ensure nothing creeps after changing the keyid */
	barrier();
	WRITE_ONCE(lookup_page_ext(page)->keyid, keyid);
	barrier();
	/* ensure nothing creeps before changing the keyid */
}

And this is very much assuming there is no concurrency through the
allocator locks.

