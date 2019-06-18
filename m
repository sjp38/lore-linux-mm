Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A27B6C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BE6D20657
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:51:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aO3C7gus"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BE6D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C52626B0005; Mon, 17 Jun 2019 21:51:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C03198E0003; Mon, 17 Jun 2019 21:51:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF22B8E0001; Mon, 17 Jun 2019 21:51:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78B7E6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:51:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k2so8869931pga.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:51:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yGUUgP1uKXn/fRTt1KOFlBO2RYvvxLk1PzE3vsueHXw=;
        b=icIGPh8RoZPuIf2N1DcBOpcJzJ2vCS1ZhxPTUpjjU61zq5+AMMqSV0JwbWHdKMK1jj
         m9AuPpP2vgz0jhVv4oUuuIdwKwtDPhxgkhmkk1DBVhH1DnXCL69GjANned902qCAG3uZ
         r1cxCJ/DdeeLB3Gj61PKfo7/TmdJPocDKXtX+FS7jpUk+YpTEg4t7R5+FgONV0f3vzAY
         Hk11/+0pJPuQ0n3jCSMXzdsTjGLnAjMSlFQCHdDtNkr2cqoudfs/8QuJmMQrlpT+Ps5O
         P9QlzrrXHGU5yyZC5k7O7vsRFe7Rz2AQ6pvwGbCYEflQDdtspFRz4h27Ptn/luYuQwBK
         25yA==
X-Gm-Message-State: APjAAAVNOtudTAwyPXEEd4enBlGfMX/BtTZWkWHZl1SeDqCcyr8OL5uE
	fc+v83YdTzCp76U6zqkP2feIe8YxDgR02QqC8ESNv2O//t0ZGJWSmnxjO5uq6MJ0yTpugb0p/e6
	AyVsyDImQ/PXhGCAWNT4Ou+SdAE9/jioRtq7tzGL68O6HoxG4OspH3G2/y0mIh3phbg==
X-Received: by 2002:a17:90a:9382:: with SMTP id q2mr2325422pjo.131.1560822660084;
        Mon, 17 Jun 2019 18:51:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWVpcWe0tv2cK4NVa64H3axMlwp4iKucGTaBSvh1W0WMFWdFf2UpWqUs8VrfWVqT3/eDME
X-Received: by 2002:a17:90a:9382:: with SMTP id q2mr2325380pjo.131.1560822659322;
        Mon, 17 Jun 2019 18:50:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560822659; cv=none;
        d=google.com; s=arc-20160816;
        b=lMtodiStIvnV1I+0H5UiNbUHlTYRzA91Gu0ljJwCYELlmNe6O/Ny/rqf+8jKOsKKLK
         C+T6iXYBqq4i665IKDmX+HHH6u7qTXmJ69NEZ49doWIdgzlMX+iZRQVwPu6536RVYZ4R
         UJVPtqZfOEMe1IrjZB0lLnO+QFWVBnGXLpQKUtk80oFwWd/qmuvDSYjIIpS2OQk6Dhnl
         5NBW65isRwX3uiFpR5Ws7okYvzA2xXF9uNJwkqLAJNymZO0BL9optvVQ7fGUeilJ2YIi
         24/1/iou36FQ9bbNA36cqsP3jG8I+n2e3o0S0GEj5qEuy5DOPFRLu5NYmy6rdm4PIJ4+
         YHLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yGUUgP1uKXn/fRTt1KOFlBO2RYvvxLk1PzE3vsueHXw=;
        b=zZnLAYiIn/i32lAfCpN9uSjvE/21C5wsCXImYHnuk+SUoqCvV9f6VbSYOwXjPLZf1L
         FAypO0bB5MRS1hjdrQ95mXKmL/PmIMiNSv683GtKgeQ0OeE8gStMyKiMmeqxja3cthdw
         1MVJE6nJM46mG0EcWs1jjT75aLuGBhhXp51atkLmCvOZhjIQm77S6qnOADhQLzO0RHKD
         IjoGNccOSil+bNbBlFYf2Uazaght0IuAueKXKUSNufOKnApQurDkYB9d2h/Vx8boU4HL
         r49/ihiuIWK4HlPVfAOjPFLqGgFzXnDfkAspoPq7HIJyicjU2inMw1bZzjAtfqzIYr/p
         FmJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aO3C7gus;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p9si2401916pgs.58.2019.06.17.18.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:50:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aO3C7gus;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8FE4F2166E
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:50:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560822658;
	bh=9pADkGP6B9XPZnoSXHTdilPdPV8psk9Fh8iUhTu3lCw=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=aO3C7gusUpRN/F1U4OsRkHAd5bWRjQMfpkle66mvj1CdvoqtH8xKaAKZisXNpFECZ
	 QOlRO1ZyOcvCR5lcG2FzLXrziVwwb7nFPBKZOO+serlPcj/7WLJ2HliilezLLDjCa7
	 qcRrhJb8zqZ5haKe+GxoCxdEy5Z5yvR95St+9PVQ=
