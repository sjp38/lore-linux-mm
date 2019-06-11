Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B632DC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 11:41:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7339120673
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 11:41:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7339120673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8946B0006; Tue, 11 Jun 2019 07:41:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 099BA6B0007; Tue, 11 Jun 2019 07:41:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7CE06B0008; Tue, 11 Jun 2019 07:41:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD166B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so8899292edm.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 04:41:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LkSzo+/iGK0/+BSAGoi+ENvefKKCGrisZxK4DaQ95UA=;
        b=JUnJhsO8MoAVfX1toVKdqsrxs9rYj60kutbHdWVXPOPhp/O2B17wQCKCZs9sxS+AXP
         f51DL8hJ4LaM07/ZSQGw1FR1uPkodV4L/AC1w2VpHFiL14/4jsxZaWUGuAjcNuCogn5L
         B+N0fk4d2Frz5UvVPUQVNGs4sRlf9dNwcU9wNVpYfmWaNec4HhovvmO974uebNonZy6Q
         etH/uUcAa94j6WeHYOuQl63GcJjOtU4MQLac0jolVb8PdyshNkp13jWtKr4fqkg50xFD
         OCif8FzuHxsaBkyEAfktmpZ6lzl2+1mbFNZxTBrbYKCK51szi7Kq839i59oo7EenXCNr
         SFLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUbTIrlxhqm4qmk22m04vJcjmhCunMVak42ziJfHQ/8GMfmTOvx
	lhJV39D1haw0XNgW9HhaZ6U9OHn2Y8pX9ZoQVvf6u4fsJpOSsyCE8Sn2Me78FA3g0PCjhIzdTG7
	6XudEyuGZLYs+2M+L3lv0fTX4ryQMjGKlBP6RoQjX/HOFhvE9VIYoVi8Y3hyN+a705w==
X-Received: by 2002:a50:90c6:: with SMTP id d6mr58456873eda.19.1560253277226;
        Tue, 11 Jun 2019 04:41:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/MNpOuOnT943NNXIGy9MCVt7/1NSkaTCVKF+Ll325a4sLcIFB05c4z+xoScO2StMH4VL+
X-Received: by 2002:a50:90c6:: with SMTP id d6mr58456808eda.19.1560253276480;
        Tue, 11 Jun 2019 04:41:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560253276; cv=none;
        d=google.com; s=arc-20160816;
        b=iSP7Pd8FhvCO/dJSkuBcqtmJknkjATlY60Ioud5RXJyDU227AGqVMgnfUsI59et8pc
         m3ENTBXcc8QQ7sPN4f5O1+EWF9PNk0NeIDY3Y4yfoQFL0cEjuK8718K3Ghb9pGxC15GK
         3VMOcuPNysY78gFvzeF9bBGBNJQZxuTePdIhxaj4fwGaYJGMFoBbTqWd3bxGHx9D+c+l
         SQ66G/AVzVdhsyMj1Z22lf4X5KLWne7T5jBnE3RQlxGsFqIPmajdZeiu1rTdzv/Ne5tk
         5S0RcDBUZcu7QOw5AUWLlIFGy96MR8jbU3JaDMmLclXii/KdyN6a7tuiG8yTh9AUywX1
         mVLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LkSzo+/iGK0/+BSAGoi+ENvefKKCGrisZxK4DaQ95UA=;
        b=GO9VfcpO8zkdMggAlUA1c/JOrtS+pQFvRw9UkyZRfhl/+WxCqMpPCr8DpTpi7QxFCD
         RZ4bFkyml99d53aK3i1dJMVs9W/BqterXSjsCcXtQulJ4BJkugCDBI9SoXOsJOQlajUp
         9AMwLazS4+zLOv0Tidyx4y7OPvCBP7LfChRtFTNYoXU4dSo0j8FZ8vlqLyIb+F/x6ukS
         OJahfrow2d82SO44gdVt175+DvrUd2W31mwDZqaYVEr+eMnytRscbdy3OY1moWY++TWs
         +3yODjUJqjcnDEdUp2kSZxnVDdqsqZCAxx4azRYatcI08HsjAS+epX4Bx5fImj6sgrWf
         4Riw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b5si2848720edb.259.2019.06.11.04.41.16
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 04:41:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4F861344;
	Tue, 11 Jun 2019 04:41:15 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1A54D3F557;
	Tue, 11 Jun 2019 04:42:53 -0700 (PDT)
Date: Tue, 11 Jun 2019 12:41:09 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Florian Weimer <fweimer@redhat.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
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
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190611114109.GN28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
> * Yu-cheng Yu:
> 
> > To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
> > logical choice.  And it breaks only a limited set of toolchains.
> >
> > I will simplify the parser and leave this patch as-is for anyone who wants to
> > back-port.  Are there any objections or concerns?
> 
> Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
> the largest collection of CET-enabled binaries that exists today.

For clarity, RHEL is actively parsing these properties today?

> My hope was that we would backport the upstream kernel patches for CET,
> port the glibc dynamic loader to the new kernel interface, and be ready
> to run with CET enabled in principle (except that porting userspace
> libraries such as OpenSSL has not really started upstream, so many
> processes where CET is particularly desirable will still run without
> it).
> 
> I'm not sure if it is a good idea to port the legacy support if it's not
> part of the mainline kernel because it comes awfully close to creating
> our own private ABI.

I guess we can aim to factor things so that PT_NOTE scanning is
available as a fallback on arches for which the absence of
PT_GNU_PROPERTY is not authoritative.

Can we argue that the lack of PT_GNU_PROPERTY is an ABI bug, fix it
for new binaries and hence limit the efforts we go to to support
theoretical binaries that lack the phdrs entry?

If we can make practical simplifications to the parsing, such as
limiting the maximum PT_NOTE size that we will search for the program
properties to 1K (say), or requiring NT_NOTE_GNU_PROPERTY_TYPE_0 to sit
by itself in a single PT_NOTE then that could help minimse the exec
overheads and the number of places for bugs to hide in the kernel.

What we can do here depends on what the tools currently do and what
binaries are out there.

Cheers
---Dave

