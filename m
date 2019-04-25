Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D5D7C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B6D520651
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B6D520651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92766B0005; Thu, 25 Apr 2019 12:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41906B0008; Thu, 25 Apr 2019 12:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90A066B000A; Thu, 25 Apr 2019 12:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9106B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:11:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e22so28809edd.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:11:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BeSU+CZOGGM0fEuM1DfXCBuaxnq52WT9lR1ZguLpj/I=;
        b=meg1QG3EjEm5LmLsoE5z+l2CS7DGHkf+x9Z7QW7g0qBUCkFj1qjhEqi7qKrfVeiA2P
         UODd9hoCEcv+SBhyorr8DwlSeTFFjG+XIoStbWUF1qLMsvAwbF758wl5uNhmqyd8EwsU
         kNEMIVMHtfNolgXFO8zQqoimC3wFqnElXhO8+u9GWSZjP/za4r3A4PGlE9sdaAa6JFfu
         C78ULbKoPdObxvgbwZ3PaYqEpDnsNy+PvSIrcxTSMrWJUPDCaZ7jK7v3MBYKJzv2bccx
         E6EwkAI8tdPqJjEzxAZYdP17xhbmD4QXQW5/2pNWPy86bE4wktL/SVuzPsa4hAmZLMtQ
         VJow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAVVZRaGnTjAe1DUQIMFQ81h0yfiuMRGFCphRP9vR0HKmXExepe9
	h6aLzj1zcL+PKKzhkwY+gGr9pE4+TUQZYY4tZgqlSwBYw7FJONp8LI181v6+zKEwgsB7/w0ahFk
	1aKMmujVZTymBS+6CnNZEpdqP+fP5BKlXOeFXajtlTVnG2EOjjpdDl/wO9b/wUsHEZg==
X-Received: by 2002:a17:906:c389:: with SMTP id t9mr11062088ejz.64.1556208680743;
        Thu, 25 Apr 2019 09:11:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfCvFESH+DGZC+zP/PdefONUSySo3PFVIUftrAvQbExtkd6lJLqUN4N55LcnZECUNNw5v+
X-Received: by 2002:a17:906:c389:: with SMTP id t9mr11062043ejz.64.1556208679809;
        Thu, 25 Apr 2019 09:11:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556208679; cv=none;
        d=google.com; s=arc-20160816;
        b=jtROwNEy/5pphPIHF0B9AIzaPT0xYRmLPfGr5DYcnq6thKP3VZC/y55fJOf+NzROJF
         pVlgLVCBe5LNl4dN2gL5u9xf3/HX5CNuIH5bC31+AvTSN4CDSLsX4b+lhyDwcp/OodaS
         DFXWSIdtjMoZzIzB63Dd5iqgyPN7Un+UED2ODCxGh3mHrHJIZz7Am317zyoF/tJGFev/
         43/p1T1RxWVcsbl8cMXBHGaqyHJcg2v9inbUFMgxI5DkFLDLgGszjQ4ls2WLQ4CyD9Jy
         lAVRY0WBG5WROc574x2xF9661f4oo+Lv1bZo0qDJPjBcKv938N7+WQjK87zZYuQVhJZv
         sJSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BeSU+CZOGGM0fEuM1DfXCBuaxnq52WT9lR1ZguLpj/I=;
        b=o3Tm3diXXT6LRi9VmT0dRfdRkw8QUFbyE1ET7VaNevz4opTgPzjgomNKlrsc/prQWc
         D2uZweLdW5rI981HOGZlfuO8QVplkvWqeByrb1rP8xL802jVnuD5ji7cx4/roRerOg7x
         RuL+L2jmgFOUgeTqb2PeucQa/ytG0zEzTAvWZBFyy+pnwMyaPIqQHvnMfoU6q7KYVHVU
         v2xxX5yvN+QZ6LWPpHsdIJ9fsgh3nu1D93ql7jQEeMXHgfDbBuCXzOlabRyhHmuVLjuF
         KZlcvSHA+xCaCKev2HA4WJTdDqEN8uf8LTJ14mZrH2h952e1dg/T98W077GGwhWftEZy
         6HGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 93si11146295edg.36.2019.04.25.09.11.19
        for <linux-mm@kvack.org>;
        Thu, 25 Apr 2019 09:11:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5B3C980D;
	Thu, 25 Apr 2019 09:11:18 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 976F43F557;
	Thu, 25 Apr 2019 09:11:13 -0700 (PDT)
