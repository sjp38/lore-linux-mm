Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECBEFC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC36220663
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:56:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC36220663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B7C8E0003; Mon,  1 Jul 2019 02:56:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B868E0002; Mon,  1 Jul 2019 02:56:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FB7F8E0003; Mon,  1 Jul 2019 02:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f78.google.com (mail-wr1-f78.google.com [209.85.221.78])
	by kanga.kvack.org (Postfix) with ESMTP id B5C328E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:56:56 -0400 (EDT)
Received: by mail-wr1-f78.google.com with SMTP id s18so5308610wru.16
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:56:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=q1BhkS2RYs4Uw9+tagf1xdsMjeJbWPNHa6y1sfaAJoc=;
        b=oKoMuabBtkx/XGtlOhSuvGsZVCYEupNMGP1BWeTsYEb7wWT64yYB+xN8wCtUD26azT
         6qX+bMHfsTPb4J7a6rvaDjSm+vKudcm+SzdpTnTB3yfhDlr8mFh/FHMzhhojK/+WaUnM
         cs1dHIADzaLbip178ROMZP5IjNPSZPcAw4nsyPXXoz51wwAgbZjBWsEvNbtqi8V+KRx8
         NtpN8TIbfN4/BKuH+odxZ/LvnWGp6a++oI7ZW1ZHOR/woyLYPlhUv6t3bu5GDgz4LGZ+
         1kLNhakRMt+n2ttBqPKXHoGL0ce865k4NXEDEchWiISf4dAq5AhObwCU7YXKhrQW7eeY
         bmRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAU1MHzmfv2thP1OH+4MD47q/DLyMQrNLNjI+6iOxCSLNyoRn7cx
	CTvHEKNsX5lpkE1P0rRMSN7NTuuYJAPc1EBTtUIXrNUl+z5TZa2xxqwKv+9aYSgYjNQMfsGKpTZ
	QuZaehZhqgcJTO3hiWG7hNFn0EgARgV8Gy5OqlKvZG5iKUI+I7ekOzM3m2cVwTrCDKw==
X-Received: by 2002:a1c:a942:: with SMTP id s63mr15773033wme.76.1561964216069;
        Sun, 30 Jun 2019 23:56:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyINar9Y6Ve7RMu6phAp34J20IqWWZyNFQIu0TnEJroSjo/Dy/+lxcHlJb04LL0WHwLvqAo
X-Received: by 2002:a1c:a942:: with SMTP id s63mr15772993wme.76.1561964215261;
        Sun, 30 Jun 2019 23:56:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561964215; cv=none;
        d=google.com; s=arc-20160816;
        b=Sc5Oud50wUTTFcLGGNWcrlopALc/La3bm72S2CtK7428oF6ZBjro/VjRGFg8kJLdpj
         YCX5zaKLq+tNPbjDX4rMlwiyLFJffbjNDSWRhzqJiVkr5o1rrdwx5MhsS64RQzq3w1UX
         0sdmTZkwyrtRmATmrRBQDpk3epByHvRv6l4w+rw8FzrvOPPAHsXeZGkNWwD2mQw+ZC/R
         /O5zwhjK9AtkMWyanipnFVvxrYETh13/GAKc5tPenX/uRvn3Ny46gDdKRcTDw/ZiGXeD
         XEAytqcKSSIeitLuu8xmY0tIDmyYrKQm0EOoJwcSTmIyHFxtGPYIn3QcyzwwCJBWL8Lv
         u68g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=q1BhkS2RYs4Uw9+tagf1xdsMjeJbWPNHa6y1sfaAJoc=;
        b=Qr56K4RrWaOSYGRJhyy4towi/qGdpLEtZIPog4rV3Z+lAwogn46O8biw8DKi3fxQ7D
         DugdAj3XWC1CKALU25TkdFtp96QKS4zo9/XYfGiyURqDUgJg4oE1K3uk1iu2tF763hW8
         x4ycwh4+GmZ8mrI2CK1j7o7vMUxIqOOlBxjMCV4fAvWoPzEwCI+GagSPGDOx++/MSsNG
         jwpfX1F+duKVZVnyWw5hjHwWR536J+hfb3gTclL48KO1yp5xiBjzhSIcftv8eJXPny9Z
         OwKd80vSRjA6HINRdmZGni0WISH4WPJ6OCn2UCrgT7elp1WDWzvD18Gd2xduuoe+US5t
         Kn/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w9si6504818wmd.47.2019.06.30.23.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Jun 2019 23:56:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7147E68B20; Mon,  1 Jul 2019 08:56:54 +0200 (CEST)
Date: Mon, 1 Jul 2019 08:56:54 +0200
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: linux-mm@kvack.org, Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: RISC-V nommu support v2
Message-ID: <20190701065654.GA21117@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Palmer, Paul,

any comments?  Let me know if you think it is too late for 5.3
for the full series, then I can at least feed the mm bits to
Andrew.

On Mon, Jun 24, 2019 at 07:42:54AM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> below is a series to support nommu mode on RISC-V.  For now this series
> just works under qemu with the qemu-virt platform, but Damien has also
> been able to get kernel based on this tree with additional driver hacks
> to work on the Kendryte KD210, but that will take a while to cleanup
> an upstream.
> 
> To be useful this series also require the RISC-V binfmt_flat support,
> which I've sent out separately.
> 
> A branch that includes this series and the binfmt_flat support is
> available here:
> 
>     git://git.infradead.org/users/hch/riscv.git riscv-nommu.2
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/riscv.git/shortlog/refs/heads/riscv-nommu.2
> 
> I've also pushed out a builtroot branch that can build a RISC-V nommu
> root filesystem here:
> 
>    git://git.infradead.org/users/hch/buildroot.git riscv-nommu.2
> 
> Gitweb:
> 
>    http://git.infradead.org/users/hch/buildroot.git/shortlog/refs/heads/riscv-nommu.2
> 
> Changes since v1:
>  - fixes so that a kernel with this series still work on builds with an
>    IOMMU
>  - small clint cleanups
>  - the binfmt_flat base and buildroot now don't put arguments on the stack
> 
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv
---end quoted text---

