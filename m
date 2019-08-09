Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7BC0C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:36:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6D3B214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:36:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6D3B214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5F36B0007; Fri,  9 Aug 2019 10:36:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 366A66B0008; Fri,  9 Aug 2019 10:36:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27D776B000A; Fri,  9 Aug 2019 10:36:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1FAA6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:36:27 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id d64so527344wmc.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:36:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l7uKp3K4EbM9KyoRj7AO/zvtCj1gEUQQuaXBGUpg0cg=;
        b=VG9tUy7XuMZjTQcNlK3CA3dJcs4/7ciHqtloMCN2FwuTv7qy6ToCP7ly4Vp5Gm9MRp
         UOKpvO+D3oiK/ZT7nQjRKgrmHBVk/dyLrihYOQOCGWBrnEaZPaf+t4UTDC0F+UNZ9cv4
         qzTdCkiOX8Owc//hPl4V6JV72ZBj5x0CpTaricYz2Vw/L1Z3zTA3jLzIMETQUx80rUTW
         B5XFngrr+bdwSF8l+B+67aaXgClpQIkF9lqLvaaoR0Cc+K2dwHNEd1SVYP/Msk/Xu2qZ
         +LLBtATKg1nK+Lx35enVC3HOZ6MGfsewDX2rg7xE74obxWy89GrhLBwIK5y0xsrDxQAe
         ugmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWi0h6ugBJ1VO/4miqUoUsZJXKpvJFHa86efQyB8CLLDtC6bA0f
	+xrCk8a+yboaoOvNKZnV9hvYUDexrJ1Tu2WBSDpLCB5ICeaFukt2vQuaGWGl3saLcgGel9oKmKD
	vTNhVIgX7M1bz4FHmVYhDfxMEnpSO1up3FzP57Pv4oy7IvvI3tcbSemdIdi75VTRutg==
X-Received: by 2002:a5d:4206:: with SMTP id n6mr24379855wrq.110.1565361387427;
        Fri, 09 Aug 2019 07:36:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcGZhb0fsRfyMJrBBkp0EgSF+JmxvngwbBrOH9B+fve6zqAzSsVjFKBISEyKLjc1XJinXS
X-Received: by 2002:a5d:4206:: with SMTP id n6mr24379789wrq.110.1565361386545;
        Fri, 09 Aug 2019 07:36:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565361386; cv=none;
        d=google.com; s=arc-20160816;
        b=XE0hpccC0V4yYqmbhFGXLSEI9M3yyJAOj7WNFxUY4ochLJzLzSdRN+UyNiKrC6WUt7
         0ogs315JNa6iZZmPHNqAoJ7oIFdF7cbbmzT/XxjK9kQr0R1QOqyFYrQdwYYNt0RK5z8B
         KTq0GgkbApka4jXSd5ae755jhhrE0I1rIfAbwGyEJAizXhcGv1FdjcJLuYAyPWU68ric
         +RrsLb0dLrJf3Odu11EwH8NiCjo5r9nyL0K1t/RNYpisyVe3JRUZ8fnJUOnrI0oqE7YV
         oLbH+nu1B6j/SBGNpSCJX0VuRXj5w5VYzEY5QzbTP/d0fZfrrTr84DaKZ52aklPiDs+t
         R19Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l7uKp3K4EbM9KyoRj7AO/zvtCj1gEUQQuaXBGUpg0cg=;
        b=CSFE0eNewbzikUP/kshMOwPFIcIwfW7HwLT+UqqnbA1e0gT8p043SYZm6xy8O30621
         FWcVacruHhqGaEcvP/1WzPd5Jqg33/dtgt96+OjjU3/h62Z2OzR7lpjt+QWdwEoRmX+9
         4umTWHDtop+xZl019kkHS05IXKq+6wyk1YpH4s6wZ/hAlzj3wWxhBBxI1JOogwDsIC5/
         +BYiVv6Bgf75l5JQE/WhYDYozbjK0ArF4jubz4KbDboBS2VG9jbykKQ38pMyAteu8pM3
         m4YS0ru5sFHBCkc2oz4DSnnRHr2CAND5g3wqRheXEe+X3nDt/qN6HcoqWIWrx/Dz6Cdx
         BIsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c23si3902679wmb.66.2019.08.09.07.36.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 07:36:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id E722868BFE; Fri,  9 Aug 2019 16:36:23 +0200 (CEST)
Date: Fri, 9 Aug 2019 16:36:23 +0200
From: Christoph Hellwig <hch@lst.de>
To: Thomas Hellstrom <thomas@shipmail.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190809143623.GA10269@lst.de>
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com> <20190808215632.GA12773@lst.de> <c5e7dbac-2d40-60fa-00cc-a275b3aa8373@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c5e7dbac-2d40-60fa-00cc-a275b3aa8373@shipmail.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 12:21:24AM +0200, Thomas Hellstrom wrote:
> On 8/8/19 11:56 PM, Christoph Hellwig wrote:
>> On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
>>>> Note that both Thomas and Steven have series touching this area pending,
>>>> and there are a couple consumer in flux too - the hmm tree already
>>>> conflicts with this series, and I have potential dma changes on top of
>>>> the consumers in Thomas and Steven's series, so we'll probably need a
>>>> git tree similar to the hmm one to synchronize these updates.
>>> I'd be willing to just merge this now, if that helps. The conversion
>>> is mechanical, and my only slight worry would be that at least for my
>>> original patch I didn't build-test the (few) non-x86
>>> architecture-specific cases. But I did end up looking at them fairly
>>> closely  (basically using some grep/sed scripts to see that the
>>> conversions I did matched the same patterns). And your changes look
>>> like obvious improvements too where any mistake would have been caught
>>> by the compiler.
>> I did cross compile the s390 and powerpc bits, but I do not have an
>> openrisc compiler.
>>
>>> So I'm not all that worried from a functionality standpoint, and if
>>> this will help the next merge window, I'll happily pull now.
>> That would help with this series vs the others, but not with the other
>> series vs each other.
>
> Although my series doesn't touch the pagewalk code, it rather borrowed some 
> concepts from it and used for the apply_to_page_range() interface.
>
> The reason being that the pagewalk code requires the mmap_sem to be held 
> (mainly for trans-huge pages and reading the vma->vm_flags if I understand 
> the code correctly). That is fine when you scan the vmas of a process, but 
> the helpers I wrote need to instead scan all vmas pointing into a struct 
> address_space, and taking the mmap_sem for each vma will create lock 
> inversion problems.


True.  So you'll just need to apply the same lessons there, and we
should probably fine with this series going into 5.3-rc.

