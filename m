Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D266C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:36:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B3C3206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:35:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B3C3206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD4906B0005; Thu, 25 Apr 2019 11:35:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5B016B0006; Thu, 25 Apr 2019 11:35:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9375F6B0008; Thu, 25 Apr 2019 11:35:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 363676B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:35:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p26so11825664edy.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:35:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=thl525jaRwKmZLD8fSWxmdoh3RN2YNKHljzlls0Sw8Q=;
        b=Cj9aMLwkwCVEEyjtNooH7duqKnJX+5vs9qmRGUiH4tjW91kHyaOHZOeczdTJDWZJlg
         zGH0MCbykO+TTKrzgwN2cJWOlwv+KGWSf1NDsJlZIgYuzwTAwTXVSxSbcLUuVvGq/BVm
         N3bDRAMOjw0vZjoOcRqY2I6de/zucFKM2WhVAvv8Fir83Tc9WhokmBcqgW2fphoYC2wf
         hv8b3yqfGCu/PUsmxscHuqjKsMy1gPYIUUkKZ7B7ruXFDWTmcNf/LK1Mev5AxCgq3CUU
         uWAD65mPRteB3pM6XreS4pVkONokuWuqiEndqzGq5m/HPAXG/x2i6agF4pxy7ZFxokBw
         sdJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAVNWNeo1QLqQyygxLyNFSmdMd6PnYnwvtAFPTzyFBE7AwuXS7aw
	rcP1oY2Z+xp2W/1BY6QSisglcj56ElbgsBm4zlX32gXqC2kHlhtDbylGPyOy8TvJCS7zh6I5V82
	O+3s+fJ2zDv4GhmFD+tQrHHn6ujO4g5442bJ2D8ir6uFSKn0pLWtot8ex9forhxuLkQ==
X-Received: by 2002:a50:ac34:: with SMTP id v49mr24505620edc.52.1556206557733;
        Thu, 25 Apr 2019 08:35:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6tDuJXrKpekGzaEB/Xg54McHZDF8WMkmvrX5+xl65mOzpBAfxEgq2j0NTbQblQDpEA9ll
X-Received: by 2002:a50:ac34:: with SMTP id v49mr24505575edc.52.1556206556847;
        Thu, 25 Apr 2019 08:35:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206556; cv=none;
        d=google.com; s=arc-20160816;
        b=Fe5TtzKuLdIrav45kCgArqOg4GsjeLXyA01UJ0neJ14SlgNSvXM3t+pCBVNgsa/61m
         CCjk85OVfod7BFT7rqeQYane9Po6xwyimTlR4h/qqKNo/KjTDKMUL+Fd9rge1Zun4RxC
         MfdjGZJ659UIvHt+bUL53Mn+aarBPbQ5f/tKabgW+70QYO1TELvdy0KXlqChWBHwo1JC
         iZ0d4Zb1ho6WvSy2h1DV9fxc3IluA0SeubTzyLwiMoR2+zmLeny33TfefUq/Su4kOjXA
         MpSDvrQlAKJg+qd8VUUXX74qmk43dI+ascUzn9EtJhgFqSU2gBV2iEelp0/vNRfE1wKD
         fUSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=thl525jaRwKmZLD8fSWxmdoh3RN2YNKHljzlls0Sw8Q=;
        b=v3My0BEzGcVPSXXCa0J343aHCH92xfgMmM8s+PbBVqqA9UZdyOG711bFBO0ZG73fml
         ycp/OzT2OsBKZF3X7Tq8HhKDzmFip8ZDEqIfkIALjm+bdBNJ9wSOat2t5UCkS/N9R0Gu
         /zt/FkCaRhXhwHNZth9OqUo2oQKwPfPcafOtzXHmyWeCkJPkDSSVvpJJrjiSMdHqL+Aa
         onAGJ8n1MAvFdnQ/JIebSAsnBSTKfIFynZ6vx3LNXE0FE1rAXsXyE3BX8EWhxd+7gLrN
         uXwsKpNjkSxKxsFvYRXZMyWQl9fE3xHgJJPpwTsueG8904kBgaGaLMudOLktBo6BD5kn
         wyYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j5si4329544edd.76.2019.04.25.08.35.56
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 08:35:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C8D0580D;
	Thu, 25 Apr 2019 08:35:55 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 116093F557;
	Thu, 25 Apr 2019 08:35:50 -0700 (PDT)
Date: Thu, 25 Apr 2019 16:35:48 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [RFC PATCH v6 22/26] x86/cet/shstk: ELF header parsing of Shadow
 Stack
Message-ID: <20190425153547.GG3567@e103592.cambridge.arm.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-23-yu-cheng.yu@intel.com>
 <20190425110211.GZ3567@e103592.cambridge.arm.com>
 <e7bbb51291434a9c8526d7b617929465d5784121.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7bbb51291434a9c8526d7b617929465d5784121.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 08:14:52AM -0700, Yu-cheng Yu wrote:
> On Thu, 2019-04-25 at 12:02 +0100, Dave Martin wrote:
> > On Mon, Nov 19, 2018 at 01:48:05PM -0800, Yu-cheng Yu wrote:
> > > Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> > > to be enabled for the task.
> > 
> > What's the status of this series?  I don't see anything in linux-next
> > yet.
> > 
> > For describing ELF features, Arm has recently adopted
> > NT_GNU_PROPERTY_TYPE_0, with properties closely modelled on
> > GNU_PROPERTY_X86_FEATURE_1_AND etc. [1]
> > 
> > So, arm64 will be need something like this patch for supporting new
> > features (such as the Branch Target Identification feature of ARMv8.5-A
> > [2]).
> > 
> > If this series isn't likely to merge soon, can we split this patch into
> > generic and x86-specific parts and handle them separately?
> > 
> > It would be good to see the generic ELF note parsing move to common
> > code -- I'll take a look and comment in more detail.
> 
> Yes, I will work on that.

Thanks.  I may try to hack something in the meantime based on your
patch.

One other question: according to the draft spec at
https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI, it
looks like the .note.gnu.property section is supposed to be marked with
SHF_ALLOC in object files.

I think that means that the linker will map it with a PT_LOAD entry in
the program header table in addition to the PT_NOTE that describes the
location of the note.  I need to check what the toolchain actually
does.

If so, can we simply rely on the notes being already mapped, rather than
needing to do additional I/O on the ELF file to fetch the notes?

[...]

Cheers
---Dave

