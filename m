Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 450B7C31E5C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AA5C20833
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:11:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AA5C20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A95016B0005; Mon, 17 Jun 2019 22:11:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A46128E0003; Mon, 17 Jun 2019 22:11:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 933B18E0001; Mon, 17 Jun 2019 22:11:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59F826B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:11:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so8208880pfb.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:11:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/qRrtZpGhZiqcSMbIelit7eCV6f8fyD0Ii+VzrhiE3U=;
        b=Lhtq17BJC5ZXJ1zF7Hncn9t/887+kb4Yx+wUbj9jy11ivwZ0I0K0ojaIophUmdRp9g
         SwnYOdIsMvPKosGbk06u/rEOgJrBRuEsYAfPyxWiNdSCD6tGmshHdipSf9ylMGfFso6I
         64JXE+0N2Pw0+ThgdmAJbghZ7d2WOrwj/ruIW4nbKGiGExswUeA64tB63T6Jtbog/MpV
         tyI8RB1OitGaoZ7zqrGq2MI3v/Dk5nUz/ubgynGK6d/hhwPvw4l1w3yI8eZPxbPgKZZz
         pfTxePyCYirB9xrFa6DBY0qNGyJgEjDSUCSBRO0Ezck9V9cFVcgIZod1BAqU2sn7DVFs
         WdCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUsYKQw8i8Ff4ypEzVhSmu7Oz7+GM1WatWQ4b4jzkh2+43gE1rR
	9puPOeRr0AdzAljQ1DO+GqdD1rGE/uimUyuLuOtYBU3Q8UyVnhh+G24vWdCZu2NwBcWUeEdzEfh
	OK3qNkfTqHkNTlCgkVA4TbLovV+d3WC+wzDSt0dAL/mALVGX3PN+2Za9CQiDX4TYFCQ==
X-Received: by 2002:a17:902:2ae7:: with SMTP id j94mr27051936plb.270.1560823907004;
        Mon, 17 Jun 2019 19:11:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNcw4R87Kp9ekkUuMDhLPsL0JRABlFCiMHCPgUWMwtOAZj2buxnIuWsdqHAWtmthyoVSrX
X-Received: by 2002:a17:902:2ae7:: with SMTP id j94mr27051890plb.270.1560823906211;
        Mon, 17 Jun 2019 19:11:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560823906; cv=none;
        d=google.com; s=arc-20160816;
        b=kMsiUX14kT8097mI/c8IXVAQh8mgUfXsNYO4QiOPthF98AXhsviKZHo8M7534/rIQ7
         w9MALVlU98yiFHEU1KAYyl3cKss2DnMOAzHNzvji5yiewkxpIrtitOYimFnL3O3DLs+x
         9goT9JKTrznA5AYQBNZXGyrwOrOr+9K4vmsIjAdf9gBOMrKiyWnCf0BOr1phBp3fNAI/
         ESLEIREVY7YeFUXg86uD6XbvNkH4+oGeQh1ybexmXjJkjv2jMNrBJLnQWU6hkwvNr7DJ
         0M5zLf/1DeYdidVvFbFN+W1aDTlpWxvwxZytzsyty5fyedpepanXipj0nfP/Sg+RDBc3
         RSpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=/qRrtZpGhZiqcSMbIelit7eCV6f8fyD0Ii+VzrhiE3U=;
        b=WennZFWYhJAREQthPe90RAqjPVrVp9r8Egy0sFc+eYy00XA71NeH8rVu/564Y0tW+G
         D/lt2AzgoapLH8rIwB9b9UdXMq5WGjrKHlTM7L4GUdizZ7tPuw+gnt0GSjFGLLEsbGbF
         tdmnMS2mdKeOHbv/m7IQG2ePTF2HC2zsCfnTkBnSeU9MmJhgBnYep5y3h1WRcTeigTml
         Su6GsW/DXvt0AVCK4vIpdiSgNoi3rqs7qR0/pWrC8/WSmeLvxtl7xtEw5F5cN6ARP4Pe
         /iBBQdZiM4914WzAPz4dZVWdq19JzdVYOW3O3Ib5HoqH3wSNx7YnfNTSrju7GNpJlLnw
         ZraA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a23si10047083pls.189.2019.06.17.19.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 19:11:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 19:11:45 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by orsmga004.jf.intel.com with ESMTP; 17 Jun 2019 19:11:40 -0700
