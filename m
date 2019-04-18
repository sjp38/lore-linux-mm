Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC15C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6193021479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:31:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="EzI3iDp3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6193021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DA186B0006; Thu, 18 Apr 2019 01:31:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AF336B0007; Thu, 18 Apr 2019 01:31:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 077C66B0008; Thu, 18 Apr 2019 01:31:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id D80216B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:31:22 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id h23so186313vsp.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:31:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=x/TP6sA5sajZCj+xhLCrRc8XOgk3i0sdPUEQY20nxic=;
        b=rbxlp+y7Wspjhj/xay6+tb3+PxDOVUjs/DRIBZYXcWBNplNiFCeVkgVPfNAGt7wwoG
         ZeEFZ1s9C95pzAFHnOVEXNJYRhin1W82OZ1cTy8rgQGHewpLn5bGD1E8ViskcCeJUhc+
         D7/HgM8SbLFcOb9Wd7xVO3agbf5sYgW/AwLodDHrrMIRj5YbTgp2NLBy6IIcy9vQk8Fw
         0d4pd+mnrjFmic6GcVEgcS1NdyttrapvqfH3XqaIvLpNgCVJovKPmkn3MdkYEwH1GGlj
         6KqWrE6tkkggAVD5hq5LWmStqB7uokV8pgGCJ9qCSsvNiDCEXyrpdlrBTLrzJ1JCKo45
         Z/UQ==
X-Gm-Message-State: APjAAAUsey5jLTXn4qY08rdwDGYxeeFSNHAS+b/8WbQIHfwO5v0gaGtf
	VKEtYrQE2gjAEVN0267CxarYJmvXIVXk7CRF3VBjpexFbZyGK1Dc0M3zfOUJOhzU5fHYoIeTjxE
	dghUXv0l3yYRrxitBBXPbfknH9aB2cdp5Y9mo0SUFAH5VZtjsXLnVyH3GoM5oBrCscw==
X-Received: by 2002:a1f:28d7:: with SMTP id o206mr49440376vko.36.1555565482189;
        Wed, 17 Apr 2019 22:31:22 -0700 (PDT)
X-Received: by 2002:a1f:28d7:: with SMTP id o206mr49440353vko.36.1555565481592;
        Wed, 17 Apr 2019 22:31:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565481; cv=none;
        d=google.com; s=arc-20160816;
        b=m92rSXMU/8L9P6mzIZYEVbOmHDimf5bY7uUnPMRzsjbKbBkxh8gyden8PNf/cLOfsZ
         8XbJ4RQl0T0bxDvclHMguWLN2t6Vp+gFN94RP+oV4AzgwKnWT3xoDrQC9bxYy9wa0IUu
         2O+lJG3/Eo+QwTOaUADNAr0FGxGikWYYIep9expKSMReI8I+bP43udAMoAY1QDKSalBz
         YxVPQ+w8xCwasYdeUNTf0ijv+vGW0U/RrOsrTWJWv98XCVwcRVZeuvFSCXSr82VHs9a0
         yjyTNfG5f9uuSDpwuo9t4x++LWrnrtdmOMjO1KItXSV9ntWs7RG8x+uaSBchGeT0MH1p
         xDJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=x/TP6sA5sajZCj+xhLCrRc8XOgk3i0sdPUEQY20nxic=;
        b=sUj7AHsudP1h+MejlhTfTtvxK62Ph2mplaaCZ38nsqHTCFUCv3ubjGW8BYpjRYvuym
         pZsxPxqqv+Jodi+2knGOXt7dBhrlbANiRHoJLoit54FR+QoMNz1sxkbK0SDbVNuaSI0+
         XWzaDUKkoeFvf8wDClHO5GRXqZ/YdaJI+KfyJ/9J7wKXIpePjKU86ZhvYJ/mGrKZ09KB
         IkahgSs5QJOzNJqLFPPVhtYuJ04qspHvLOaQj5MS3VFS+rJp65vs4ss85nQQAkD0vGmX
         qgDTNdEGqfpFcpDwa3lMWmpt0qTymQRssvGFEou1Y0vxJkLb4hadCDvDUZI+K+wVtWK+
         kK2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=EzI3iDp3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor381577vsc.84.2019.04.17.22.31.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:31:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=EzI3iDp3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x/TP6sA5sajZCj+xhLCrRc8XOgk3i0sdPUEQY20nxic=;
        b=EzI3iDp3/PwAWlzrGsEJt8pSHXmaq0t/LgPtPVDCMvm+jD1PtYJaid1ZV/xGYcmd5I
         lwY7VI0ze2TcOE31b8X8Debj5ZrSlCq5cQ8C17/vua658wrm2sWXYl5IeWCxo5rmKiWr
         /FetUT2kibkKsifqxGloTOoB5vk3HAZhnG57A=
X-Google-Smtp-Source: APXvYqwaLkNS6f9cCfBlhxM3iB4UPOOIG1dWb37pvwvgqWrqaBuSAyMpTVsS0vLRSxJDVRzqAcck/Q==
X-Received: by 2002:a67:e28e:: with SMTP id g14mr50247252vsf.59.1555565480359;
        Wed, 17 Apr 2019 22:31:20 -0700 (PDT)
Received: from mail-vs1-f53.google.com (mail-vs1-f53.google.com. [209.85.217.53])
        by smtp.gmail.com with ESMTPSA id c192sm930874vka.10.2019.04.17.22.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:31:19 -0700 (PDT)
Received: by mail-vs1-f53.google.com with SMTP id o10so491257vsp.12
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:31:18 -0700 (PDT)
X-Received: by 2002:a67:bc13:: with SMTP id t19mr2611825vsn.222.1555565478030;
 Wed, 17 Apr 2019 22:31:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-10-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-10-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:31:06 -0500
X-Gmail-Original-Message-ID: <CAGXu5jKx_A8GsFWWABKwEXmL5dTMKjk3Ub9GoE7Do9NcZ_ai=A@mail.gmail.com>
Message-ID: <CAGXu5jKx_A8GsFWWABKwEXmL5dTMKjk3Ub9GoE7Do9NcZ_ai=A@mail.gmail.com>
Subject: Re: [PATCH v3 09/11] mips: Use STACK_TOP when computing mmap base address
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, 
	Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, 
	linux-riscv@lists.infradead.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:32 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> mmap base address must be computed wrt stack top address, using TASK_SIZE
> is wrong since STACK_TOP and TASK_SIZE are not equivalent.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/mm/mmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index 3ff82c6f7e24..ffbe69f3a7d9 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
>
>  /* gap between mmap and stack */
>  #define MIN_GAP                (128*1024*1024UL)
> -#define MAX_GAP                ((TASK_SIZE)/6*5)
> +#define MAX_GAP                ((STACK_TOP)/6*5)
>  #define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>
>  static int mmap_is_legacy(struct rlimit *rlim_stack)
> @@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>         else if (gap > MAX_GAP)
>                 gap = MAX_GAP;
>
> -       return PAGE_ALIGN(TASK_SIZE - gap - rnd);
> +       return PAGE_ALIGN(STACK_TOP - gap - rnd);
>  }
>
>  #define COLOUR_ALIGN(addr, pgoff)                              \
> --
> 2.20.1
>


-- 
Kees Cook

