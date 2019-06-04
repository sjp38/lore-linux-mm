Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2793C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73E6D23E30
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="a6FgIBxg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73E6D23E30
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B2AC6B026C; Tue,  4 Jun 2019 08:28:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 064026B026E; Tue,  4 Jun 2019 08:28:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E95726B0270; Tue,  4 Jun 2019 08:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC6146B026C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:28:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n190so3425204qkd.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=piwrTztXhC39aA20VdmSLRCidVge2JjKgB3c0ijpNGA=;
        b=BWvxGBvhb3owe1jfsv3Tzzyx8KXVI/n+L73fiK9uPuQwvLrZItmOT8IxUoaqyoHJmn
         Ukgu/pKZi/KNPaAF9uQ0vNAzbPkgspHoSgj2wEgJqk9tVYTM0UvCEHPMN2rFwyJ5ra5D
         7NAqSissXr8DhLadP+6n6KUK+fNbYsVotg/AvXWTjmJLPEhqO37naI5KcQqS0PKT7WrT
         sImkxXP6d0gXsNRw/UwtWONCWHxCZ8ZzQ7l7EePCd2csKEabHpVXjFLqfiXnwDvveXMC
         2OynmaHBHrE2bUKyhQlUFieG6kQ+sxUkMgN9rkqYO3ruuZvmMqgKIvzGPO+7Wgqiflxo
         JNvA==
X-Gm-Message-State: APjAAAX2yaoCYklv9eiQhaidH/UllMdDr7vuXTcUVhsXidvrIkERKwXj
	keJT6+x0YSpjxsBHWHK9yoNTQnA6Bi/FKyunwuQmJiQpqO0pJvGoq7ykK5hIR8Cle6HwnwitrXO
	kL4lrFDRvoiPmAGJxQNUrFOID52qoNFuiSNS0vu98Av9rsjrsCM0dqMIipvrKFE8zJA==
X-Received: by 2002:a37:e402:: with SMTP id y2mr7754449qkf.200.1559651323483;
        Tue, 04 Jun 2019 05:28:43 -0700 (PDT)
X-Received: by 2002:a37:e402:: with SMTP id y2mr7754407qkf.200.1559651322931;
        Tue, 04 Jun 2019 05:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651322; cv=none;
        d=google.com; s=arc-20160816;
        b=TjcfSyHhSkKV8XLB2Ed77g3ggean9n7nJ91wVqoOHeXEltCjJyyyNEWiTJypJJ8/Vv
         8iqp9xVHbM4Hrw5b9Ug1avwwUiPa+SVYqhJHVhhQEvyyV+achso/0gIGMFf5ujHh50MI
         6+txZOeoy64ryvLiI0qKabLVjW3LVKyF2yXY1bXfyg5X2xQganyylBbXwBAaYdDkJvbg
         kiAF2QqlPrIJskjxiYd1TfMEvt3mWUnOq9JQmoEOdFG+ux8UiOjKoJlLu4K2473E4pm4
         svPrZMTSJEvzXQRaDdtdGTfZN6g/LiammB7Sdnd5XvlGoNtKjkARf8NpA/UgP7PxWFud
         sb4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=piwrTztXhC39aA20VdmSLRCidVge2JjKgB3c0ijpNGA=;
        b=WjjKB0MRwTXvf74A8EEVowln5Hs0m9Qtl8o0m6xouM9YmvmrJSZG95ORKcmbIo1rv6
         VJSsYIhWnjDShICIPzo6lTXazcTebAtEdU7DCyIlfxfCGSRVW9YpLIO0dC+uSLlBZQjE
         GJCkWjSz8DJMd3HYR+lmUwUijAXBYmCJWSz6YkT6+6rYzXF3zqFEMMVMCaK1BlcX5rMj
         oo1PJK3wreonWCxnUJvERjbTxD5OJefb4/vEg4RiMdRuoLvHjjD2yQhTcD7/cgnlbbAE
         R7er21YH83EhUPmAVyXqEcVFCsIP49d2k7omPWvQHm4pAN9dklXz6PO7Ku/tstfe9iEk
         iKCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=a6FgIBxg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p41sor5967661qtp.61.2019.06.04.05.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=a6FgIBxg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=piwrTztXhC39aA20VdmSLRCidVge2JjKgB3c0ijpNGA=;
        b=a6FgIBxgNByE1AswojUTFyEmYC72QqH/LQqqHz7ixlPVsXOPCgYd6mlw3XQTwnM2uh
         oSGphZh6q0/2oLSC/6UR/PVOiDLxeNrPqz3Xwh66LKb+PMN/RXj9Mb0rZNkmDNbLDRnv
         CDWrRylaRnKOork+/GTVzWguM6veviFxYDrHZyjqWmhP2Vq2sYJ9UIswPK1qUkGaukdi
         k6ldM/RmNazR5Btl5NCkOzRIKY7xN77rgF9vRVvC1DB/O3CaVrJjdtoBXxCeg/JcPdxV
         dPdKuKgQLxyqTRqoGtEBLBY4RwLUOzQy0WyfZWfqmqxAPStw46U6hbvqjfP22IPycU4j
         75jA==
X-Google-Smtp-Source: APXvYqz1oMF9jOCQzUyuq8/gZIjlw5l60lDqJs2tR/Yg0Za5sOTQcYevs45DA2dZqbA4i3Qtsa1ReA==
X-Received: by 2002:ac8:2c7d:: with SMTP id e58mr28082215qta.243.1559651322669;
        Tue, 04 Jun 2019 05:28:42 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e133sm13448610qkb.76.2019.06.04.05.28.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 05:28:42 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hY8YT-00042G-HE; Tue, 04 Jun 2019 09:28:41 -0300
Date: Tue, 4 Jun 2019 09:28:41 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v2] uaccess: add noop untagged_addr definition
Message-ID: <20190604122841.GB15385@ziepe.ca>
References: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 02:04:47PM +0200, Andrey Konovalov wrote:
> Architectures that support memory tagging have a need to perform untagging
> (stripping the tag) in various parts of the kernel. This patch adds an
> untagged_addr() macro, which is defined as noop for architectures that do
> not support memory tagging. The oncoming patch series will define it at
> least for sparc64 and arm64.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>  include/linux/mm.h | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..dd0b5f4e1e45 100644
> +++ b/include/linux/mm.h
> @@ -99,6 +99,17 @@ extern int mmap_rnd_compat_bits __read_mostly;
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
>  
> +/*
> + * Architectures that support memory tagging (assigning tags to memory regions,
> + * embedding these tags into addresses that point to these memory regions, and
> + * checking that the memory and the pointer tags match on memory accesses)
> + * redefine this macro to strip tags from pointers.
> + * It's defined as noop for arcitectures that don't support memory tagging.
> + */
> +#ifndef untagged_addr
> +#define untagged_addr(addr) (addr)

Can you please make this a static inline instead of this macro? Then
we can actually know what the input/output types are supposed to be.

Is it

static inline unsigned long untagged_addr(void __user *ptr) {return ptr;}

?

Which would sort of make sense to me.

Jason

