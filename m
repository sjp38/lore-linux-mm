Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F2F8C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:59:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6090E20578
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:59:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6090E20578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEE9B6B0006; Mon, 17 Jun 2019 19:59:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E780F8E0004; Mon, 17 Jun 2019 19:59:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D18A98E0001; Mon, 17 Jun 2019 19:59:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9389D6B0006
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:59:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b10so8675016pgb.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:59:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fWOCouRdPcVqLU8gFsDhodOGGCKE0Cxxt20INAQ5IDE=;
        b=CJ/9qeHgnVOt8X+2G6A+skBL8uj/TII8Q8/4hndx0Zu6kpi7aqkWYrCGf2FH4AnzEI
         M16OW9WCjWYCNDRE/CEJbhZU9F3bbSPDA2Y0ZvDhYaaNY0yIsvxNWKA692Btdp5K7UQx
         dFnUkzONds3V0qs5ETABofjPAtuqqsoRL2A2JgbpDlpR7JG7yJG5B639mZq//CI3jFnC
         Bkj4yuNOSJ9ErkQou+rrXVNXTotkW4gtuaxuI8Pu5oooW2U4w9VaHHz+pqpjPe75Oq+q
         v9YLOSF5My2GBBrnQjmLmZvj7hHlvMPb8P+fMLIEZ3XPno9ZQg97ASYH8fDmBfIx5Xrv
         TsYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXRTMUrcoBoj+mfg1+Fby+hu7E0DPrpHfxuIqbby8Ldzs18HHwO
	7d5Vm4L0LERvyu4rFPJm4p4m5rVsNoMgI7HbJkH+oltJq/gjiliUbW6OD+2pwoznv9OOQ7fgyaT
	uKs7KNpYptXRoPrqHeBav+hCiRD/aTevE3Gj5J0bJ6dWJuzr58wfcICdl4X45d8CtRQ==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr92992953plb.3.1560815967144;
        Mon, 17 Jun 2019 16:59:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu2gGz3j8t9zmAppxpVVmlLA8Td6EI1s9vIrB+ea3wuEgrxUBPuJifV6COL6JOc/6yaKpW
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr92992872plb.3.1560815966003;
        Mon, 17 Jun 2019 16:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560815965; cv=none;
        d=google.com; s=arc-20160816;
        b=N2PqrRlFbnVvrm86xHM7kvQ7kXONrjEu0qsa/TDkxR5QOvEPnLesROqOD75+X5hpzn
         1dG68nSfKQfnvAj4e/KKBFROd3+Qw8VOXeNL6kgesre1eRj/dQEkNOFgzqY87TDPcFlw
         VpMfwMJ+1dtGAko+PHNS5+VirDcpK/Ok4TmOKCtal+TIqfmez/JAWcr8NZS0EjeDLL56
         6boVhNtDdahvjMOI0UR8XR1j1eIDu/VU+1RB5jpJkcFS/60Bz00cg/5o668W+KtU04/2
         +ppKet4JM8ukhBtb3KZuW5i4mVM0RRysx1WExzXPCv+WT3l09igFXQmb+OGjwRzTL3Ni
         LLRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=fWOCouRdPcVqLU8gFsDhodOGGCKE0Cxxt20INAQ5IDE=;
        b=kg/zFl5G0YKNZNWOZS7MrKEBw1W1ryM5oKfdkPoiExn+Z6ZMCcrTR3VrFYghtZJx/H
         Tb2OjoXNhgOh6d8d6BoZNy6n794SsZGKKWBl6iMIMx6XBB7ofolsDAIX7TI4tyM2Q/u2
         /WLTJn9eCeSug0XNF9ARPVcdHZs7U4La6RsrBlzObvjB2OgvWKKh8eUN2T9QxRwb9Ye2
         7az3v2NO1hd7peB24OoroMuEYRjhDGFRwipEFxZW1QwjBaERtX06L5dWjMfoHjHLj5tR
         i344cEiXAbNKVRpuivZhZsWQnB6CfJoAf3897x7IOpVmqI88nZPcP5vry842t83JhUkY
         IEmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s17si12299153pfc.237.2019.06.17.16.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 16:59:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 16:59:25 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by orsmga005.jf.intel.com with ESMTP; 17 Jun 2019 16:59:20 -0700
Message-ID: <1560815959.5187.57.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
From: Kai Huang <kai.huang@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Alison
 Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm
 list <kvm@vger.kernel.org>,  keyrings@vger.kernel.org, LKML
 <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 18 Jun 2019 11:59:19 +1200
