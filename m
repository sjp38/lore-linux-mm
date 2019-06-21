Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2000AC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:45:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D836F206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:45:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="IKvWFo0f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D836F206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CC618E0002; Fri, 21 Jun 2019 09:45:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A3458E0001; Fri, 21 Jun 2019 09:45:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690EB8E0002; Fri, 21 Jun 2019 09:45:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 457568E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:45:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so7555731qkj.10
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:45:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5X0rmkRC95nceR2b+WbG0Q+b41qnJ7FNz5RDX36KkRU=;
        b=Zz+Yyr8wKP8j3ijUY5lROovcVIBgCrWAOb9XoSzHtWXgCizNeXRQGfqeHcYuWDp0hk
         9xeistVlC5WXonSXinTqRRNRY+h9HnDvblq/vmjLK97fLyKScl8O4+bL/U2ri2pVJ82g
         yY0jXrxBv6e6bJCZia86PbMmd9A4ToELoQC83vg5qX9A4CuzfJN8CUkZoh4iymJ94mU/
         qbA//659nL02ulYx3ygZHGwAFsGcQkMF+Y5XS27p5VZo+w4S+6kfhJrEbAjBnGYiw0Io
         fe77tbrZL8Ed4NHhjoXBtPZaqCBuOEJCuL3JFNQqJxtAQsYm9xTunIv0clbza4AFodw4
         huDg==
X-Gm-Message-State: APjAAAUY3xgUMI5PTtgEHjAW6Su9k4S+QVef6wPL3tNcdbbFze3RGedP
	ddrsy43p9vHcyS9CMRADiIZpZPwJpaKUKTwIDcmCTuJglh1gjiXARn1wevhGPYc3C1Hh/bZloLH
	yiI/q/QLeuA1CJ4wo6JM764sk3m2DEfftkYp5lkA/7N737T6G8rsw2iFLsj4i4rJZDw==
X-Received: by 2002:ac8:444c:: with SMTP id m12mr21504146qtn.306.1561124733014;
        Fri, 21 Jun 2019 06:45:33 -0700 (PDT)
X-Received: by 2002:ac8:444c:: with SMTP id m12mr21504093qtn.306.1561124732472;
        Fri, 21 Jun 2019 06:45:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124732; cv=none;
        d=google.com; s=arc-20160816;
        b=AABvK2ic+7AN4CruSVvOm/Wk+5R1LN8Dib0VSGulRSZlv1ulieBzevKjO77JnZuEet
         JirCXCBi/teqrBigdFpVQ80kZmKYS6emnutnxkXCjxjqVMdJVMr2i9ZJhM0VRcF2xX7V
         6oU0R76pdGMbn2M5lO6co00oWoRuTOhIvoBsKIknzGzcnXdSUz1B/O2iodItcOllssL9
         Z/I/gnZiF3AGrZ0frG3pK03MaFfXhJb0rAHwPMOHhY6frbMKb/yL+4UQ/xbzjq8MY1lF
         23h+lfK21crIqmLCKVswLFuwIVauHIEkAByxiZm3NUae8+Pe9eElMhuZ63CPhLleedLv
         uoGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5X0rmkRC95nceR2b+WbG0Q+b41qnJ7FNz5RDX36KkRU=;
        b=b4mVpCXiLE+zkzl0EZcendmuQIsvanqwsFpL1g1e8nksLjMkyBNsD99M6ApQiKrWOj
         8foaDXpRfiwfokd1XSFaEOimz2M4KJJSiY+uHTQrDmqgZ2Kv4RLf/0QFMjhkmJsI8EzW
         bhQixX/4H56iV9Vj2c7mkIr4mGuhAz1D5SNczQhEFmGVDv0saBjt6G/YoeNQCDjzuBrm
         2omMVut+FCSTEQnQRyMlZVKr7Gs58TvIIvHuG4jgXzeJv6cVINv1Rx3WqeNsQ8NxLUbQ
         fGHPIm+2pu4CrpRe6ei0ZR79g+YqdI1GBspT5OyJDHYwLKxDARwEKUQKpAq+BSNikK4X
         5fTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=IKvWFo0f;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o18sor1543782qke.38.2019.06.21.06.45.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:45:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=IKvWFo0f;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5X0rmkRC95nceR2b+WbG0Q+b41qnJ7FNz5RDX36KkRU=;
        b=IKvWFo0f0mTVaCe/ijJtv0mDxHgoNp8HulNuI0gdobye37WUW94nv8DO7J1ctBzM/s
         y1U3xE4o3pFMYs/7BSYNHk45TVTdOg5ah1B/Ezb+sYysR+frntFucIE6z4FaKjp7+kPS
         CWfRQXI0wAV8/s5+T6lJtOeXR69gDXp75nl/bDlVvB0CS61j1/DQcB5+JxxW8c8h8L/W
         Do9nWLXeCDBlSBMAgLef2HJyHbQwTzNWgF989V9+FjYpu72cru6fLYnt32uoCsfDkKYD
         8v1BgRCJXKFONlNlM8ZrySrf2ZWJIGMy+aVFl4b0JnDL684iSD+C68Fqbqka+ZNuPT7s
         EMwg==
X-Google-Smtp-Source: APXvYqw6Aa1vtmaoAcmmWYgjcUlAuKLWmpTyuJq4yf3HeH8qCqVB5lh6+d5sgipawN8uf35W8F5eHQ==
X-Received: by 2002:a37:6808:: with SMTP id d8mr5468961qkc.478.1561124732220;
        Fri, 21 Jun 2019 06:45:32 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id h4sm1369861qkk.39.2019.06.21.06.45.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 06:45:31 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heJr9-00008q-7e; Fri, 21 Jun 2019 10:45:31 -0300
Date: Fri, 21 Jun 2019 10:45:31 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 03/16] mm: lift the x86_32 PAE version of gup_get_pte to
 common code
Message-ID: <20190621134531.GN19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-4-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:49PM +0200, Christoph Hellwig wrote:
> The split low/high access is the only non-READ_ONCE version of
> gup_get_pte that did show up in the various arch implemenations.
> Lift it to common code and drop the ifdef based arch override.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/x86/Kconfig                      |  1 +
>  arch/x86/include/asm/pgtable-3level.h | 47 ------------------------
>  arch/x86/kvm/mmu.c                    |  2 +-
>  mm/Kconfig                            |  3 ++
>  mm/gup.c                              | 51 ++++++++++++++++++++++++---
>  5 files changed, 52 insertions(+), 52 deletions(-)

Yep, the sh and mips conversions look right too.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..fe51f104a9e0 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -762,6 +762,9 @@ config GUP_BENCHMARK
>  
>  	  See tools/testing/selftests/vm/gup_benchmark.c
>
> +config GUP_GET_PTE_LOW_HIGH
> +	bool
> +

The config name seems a bit out of place though, should it be prefixed
with GENERIC_ or ARCH_?

Jason

