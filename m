Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BFD1C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC09D212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:55:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC09D212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 699DA8E0006; Mon, 24 Jun 2019 07:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A488E0002; Mon, 24 Jun 2019 07:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5386F8E0006; Mon, 24 Jun 2019 07:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B41A8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:55:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g13so1097627wrb.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1aGT1T5nbQpmPAM03lWMCmYdwSD2s2w2P4atC5NfPRE=;
        b=XIEhjrWJJ8vXk79gfaE2G77uuIG0WblexQBRi8WgFAAs+/SL6KjbpGfCCYTyWrMQle
         rWr8ehTaVt1sFPqMAXkxvY9+BbQL5+9y2ONxElROK1QGmcE3iGTzMuyVZ/nuDkXklsKm
         ttmgDVOpkO/92Ymtn62ihmutPxWlv8wperzQ55T8aPPdeZ3PRoe7dFeWKbtcazsfiReV
         iQl/wB1OvMzIcMMvydcEkMb4lA8El57agJ7cFgX9SHwvSd2daLoWqTFWERTqPMCe8l/d
         Ug9TX7dwX9d0aSqc+daoVZvGutZEaEIXNXcSUkPYasYh/zvItstjWr1zMI95bqR3dEjk
         yQEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXRMgo40bYYk7oykKfh4HKJXynw1hRySocSNDNIh+y5Ouy+nYTZ
	KT/1y3ksq8yG+jdlfnMPfnPfYIsjXvYm1ytY0cp0E1IQV7HXPDFAEa5VxjXJSTAI+pG93wngYq7
	BASUpOt/86L8bLaBtYyCj03gvdiphodlb2jXQcdP6JuDIGlWmnOKqryka1ld0pFQPZg==
X-Received: by 2002:a5d:6b12:: with SMTP id v18mr29949444wrw.306.1561377300699;
        Mon, 24 Jun 2019 04:55:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGsp4JrSk1UxLTwfL0m/P8Ubbf8t/OgI/M7SE732m5iLjcPocoeKf+a22u00oQeU37JnIG
X-Received: by 2002:a5d:6b12:: with SMTP id v18mr29949400wrw.306.1561377300017;
        Mon, 24 Jun 2019 04:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561377300; cv=none;
        d=google.com; s=arc-20160816;
        b=jzb473uLL9uYbo+OmXIbS2443J/O0N0PVdvYYPlMB+epu8DH0ybHQetGlTVwoiYnbW
         /r2FCCmfgM3/1LcEXTN23uwtBgLtLg1sYkbDJfNU4vVMJBMyRXNvwvWV+b/8jU/F+jCp
         k+D4HIEskddnyLt++KYASaOcg5TbpR/eihPuGgmK1UaXDht7epM+N97rd9I3Rewu55jw
         53HbFTS1Usy4Vz3aSa9Glm1EKbJdI61ARWzyeYwe+rBfv1M2t10XmJpAnDakbdUbL7uo
         j+W6MVlUjwQUIT8iMn4lV7DGSAoYtAJVkztJor0gUucW//b0MeOTpDHdlOrRWxKDRCkJ
         27vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1aGT1T5nbQpmPAM03lWMCmYdwSD2s2w2P4atC5NfPRE=;
        b=mf0aodjnbGvJ+AFsH4iO9zGDHJaY2DJ0Zd0SW2IdyzVUBBaXoIQ1S1FDDpBloPLUtL
         hk5IpZfP3U1wHnmGvT0w/SR5Gh3lBNc0xCIc4UaUrxIa9CLp7MJ64xKT0grRac9CR7Xf
         BUk/I4TzGYvF9YmsDyEK5BXx9QMHgk0zduCRbH3CoGOsb+MUy8xxdmuGIF3lqiO1RyXo
         jCYXnv9mjL2NYTFliOkKVwU8HhgoOLlrAmQTPmLUkNv9lyQMHhlFL4hRAUduTb81YwAD
         /+GXAHQgKojbLLw1pgpwtxGnWV1fBOXAQezJUq5qIoto6tS4Hr8829qC2T+vKjx3/D9d
         6zlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a17si9016835wrs.247.2019.06.24.04.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 04:55:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 647BB68B02; Mon, 24 Jun 2019 13:54:29 +0200 (CEST)
Date: Mon, 24 Jun 2019 13:54:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>,
	Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: RISC-V nommu support v2
Message-ID: <20190624115428.GA9538@lst.de>
References: <20190624054311.30256-1-hch@lst.de> <28e3d823-7b78-fa2b-5ca7-79f0c62f9ecb@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28e3d823-7b78-fa2b-5ca7-79f0c62f9ecb@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 12:47:07PM +0100, Vladimir Murzin wrote:
> Since you are using binfmt_flat which is kind of 32-bit only I was expecting to see
> CONFIG_COMPAT (or something similar to that, like ILP32) enabled, yet I could not
> find it.

There is no such thing in RISC-V.  I don't know of any 64-bit RISC-V
cpu that can actually run 32-bit RISC-V code, although in theory that
is possible.  There also is nothing like the x86 x32 or mips n32 mode
available either for now.

But it turns out that with a few fixes to binfmt_flat it can run 64-bit
binaries just fine.  I sent that series out a while ago, and IIRC you
actually commented on it.

