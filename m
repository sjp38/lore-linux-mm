Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAB0DC31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80D0220B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:32:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80D0220B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16A4B8E0002; Tue, 18 Jun 2019 09:32:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1427D8E0001; Tue, 18 Jun 2019 09:32:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0304C8E0002; Tue, 18 Jun 2019 09:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6FF38E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:32:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so21290219edd.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N4pVrL6usQLH6c5p5qN/YVIiWKQ3Q0SXmNB3pZRT4Ac=;
        b=QcT7khPOVonrzHV+mZZno7mFlCsr/Jmlp0pdt0kGzqjIJx/dtswVBXKv4gdLjbxs5Q
         JXWw2j9osLzdKJ8zyRDQ6ACaHQeNIr1Ssy+Co2snYyder3duURdbX5WZnriyRzxdKR/k
         VhbOTrfMriZAZ8gS0G3t1j0jOxz2zRVNY5b/RCyrxWTy7CI146EbwbT3s1JLynyQXaBQ
         Dmm958iIVNEFpjVa/++S6uASjJXT+JxX47DVhniO89xu6rzUWG1w5OHvmXMLMVYkq4fb
         cQC3kdtyT3mBidwvA2iUjlt0zlySn+jn56sJNTRJtJgdHDrzvbucbibR6XjK5Di9Wj4O
         rylA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAVS9V1nMh2v8t2wmwQkc47yZNe/CHXzMMppTlulLH4ycf9legDv
	5MxWRbqL63QgFoUxBswhYviLjLcYFoEnfO4jtovjjwAktWQfsyYKjc6DCt/7+1nJNmgeU8IHSOv
	YvFFTEYTtFfa2h6DCoyzvk4GvPDvK/3Xc7Wpg7Tl/KTUBvfMiF65jcp74K19x6VqYMQ==
X-Received: by 2002:a50:9441:: with SMTP id q1mr97943387eda.41.1560864753112;
        Tue, 18 Jun 2019 06:32:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJB3Ti90YJy1qyKirv2txLkFArIZ+H9/xss3bzds9Yz45SF/JgYu/BSiqd+dyboLzc97do
X-Received: by 2002:a50:9441:: with SMTP id q1mr97943275eda.41.1560864752244;
        Tue, 18 Jun 2019 06:32:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560864752; cv=none;
        d=google.com; s=arc-20160816;
        b=diYw7ey8tbBVjCuYUVzoHu0Y1PxQqwS0842IxbFI0WlgFHSDrJCBJXI6yWFheRGTvu
         Gdij65ygmJW1uwi4TdVka5wfZm0BuyavHdAJfzjZnncCmDiOyVtN8z2ztpKKTO+FyFMd
         3rI2Y51B2JDLZ+fNtqFpl2PQS5YYPNIx0cZZZPiTmFI4OseIo2pKr5x/2BoniREbJCAK
         /Jo/5ZeZJIaYZHjzwWJ4LH4Er2Qe4W2tg5pwEzhx7x6cQPebZ6mhaCQhg/8JlUgjmL+l
         hxPSXhFX1y21OoEvd9HmAh6z+zgFjM8pvS8nmYip3C7tTJVfkZ1CaDptzL6XhQO/tD4f
         TzLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N4pVrL6usQLH6c5p5qN/YVIiWKQ3Q0SXmNB3pZRT4Ac=;
        b=lMeoe0O0hvwL+e4+mDJO2lPDwqdYXKd2H1rdHvdh89vCliHfOP4RKH+HVEgRgSaL0C
         vzE8i2sIDtwmULtxitr4lj7ukvDfJYLLcfMdoL54kZ76bPDQ/yq3lIeIDNtZv+zT8sKt
         XchTt2Y2qTzk9CDziEJv91BiKRg/nUbpq2k/ACH5eHsordMTiUmRvyM+0OeDh0OVtd0F
         zLR9nCR33Rudpz2p3po1bDo35xmvQCPn4S1ZXPtOQB6EFgF3pWNb8zw06yD2qc52yo0m
         hKEvtPhpT4mjhINnpgi6cjk85aDWoHT6OqLJIeYPLvgKd5BmXlM9nr/qUsdgWOBYJnAz
         Stew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c18si10869120edc.229.2019.06.18.06.32.31
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 06:32:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2CBDA2B;
	Tue, 18 Jun 2019 06:32:31 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 956973F718;
	Tue, 18 Jun 2019 06:32:27 -0700 (PDT)
Date: Tue, 18 Jun 2019 14:32:25 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618133223.GD2790@e103592.cambridge.arm.com>
References: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
 <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
 <20190618091248.GB2790@e103592.cambridge.arm.com>
 <20190618124122.GH3419@hirez.programming.kicks-ass.net>
 <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
 <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 02:55:12PM +0200, Peter Zijlstra wrote:
> On Tue, Jun 18, 2019 at 02:47:00PM +0200, Florian Weimer wrote:
> > * Peter Zijlstra:
> > 
> > > I'm not sure I read Thomas' comment like that. In my reading keeping the
> > > PT_NOTE fallback is exactly one of those 'fly workarounds'. By not
> > > supporting PT_NOTE only the 'fine' people already shit^Hpping this out
> > > of tree are affected, and we don't have to care about them at all.
> > 
> > Just to be clear here: There was an ABI document that required PT_NOTE
> > parsing.
> 
> URGH.
> 
> > The Linux kernel does *not* define the x86-64 ABI, it only
> > implements it.  The authoritative source should be the ABI document.
> >
> > In this particularly case, so far anyone implementing this ABI extension
> > tried to provide value by changing it, sometimes successfully.  Which
> > makes me wonder why we even bother to mainatain ABI documentation.  The
> > kernel is just very late to the party.
> 
> How can the kernel be late to the party if all of this is spinning
> wheels without kernel support?

PT_GNU_PROPERTY is mentioned and allocated a p_type value in hjl's
spec [1], but otherwise seems underspecified.

In particular, it's not clear whether a PT_GNU_PROPERTY phdr _must_ be
emitted for NT_GNU_PROPERTY_TYPE_0.  While it seems a no-brainer to emit
it, RHEL's linker already doesn't IIUC, and there are binaries in the
wild.

Maybe this phdr type is a late addition -- I haven't attempted to dig
through the history.


For arm64 we don't have this out-of-tree legacy to support, so we can
avoid exhausitvely searching for the note: no PT_GNU_PROPERTY ->
no note.

So, can we do the same for x86, forcing RHEL to carry some code out of
tree to support their legacy binaries?  Or do we accept that there is
already a de facto ABI and try to be compatible with it?


From my side, I want to avoid duplication between x86 and arm64, and
keep unneeded complexity out of the ELF loader where possible.

Cheers
---Dave


[1] https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI

