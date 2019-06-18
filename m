Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F5FC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:24:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2A2B208E4
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:24:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="X6icH23w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2A2B208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E7FD8E0006; Tue, 18 Jun 2019 00:24:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798778E0001; Tue, 18 Jun 2019 00:24:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 686F38E0006; Tue, 18 Jun 2019 00:24:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 318B48E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:24:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so8415213pfv.18
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:24:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jLvrJIICqH/KGJGydYZP5bkBQHxZougG4pbeXQV45wE=;
        b=ZqPUh7cd1sSzCqIVzKaDUtt81BNDRadl4AtYTA4N7XKubUf8Gsmct4kmCGbVXvPcOZ
         gd2GAaGZMneUMnYX5h7D0tL97z4bX6Jma061bwHaChYCIpF4R6N+rj6RdxLO4LCd79hc
         0KLVK80JewDY2ZooVqHQn0vlP/CvD/kn/eEUIYib9Mf2LXiGikuGZcvDWyTteTwjE9+J
         00RSJiOlFnzBdmzmn2TnT8RDUliBGDsKUJHaUyfaMFnCwnwb7COceQKV3UmRWR1q3Vvq
         4Y69372BtX32iJ36HBhOf4SPPfxf5E7eFNEyds/vyVQY9bFQTrOROrMS94qXEPehBaL1
         MIOw==
X-Gm-Message-State: APjAAAWUdCYpCa7ab/p2zFUouhF+8t+YR4UmgENWF7QTMrld7C/AGQOL
	EINezZBViTRawUO2MsTzbh3TT/NTbUqDDmVn/7CP8jM1vyu+1f8U+awv/axMqm2pVVG/jB4iEll
	wd06TNC26Cm7vbnjT09y0ubu0Un7s38xYQvHtKJdttnezd9wvb56atZOlZN+POluZIQ==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr45436762plb.139.1560831874821;
        Mon, 17 Jun 2019 21:24:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIHaounxoKt8Tc6wrPr3N0e6gMUjSNFBBbJrTwSd5hUcd3ppX3qiF4KdqcPGas4rR/vL3r
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr45436719plb.139.1560831874045;
        Mon, 17 Jun 2019 21:24:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560831874; cv=none;
        d=google.com; s=arc-20160816;
        b=nKSQWkoqHst9P2HFKMC1bS4z8t9VnP5zX11qd3LQxs1AZK0X+CRqFz+0Wrm1kZh7wQ
         bSE2/aR/MZWjxIkKSBtK7cJrCCT6xDlfzudpC2f8Rjbq1UthOOaXu/HFaWISjkIMbjqT
         TXAi3od/OSIC7qJt82c7w/ZMUHnxg2Ui2kgp8WWZd9SUMjFcDJVnE1VqWXBYnPW6+605
         KMc1Jqi/6Eo0xBS4pCycVGqvyKYNIUTbZsj+YDtFAghyr2JhWdbcu4gVU3zmB0XN+ifX
         vvAjMJAV7cbte1BGom8bfzjAx3djduEmm23/8CmDnjkSqVyAFPJFSIM6zaSZukx9kP91
         0OIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jLvrJIICqH/KGJGydYZP5bkBQHxZougG4pbeXQV45wE=;
        b=WSYWYvQ+C5sF61J9Bbg10O9ijCwr24F1x1pwUrnJfAJhveG2YVU5tIdm+9mAxZh34U
         2djycHXloCEJd4eEZufRZOzQ+B93wIYpDzbOhE/vrbfgFIZSTqNDupuyoQNCccVNFSwU
         mISw9Pg6LJx2ObTWfNhoiMvh+KE59XDUY9oY1QgqRQrmeaDVDw48Mq6uzTES7tZgVXqh
         MeESY/ukrbXDKKuBPxvRKw3uOTRzo535kIBO66CsOiUF/Yd+eJ15ZaeHvJvaQxnrxFRF
         7E2SqPhPS2ipOsmMXA6xd2yA0MxjOuluk9mP84SU9q6mebcu1eCfesbaWFci+VyNJ06Q
         EWpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=X6icH23w;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g3si12324940pgq.247.2019.06.17.21.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 21:24:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=X6icH23w;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 598C52182B
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 04:24:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560831873;
	bh=9ReCKOz5FyiWYbaWF0e9yUvLI4xOn5aBSEcVZBfweIA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=X6icH23wLami3qVLS+W9x15FWYVyjUV2lrsKX5ptElPPqwXfwlVFNzngaWsYOhdPZ
	 Md37Fra9XLkQD0GOttnpfHbIQYsXmCjGa5vLNTbtjgd+cCFBo/w0/GiWXUFOIPagKg
	 rHUkFYvP+C+l1qxx5AASZU1zrnwJcZB1meO74imU=