Message-ID: <1560823899.5187.92.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
From: Kai Huang <kai.huang@linux.intel.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>,  X86 ML <x86@kernel.org>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,  "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Alison
 Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm
 list <kvm@vger.kernel.org>,  keyrings@vger.kernel.org, LKML
 <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 18 Jun 2019 14:11:39 +1200
In-Reply-To: <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
	 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
	 <d599b1d7-9455-3012-0115-96ddbad31833@intel.com>
	 <1560818931.5187.70.camel@linux.intel.com>
	 <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 18:50 -0700, Andy Lutomirski wrote:
> On Mon, Jun 17, 2019 at 5:48 PM Kai Huang <kai.huang@linux.intel.com> wrote:
> > 
> > 
> > > 
> > > > And another silly argument: if we had /dev/mktme, then we could
> > > > possibly get away with avoiding all the keyring stuff entirely.
> > > > Instead, you open /dev/mktme and you get your own key under the hook.
> > > > If you want two keys, you open /dev/mktme twice.  If you want some
> > > > other program to be able to see your memory, you pass it the fd.
> > > 
> > > We still like the keyring because it's one-stop-shopping as the place
> > > that *owns* the hardware KeyID slots.  Those are global resources and
> > > scream for a single global place to allocate and manage them.  The
> > > hardware slots also need to be shared between any anonymous and
> > > file-based users, no matter what the APIs for the anonymous side.
> > 
> > MKTME driver (who creates /dev/mktme) can also be the one-stop-shopping. I think whether to
> > choose
> > keyring to manage MKTME key should be based on whether we need/should take advantage of existing
> > key
> > retention service functionalities. For example, with key retention service we can
> > revoke/invalidate/set expiry for a key (not sure whether MKTME needs those although), and we
> > have
> > several keyrings -- thread specific keyring, process specific keyring, user specific keyring,
> > etc,
> > thus we can control who can/cannot find the key, etc. I think managing MKTME key in MKTME driver
> > doesn't have those advantages.
> > 
> 
> Trying to evaluate this with the current proposed code is a bit odd, I
> think.  Suppose you create a thread-specific key and then fork().  The
> child can presumably still use the key regardless of whether the child
> can nominally access the key in the keyring because the PTEs are still
> there.

Right. This is a little bit odd, although virtualization (Qemu, which is the main use case of MKTME
at least so far) doesn't use fork().

> 
> More fundamentally, in some sense, the current code has no semantics.
> Associating a key with memory and "encrypting" it doesn't actually do
> anything unless you are attacking the memory bus but you haven't
> compromised the kernel.  There's no protection against a guest that
> can corrupt its EPT tables, there's no protection against kernel bugs
> (*especially* if the duplicate direct map design stays), and there
> isn't even any fd or other object around by which you can only access
> the data if you can see the key.

I am not saying managing MKTME key/keyID in key retention service is definitely better, but it seems
all those you mentioned are not related to whether to choose key retention service to manage MKTME
key/keyID? Or you are saying it doesn't matter we manage key/keyID in key retention service or in
MKTME driver, since MKTME barely have any security benefits (besides physical attack)?

> 
> I'm also wondering whether the kernel will always be able to be a
> one-stop shop for key allocation -- if the MKTME hardware gains
> interesting new uses down the road, who knows how key allocation will
> work?

I by now don't have any use case which requires to manage key/keyID specifically for its own use,
rather than letting kernel to manage keyID allocation. Please inspire us if you have any potential.

Thanks,
-Kai

