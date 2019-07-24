Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 944F1C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651BF21911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:11:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651BF21911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC4158E0007; Wed, 24 Jul 2019 13:11:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E73538E0005; Wed, 24 Jul 2019 13:11:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D150E8E0007; Wed, 24 Jul 2019 13:11:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A35318E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:11:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so28931017pfb.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:11:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ITF8T/T4IRmGXwtRff4SYZQW9zAOexuz5C2yXEWqdiw=;
        b=EYci37GmPLjYy50eJapJxqS1hhaysEZYPdXCIUTQpg3zDK0BpZiV+5kkj3DlzkxwD0
         q9VnggnUAHpxFTrW8thziwUKjSRlS54aWVrE54433aZg72iOa8y/dUJsGhIWdQni3n3R
         fIXnSE4GRq8b2dLbIhpwyltMN0DQrhiQ3f0bbzGIVHVnJJ5DYpN4ZiYYEzK8ceqwyqFh
         iWSgY/UvM5ybWu20/YO/C6uUm6GFr0kDnXsgC2BHr3tZvkTly+eRQTSz37oTKbCQWyBS
         ppcP96oSQ1g4n+Sk7Q+2d7Swtilx87oYveFFrjjRKhz/zOBiXDpYkvhJwfQBvsjVI7dG
         Qq+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU7E0NRHMr6o4VEeN/5kyTbjWLN8/VRGFNE6drkHaHXHtDv7a9x
	QquWoFzZoUes/wmWjKXWNWYqY4vlLlvdwBtAHt7i24JlS9lZ117EZUDCqMsXWSAtuKigDj5BEiZ
	uc+X1f/eymMOZ9FK0oy0YqZROw+lbocaoSDuywiEApdzMYguncNG8YbgLXeiJ0Xk=
X-Received: by 2002:a63:5823:: with SMTP id m35mr83573161pgb.329.1563988287221;
        Wed, 24 Jul 2019 10:11:27 -0700 (PDT)
X-Received: by 2002:a63:5823:: with SMTP id m35mr83573096pgb.329.1563988286322;
        Wed, 24 Jul 2019 10:11:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988286; cv=none;
        d=google.com; s=arc-20160816;
        b=yVrQ4lJzjCigAt7RppE10Z0jJJG8lBHNVstQvzfKBKaGtag03lmx+wVogbZgbr+YWZ
         7b2SPO6rWoymP2U5zFZ4jXv0FPFLWesIjCckxpwSK/JPZNwF6PL2uCfXd12kMj1yahGL
         UOHs9Byt457/alxy+/l2tPCX3d8xMxDvpUiXpDXTUaZxl/ub4OgBBs2cO2mrrI1V92an
         +2BmLpXSXGSmmGPUeKcTcTqzIUuJmY9F/yAmizNaR120qYF6OUbxk9WGbqiJEgdvXGDa
         PLzSbASjPD4RUJOJi/gWx2UFmu2OokoiV11hyZJXSKoUdIs0aJryRVlaL63KgaluSm0M
         brpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ITF8T/T4IRmGXwtRff4SYZQW9zAOexuz5C2yXEWqdiw=;
        b=kYjGv7JNKtqbJA5e+Jl20tXI6F748+VGAHL9SM3hrQFssUVk4CjMugixRXbycWqmBt
         Ccoz8Ot3N2oQ6J+XtkPTqbxeADiPgNK6FXcwMfn8jABTgLGVGuCD+kk7Q+kNsPgxWhOU
         3s4/WxTFf85WURN42mS3EHcVEnRXeqtI6TgoPzKplretx1aeCHm75F+27HlJNR8q8hRz
         XXVSG8SaCcXq6R+6H6d8wMle0t4R/YFfL8IM1N1VkgVgNclF+JKHzptQunMZ/uJuNpOy
         542l6rHGI4gyWoJnbUXDkn7koL3Pv/CBgMlFBzBwv4/dMEDI0uEBF7EK6IMrXuw75fl/
         /4uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor56708935plt.32.2019.07.24.10.11.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:11:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwoAqWJaD8G9kpqywHtKCy/l+Vyxr3KKHtKTaJVbqukgpdEilFdeN9cgx3TW9bJG3WUBlH/LA==
X-Received: by 2002:a17:902:7488:: with SMTP id h8mr12079513pll.168.1563988285727;
        Wed, 24 Jul 2019 10:11:25 -0700 (PDT)
Received: from 42.do-not-panic.com (42.do-not-panic.com. [157.230.128.187])
        by smtp.gmail.com with ESMTPSA id h16sm51887353pfo.34.2019.07.24.10.11.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 10:11:24 -0700 (PDT)
Received: by 42.do-not-panic.com (Postfix, from userid 1000)
	id BEECC402A1; Wed, 24 Jul 2019 17:11:23 +0000 (UTC)
Date: Wed, 24 Jul 2019 17:11:23 +0000
From: Luis Chamberlain <mcgrof@kernel.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH REBASE v4 05/14] arm64, mm: Make randomization selected
 by generic topdown mmap layout
Message-ID: <20190724171123.GV19023@42.do-not-panic.com>
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-6-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724055850.6232-6-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:58:41AM -0400, Alexandre Ghiti wrote:
> diff --git a/mm/util.c b/mm/util.c
> index 0781e5575cb3..16f1e56e2996 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -321,7 +321,15 @@ unsigned long randomize_stack_top(unsigned long stack_top)
>  }
>  
>  #ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> -#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
> +unsigned long arch_randomize_brk(struct mm_struct *mm)
> +{
> +	/* Is the current task 32bit ? */
> +	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
> +		return randomize_page(mm->brk, SZ_32M);
> +
> +	return randomize_page(mm->brk, SZ_1G);
> +}
> +
>  unsigned long arch_mmap_rnd(void)
>  {
>  	unsigned long rnd;
> @@ -335,7 +343,6 @@ unsigned long arch_mmap_rnd(void)
>  
>  	return rnd << PAGE_SHIFT;
>  }

So arch_randomize_brk is no longer ifdef'd around
CONFIG_ARCH_HAS_ELF_RANDOMIZE either and yet the header
still has it. Is that intentional?

  Luis