Received: by mail-wm1-f49.google.com with SMTP id 207so1592667wma.1
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:24:33 -0700 (PDT)
X-Received: by 2002:a1c:a942:: with SMTP id s63mr1318487wme.76.1560831871826;
 Mon, 17 Jun 2019 21:24:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <d599b1d7-9455-3012-0115-96ddbad31833@intel.com> <1560818931.5187.70.camel@linux.intel.com>
 <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com> <1560823899.5187.92.camel@linux.intel.com>
In-Reply-To: <1560823899.5187.92.camel@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 21:24:20 -0700
X-Gmail-Original-Message-ID: <CALCETrUJ7LU2JmYT9hsT_LJHNxgza+uKUJ8RJG4mY93F5yRW_Q@mail.gmail.com>
Message-ID: <CALCETrUJ7LU2JmYT9hsT_LJHNxgza+uKUJ8RJG4mY93F5yRW_Q@mail.gmail.com>
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

On Mon, Jun 17, 2019 at 7:11 PM Kai Huang <kai.huang@linux.intel.com> wrote:
>
> On Mon, 2019-06-17 at 18:50 -0700, Andy Lutomirski wrote:
> > On Mon, Jun 17, 2019 at 5:48 PM Kai Huang <kai.huang@linux.intel.com> wrote:
> > >
> > >
> > > >
> > > > > And another silly argument: if we had /dev/mktme, then we could
> > > > > possibly get away with avoiding all the keyring stuff entirely.
> > > > > Instead, you open /dev/mktme and you get your own key under the hook.
> > > > > If you want two keys, you open /dev/mktme twice.  If you want some
> > > > > other program to be able to see your memory, you pass it the fd.
> > > >
> > > > We still like the keyring because it's one-stop-shopping as the place
> > > > that *owns* the hardware KeyID slots.  Those are global resources and
> > > > scream for a single global place to allocate and manage them.  The
> > > > hardware slots also need to be shared between any anonymous and
> > > > file-based users, no matter what the APIs for the anonymous side.
> > >
> > > MKTME driver (who creates /dev/mktme) can also be the one-stop-shopping. I think whether to
> > > choose
> > > keyring to manage MKTME key should be based on whether we need/should take advantage of existing
> > > key
> > > retention service functionalities. For example, with key retention service we can
> > > revoke/invalidate/set expiry for a key (not sure whether MKTME needs those although), and we
> > > have
> > > several keyrings -- thread specific keyring, process specific keyring, user specific keyring,
> > > etc,
> > > thus we can control who can/cannot find the key, etc. I think managing MKTME key in MKTME driver
> > > doesn't have those advantages.
> > >
> >
> > Trying to evaluate this with the current proposed code is a bit odd, I
> > think.  Suppose you create a thread-specific key and then fork().  The
> > child can presumably still use the key regardless of whether the child
> > can nominally access the key in the keyring because the PTEs are still
> > there.
>
> Right. This is a little bit odd, although virtualization (Qemu, which is the main use case of MKTME
> at least so far) doesn't use fork().
>
> >
> > More fundamentally, in some sense, the current code has no semantics.
> > Associating a key with memory and "encrypting" it doesn't actually do
> > anything unless you are attacking the memory bus but you haven't
> > compromised the kernel.  There's no protection against a guest that
> > can corrupt its EPT tables, there's no protection against kernel bugs
> > (*especially* if the duplicate direct map design stays), and there
> > isn't even any fd or other object around by which you can only access
> > the data if you can see the key.
>
> I am not saying managing MKTME key/keyID in key retention service is definitely better, but it seems
> all those you mentioned are not related to whether to choose key retention service to manage MKTME
> key/keyID? Or you are saying it doesn't matter we manage key/keyID in key retention service or in
> MKTME driver, since MKTME barely have any security benefits (besides physical attack)?

Mostly the latter.  I think it's very hard to evaluate whether a given
key allocation model makes sense given that MKTME provides such weak
security benefits.  TME has obvious security benefits, as does
encryption of persistent memory, but this giant patch set isn't needed
for plain TME and it doesn't help with persistent memory.


>
> >
> > I'm also wondering whether the kernel will always be able to be a
> > one-stop shop for key allocation -- if the MKTME hardware gains
> > interesting new uses down the road, who knows how key allocation will
> > work?
>
> I by now don't have any use case which requires to manage key/keyID specifically for its own use,
> rather than letting kernel to manage keyID allocation. Please inspire us if you have any potential.
>

Other than compliance, I can't think of much reason that using
multiple keys is useful, regardless of how their allocated.  The only
thing I've thought of is that, with multiple keys, you can use PCONFIG
to remove one and flush caches and the data is most definitely gone.
On the other hand, you can just zero the memory and the data is just
as gone even without any encryption.

