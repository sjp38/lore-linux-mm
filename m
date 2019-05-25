Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37211C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 09:58:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D406A2168B
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 09:58:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D406A2168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A8AC6B0003; Sat, 25 May 2019 05:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 333316B0005; Sat, 25 May 2019 05:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D2F06B0007; Sat, 25 May 2019 05:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0D7E6B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 05:58:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y12so18327024ede.19
        for <linux-mm@kvack.org>; Sat, 25 May 2019 02:58:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=meawqYuXeKgnlOM1B+swkS11bwuyzIrlMn1rol6uNbE=;
        b=V8newMYXNtK5uiXvdiEsBI26o5x/uxNKNvCqm1IBDcazujaNX8i6H6wl5w2Y0GDAyI
         ++IeiGF7wb5AzSu3DuSsKXo3UHDvizUtsVfW2aaHyet0aY9FacOaElpBFxMe9vVOzoIN
         ixIDWsC8ltfe0Cfasi2H6e2iRbtRBQ8tN3buiee2XPvmia2xCRe6aNwCrp4/6tmC4YhF
         VpCra3VlPzNDp1cj7jprJjNEtwM1LCfsVFhUlTQjc7SFljNM+MswcDvJfDU+BWrHfgTZ
         Y45G0xoE+Kd2gkBWrSf0VpCi02oU21zLDc3kdiXEE/fDe/8kGZLDcWjDywqJ63GTwrXV
         GL+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVsXkTq8/kYeJYqKGl2GxJnKthgZx30btdoyjoEYb0pGSxE6LTU
	yLpu03zHbxNbvwWImV5DiSKEyq+jbg+N5f1M1Z/ni9RsYIDi3UwCk2dx4Hj5ZqlH2eX1JdR12bb
	P0uOXqN+//h9mIs8snjZ6uxMcIoZPUgus5HPfveqOUX45ti7uwYok2RBMuUJ5DbRUZg==
X-Received: by 2002:a50:9266:: with SMTP id j35mr111226394eda.60.1558778286282;
        Sat, 25 May 2019 02:58:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFA+5mbPDPmg/WBO4G8zDj1sHlv1DJy+Ch8I2kYgqWQAOdl0dCw6t+A6zY5b5FFYKw+wGw
X-Received: by 2002:a50:9266:: with SMTP id j35mr111226337eda.60.1558778285314;
        Sat, 25 May 2019 02:58:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558778285; cv=none;
        d=google.com; s=arc-20160816;
        b=LqEbLAnUL/eA1Kq4SmmF+45wTj5+XZ1xKY1vTBFvMngN/tOPD0EOrrXYz5WfYu+tEs
         3avmhWRsW8JYuQtsXhCrT/BEvOnh2x3vQDHozZaFtF8cLOiMpV5HaeMcUmA86m0DWdV8
         dsiWF0KcrNxX9+7kQNP8RjoPbxYsA11IqFSc1fYMoN+wUgOlDTm7myk2u495XF13DKhc
         KjsU2rTV+0pFx/zCqKQmg8aYf2KdXrhRry4Z2PUV6DM2SGz6D54X6kZlqVGDi54OKD/i
         /M1FLsTBJmJNQ43TsS1mE/iY6gL75iwJV5AqC4aLdvmPaOGsaFrHJUtM6QXyK3QcvGpG
         YlIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=meawqYuXeKgnlOM1B+swkS11bwuyzIrlMn1rol6uNbE=;
        b=yzhpFPY3QheP/QEhJH/CUpR0NXXjgUEBNTvOeDFclzTShrCxy2XTbN8iL0/eoNd+te
         6Iy1XrZwFrmNuwVkSjFa9flLAQTEsp+ih340imksy6UfclszEfOfC2tnINRV79XswQST
         0/4vy90Gd97YdwJkhcuGPTSXQ9l4YQWjpIhLp01XUVnXZCilTsAmk76vzJQdvTW7xJFU
         z4pomNBmyifsNhQOhumdGEmui2LZs79xAi5ANAsCZtHuQe0CTCW65ze8M1CGJDsYdaL2
         /9hdA5IskxYrsC75F6LGv8uNpHNsNLBOBkAso6npSxijB5qpFv7qghWPHz30fyMCD3fw
         h8jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d14si2161267ejp.167.2019.05.25.02.58.04
        for <linux-mm@kvack.org>;
        Sat, 25 May 2019 02:58:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DC81580D;
	Sat, 25 May 2019 02:58:03 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 19D783F703;
	Sat, 25 May 2019 02:57:57 -0700 (PDT)
Date: Sat, 25 May 2019 10:57:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
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
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190525095753.caehqipafdc5m3yp@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> +SYSCALL_DEFINE5(arm64_get_mempolicy, int __user *, policy,
> +		unsigned long __user *, nmask, unsigned long, maxnode,
> +		unsigned long, addr, unsigned long, flags)
> +{
> +	addr = untagged_addr(addr);
> +	return ksys_get_mempolicy(policy, nmask, maxnode, addr, flags);
> +}
[...]
> +SYSCALL_DEFINE6(arm64_mbind, unsigned long, start, unsigned long, len,
> +		unsigned long, mode, const unsigned long __user *, nmask,
> +		unsigned long, maxnode, unsigned int, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mbind(start, len, mode, nmask, maxnode, flags);
> +}

The kernel fails to build with CONFIG_NUMA disabled because the above
are in mm/mempolicy.c which is no longer compiled in.

-- 
Catalin

