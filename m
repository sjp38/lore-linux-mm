Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FCB4C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E22B2084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:46:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wa35xolY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E22B2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C0C68E0005; Mon, 17 Jun 2019 11:46:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8709A8E0001; Mon, 17 Jun 2019 11:46:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7387D8E0005; Mon, 17 Jun 2019 11:46:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7A28E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:46:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so7984111pgk.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AEH93xRAAUZFLy3im83sD7R1OWMiuy7/9NIIATHOAZ8=;
        b=ojaWyNSuV0z16Isc1Kxe/kr6aDcfYXCCEr7gA9Hfp4LICliZ2ESn+qIknW1kedZbsF
         Am6jyCyH+A0pdKr/7f/mFitM6TT9eO1d3vGPQsKHRES0KGR3OLp59957fZopP5jYxGKc
         XyA1mnh2zjuR//WNzsK7bNjEI7YYVYGFRvas5eoZ7d5DPQspYYE8T/ugnLn1ZbpOAVhd
         MPbKUVJNrcBHhFnvEUYOv0DCC/9SniRu9PLmvtK5NnCwSDgnsL0simf3k0A8Mpg/uUGM
         quSTZDrzna8dCRCYfCM+jcxkeunV8yjte3gWPlR/vkM/ty/bOgAu103wd5pvloqo+WpM
         EkbA==
X-Gm-Message-State: APjAAAXy2L1q823e0jvp7dKvFTIcM2EY9G5UOzCtJV9aDZ2oN8BpFBbz
	CXRVBjW3rDwTy96Ql78O8GR5yq9xarm0kiefgHEMDV/Om1+s3ryHsPntntI/9fZJo058BUYlXQx
	m3pmdkr1IfkykEpgW5kCDTMn89w7SRaf2T3jdtp+hhYE8j8QBGe5FLKnuiMGBd6sYjg==
X-Received: by 2002:a65:56c2:: with SMTP id w2mr50856601pgs.49.1560786386759;
        Mon, 17 Jun 2019 08:46:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6KczuAaCTEXXfLV0Q0+9NWWYyPIzTwGFfQAQfhKiZMzu0KGp9xDnzprHyQ9immZFJzufF
X-Received: by 2002:a65:56c2:: with SMTP id w2mr50856545pgs.49.1560786385912;
        Mon, 17 Jun 2019 08:46:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560786385; cv=none;
        d=google.com; s=arc-20160816;
        b=tMZojfgXuWH1ff3OQ3VsLc9PfTkzUxsTxt4b9bvywrqdDowgBtO1q1Qfoa0SNqGTiO
         OZvsAdzDSLP7nGxiFhG6uYBAYWf/MY5Rx1pWm5wYunRpmElYZ7pWSF4KwezCPXz5ztKj
         OOZ2Ja2fkMpR2GZJn0/YNQoz9Z7DmYqzE6NKRGrjgmmOsyGHay0bzWihZgOpp4U9dNJl
         dfIxGFv5zbUIOgdhJFW9jQ3G8oWGxG+K3hdWfVgH1HSEtK4a1LAZbsNKhEvw583Dff1A
         TdrAPYI6j5l87bIMDfUIFlfPwUc4t+ZbbCKBx7ytmZCmOx/717jkZAaM1ftpV8n65zAD
         NTmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AEH93xRAAUZFLy3im83sD7R1OWMiuy7/9NIIATHOAZ8=;
        b=ZlDcWMiMcPevSI3qbN8s/IupgXSNJYX+SOtooAvG8MUjniyAhieeVG83x/6d3o4jvt
         6YpNFrLoDhneFUGAmV14dfXe/vBt3ZhrJQg6HofNbQBZAXrr1N+tS7ukK/M/wuN0Dog8
         fkacTnLOjXIKA+8Pw23aVDtJFY3siCTuqblmkvro0f3FuEmUqOseF+nXnDCeg2octxyF
         H+2aO9ZpIxAs78TIzjkTFCJUGMOcPc5HOaa9sNowDRBxyiJiWc1JyuTLtmDIgvs+Bv5I
         tYFeqwTKUTRM6vzX9z6C6xIrmBG211Xu7YGDwv4FsDfCpKAG92RpLZN8ic2KOu2Fhwqy
         rVbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wa35xolY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j31si11310398pgm.339.2019.06.17.08.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:46:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wa35xolY;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 484A521855
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:46:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560786385;
	bh=F3uEyDN+Xs7L0Di68zDs4MEi1Cbu2UWQXut0pG0xWMs=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=wa35xolYW4YasUKQT8EwzT6szfhNdHDv0tXqCBbVczs42MXSBCsyqEPKC57euY3wj
	 xTlfaENabxyxNZ4xaXCX4kGyw7z94wbPMr9w+hYWZLZqYfzBKsWgmhZHcCSZ61Sbjv
	 HM3+iiGzq5mOAoMIYcKW89sL9P2A2CmPt30I6s04=
