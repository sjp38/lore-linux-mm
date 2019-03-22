Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1331C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A84102183E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:47:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A84102183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DDC36B0003; Fri, 22 Mar 2019 11:47:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B63D6B0006; Fri, 22 Mar 2019 11:47:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A5CB6B0007; Fri, 22 Mar 2019 11:47:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DED056B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:47:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s27so1118501eda.16
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:47:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OOIzFDQWSkkpyrTDZcT+Jg4W9GHz59SKHXuCylWd4PA=;
        b=IaxM3O0DCJgac7b+qwwfpUy6IjV0a1rX1QZn6RmtcbGDc/cl2VZm6roqeqfyt5HA5y
         9wgmgfWwdE8T3vRMwQ46HhceQIcE2O0rOzzmRJYunA0HRt5731T7DFqz3IqBsviW9c87
         28S8d+4PlZrHTPO1sP95Oh1HFYDRxmYxGUQHK9nN89+DIot66I5AeYxD1LAjyuPGPvZC
         2d0RUC2ePUtRdIJvbPHSfj2jG0Izu0/B0b9rpayKL/nT4r/hs3B0E/F2kHfDq3n7QdiG
         s6h+bXjPCcb9v/K7y9fFUyyGnRew6TwsJ0Fgvre2buTNW5yeDIK82THoXO25aLRT3zRa
         bxJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUpmUpw4WPvrprMbMIxU0yOfGN0+sp7P1zW95/Lp8dWGpdLn1a2
	3GOSImti6VY4msaIjrZSQW4UoMTcWvcdyC1ZYbR/vRVTXUWyLuUF4PXuWYagzhpKsyeYE1bJ9wV
	QmBeMyfS7bAhcJKzyMIwVwPmT910BpK8ayv78opHDDynD2AH8Lkzi3v81sDsi3EaoYg==
X-Received: by 2002:a17:906:5212:: with SMTP id g18mr5854953ejm.149.1553269630487;
        Fri, 22 Mar 2019 08:47:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcgGEwIn5eaSeTyxWHm8SZajdxs8dMFm4h1cIeLJA3HrY7DVDEVe4mh7iXfB8SrguI2+Vx
X-Received: by 2002:a17:906:5212:: with SMTP id g18mr5854917ejm.149.1553269629592;
        Fri, 22 Mar 2019 08:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269629; cv=none;
        d=google.com; s=arc-20160816;
        b=Zq0gK1vEq34cpECzlPgCwU6yEIuGh55VbjdYYxFzv+oq03icIjk0N0bXwfdS44IJHP
         gnH+rTi2s33RhqceeMeo+3XIaZ6DnwIBeTso722vZoAAi9Lf1MEfi9b119qBRKpRAoW4
         n5H9UGvjal+OkyzCxF7uEacHChvfRGBbEaklX040AKaK3OFTns0PmPyw3kDLrc1EVDo/
         WI1tLtwPU0lfoDJUuHsROT7ohrVcd7t+6GFCdfXw6C7Pj9vCOHwRYqZnRjo1a200xy2X
         HNagRknFnJD42lApCtx5fUf1lIjh2EU/tmkZq5Aq2z9auxubOiCDLv3Or/QMo4ycRhO7
         lvSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OOIzFDQWSkkpyrTDZcT+Jg4W9GHz59SKHXuCylWd4PA=;
        b=R1wUaHDr7uQMtbxpDXDj/vwsW6BvXzB51cmdgf7jQ+cJn0LuHqY6vGq0gJ7RQllmmP
         VArgZ/xaUmUYUl5lX9tlw1pe7lciUTMkCCcFTEQhKwh0dTv5AIrbnYQ3x7JFtPxN8PrN
         yjns2hZ4WNFSQTUghXkwcC4BA38J33TcQcUi4DfnRvVMPjYtu9zAnSIeWxuhkSVhTXrR
         smsi6U46cP18kinyT15l62KVbrgVt+X3DG+EUTi8slJV5iEhG2AArm/ZoBc3ZnG8v0p+
         qBUPUkQM3TVDExqzGH5WVmYHjlVEflmBaWR/bNzquOB0CQJ6l+0AldWCinNbca0/qrPq
         vc3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c1si1039163edt.185.2019.03.22.08.47.09
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 08:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5BA97A78;
	Fri, 22 Mar 2019 08:47:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9B2CB3F59C;
	Fri, 22 Mar 2019 08:47:00 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:46:58 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 12/20] uprobes, arm64: untag user pointers in
 find_active_uprobe
Message-ID: <20190322154657.GR13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <88d5255400fc6536d6a6895dd2a3aef0f0ecc899.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88d5255400fc6536d6a6895dd2a3aef0f0ecc899.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:26PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> find_active_uprobe() uses user pointers (obtained via
> instruction_pointer(regs)) for vma lookups, which can only by done with
> untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  kernel/events/uprobes.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index c5cde87329c7..d3a2716a813a 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -1992,6 +1992,8 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
>  	struct uprobe *uprobe = NULL;
>  	struct vm_area_struct *vma;
>  
> +	bp_vaddr = untagged_addr(bp_vaddr);
> +
>  	down_read(&mm->mmap_sem);
>  	vma = find_vma(mm, bp_vaddr);
>  	if (vma && vma->vm_start <= bp_vaddr) {

Similarly here, that's a breakpoint address, hence instruction pointer
(PC) which is untagged.

-- 
Catalin

