Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49D8CC282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:11:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E4322184E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E4322184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FD506B0006; Fri, 24 May 2019 06:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B09C6B0007; Fri, 24 May 2019 06:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69CC36B0008; Fri, 24 May 2019 06:11:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1376B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:11:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so13499099edc.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:11:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hzoQiEzatCzqSry/wFJPSh0ZjGEvG34vCJzJ1BSxvEU=;
        b=PDdIZkcl6VwIQJHAIBqguS1cqi3o1a9spB2XZfJTPMO3kmbC4zxuygTJ7UdsPkvPy0
         vlQn2cY4fZyxr2aBpWL1GOiERsZh2N/RdXwhc+7x8CI2nAAtibOpqn/OcdmlGaRaRUJ5
         P0w4X8tW4sReqS7k5Wg8gO3mWf8LgjrzqU8iK+PR1oDxkh2e4fuZoH/CLIAI+Ssjc9ZN
         UhdoidC2mhz8PnpkvDiFrF/gdhzWkBH4sYcNKX6+6KVHyhxZWVgC1bqVpgsujZJDQUyo
         f4hn9UtWyiuSScq/vpcZ9+09ysir6W7k5cfHHe4QV4PhqMIWEsbVilUJeYBCxv/it0om
         CnwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWsz6nOnkIGgym+XpQDXUoShCucRZ+DAVEdFaT0i5DXlw/qh2w9
	3PVtab7a/UYDWxkR+QX9lJT+9t/+Gc+e5mK8UxDQv8UHfpkAM+wQRCwKF6rUKOJIjDkNDgifd3l
	DWCHJNBvp2gKUZpi7gtoWlweRPjtBzzfNoJnqEJ8WHyixfNqFbngJXlnJxcTYtygN9A==
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr73842540edo.205.1558692715699;
        Fri, 24 May 2019 03:11:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd9sLW6aknCow2VjF4CjqRR59KlpnWPdTwW7WZuy+gm7aLBDDKUG6GOyTP8AzdrceTnQ8E
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr73842465edo.205.1558692714863;
        Fri, 24 May 2019 03:11:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558692714; cv=none;
        d=google.com; s=arc-20160816;
        b=ugLIKiPmBHI2MyEQlGL5cClYqdxbe3tM+ICa8RHO7wa4I+fEUGEpC8wjXxgoG1CLW6
         pkghZn0bw06sSyG0A3ZfonPydOMnVsxx1P5ymhSqEE/fu1/Tpa5UyahbhEiLqyFnakNb
         73hLIXjBCqRCxkeK/7ntp6bFQ3OPZFmdRYh93jMUbwy/j8RhihBiNEulhqUAALc3gQTv
         IPGZqocuhrI7raWBDsovNUUfHK5wkKsJIhbzQakSV7wbi9ytFQC3h3kT5Xro6U7x11TH
         tcvxnc+6wBfeesqgu+w0cItk+i5HGgpghRPb5knaI5sR5tEk+L5rAK4geD0USfFVjbO4
         jSeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hzoQiEzatCzqSry/wFJPSh0ZjGEvG34vCJzJ1BSxvEU=;
        b=DCDMUlU9KkgRiEaGjrIKhO0X54gyXZ7ZOLTxMM7MSgvVR1POpVgIo0RCzIQ0Y1FHAf
         JUly8C1eLm1UBxVnOXtxPnMIYWU6N/FrDR6CwjDlxFGt30BLTvkbknthMpoSWSp7Xxd1
         nrZP46BORj+hicCBb/ZcHNt8zOxz4hJantkeG0zsS+smV0lbIAbVgJBF5hDOW/KZ+BA2
         DAAljRUzH//4/i4lNXH9BoC88sIk1zl8NCxTzn/OEZ9taCpsfY29TzAAuEeIuSt5++qp
         8RVn8XrZNy7D7YF5/+8Vp5SUmoua6pV8HcaPGj99kQT8ddGqiodG3CIdgDV0n0ztmnRB
         Q7lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l20si1583268edc.154.2019.05.24.03.11.54
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 03:11:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9EB11A78;
	Fri, 24 May 2019 03:11:53 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 85B933F703;
	Fri, 24 May 2019 03:11:47 -0700 (PDT)
Date: Fri, 24 May 2019 11:11:40 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190524101139.36yre4af22bkvatx@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 03:49:05PM -0600, Khalid Aziz wrote:
> On 5/23/19 2:11 PM, Catalin Marinas wrote:
> > On Thu, May 23, 2019 at 11:51:40AM -0600, Khalid Aziz wrote:
> >> On 5/21/19 6:04 PM, Kees Cook wrote:
> >>> As an aside: I think Sparc ADI support in Linux actually side-stepped
> >>> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel must
> >>> be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI
> >>> for kernel code.") I think this was a mistake we should not repeat for
> >>> arm64 (we do seem to be at least in agreement about this, I think).
> >>>
> >>> [1] https://lore.kernel.org/patchwork/patch/654481/
> >>
> >> That is a very early version of the sparc ADI patch. Support for tagged
> >> addresses in syscalls was added in later versions and is in the patch
> >> that is in the kernel.
> > 
> > I tried to figure out but I'm not familiar with the sparc port. How did
> > you solve the tagged address going into various syscall implementations
> > in the kernel (e.g. sys_write)? Is the tag removed on kernel entry or it
> > ends up deeper in the core code?
> 
> Another spot I should point out in ADI patch - Tags are not stored in
> VMAs and IOMMU does not support ADI tags on M7. ADI tags are stripped
> before userspace addresses are passed to IOMMU in the following snippet
> from the patch:
> 
> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
> index 5335ba3c850e..357b6047653a 100644
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -201,6 +202,24 @@ int __get_user_pages_fast(unsigned long start, int
> nr_pages
> , int write,
>         pgd_t *pgdp;
>         int nr = 0;
> 
> +#ifdef CONFIG_SPARC64
> +       if (adi_capable()) {
> +               long addr = start;
> +
> +               /* If userspace has passed a versioned address, kernel
> +                * will not find it in the VMAs since it does not store
> +                * the version tags in the list of VMAs. Storing version
> +                * tags in list of VMAs is impractical since they can be
> +                * changed any time from userspace without dropping into
> +                * kernel. Any address search in VMAs will be done with
> +                * non-versioned addresses. Ensure the ADI version bits
> +                * are dropped here by sign extending the last bit before
> +                * ADI bits. IOMMU does not implement version tags.
> +                */
> +               addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();
> +               start = addr;
> +       }
> +#endif
>         start &= PAGE_MASK;
>         addr = start;
>         len = (unsigned long) nr_pages << PAGE_SHIFT;

Thanks Khalid. I missed that sparc does not enable HAVE_GENERIC_GUP, so
you fix this case here. If we add the generic untagged_addr() macro in
the generic code, I think sparc can start making use of it rather than
open-coding the shifts.

There are a few other other places where tags can leak and the core code
would get confused (for example, madvise()). I presume your user space
doesn't exercise them. On arm64 we plan to just allow the C library to
tag any new memory allocation, so those core code paths would need to be
covered.

And similarly, devices, IOMMU, any DMA would ignore tags.

-- 
Catalin

