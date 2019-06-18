Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53F36C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C36E2084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:43:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bzbrz8Oz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C36E2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A82708E0005; Mon, 17 Jun 2019 21:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0C2E8E0001; Mon, 17 Jun 2019 21:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 886868E0005; Mon, 17 Jun 2019 21:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 531C08E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:43:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d3so8879853pgc.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7SHNy+lxlm3oQh4ZyrOb9wCOH400EZULabKwn72n9yU=;
        b=DdF+f1vkmPXaaMLMBh8YD/w/QfTBw7wWNUGs0qU2xoFG5E9ELyvb2Sa05uFLwUgjVE
         qbfKmOBaPJ7msGAJYxR4z7G2ZMEmNMJmfqMIvHNiAmsQu6sEGbjhSsIFALVgv7IflbHb
         dIWUWRJjgssnpUSDE/c0U6O2xmcuAIZMuvYSt0Keoh+wa5wmMnsVXO1vJYIUQVOSYSnk
         ZwzVvwkAVR4nMy2Jy/avP7h8iY8OVJmhZzynYw9nr6eilNBTDAsMpUJg14UC0HrgNd4/
         PjPKL04yAPeGouPq0TFQXEblZvjoopjnuo/9dyQZA05jgMdEzFtCb/ftjYjjtyISWiIt
         WSqg==
X-Gm-Message-State: APjAAAVfSHJseKp9Obp945hA6iJhNfkdJHZT6RQ5CZfPG9XYw/8biiDp
	jD9QhO9C1rc1odkAxJGW3kyI7js6Cv0ObWXcYh+tjM3E01oyaUla+PFnRJzqAVGz8uiex1Z3CSp
	BsvUWysdIaTkrih6+wu15nFfBL/VFixX8QDqB9lgtVocOS5kEvmOHUOsdx2bXzJ8LVw==
X-Received: by 2002:a63:f648:: with SMTP id u8mr275812pgj.132.1560822233837;
        Mon, 17 Jun 2019 18:43:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMDfXUPhhMSCmQkSOrLQ9W1ac42pndGj0na50N/8YzBhOmsDxoCO4L+IyUaB+Zd1aA6PWF
X-Received: by 2002:a63:f648:: with SMTP id u8mr275788pgj.132.1560822233156;
        Mon, 17 Jun 2019 18:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560822233; cv=none;
        d=google.com; s=arc-20160816;
        b=CfeGZusM0Qoi7RDamE32kbx/FF6r8LWpT7mZzWGTzVC6hXsOfdYNbYCbDJd2YCUG5u
         UnUMETZYyQeWBfg32C+5E4sCWwO631ev3wTQCqgRLeSPR5VQOCuLSixgx71SjJGooMZy
         OIBybj2NPILAiS7yCaqZtaZKsvk64fx6zTucmd/PG61K9J9U4f/dbE2N36ph1xFKwjzZ
         /AFpOB6b64kIPDlUNgK4CEqTJvV4UOgAT2XvaPruvrulRbSva80dpxLNkmv2ngfQ7agS
         iV49D77JxCb/aJijfVBNamrL/rIQcc9K1/oXRoqgIfeu7WS8f7UhDTovGWGM4Ef42p24
         YPfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7SHNy+lxlm3oQh4ZyrOb9wCOH400EZULabKwn72n9yU=;
        b=pGN9s4/Z6+RcxCGiuhDc0E7V9lC2IcjgNbBRN5O5AcwvP/g73YQwLoHxGa8fRFcSmM
         8cXoJSyRLLRQX1v2VW0XoyIQOpU1V00y/e5c/qAlsVUhjVAlmwjgTWTIIF4jIqmAF/zh
         fzc4OE1MTe62jRWDxiXwUyg+QAVHb69Nmwoycdb4qUJ+iUowp5zHJdyl2hvnt4BPHIl5
         f9nj171t3Ot0dLnTmmuEP4xhOOumQHj4JZXXvtYrDZi0hqdl2+p2UNSQhM06iTo1LJrc
         PO7GUH0T4NXsXMjAvfu0AWYDOqUog0G1GBKga/PYHBxZCBd62g14Pg4doOVicBzShggD
         okmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Bzbrz8Oz;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b36si12238642pla.289.2019.06.17.18.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:43:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Bzbrz8Oz;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 82FA52166E
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:43:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560822232;
	bh=UeYxzLzSuHkMsOuXwbF2xE8bLo2DE9Ww1ky5l8uVDBU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Bzbrz8OzybZx3nRD8sszmrux5YYYBpI0S2wK2zb8PyRZ4zcxsLG3dVRc64HvmE3Ui
	 M7Sl4fczjevhlcuk02zlNt8Ymdmk+E4IgnWBm+yXVqstWxyO3bf3QA3M9Q1RivuPh1
	 NnIRmdDmIbcCeiljctgQl+Clg5Pl3NWlQ2WIF1XA=
Received: by mail-wr1-f54.google.com with SMTP id n9so12078584wru.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:43:52 -0700 (PDT)
X-Received: by 2002:adf:a443:: with SMTP id e3mr25678448wra.221.1560822231037;
 Mon, 17 Jun 2019 18:43:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com> <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
 <1560821746.5187.82.camel@linux.intel.com>
In-Reply-To: <1560821746.5187.82.camel@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 18:43:40 -0700
X-Gmail-Original-Message-ID: <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
Message-ID: <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: Kai Huang <kai.huang@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
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

On Mon, Jun 17, 2019 at 6:35 PM Kai Huang <kai.huang@linux.intel.com> wrote:
>
>
> > > >
> > > > I'm having a hard time imagining that ever working -- wouldn't it blow
> > > > up if someone did:
> > > >
> > > > fd = open("/dev/anything987");
> > > > ptr1 = mmap(fd);
> > > > ptr2 = mmap(fd);
> > > > sys_encrypt(ptr1);
> > > >
> > > > So I think it really has to be:
> > > > fd = open("/dev/anything987");
> > > > ioctl(fd, ENCRYPT_ME);
> > > > mmap(fd);
> > >
> > > This requires "/dev/anything987" to support ENCRYPT_ME ioctl, right?
> > >
> > > So to support NVDIMM (DAX), we need to add ENCRYPT_ME ioctl to DAX?
> >
> > Yes and yes, or we do it with layers -- see below.
> >
> > I don't see how we can credibly avoid this.  If we try to do MKTME
> > behind the DAX driver's back, aren't we going to end up with cache
> > coherence problems?
>
> I am not sure whether I understand correctly but how is cache coherence problem related to putting
> MKTME concept to different layers? To make MKTME work with DAX/NVDIMM, I think no matter which layer
> MKTME concept resides, eventually we need to put keyID into PTE which maps to NVDIMM, and kernel
> needs to manage cache coherence for NVDIMM just like for normal memory showed in this series?
>

I mean is that, to avoid cache coherence problems, something has to
prevent user code from mapping the same page with two different key
ids.  If the entire MKTME mechanism purely layers on top of DAX,
something needs to prevent the underlying DAX device from being mapped
at the same time as the MKTME-decrypted view.  This is obviously
doable, but it's not automatic.

