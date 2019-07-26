Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 572EDC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:15:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFDAE22BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:15:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="Fb1/iCLj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFDAE22BE8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FFBB6B0003; Fri, 26 Jul 2019 16:15:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B01B8E0003; Fri, 26 Jul 2019 16:15:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59E6F8E0002; Fri, 26 Jul 2019 16:15:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 397B46B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:15:28 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e20so59532489ioe.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 13:15:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=9WyyFtGDa/oI2K0SoorWyGV62gLsK5AqqZUD+AVwi30=;
        b=Si4DpNgBHkTN2r+ROcS34MwwfNUcG3rY2OydVHcKAXNw9eXbaA6xcZkb+apyR/Dw5P
         d/AXo0GljsVCd36HKwZdjYF+C2PjDODfxrQcjlVdmmDcFd2bWsTGp0P+vvyvRT8bg1BY
         fyLfXKIz9Uf49LkhkEaFXWiwzv1KNLv0PqNdRZeZJvqyBa8zWSJyEptKO1ANVeRvpoLW
         JmKr650sl1Wv1+CRASSE72AqfmyAeaEptF+8b4NObdnhCkF9Gg6fxyT4ylrdW9XURrC6
         qDHhX5lslzn6d29380LeVH2Vpk6dCXbXfkvUgHq8JUHFcnvxRXHjWP9sN5ku7iWKUQuW
         w1yw==
X-Gm-Message-State: APjAAAWcdWLsBwr612ANEgc45by7Hn6G0cTtDEU1OauIL+9alTKj5Za5
	WclBCF6U2i+PtZFPDLj+SbOEJbY+ixqLjbGZVuTh6RKQMmSLD/KTaVTamE1wW2+S6lRAZ9m8noY
	CQmSBfHbBKF5OIgz0xyr6r7XG3z/7068s4nQpou6ZRJiDE4bd6luvkT9wnncy/kGCpQ==
X-Received: by 2002:a05:6638:52:: with SMTP id a18mr100483185jap.75.1564172127938;
        Fri, 26 Jul 2019 13:15:27 -0700 (PDT)
X-Received: by 2002:a05:6638:52:: with SMTP id a18mr100483108jap.75.1564172127083;
        Fri, 26 Jul 2019 13:15:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564172127; cv=none;
        d=google.com; s=arc-20160816;
        b=yaDbvmYa1+sRJssOA7MamrElP2Ur+wENMFkBp3AvWMdnvzsphUsN/6jt3C9qTlPxHg
         Hx7MTaY1nP1SIPFdFjzQbkICILZ4OrDhawpw2+eZ8xvcJVIeyAToMp97/5Xm7DCS1wjz
         pln5fsdool3W3KUZWP54Szk09RsT7PbagobpQsY0eM3h6DEctW35FKwm2/dRRdJN1DZk
         vQmHS41P1zhtVXqQYdmIsEdyep2zKJLAUH4hJ9rSYp8BedMXAX+W7U1Y06QsWpdkXeUj
         dGon+wDfn2ahoiqmjUxAft1ieHN+Wrh9sIKYnUaN1lnj6vMaC8NhfnYNckoWjSXO+V0k
         PLeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=9WyyFtGDa/oI2K0SoorWyGV62gLsK5AqqZUD+AVwi30=;
        b=kV3eUSzDzriwndG0qYWkQMDUdiAiHhAEyhLvYB8d2FyKj7ubXUEajlWMU0nSJVQW1j
         C0gCbNqdu3DBi6HstY1nlH/v8/AXdNF5kiZnaWfUzeaypJ6UpEodBGrS3FD3XejItTGp
         UhRujb2Wm5veU64goSN90Nh6pyP8kwP6N9/iOshGfYChAGvKvU/3IrcE/pF1gLkkPeWa
         v1fgk62sZTe/YzzhAaZsd1RNmyfSkDcZcokVZiD5Ecwctp+3pT0mVR7IjdOmhrUtX4uv
         SIBmrMBdUbIVSlkVgx261PiYYxSKvQjO78A9TdTKU2gSrVzbWdFVsgez0IYJzt4ETZO4
         r+6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b="Fb1/iCLj";
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor125502211jae.3.2019.07.26.13.15.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 13:15:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b="Fb1/iCLj";
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=9WyyFtGDa/oI2K0SoorWyGV62gLsK5AqqZUD+AVwi30=;
        b=Fb1/iCLjf/NTOtNNhbSpzOTh2HSJi8m3cogsN6IlhBqqXfIsc8b6/c5d54iSoV9tf2
         4IXGW09arBQ1PLR9BDnrrDFFZeThGRlGJb1zcCHOBX/uSTmXUxjsHC5Wtn6a5v+3nRf1
         oJ+3ikPkGPiZj3GBLWuU4dq/hVwWrnpaCbKsm+AtPr1gurUkCfgxi0HX4Wk1tLHikQWj
         wT6aPzheIXgs4SsO5mbwNoQsUAkKQE6saF99TaAMGMeKeDLlNQIkXR1NdUvfX7qT7FYa
         eTNtjQNzwfQ9/SFfxUX4M5xnr2uLMMhN3nt8caAvX1DdPVHS/1ToO3yYaSeHBD04DYMw
         oJSw==
X-Google-Smtp-Source: APXvYqzsqQtosoZzCBtwEUSq2JCLj43JNgQACq9apPNl9xsQbwBsE8qGPx2yPCPSFW8euGk6L+kJ2A==
X-Received: by 2002:a02:5185:: with SMTP id s127mr28951962jaa.44.1564172126478;
        Fri, 26 Jul 2019 13:15:26 -0700 (PDT)
