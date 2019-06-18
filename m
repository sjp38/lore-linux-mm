Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1657FC31E5C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C314520657
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:23:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C314520657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50DCB6B0005; Mon, 17 Jun 2019 22:23:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BEEB8E0003; Mon, 17 Jun 2019 22:23:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AE018E0001; Mon, 17 Jun 2019 22:23:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02B4C6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:23:39 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id r7so6929900plo.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:23:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=txRIaWhSfzqBxD1NzIX0yspEqQ9516er1fu65kGUCoM=;
        b=q1c8mFRJVeVKo9Bmo77qIoG/dSMqviIfpfwfM8vvVE4hmhzfBf1Nxl/b9VZ2/gatnw
         7X62XFlt+wzn0cCcknjXYpZYtTK9TJUeOriKMgeg/nQMoDXUycxHyhV+kelJDJR+h7Yf
         4pVQIMqKma6heKIqQDpUZgIKyDauM5wLH6ZxroeHjyRJFOhXukFBuNpAzatAJ3ecVr09
         79BFGr2rc+39jJKKFe70q8qW9LfexgsyOjotqXFHzp+Hq3QFA5OyrHUK85d6v7zVIsUe
         pwXV4P8G+AZLEgY7lsq6NGqVJ8KhJStz039CA6vWUkyefdE1+vMqgBpQF/ZzxnXStdgs
         1R8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyxBS+TFTsHcio9l2gQp7QtRz5AlX6xjjWhFpnpjf6US9flJ7q
	oE3K1D2ZDZywj/M/4/Lm83AlStmloSBKckCmBtz6a3//KwcnCLIFn9pzGTZIRPxUGLrmHJHe9N0
	HS6Z0/IHPLrOsaEpZqDpT+mVHEbKNQXEIRnxgp+fR1snu+LU82Uk62XR61r+V/iTI0w==
X-Received: by 2002:a17:90a:2768:: with SMTP id o95mr2438517pje.37.1560824618674;
        Mon, 17 Jun 2019 19:23:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0anrN1VjLI09ai33oq9atOXvoOU+tiytZUmekB/nrTREJAvQdn7HdAHSaX0t9FbBmf65A
X-Received: by 2002:a17:90a:2768:: with SMTP id o95mr2438469pje.37.1560824617912;
        Mon, 17 Jun 2019 19:23:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560824617; cv=none;
        d=google.com; s=arc-20160816;
        b=Ta+Y7RzV4Z2w5Jz4UUyEZxjMF0uJ3TnbzNGS8SFQuTFBeK92CAYp0X64XmvItv0uBK
         NCtrozfqABHnIULlUfdrVPHjpUlG7U5+zb64NAJsEZwaUvq2+u+0MpNG1XBB1TXvoLP9
         H8tuDLISWgqd1PW13/LVv732j7THZwmeVXoCpbx/uKwkzqu6OzikKCLh6bvm5GdGvTAc
         IwPXlU+DpUJ3b92zRquL+fJdNmDaMsOpR/cH/hyVxo9hlbFSTRyVIAuhvKdx2hteCIJL
         Ora2RT++5qpFBDdYj7V+csnyPUCcFwdiFp7Viu/ztOnnyCl1asbUFQm8s/B8xmf45RtZ
         13+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=txRIaWhSfzqBxD1NzIX0yspEqQ9516er1fu65kGUCoM=;
        b=Xh/ldFotQJk/mwnxuZpz496Pz/xwibYPGmRfoa3sv/rftHtS1q7oOEgPbCmTqk2mBN
         lhQ6AAAoksKxuwrYYpbWStwEJUOT/HplP1aHHit1PLUdoLQX41bmXpovh96nNiFkFWQa
         7lI5Aiot4lVLqsbfeXetUJq6UOlz69msIDBISkdG92UzgLhD24hkB0d4L58XAeD9mGaZ
         rowSTRKR+23LGTkVznBIZuSDyfUH3RBZVgOXul2jwZfjrhwe0vtsUcveaSrPfTkiyeun
         sUYDIpgV8haHfoeNzu5bJDWT2Uce8ov/tDGbSUHJ0+91a7k6ujciWks8EiCqIlkeB87q
         +Rhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f89si903492pje.50.2019.06.17.19.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 19:23:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 19:23:37 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by orsmga007.jf.intel.com with ESMTP; 17 Jun 2019 19:23:33 -0700
Message-ID: <1560824611.5187.100.camel@linux.intel.com>
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
Date: Tue, 18 Jun 2019 14:23:31 +1200
In-Reply-To: <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
	 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
	 <1560816342.5187.63.camel@linux.intel.com>
	 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
	 <1560821746.5187.82.camel@linux.intel.com>
	 <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 18:43 -0700, Andy Lutomirski wrote:
> On Mon, Jun 17, 2019 at 6:35 PM Kai Huang <kai.huang@linux.intel.com> wrote:
> > 
> > 
> > > > > 
> > > > > I'm having a hard time imagining that ever working -- wouldn't it blow
> > > > > up if someone did:
> > > > > 
> > > > > fd = open("/dev/anything987");
> > > > > ptr1 = mmap(fd);
> > > > > ptr2 = mmap(fd);
> > > > > sys_encrypt(ptr1);
> > > > > 
> > > > > So I think it really has to be:
> > > > > fd = open("/dev/anything987");
> > > > > ioctl(fd, ENCRYPT_ME);
> > > > > mmap(fd);
> > > > 
> > > > This requires "/dev/anything987" to support ENCRYPT_ME ioctl, right?
> > > > 
> > > > So to support NVDIMM (DAX), we need to add ENCRYPT_ME ioctl to DAX?
> > > 
> > > Yes and yes, or we do it with layers -- see below.
> > > 
> > > I don't see how we can credibly avoid this.  If we try to do MKTME
> > > behind the DAX driver's back, aren't we going to end up with cache
> > > coherence problems?
> > 
> > I am not sure whether I understand correctly but how is cache coherence problem related to
> > putting
> > MKTME concept to different layers? To make MKTME work with DAX/NVDIMM, I think no matter which
> > layer
> > MKTME concept resides, eventually we need to put keyID into PTE which maps to NVDIMM, and kernel
> > needs to manage cache coherence for NVDIMM just like for normal memory showed in this series?
> > 
> 
> I mean is that, to avoid cache coherence problems, something has to
> prevent user code from mapping the same page with two different key
> ids.  If the entire MKTME mechanism purely layers on top of DAX,
> something needs to prevent the underlying DAX device from being mapped
> at the same time as the MKTME-decrypted view.  This is obviously
> doable, but it's not automatic.

Assuming I am understanding the context correctly, yes from this perspective it seems having
sys_encrypt is annoying, and having ENCRYPT_ME should be better. But Dave said "nobody is going to
do what you suggest in the ptr1/ptr2 example"? 

Thanks,
-Kai

