Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3CE6C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:41:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5784727CEE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 07:41:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5784727CEE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1A7C6B0008; Mon,  3 Jun 2019 03:41:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACADD6B000E; Mon,  3 Jun 2019 03:41:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992836B0266; Mon,  3 Jun 2019 03:41:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCDA6B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 03:41:49 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id w126so2681067wmb.0
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 00:41:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tPxxp3WlKOdZTHfCrlsjcZmn83DoBW4iVVBVhmrCh3U=;
        b=EoXaDdIbgQSDfwg30Pb0fJfiIMjiVWTUA93KTlUbL4uIJsPGWOTTdYZD5aXO809cCn
         fEfFBL+mwyuhMMaPvm2SjPPawSse1fiVxImQJcnXPPtsLFjNFssCo+lUbnhYwGHQzFPD
         foT51tDjMcCGAYbGkOzUL9iMcak46n44atXhcbQc0Hdk8dzlC3r2dKM++uTbUY6cBCRm
         OkYIyfuF5MiYE+rp5fF1zht8JykkEA+CZshta30p/W1M7Zw2biPZQlZw+lScjK3MV6nn
         mddV90mVDeeWcujr/fs61MJI6XT2/4Y0rYkBSei4uFO4KwzEpq7iBb14WFuw55taXxPo
         kurQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWh+QNClh0kCTLM3RrXAUf7h79eRHIJwJb7n+k4MgudpZfp9DCc
	Zp1DUb/Li7UB3y1mDL06ICCRoz2U8ZdBT0qg7auFzeYWJ97edvUpyOuH7eY8P/+Mm7w5028NyT7
	TLDUjGHyNKgjR06U4p7zBjsJ6doqejjuAXjhZ1doX2lWCX8UE0rVMxrhCwXeKpzuJSQ==
X-Received: by 2002:adf:f78b:: with SMTP id q11mr13312431wrp.13.1559547708742;
        Mon, 03 Jun 2019 00:41:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwQ5DPCCGb7LQGUoQSWXs4Y/+ZtE/Nh5VVfMaWBA9/v+50tVT6CRvgNOXbw3Q5vDjabWuA
X-Received: by 2002:adf:f78b:: with SMTP id q11mr13312399wrp.13.1559547708069;
        Mon, 03 Jun 2019 00:41:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559547708; cv=none;
        d=google.com; s=arc-20160816;
        b=JTgHfJIiNkkeqk1wjCEbGgkf+fHz65k2pBo03JgD7+BDCJv2YF0UYPs6443ob5pZ4p
         J3ZbTS/G0C8rtFff0WdB9wj02aO57Da2N1bQDT2eWIdiASqxGRaNTq6fSvwBXqGF7SUs
         c7EUxGdCtV0WC2XKUnpn+6/pFsa8P7DobUG22WQZnh1EnfiC2RmfH31MHKtJAb5+LdEZ
         +Yj1yTS82mO6Xrgq+8h2UjwBGblIzEhI8T3DPGpaHp1s/iirKl/YJgckZ/S30yWafC5r
         BCtKewP2L/nBH6i6nStikX98PTdqCrRppssVl2/ekhx0KyDMTT2tuqMEt9Ftxswev3pz
         p1sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tPxxp3WlKOdZTHfCrlsjcZmn83DoBW4iVVBVhmrCh3U=;
        b=0bH7pwEKku9JnvupgE7jwIBbZmXYpWqYW/7G6n27JES8eEmU85z8CjUZr4r+siBCO4
         1AcylTccNkuuPajrvyl4Udpzd+6A+fg2TDYbgEPLgPSo1EyC5dWUJMFis/IYL297MeXB
         aBClR1MSUs1xhSC9tuogTBpmzEEsfSjAkVUx0dLQ52iJ6xUtTkBiRNBPMiwYJ8Dx7V+C
         lONHfGKtgG3P8sdrYyln/l0fj7+DqvtpHCABFxkx6E2H/vlnJh6oP7s7fZAPpvJ7LhZd
         nzEc2HS4Y+sqqGe2nM0+m/PNoN4yb+UQ2WfIq+TyRlQGkCay2Qt6LarkEHlDmoldyjzQ
         f5XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d11si7915342wrv.44.2019.06.03.00.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 00:41:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B4E2E67358; Mon,  3 Jun 2019 09:41:21 +0200 (CEST)
Date: Mon, 3 Jun 2019 09:41:21 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Linux-MM <linux-mm@kvack.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/16] mm: simplify gup_fast_permitted
Message-ID: <20190603074121.GA22920@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-4-hch@lst.de> <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 01, 2019 at 09:14:17AM -0700, Linus Torvalds wrote:
> On Sat, Jun 1, 2019 at 12:50 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > Pass in the already calculated end value instead of recomputing it, and
> > leave the end > start check in the callers instead of duplicating them
> > in the arch code.
> 
> Good cleanup, except it's wrong.
> 
> > -       if (nr_pages <= 0)
> > +       if (end < start)
> >                 return 0;
> 
> You moved the overflow test to generic code - good.
> 
> You removed the sign and zero test on nr_pages - bad.

I only removed a duplicate of it.  The full (old) code in
get_user_pages_fast() looks like this:

	if (nr_pages <= 0)
		return 0;

	if (unlikely(!access_ok((void __user *)start, len)))
		return -EFAULT;

	if (gup_fast_permitted(start, nr_pages)) {

