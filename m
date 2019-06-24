Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4E93C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73622204EC
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:17:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73622204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B6A18E0007; Mon, 24 Jun 2019 09:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0660F8E0002; Mon, 24 Jun 2019 09:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E70F48E0007; Mon, 24 Jun 2019 09:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B138F8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:17:05 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d15so6365280wrx.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lVi7efEyMXSuInljZFOxYkNyqzRF6ZaNOuiAyjFVxlY=;
        b=DdyjzvMiC5nvxeJJyEGh7Ku+JbDEcPiSVlencG6IWeeQSW57TjM5Y7ZVrEbQ7gCazc
         Bvo/eGy3p5AjNpNN6W9sCVD9BbpPmc3PHgFs+dVu2M8gL9ayze2aC99cvjzqwHDLlfdz
         2lKSfFB9zd/2NEzG0XtNQQJkyUwJhWGzugasGFnOrmdV+IRsdDcqvQBvNXLWDTFA/d2r
         W3RsKetAyHqbD8uA8wsth5z3Cs5YDydmXDWWhVIzjKdddFz2bgkQs9f/nRHFVyPw6jNj
         Cf0T6pcfT5kqj59CvcZPsH6zCHctfEtNFgf3PiEdV9E+AftCpoFXP4G0eOXTxa2UqIC+
         T+wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUZg25AwvVdI7RQSRsnQFaPzKtJRffvLwItLL8kQlBSpszYdvaO
	ptxWpgQtz4DItDE/x8k77Se38uANQvjLjNaGYTXeK5RODVuYlxnEsT21p6cJk7jsWogn8emd9M6
	F5Q3EC54ldqz3OxJtrqBx0sAfiOqUQthWyeRdenC8IkuecOdOO+vv/pF3khbpY3irPA==
X-Received: by 2002:a1c:2088:: with SMTP id g130mr8061440wmg.80.1561382225217;
        Mon, 24 Jun 2019 06:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6qw8j3F8YdfMBEX0oqIx3CTnmTnCQdJsvj2yfF7D5wua/RE85OYutvaGw3zZ5s2eYe1rZ
X-Received: by 2002:a1c:2088:: with SMTP id g130mr8061409wmg.80.1561382224493;
        Mon, 24 Jun 2019 06:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561382224; cv=none;
        d=google.com; s=arc-20160816;
        b=OCydaGKsht5ycsQve2Z9CmAUlTbRdeivhZBBcL5HtnEnLRCmiEo0hxquBzAaW1I64j
         o1oo5wXRuIKGJWvJ5xOAgL8u7HaPmIopJCTySZQBB9IYtqHYkSfbPiGzCyXz+rtc1bMI
         rntxWWSUIMJINaKbZ1kOjCpwvVeb9I5qTq99itcJX/Yar3wTja8j/KoWknNBZNnDJXKV
         o6ZrhpddIA4nobxGB/7Z+oOvIHvIoXuTuUx4cCWJkdIYdVOFaoaly8FqUDgHWsSgEfpr
         YrfdiZSyhqkxc+bncOFNrpzslmX15rydntjQYB0MiM+/2+0Fw8yWxHK2XkMNymYbDtn+
         k/8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lVi7efEyMXSuInljZFOxYkNyqzRF6ZaNOuiAyjFVxlY=;
        b=duAMwUDgb1BQLWwhJrhboRjGuqy2o8kdWMy6Et1DqRVPpSM4ZzkOAu44W6nHl3I6b0
         o7W6Rti50vG+VxFDf50AByyPmJapfXoVCKB9/tbAG8LpYCFVlNLvCmM30EvC0jWC7DKt
         IcFk8qrNXJdMLOGxhf9PJ5RNNGmdZpo4YXKQb/lIjr2ovPbGwqiFwRu2cClg/7tQ9zyZ
         PJt4LSDJVcSXd22V1VdRBrWwILuR9/N+WSEkplRNd9fGa4BBYMgEijRq5QnHf3B0i9dw
         KyjbAfLQgD+s7Ou/Z7jpvidw2b7FfVeF79SAr/pS9DL7UDWEGA5OeKfG02DZ63uSyKfL
         KkIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r187si7490120wma.34.2019.06.24.06.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:17:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D879268AFE; Mon, 24 Jun 2019 15:16:33 +0200 (CEST)
Date: Mon, 24 Jun 2019 15:16:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>,
	Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: RISC-V nommu support v2
Message-ID: <20190624131633.GB10746@lst.de>
References: <20190624054311.30256-1-hch@lst.de> <28e3d823-7b78-fa2b-5ca7-79f0c62f9ecb@arm.com> <20190624115428.GA9538@lst.de> <d4fd824d-03ff-e8ab-b19f-9e5ef5c22449@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4fd824d-03ff-e8ab-b19f-9e5ef5c22449@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:08:50PM +0100, Vladimir Murzin wrote:
> True, yet my observation was that elf2flt utility assumes that address
> space cannot exceed 32-bit (for header and absolute relocations). So,
> from my limited point of view straightforward way to guarantee that would
> be to build incoming elf in 32-bit mode (it is why I mentioned COMPAT/ILP32).
> 
> Also one of your patches expressed somewhat related idea
> 
> "binfmt_flat isn't the right binary format for huge executables to
> start with"
> 
> Since you said there is no support for compat/ilp32, probably I'm missing some
> toolchain magic?

There is no magic except for the tiny elf2flt patch, which for
now is just in the buildroot repo pointed to in the cover letter
(and which I plan to upstream once the kernel support has landed
in Linus' tree).  We only support 32-bit code and data address spaces,
but we otherwise use the normal RISC-V ABI, that is 64-bit longs and
pointers.