Date: Thu, 25 Apr 2019 17:11:11 +0100
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
Message-ID: <20190425161110.GH3567@e103592.cambridge.arm.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-23-yu-cheng.yu@intel.com>
 <20190425110211.GZ3567@e103592.cambridge.arm.com>
 <e7bbb51291434a9c8526d7b617929465d5784121.camel@intel.com>
 <20190425153547.GG3567@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425153547.GG3567@e103592.cambridge.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 04:35:48PM +0100, Dave Martin wrote:
> On Thu, Apr 25, 2019 at 08:14:52AM -0700, Yu-cheng Yu wrote:
> > On Thu, 2019-04-25 at 12:02 +0100, Dave Martin wrote:
> > > On Mon, Nov 19, 2018 at 01:48:05PM -0800, Yu-cheng Yu wrote:
> > > > Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> > > > to be enabled for the task.
> > > 
> > > What's the status of this series?  I don't see anything in linux-next
> > > yet.
> > > 
> > > For describing ELF features, Arm has recently adopted
> > > NT_GNU_PROPERTY_TYPE_0, with properties closely modelled on
> > > GNU_PROPERTY_X86_FEATURE_1_AND etc. [1]
> > > 
> > > So, arm64 will be need something like this patch for supporting new
> > > features (such as the Branch Target Identification feature of ARMv8.5-A
> > > [2]).
> > > 
> > > If this series isn't likely to merge soon, can we split this patch into
> > > generic and x86-specific parts and handle them separately?
> > > 
> > > It would be good to see the generic ELF note parsing move to common
> > > code -- I'll take a look and comment in more detail.
> > 
> > Yes, I will work on that.
> 
> Thanks.  I may try to hack something in the meantime based on your
> patch.
> 
> One other question: according to the draft spec at
> https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI, it
> looks like the .note.gnu.property section is supposed to be marked with
> SHF_ALLOC in object files.
> 
> I think that means that the linker will map it with a PT_LOAD entry in
> the program header table in addition to the PT_NOTE that describes the
> location of the note.  I need to check what the toolchain actually
> does.
> 
> If so, can we simply rely on the notes being already mapped, rather than
> needing to do additional I/O on the ELF file to fetch the notes?

[...]

BTW, it looks like this holds true for AArch64 (see below).

Providing this also works on other arches, I think we can just pick
PT_GNU_PROPERTY out of the program headers and rely on the
corresponding note being already mapped by the existing binfmt_elf
code.

Cheers
---Dave


--8<--

$ echo 'void f(void) { }' | \
	aarch64-linux-gnu-gcc -v -nostdlib -Wl,-ef \
		-mbranch-protection=standard -o /tmp/x -x c - && \
	aarch64-linux-gnu-readelf -nl /tmp/x

[...]

gcc version 9.0.1 20190425 (experimental) (GCC) 

[...]

GNU assembler version 2.32.51 (aarch64-linux-gnu) using BFD version (GNU Binutils) 2.32.51.20190425

[...]

Elf file type is EXEC (Executable file)
Entry point 0x400178
There are 5 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x00000000000001c0 0x00000000000001c0  R E    0x10000
  NOTE           0x0000000000000158 0x0000000000400158 0x0000000000400158
                 0x0000000000000020 0x0000000000000020  R      0x8
  GNU_PROPERTY   0x0000000000000158 0x0000000000400158 0x0000000000400158
                 0x0000000000000020 0x0000000000000020  R      0x8
  GNU_EH_FRAME   0x0000000000000184 0x0000000000400184 0x0000000000400184
                 0x0000000000000014 0x0000000000000014  R      0x4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10

 Section to Segment mapping:
  Segment Sections...
   00     .note.gnu.property .text .eh_frame_hdr .eh_frame 
   01     .note.gnu.property 
   02     .note.gnu.property 
   03     .eh_frame_hdr 
   04     

Displaying notes found in: .note.gnu.property
  Owner                 Data size	Description
  GNU                  0x00000010	NT_GNU_PROPERTY_TYPE_0
      Properties: AArch64 feature: BTI, PAC

