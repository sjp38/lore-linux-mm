Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA4F1C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:24:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC4D820868
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:24:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC4D820868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3556B000A; Fri, 24 May 2019 10:24:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397346B000C; Fri, 24 May 2019 10:24:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AAB86B000D; Fri, 24 May 2019 10:24:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D16556B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:24:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r48so14418515eda.11
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:24:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/ni3H7vmzRcpLi5zY2OG4Vfzj9SMruM5cp3s3+OGOqM=;
        b=e3oBwCsvlz3uGiLsjkEleycKBmdjnB5olCmWS1vwx1KFHNk76SqymMMNvl2or7KFQN
         P4WRt1dxY6LxSnbY7t9sKcUqWV/0V+248yUUGezLIuZHhOAgURotxudZEUxwO5FF+NVk
         JFcNCQWc3vulOwUvqFehyL3tMPDHFFkzdWrENOXTTXLfQGH62erocGccC6al0x/rECEa
         idCuteI/ODJP1e2Ep7EHEmUKvv0Hb1yvGSGtEz+ik2JpsRinAbv/Dc3OwSU0afaC4z+r
         4sW5fJx1bnDA3RiPx8IHimc6gAJlvyTtd2QtrQ9vF7o3W6vh6t3ilkdaEXFARnRbZLm3
         zFvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAXVurd95b1nuSH2Ran5+ONDn8bWdfwhp0z/4GPFOqPY/CtJUiFu
	cb4/fgyjdm154EguaeCoMDXsmnfen8pKfcT+OOTBCdZemyChIwSUbR+z7qLoNKmLm7pP6vD57Od
	XdHsCMlGJvonpTHPQFowJGA5dUutEDW/TELe5zSirXK/7V1AYbGaxCcfO7+17wjUqYg==
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr27303109ejb.186.1558707845379;
        Fri, 24 May 2019 07:24:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxupKBwYaSIn3/hBXRJXvqOEaHOCUaitwMe0KOPxj7nEBKBHq/sLyBEBN17hYcsFn4xw+20
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr27303001ejb.186.1558707844373;
        Fri, 24 May 2019 07:24:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558707844; cv=none;
        d=google.com; s=arc-20160816;
        b=Yt1EezsJEURyqQLB3lvZ/WRn/wf9GHizoIlMYA2AgK6zh8UkNgUIw7Y4V+pR7duodn
         lioGP9Z8PRv4QzcMx2f9m4A2/FaAKcuYKp721W/0QIVZQWoitYktyqZZeZYSbboRJAYs
         Vu7kPPu2RIDrmGrX8powXkahN3zJmVgix3330cZsZ1gtZlFVPrc4CvNAKe8V9pmGbkVA
         I3SUb+fB80g+//xmIpnszFon62rzFkFjxhABYL4WXokgGPYTUk29zVfPmlVaKHZjQ8c+
         av/YwAMMA7zV8FBobhyzZ/FIz9b1q4rqYb5Wrn59drZSTO91k5Vp3gGVPYKO8N+eiv+Z
         FtEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/ni3H7vmzRcpLi5zY2OG4Vfzj9SMruM5cp3s3+OGOqM=;
        b=p1ZZPwxT36oKqnHF2l6wBa/EiwxB/D1UKjR2Hf/coT+hPY5qVaMF+AIzb6C3i2QPX1
         RMLNsuQ+JuoY/PY/N4mSPgCIdOR0O5zcXqEf5aGn1BSSnMrD8x7b+DgW+ydmNjsEs3uN
         HS4KXWaYYQjUs8e9MMesZvW7Xc3fm06YykIZ5YKOuK16X/9fH0/petvggWLm6ox9NrJf
         slaP8s4EvI3NBFr0XXoYabFsEHYPXD+LlnLJm3WSJErehK2+6hn+DSEdpRlJd+swGFKi
         aqSoB5hkivQMZ7mLml33vLerKn895/U9ukMIk8H2l+4RYI8m8y+Qxqj8ysY7V2MfrSqZ
         th3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v11si1802958ejo.14.2019.05.24.07.24.03
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 07:24:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 268E8A78;
	Fri, 24 May 2019 07:24:03 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 65CAA3F575;
	Fri, 24 May 2019 07:23:57 -0700 (PDT)
Date: Fri, 24 May 2019 15:23:54 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@ziepe.ca>,
	Dmitry Vyukov <dvyukov@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190524142352.GY28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <20190521184856.GC2922@ziepe.ca>
 <20190522134925.GV28398@e103592.cambridge.arm.com>
 <20190523002052.GF15389@ziepe.ca>
 <20190523104256.GX28398@e103592.cambridge.arm.com>
 <20190523165708.q6ru7xg45aqfjzpr@mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523165708.q6ru7xg45aqfjzpr@mbp>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 05:57:09PM +0100, Catalin Marinas wrote:
> On Thu, May 23, 2019 at 11:42:57AM +0100, Dave P Martin wrote:
> > On Wed, May 22, 2019 at 09:20:52PM -0300, Jason Gunthorpe wrote:
> > > On Wed, May 22, 2019 at 02:49:28PM +0100, Dave Martin wrote:
> > > > If multiple people will care about this, perhaps we should try to
> > > > annotate types more explicitly in SYSCALL_DEFINEx() and ABI data
> > > > structures.
> > > > 
> > > > For example, we could have a couple of mutually exclusive modifiers
> > > > 
> > > > T __object *
> > > > T __vaddr * (or U __vaddr)
> > > > 
> > > > In the first case the pointer points to an object (in the C sense)
> > > > that the call may dereference but not use for any other purpose.
> > > 
> > > How would you use these two differently?
> > > 
> > > So far the kernel has worked that __user should tag any pointer that
> > > is from userspace and then you can't do anything with it until you
> > > transform it into a kernel something
> > 
> > Ultimately it would be good to disallow casting __object pointers execpt
> > to compatible __object pointer types, and to make get_user etc. demand
> > __object.
> > 
> > __vaddr pointers / addresses would be freely castable, but not to
> > __object and so would not be dereferenceable even indirectly.
> 
> I think it gets too complicated and there are ambiguous cases that we
> may not be able to distinguish. For example copy_from_user() may be used
> to copy a user data structure into the kernel, hence __object would
> work, while the same function may be used to copy opaque data to a file,
> so __vaddr may be a better option (unless I misunderstood your
> proposal).

Can you illustrate?  I'm not sure of your point here.

> We currently have T __user * and I think it's a good starting point. The
> prior attempt [1] was shut down because it was just hiding the cast
> using __force. We'd need to work through those cases again and rather
> start changing the function prototypes to avoid unnecessary casting in
> the callers (e.g. get_user_pages(void __user *) or come up with a new
> type) while changing the explicit casting to a macro where it needs to
> be obvious that we are converting a user pointer, potentially typed
> (tagged), to an untyped address range. We may need a user_ptr_to_ulong()
> macro or similar (it seems that we have a u64_to_user_ptr, wasn't aware
> of it).
> 
> It may actually not be far from what you suggested but I'd keep the
> current T __user * to denote possible dereference.

This may not have been clear, but __object and __vaddr would be
orthogonal to __user.  Since __object and __vaddr strictly constrain
what can be done with an lvalue, they could be cast on, but not be
cast off without __force.

Syscall arguments and pointer in ioctl structs etc. would typically
be annotated as __object __user * or __vaddr __user *.  Plain old
__user * would work as before, but would be more permissive and give
static analysers less information to go on.

Conversion or use or __object or __vaddr pointers would require specific
APIs in the kernel, so that we can be clear about the semantics.

Doing things this way would allow migration to annotation of most or all
ABI pointers with __object or __vaddr over time, but we wouldn't have to
do it all in one go.  Problem cases (which won't be the majority) could
continue to be plain __user.


This does not magically solve the challenges of MTE, but might provide
tools that are useful to help avoid bitrot and regressions over time.

I agree though that there might be a fair number of of cases that don't
conveniently fall under __object or __vaddr semantics.  It's hard to
know without trying it.

_Most_ syscall arguments seem to be fairly obviously one or another
though, and this approach has some possibility of scaling to ioctls
and other odd interfaces.

Cheers
---Dave

