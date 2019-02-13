Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30C50C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:48:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6E04222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:48:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6E04222BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A438E0002; Wed, 13 Feb 2019 07:48:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FAE18E0001; Wed, 13 Feb 2019 07:48:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 710F18E0002; Wed, 13 Feb 2019 07:48:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 142C48E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:48:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so976974edh.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:48:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oTIOdswIZvO+jxCXUmKlZKTfqpu7OQoyvM3/PhNuASY=;
        b=YybBYX2AGShgwnsfDDKZxO4qok9P9ZgYXurxgixLFukhTe5/o5k83sSl2s2ajULpLt
         dh9FhMoWwWtE0ZelZUo4rwD6sOrVro/KzAnHKt2V2TDaNZM1O3xeSJeVqaHMUVqU51e+
         qWhqSygRjl+2PWLs0BZDuqFbyEIF0HwC77d9e98PB1KdZn8SPGcOIXVSbrrJrX2hX9hy
         DsiCjl3CQmOIw1rZ9BWm2aYRtTNkStySJbnc4rI4DBqoS1dyPP66ea24CE4xFH4S4tp4
         gR3vN/T21lgtmMnCs3zLxs4u/PCIlVAp/GR8QqiJK4yN4+Z5wlIoazQrDvLgwiOtsu4H
         OSkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuaUEgQMOq6VGhz9vQ8ZM4XiggjFRr6c9kwPZcTdhGeUNXr5kJoH
	XO9iUlw4ODPWl/e1nIPby0hLZu1dLIl+BBFvULEW7olAKVoZBwVG/+DeRlMUyE7BLP4xOIytPGE
	DsqHqLu5NeDsvDRHWjXpYIWfA0VuUWQEeYmrmvUZxiLoy18J6/VauCKyRwq41E/ZCEA==
X-Received: by 2002:a50:a1e5:: with SMTP id 92mr257232edk.181.1550062133633;
        Wed, 13 Feb 2019 04:48:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayLL5LwJXwMycwyKsoe51O+60D1agjPeXGQrHzDrVhTPGFUdXoe9JBIvGlPoU68faBssiz
X-Received: by 2002:a50:a1e5:: with SMTP id 92mr257187edk.181.1550062132724;
        Wed, 13 Feb 2019 04:48:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550062132; cv=none;
        d=google.com; s=arc-20160816;
        b=0SSPhWz6YXBTZpeXNu4579MNB9YmPWDQvLaaP+Rz23L1ft+/mxYE87czeKZ8epst0s
         wfvjx6wtnUUHnCCH6JN3yQiEJNpauMILn308Dh8kqLYdlT7ahcP0Y1GxFfxdqcF+yWIU
         CMqLPQOtXZ4e312WZmTKdLftgA8nRgL8MDCafMP5+nrezGrkgSx1Y/8QYoV0Y6btWQj+
         Go+mWFiT5yH8TRpxzVWYed8NuVzyFoSzbWhmdN4jk6uuLlxl+kxf5TNQx63Zv1+yT332
         5GHrhtVOFbuHiZWtMn/60gCWg5cbjwXPHwNnyhfSxITFiEJja3ij0B0FTWcqgaZ/w/27
         6m2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oTIOdswIZvO+jxCXUmKlZKTfqpu7OQoyvM3/PhNuASY=;
        b=kyCu9ckcURn9AAzVwOAKHzrbZoOUsQoaVB2Bg5/iNu4/Mh40xB10AG+HJKm66QtEbR
         QJrv1DCPC9MC65TP6wdSxSPGYnPUUSs5JNI/Jc6T0KqPZBWHgfk+IGJQitLLpuItiFUg
         cVMWZ3RNyiE+xrk/Yu8nshZoJ3Sr3aM+EecKpp/C0PGzlrONhPqb7XFzoM17egqT9AU6
         b0qXUceoSX2wqTz2u2o9k54hY3YoRGxtF0NIdr6uIEu6q//u+4+EYcNjovIrYRC3hMXL
         rDD2FCv2Pn2BOg7/31DrdhLime72F20QvMbjtc8R94gYL+ViK5vyXeWvLcBtPk1JopoB
         cRHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p4-v6si4815343ejj.5.2019.02.13.04.48.52
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 04:48:52 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4073080D;
	Wed, 13 Feb 2019 04:48:51 -0800 (PST)
Received: from brain-police (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DE75E3F557;
	Wed, 13 Feb 2019 04:48:46 -0800 (PST)
Date: Wed, 13 Feb 2019 12:48:43 +0000
From: Will Deacon <will.deacon@arm.com>
To: Jann Horn <jannh@google.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Hansen <dave.hansen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-api@vger.kernel.org
Subject: Re: [PATCH] mmap.2: describe the 5level paging hack
Message-ID: <20190213124842.GD1912@brain-police>
References: <20190211163653.97742-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211163653.97742-1-jannh@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jann,

On Mon, Feb 11, 2019 at 05:36:53PM +0100, Jann Horn wrote:
> The manpage is missing information about the compatibility hack for
> 5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
> Allow userspace have mappings above 47-bit"). Add some information about
> that.
> 
> While I don't think any hardware supporting this is shipping yet (?), I
> think it's useful to try to write a manpage for this API, partly to
> figure out how usable that API actually is, and partly because when this
> hardware does ship, it'd be nice if distro manpages had information about
> how to use it.
> 
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
> This patch goes on top of the patch "[PATCH] mmap.2: fix description of
> treatment of the hint" that I just sent, but I'm not sending them in a
> series because I want the first one to go in, and I think this one might
> be a bit more controversial.
> 
> It would be nice if the architecture maintainers and mm folks could have
> a look at this and check that what I wrote is right - I only looked at
> the source for this, I haven't tried it.
> 
>  man2/mmap.2 | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 8556bbfeb..977782fa8 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -67,6 +67,8 @@ is NULL,
>  then the kernel chooses the (page-aligned) address
>  at which to create the mapping;
>  this is the most portable method of creating a new mapping.
> +On Linux, in this case, the kernel may limit the maximum address that can be
> +used for allocations to a legacy limit for compatibility reasons.
>  If
>  .I addr
>  is not NULL,
> @@ -77,6 +79,19 @@ or equal to the value specified by
>  and attempt to create the mapping there.
>  If another mapping already exists there, the kernel picks a new
>  address, independent of the hint.
> +However, if a hint above the architecture's legacy address limit is provided
> +(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
> +book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the
> +kernel is permitted to allocate mappings beyond the architecture's legacy
> +address limit.

On arm64 we support 36-bit, 39-bit, 42-bit, 47-bit, 48-bit and 52-bit user
virtual addresses, some of which also enforce a particular page size of 4k,
16k or 64k. With the exception of 52-bit, the user virtual address size is
fixed at compile time and mmap() can allocate up to the maximum address
size.

When 52-bit virtual addressing is configured, we continue to allocate up to
48 bits unless either a hint is passed to mmap() as you describe, or
CONFIG_ARM64_FORCE_52BIT=y (this is really intended as a debug option and is
hidden behind EXPERT as well as being off by default).

One thing that just occurred to me is that our ASLR code is probably pretty
weak for addresses greater than 48 bits because I don't think it was updated
when we added 52-bit support. I'll take a deeper look when I get some time.

Will