In-Reply-To: <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 11:27 -0700, Dave Hansen wrote:
> Tom Lendacky, could you take a look down in the message to the talk of
> SEV?  I want to make sure I'm not misrepresenting what it does today.
> ...
> 
> 
> > > I actually don't care all that much which one we end up with.  It's not
> > > like the extra syscall in the second options means much.
> > 
> > The benefit of the second one is that, if sys_encrypt is absent, it
> > just works.  In the first model, programs need a fallback because
> > they'll segfault of mprotect_encrypt() gets ENOSYS.
> 
> Well, by the time they get here, they would have already had to allocate
> and set up the encryption key.  I don't think this would really be the
> "normal" malloc() path, for instance.
> 
> > >  How do we
> > > eventually stack it on top of persistent memory filesystems or Device
> > > DAX?
> > 
> > How do we stack anonymous memory on top of persistent memory or Device
> > DAX?  I'm confused.
> 
> If our interface to MKTME is:
> 
> 	fd = open("/dev/mktme");
> 	ptr = mmap(fd);
> 
> Then it's hard to combine with an interface which is:
> 
> 	fd = open("/dev/dax123");
> 	ptr = mmap(fd);
> 
> Where if we have something like mprotect() (or madvise() or something
> else taking pointer), we can just do:
> 
> 	fd = open("/dev/anything987");
> 	ptr = mmap(fd);
> 	sys_encrypt(ptr);
> 
> Now, we might not *do* it that way for dax, for instance, but I'm just
> saying that if we go the /dev/mktme route, we never get a choice.
> 
> > I think that, in the long run, we're going to have to either expand
> > the core mm's concept of what "memory" is or just have a whole
> > parallel set of mechanisms for memory that doesn't work like memory.
> 
> ...
> > I expect that some day normal memory will  be able to be repurposed as
> > SGX pages on the fly, and that will also look a lot more like SEV or
> > XPFO than like the this model of MKTME.
> 
> I think you're drawing the line at pages where the kernel can manage
> contents vs. not manage contents.  I'm not sure that's the right
> distinction to make, though.  The thing that is important is whether the
> kernel can manage the lifetime and location of the data in the page.
> 
> Basically: Can the kernel choose where the page comes from and get the
> page back when it wants?
> 
> I really don't like the current state of things like with SEV or with
> KVM direct device assignment where the physical location is quite locked
> down and the kernel really can't manage the memory.  I'm trying really
> hard to make sure future hardware is more permissive about such things.
>  My hope is that these are a temporary blip and not the new normal.
> 
> > So, if we upstream MKTME as anonymous memory with a magic config
> > syscall, I predict that, in a few years, it will be end up inheriting
> > all downsides of both approaches with few of the upsides.  Programs
> > like QEMU will need to learn to manipulate pages that can't be
> > accessed outside the VM without special VM buy-in, so the fact that
> > MKTME pages are fully functional and can be GUP-ed won't be very
> > useful.  And the VM will learn about all these things, but MKTME won't
> > really fit in.
> 
> Kai Huang (who is on cc) has been doing the QEMU enabling and might want
> to weigh in.  I'd also love to hear from the AMD folks in case I'm not
> grokking some aspect of SEV.
> 
> But, my understanding is that, even today, neither QEMU nor the kernel
> can see SEV-encrypted guest memory.  So QEMU should already understand
> how to not interact with guest memory.  I _assume_ it's also already
> doing this with anonymous memory, without needing /dev/sme or something.

Correct neither Qemu nor kernel can see SEV-encrypted guest memory. Qemu requires guest's
cooperation when it needs to interacts with guest, i.e. to support virtual DMA (of virtual devices
in SEV-guest), qemu requires SEV-guest to setup bounce buffer (which will not be SEV-encrypted
memory, but shared memory can be accessed from host side too), so that guest kernel can copy DMA
data from bounce buffer to its own SEV-encrypted memory after qemu/host kernel puts DMA data to
bounce buffer.

And yes from my reading (better to have AMD guys to confirm) SEV guest uses anonymous memory, but it
also pins all guest memory (by calling GUP from KVM -- SEV specifically introduced 2 KVM ioctls for
this purpose), since SEV architecturally cannot support swapping, migraiton of SEV-encrypted guest
memory, because SME/SEV also uses physical address as "tweak", and there's no way that kernel can
get or use SEV-guest's memory encryption key. In order to swap/migrate SEV-guest memory, we need SGX
EPC eviction/reload similar thing, which SEV doesn't have today.

From this perspective, I think driver proposal kinda makes sense since we already have security
feature which uses normal memory some kind like "device memory" (no swap, no migration, etc), so it
makes sense that MKTME just follows that (although from HW MKTME can support swap, page migration,
etc). The downside of driver proposal for MKTME I think is, like Dave mentioned, it's hard (or not
sure whether it is possible) to extend to support NVDIMM (and file backed guest memory), since for
virtual NVDIMM, Qemu needs to call mmap against fd of NVDIMM.

Thanks,
-Kai