Received: by mail-wm1-f41.google.com with SMTP id s15so9657704wmj.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:46:25 -0700 (PDT)
X-Received: by 2002:a1c:a942:: with SMTP id s63mr19448598wme.76.1560786383736;
 Mon, 17 Jun 2019 08:46:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
In-Reply-To: <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 08:46:12 -0700
X-Gmail-Original-Message-ID: <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
Message-ID: <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>, 
	Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>, 
	Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, keyrings@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 8:28 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/17/19 8:07 AM, Andy Lutomirski wrote:
> > I still find it bizarre that this is conflated with mprotect().
>
> This needs to be in the changelog.  But, for better or worse, it's
> following the mprotect_pkey() pattern.
>
> Other than the obvious "set the key on this memory", we're looking for
> two other properties: atomicity (ensuring there is no transient state
> where the memory is usable without the desired properties) and that it
> is usable on existing allocations.
>
> For atomicity, we have a model where we can allocate things with
> PROT_NONE, then do mprotect_pkey() and mprotect_encrypt() (plus any
> future features), then the last mprotect_*() call takes us from
> PROT_NONE to the desired end permisions.  We could just require a plain
> old mprotect() to do that instead of embedding mprotect()-like behavior
> in these, of course, but that isn't the path we're on at the moment with
> mprotect_pkey().
>
> So, for this series it's just a matter of whether we do this:
>
>         ptr = mmap(..., PROT_NONE);
>         mprotect_pkey(protect_key, ptr, PROT_NONE);
>         mprotect_encrypt(encr_key, ptr, PROT_READ|PROT_WRITE);
>         // good to go
>
> or this:
>
>         ptr = mmap(..., PROT_NONE);
>         mprotect_pkey(protect_key, ptr, PROT_NONE);
>         sys_encrypt(key, ptr);
>         mprotect(ptr, PROT_READ|PROT_WRITE);
>         // good to go
>
> I actually don't care all that much which one we end up with.  It's not
> like the extra syscall in the second options means much.

The benefit of the second one is that, if sys_encrypt is absent, it
just works.  In the first model, programs need a fallback because
they'll segfault of mprotect_encrypt() gets ENOSYS.

>
> > This is part of why I much prefer the idea of making this style of
> > MKTME a driver or some other non-intrusive interface.  Then, once
> > everyone gets tired of it, the driver can just get turned off with no
> > side effects.
>
> I like the concept, but not where it leads.  I'd call it the 'hugetlbfs
> approach". :)  Hugetblfs certainly go us huge pages, but it's continued
> to be a parallel set of code with parallel bugs and parallel
> implementations of many VM features.  It's not that you can't implement
> new things on hugetlbfs, it's that you *need* to.  You never get them
> for free.

Fair enough, but...

>
> For instance, if we do a driver, how do we get large pages?  How do we
> swap/reclaim the pages?  How do we do NUMA affinity?

Those all make sense.

>  How do we
> eventually stack it on top of persistent memory filesystems or Device
> DAX?

How do we stack anonymous memory on top of persistent memory or Device
DAX?  I'm confused.

Just to throw this out there, what if we had a new device /dev/xpfo
and MKTME were one of its features.  You open /dev/xpfo, optionally do
an ioctl to set a key, and them map it.  The pages you get are
unmapped entirely from the direct map, and you get a PFNMAP VMA with
all its limitations.  This seems much more useful -- it's limited, but
it's limited *because the kernel can't accidentally read it*.

I think that, in the long run, we're going to have to either expand
the core mm's concept of what "memory" is or just have a whole
parallel set of mechanisms for memory that doesn't work like memory.
We're already accumulating a set of things that are backed by memory
but aren't usable as memory. SGX EPC pages and SEV pages come to mind.
They are faster when they're in big contiguous chunks (well, not SGX
AFAIK, but maybe some day), they have NUMA node affinity, and they
show up in page tables, but the hardware restricts who can read and
write them.  If Intel isn't planning to do something like this with
the MKTME hardware, I'll eat my hat.

I expect that some day normal memory will  be able to be repurposed as
SGX pages on the fly, and that will also look a lot more like SEV or
XPFO than like the this model of MKTME.

So, if we upstream MKTME as anonymous memory with a magic config
syscall, I predict that, in a few years, it will be end up inheriting
all downsides of both approaches with few of the upsides.  Programs
like QEMU will need to learn to manipulate pages that can't be
accessed outside the VM without special VM buy-in, so the fact that
MKTME pages are fully functional and can be GUP-ed won't be very
useful.  And the VM will learn about all these things, but MKTME won't
really fit in.

And, one of these days, someone will come up with a version of XPFO
that could actually be upstreamed, and it seems entirely plausible
that it will be totally incompatible with MKTME-as-anonymous-memory
and that users of MKTME will actually get *worse* security.