Received: by mail-wm1-f41.google.com with SMTP id s3so1372939wms.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:50:58 -0700 (PDT)
X-Received: by 2002:a7b:cd84:: with SMTP id y4mr951107wmj.79.1560822657085;
 Mon, 17 Jun 2019 18:50:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <d599b1d7-9455-3012-0115-96ddbad31833@intel.com> <1560818931.5187.70.camel@linux.intel.com>
In-Reply-To: <1560818931.5187.70.camel@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 18:50:46 -0700
X-Gmail-Original-Message-ID: <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
Message-ID: <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: Kai Huang <kai.huang@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, 
	David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, 
	Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, keyrings@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 5:48 PM Kai Huang <kai.huang@linux.intel.com> wrote:
>
>
> >
> > > And another silly argument: if we had /dev/mktme, then we could
> > > possibly get away with avoiding all the keyring stuff entirely.
> > > Instead, you open /dev/mktme and you get your own key under the hook.
> > > If you want two keys, you open /dev/mktme twice.  If you want some
> > > other program to be able to see your memory, you pass it the fd.
> >
> > We still like the keyring because it's one-stop-shopping as the place
> > that *owns* the hardware KeyID slots.  Those are global resources and
> > scream for a single global place to allocate and manage them.  The
> > hardware slots also need to be shared between any anonymous and
> > file-based users, no matter what the APIs for the anonymous side.
>
> MKTME driver (who creates /dev/mktme) can also be the one-stop-shopping. I think whether to choose
> keyring to manage MKTME key should be based on whether we need/should take advantage of existing key
> retention service functionalities. For example, with key retention service we can
> revoke/invalidate/set expiry for a key (not sure whether MKTME needs those although), and we have
> several keyrings -- thread specific keyring, process specific keyring, user specific keyring, etc,
> thus we can control who can/cannot find the key, etc. I think managing MKTME key in MKTME driver
> doesn't have those advantages.
>

Trying to evaluate this with the current proposed code is a bit odd, I
think.  Suppose you create a thread-specific key and then fork().  The
child can presumably still use the key regardless of whether the child
can nominally access the key in the keyring because the PTEs are still
there.

More fundamentally, in some sense, the current code has no semantics.
Associating a key with memory and "encrypting" it doesn't actually do
anything unless you are attacking the memory bus but you haven't
compromised the kernel.  There's no protection against a guest that
can corrupt its EPT tables, there's no protection against kernel bugs
(*especially* if the duplicate direct map design stays), and there
isn't even any fd or other object around by which you can only access
the data if you can see the key.

I'm also wondering whether the kernel will always be able to be a
one-stop shop for key allocation -- if the MKTME hardware gains
interesting new uses down the road, who knows how key allocation will
work?

