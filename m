Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8E91C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D44C20663
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D44C20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06AF96B0006; Mon, 17 Jun 2019 20:05:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B458E0004; Mon, 17 Jun 2019 20:05:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E731F8E0001; Mon, 17 Jun 2019 20:05:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0CE76B0006
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:05:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v6so4631424pgh.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:05:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P3nxrY717BKTkiVI120EuB8btH0pMUXP0qaiy/FBJKA=;
        b=SGFOjVGtBAfQ5AdTiFtqUV7iQgGvn0mW886ceaBzWIISOgqrmm76lldAo5wpS8w96W
         D2qiTUviDMXA04//jVvbuCRvMFIJT0MGOoeS0M7kUh0/C6AF2PbvqP2XgMJ0vkZLfY9B
         Apy2Gk9eNDtJf4v2jScy2nmYbw+EFQoW4R+plDfpTbR5q7HN0ftNSBUZwR8I5UpJXkw+
         4vJG/BbKSENNnYyQvlNZlvMou4s9calPy8ZvL0AZUCrsK+EAf/NNmMgJGOUAP0qP3mb8
         nh4uv5COWN4oP3jDuypKYReYFUguWm8xj3qbIZb6vOlwlnQPceZjU7pEGYcodZY5OBCq
         6bog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVBMUs3tpUR7FcEqiZfwvvK5h92F53+wAgdEPqzFIw9xP5TabS5
	nhc5kE+XdvAc+cS1z0RfMSA1jcHDZemZNx3ss6S8/IAV7GbD7k1NHgRw97meJ8dOmGt1GzHgeSV
	Ap9wug4NH76nfO/tzpx3ZiiDeuHTJZ7AVNAy7Ze66c4oo0OZ7s4Vxv0qyzlwPxSr3Yg==
X-Received: by 2002:a17:902:b70f:: with SMTP id d15mr28659644pls.318.1560816348376;
        Mon, 17 Jun 2019 17:05:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQRP80V9gAZqG6gzRyX6Nxc2csmbJYfzSTEgVP/c+C/iED1nRc6Xb7naCGtXvPz+s816/B
X-Received: by 2002:a17:902:b70f:: with SMTP id d15mr28659582pls.318.1560816347625;
        Mon, 17 Jun 2019 17:05:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560816347; cv=none;
        d=google.com; s=arc-20160816;
        b=KoOYVM3C3Kfai/sVi6tJ8jdTh2EYR1lKL5dIupb7wJ52HC+QabFucrCI96b4VZVew/
         CSV8Us2Y9Jh1lNDwcP5VmySPAGRD0BQPrEninwgoC+C3w4P6zlteZlcEbNHD1i333Qux
         gv0u4PX79dPaYXehsga8vFpxcRmcSJ0ce7JrvvlGZFJiQHQL101Bx6q+ehPU1/hn2qSD
         AokJtbdetUTMnGky3VIHk7l8GnRzwl6wGPalwIZ3gis8/hqPaPzkBii+zyR4IqWwV1ro
         yCcEkDzSXhFU1NNscEqkkdWfNDUu5nV34H/VXWTA4fg4SJQgNS7q1mwKv3eW+R/JaqoO
         nTVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=P3nxrY717BKTkiVI120EuB8btH0pMUXP0qaiy/FBJKA=;
        b=ZAmuV69FiHfQf7b4RZF5HACvb/2EC3B3K7ljC/Vfk50Z/9mXAcsBW7s3jLaxMbKsZ4
         htXOFJOfnjsXhOM/+CQUFCDb+EeUCdbB4ijYQ2FNRxl80tb2BKnc4hMTBEwRvlT2pfSw
         XrzYPTzM8gJuVZdtgR+EUgGpHRXFJBor0wq+ufcSrscuPo/SIPmFuZP/E5ZACWUVJWkN
         M6defhYw+0AOlONHbxGNmSuC72N2f2eugb7ZsrpcysbLl5uLOnAEY3b3YEiNSMpQsett
         y+UUaKd9hdSh9/sC1V2RL3AoZopF8sBRxtAW30uUxefEWKTbKuuZcDLl1hVVG6h3XHxk
         rixg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m32si11049473pld.236.2019.06.17.17.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:05:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 17:05:47 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga008.fm.intel.com with ESMTP; 17 Jun 2019 17:05:43 -0700
Message-ID: <1560816342.5187.63.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
From: Kai Huang <kai.huang@linux.intel.com>
To: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Alison
 Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm
 list <kvm@vger.kernel.org>,  keyrings@vger.kernel.org, LKML
 <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 18 Jun 2019 12:05:42 +1200
In-Reply-To: <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
	 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 12:12 -0700, Andy Lutomirski wrote:
> On Mon, Jun 17, 2019 at 11:37 AM Dave Hansen <dave.hansen@intel.com> wrote:
> > 
> > Tom Lendacky, could you take a look down in the message to the talk of
> > SEV?  I want to make sure I'm not misrepresenting what it does today.
> > ...
> > 
> > 
> > > > I actually don't care all that much which one we end up with.  It's not
> > > > like the extra syscall in the second options means much.
> > > 
> > > The benefit of the second one is that, if sys_encrypt is absent, it
> > > just works.  In the first model, programs need a fallback because
> > > they'll segfault of mprotect_encrypt() gets ENOSYS.
> > 
> > Well, by the time they get here, they would have already had to allocate
> > and set up the encryption key.  I don't think this would really be the
> > "normal" malloc() path, for instance.
> > 
> > > >  How do we
> > > > eventually stack it on top of persistent memory filesystems or Device
> > > > DAX?
> > > 
> > > How do we stack anonymous memory on top of persistent memory or Device
> > > DAX?  I'm confused.
> > 
> > If our interface to MKTME is:
> > 
> >         fd = open("/dev/mktme");
> >         ptr = mmap(fd);
> > 
> > Then it's hard to combine with an interface which is:
> > 
> >         fd = open("/dev/dax123");
> >         ptr = mmap(fd);
> > 
> > Where if we have something like mprotect() (or madvise() or something
> > else taking pointer), we can just do:
> > 
> >         fd = open("/dev/anything987");
> >         ptr = mmap(fd);
> >         sys_encrypt(ptr);
> 
> I'm having a hard time imagining that ever working -- wouldn't it blow
> up if someone did:
> 
> fd = open("/dev/anything987");
> ptr1 = mmap(fd);
> ptr2 = mmap(fd);
> sys_encrypt(ptr1);
> 
> So I think it really has to be:
> fd = open("/dev/anything987");
> ioctl(fd, ENCRYPT_ME);
> mmap(fd);

This requires "/dev/anything987" to support ENCRYPT_ME ioctl, right?

So to support NVDIMM (DAX), we need to add ENCRYPT_ME ioctl to DAX?

> 
> But I really expect that the encryption of a DAX device will actually
> be a block device setting and won't look like this at all.  It'll be
> more like dm-crypt except without device mapper.

Are you suggesting not to support MKTME for DAX, or adding MKTME support to dm-crypt?

Thanks,
-Kai