Received: from localhost (67-0-24-96.albq.qwest.net. [67.0.24.96])
        by smtp.gmail.com with ESMTPSA id a8sm40604193ioh.29.2019.07.26.13.15.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 13:15:25 -0700 (PDT)
Date: Fri, 26 Jul 2019 13:15:24 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Alexandre Ghiti <alex@ghiti.fr>
cc: linux-arm-kernel@lists.infradead.org, Albert Ou <aou@eecs.berkeley.edu>, 
    Kees Cook <keescook@chromium.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>, 
    Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    Paul Burton <paul.burton@mips.com>, 
    Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>, 
    linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
    linux-riscv@lists.infradead.org, Daniel Cashman <dcashman@google.com>, 
    Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH REBASE v4 14/14] riscv: Make mmap allocation top-down by
 default
In-Reply-To: <6b2b45a5-0ac4-db73-8f50-ab182a0cb621@ghiti.fr>
Message-ID: <alpine.DEB.2.21.9999.1907261310490.26670@viisi.sifive.com>
References: <20190724055850.6232-1-alex@ghiti.fr> <20190724055850.6232-15-alex@ghiti.fr> <alpine.DEB.2.21.9999.1907251655310.32766@viisi.sifive.com> <6b2b45a5-0ac4-db73-8f50-ab182a0cb621@ghiti.fr>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019, Alexandre Ghiti wrote:

> On 7/26/19 2:20 AM, Paul Walmsley wrote:
> > 
> > On Wed, 24 Jul 2019, Alexandre Ghiti wrote:
> > 
> > > In order to avoid wasting user address space by using bottom-up mmap
> > > allocation scheme, prefer top-down scheme when possible.
> > > 
> > > Before:
> > > root@qemuriscv64:~# cat /proc/self/maps
> > > 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> > > 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> > > 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> > > 00018000-00039000 rw-p 00000000 00:00 0          [heap]
> > > 1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> > > 155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> > > 155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> > > 155556f000-1555570000 rw-p 00000000 00:00 0
> > > 1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
> > > 1555574000-1555576000 rw-p 00000000 00:00 0
> > > 1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> > > 1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> > > 1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> > > 155567a000-15556a0000 rw-p 00000000 00:00 0
> > > 3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]
> > > 
> > > After:
> > > root@qemuriscv64:~# cat /proc/self/maps
> > > 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> > > 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> > > 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> > > 2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
> > > 3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
> > > 3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> > > 3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> > > 3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> > > 3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
> > > 3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
> > > 3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> > > 3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> > > 3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> > > 3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
> > > 3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]
> > > 
> > > Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> > > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > > ---
> > >   arch/riscv/Kconfig | 11 +++++++++++
> > >   1 file changed, 11 insertions(+)
> > > 
> > > diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> > > index 59a4727ecd6c..6a63973873fd 100644
> > > --- a/arch/riscv/Kconfig
> > > +++ b/arch/riscv/Kconfig
> > > @@ -54,6 +54,17 @@ config RISCV
> > >   	select EDAC_SUPPORT
> > >   	select ARCH_HAS_GIGANTIC_PAGE
> > >   	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
> > > +	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
> > > +	select HAVE_ARCH_MMAP_RND_BITS
> > > +
> > > +config ARCH_MMAP_RND_BITS_MIN
> > > +	default 18
> > Could you help me understand the rationale behind this constant?
> 
> 
> Indeed, I took that from arm64 code and I did not think enough about it: 
> that's great you spotted this because that's a way too large value for 
> 32 bits as it would, at minimum, make mmap random offset go up to 1GB 
> (18 + 12), which is a big hole for this small address space :)
> 
> arm and mips propose 8 as default value for 32bits systems which is 1MB offset
> at minimum.

8 seems like a fine minimum for Sv32.

> > > +
> > > +# max bits determined by the following formula:
> > > +#  VA_BITS - PAGE_SHIFT - 3
> > I realize that these lines are probably copied from arch/arm64/Kconfig.
> > But the rationale behind the "- 3" is not immediately obvious.  This
> > apparently originates from commit 8f0d3aa9de57 ("arm64: mm: support
> > ARCH_MMAP_RND_BITS"). Can you provide any additional context here?
> 
> 
> The formula comes from commit d07e22597d1d ("mm: mmap: add new /proc 
> tunable for mmap_base ASLR"), where the author states that "generally a 
> 3-4 bits less than the number of bits in the user-space accessible 
> virtual address space [allows to] give the greatest flexibility without 
> generating an invalid mmap_base address".
> 
> In practice, that limits the mmap random offset to at maximum 1/8 (for - 
> 3) of the total address space.

OK.

> > > +config ARCH_MMAP_RND_BITS_MAX
> > > +	default 33 if 64BIT # SV48 based
> > The rationale here is clear for Sv48, per the above formula:
> > 
> >     (48 - 12 - 3) = 33
> > 
> > > +	default 18
> > However, here it is less clear to me.  For Sv39, shouldn't this be
> > 
> >     (39 - 12 - 3) = 24
> > 
> > ?  And what about Sv32?
> 
> 
> You're right. Is there a way to distinguish between sv39 and sv48 here ?

This patch has just been posted:

https://lore.kernel.org/linux-riscv/alpine.DEB.2.21.9999.1907261259420.26670@viisi.sifive.com/T/#u

Assuming there are no negative comments, we'll plan to send it upstream 
during v5.3-rc.  Your patch should be able to set different minimums and 
maximums based on the value of CONFIG_RISCV_VM_SV*


- Paul

