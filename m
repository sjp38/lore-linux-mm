Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 360AEC4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E59D92083B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:00:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1U/t75gP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E59D92083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91EFC8E018B; Mon, 11 Feb 2019 18:00:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CF538E0189; Mon, 11 Feb 2019 18:00:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7971C8E018B; Mon, 11 Feb 2019 18:00:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37EF88E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:00:15 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t6so470823pgp.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:00:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wYva7BRCTD4pLVk0ePeliF8AvH48fT/H37gCYYyrEKk=;
        b=ok5eBn7xkja6C45YwY5WAX8BEl5s9AOgEbbhIuyvZW8aZUnjWjtII2bixwMaYr/RAk
         eG61IbFzkCHNmg19FozxwfwGjQqbl3UDvMy1Ibd96Th+AAPHGiwMQeHPFF94ZYdFE1DA
         3U5KdM3roW5E8RdamQVbDkIR100t4Sd7lf4WKv6N5fB2GHWh9khm3d48iUkZ3thKmV68
         CY+S/UqCM0oW6ILwpEu0HPUVULisNQmOBv9IX+3x6pZBtxqljAAGMGcE6mtdhjlib3lK
         JcKX4Axroh97IIG/Ii/paNxIRHJ+zbEHVBsRAU0/hAG00aekcoHx4u8EUOwNgg6I/mNC
         iflA==
X-Gm-Message-State: AHQUAuZPxFqJHC2JiO4FbgQ8+tf64az0RYNS6/z13ggVouAp2mzaFyZb
	gt27qJ4y2th9gFJSX6pageqxHNTZCyQgf5quFCFmpOejf8e3WV2Jr1v6PhXxm5n5qsEtgZj16Tm
	5q2BEiL3mROtd3gn27XTYXjzVWPhKp4pQya5QYHVnvk7kkr8R8qdADETHbJyuKOkMZA==
X-Received: by 2002:a63:100c:: with SMTP id f12mr642871pgl.324.1549926014866;
        Mon, 11 Feb 2019 15:00:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYLg5TKh6F9LkzECM9oN+ju5tMO7W+Xc1dyIE/S3M8Hynw6lCd/ZRnXOs8/lG1Xis4kBD9d
X-Received: by 2002:a63:100c:: with SMTP id f12mr642803pgl.324.1549926013956;
        Mon, 11 Feb 2019 15:00:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549926013; cv=none;
        d=google.com; s=arc-20160816;
        b=cNdl5NPWjIg3gcRQed1M8Yg3iKhJWxUGTuiebyqJ/XOtxjJ/MjjnM6gdUkqAc1wtg6
         h9f+suyw4gOUkD5xFT8CwHP7M3eXkYX1e7kuS3Xmv3JU7ICVrQaccK6dAzi0wvroyDGK
         6RSkGBTU7qWDosALp8bgbTmr9ffqQnfPhAX+7KY3gctX5YVWi6/f4SkgBV6SRBG4/lLM
         za9FhKu2AfPzfkg68Yb/T8Vl4mKOTgY0zRhT+EC65w5WDMbWbesXYxjglQj4TeT1bz0i
         9WhQQDJbpdQSEquyrhf2ea3ZR8b5P3ZDn4g++wuRYW2c/6GoA7C77gfJc3zZYvsCzIAL
         iHOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wYva7BRCTD4pLVk0ePeliF8AvH48fT/H37gCYYyrEKk=;
        b=vt/HrNAq/nuTiTiTewXlvdxqkQSPLaDVPFtQVJANTNQZ9aALC1iHajcmqoX9OqKNtT
         cL80Sdsgb0Wwq2Tvse1DxeLw2x9eBV1yik7zoDNKmuxxvuKh8sfny/o3u4t5lWZYo7Rf
         wZu8kBBUv+SZ91/gcCiiRSF/34HE/pg4x3krl0lgVIqYL9qvunQQerTj2yc1uhQ8L+1B
         NUfVHYexK1lMC9Xnq5x/fniw6e+KrssK1nUfs54pkevnxLg9IOoRSzKlxy867+AnO/ZX
         r4EkB0m9tlU9x9OugRqX3NwSr3pGbWyanDNfnJ+B44iF2J7dSDCT1KvPztnsnmg1UbT7
         le9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="1U/t75gP";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y13si5799592pgf.524.2019.02.11.15.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:00:12 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="1U/t75gP";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 604B6218AD
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:00:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549926011;
	bh=RdARy0D2d2IImaaPeK+pm12Sk+zLe4PWvJ4Rp1UMq8o=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=1U/t75gPlPzV0GunWAAj580UQ0M8IQO7b/0ocVXPNelID0RVlkdhMj4hsKGasjksD
	 EVjIa8/xD1Gua910hLYZzaNPVVqqmjn0XIr7KSRz+zjA74djGWCRG2PhI6a6hymlpQ
	 09sU7CdhUpL1YU0IzM5ExJ2bmf1i/5n92jcXqhYA=
Received: by mail-wm1-f46.google.com with SMTP id d15so956794wmb.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:00:11 -0800 (PST)
X-Received: by 2002:a7b:cc13:: with SMTP id f19mr377508wmh.83.1549926009812;
 Mon, 11 Feb 2019 15:00:09 -0800 (PST)
MIME-Version: 1.0
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-14-rick.p.edgecombe@intel.com> <20190211190925.GQ19618@zn.tnic>
In-Reply-To: <20190211190925.GQ19618@zn.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 11 Feb 2019 14:59:55 -0800
X-Gmail-Original-Message-ID: <CALCETrX2AOTTZOQafZgOFxiQsFgdYHVaLonXTqTa3RUs5MPVUQ@mail.gmail.com>
Message-ID: <CALCETrX2AOTTZOQafZgOFxiQsFgdYHVaLonXTqTa3RUs5MPVUQ@mail.gmail.com>
Subject: Re: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
To: Borislav Petkov <bp@alien8.de>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:09 AM Borislav Petkov <bp@alien8.de> wrote:
>
> On Mon, Jan 28, 2019 at 04:34:15PM -0800, Rick Edgecombe wrote:
> > This adds two new functions set_alias_default_noflush and
>
> s/This adds/Add/
>
> > set_alias_nv_noflush for setting the alias mapping for the page to its
>
> Please end function names with parentheses, below too.
>
> > default valid permissions and to an invalid state that cannot be cached in
> > a TLB, respectively. These functions to not flush the TLB.
>
> s/to/do/
>
> Also, pls put that description as comments over the functions in the
> code. Otherwise that "nv" as part of the name doesn't really explain
> what it does.
>
> Actually, you could just as well call the function
>
> set_alias_invalid_noflush()
>
> All the other words are written in full, no need to have "nv" there.

Why are you calling this an "alias"?  You're modifying the direct map.
Your patches are thinking of the direct map as an alias of the vmap
mapping, but that does seem a bit backwards.  How about
set_direct_map_invalid_noflush(), etc?

--Andy

