Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE3BCC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 09:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91630218CD
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 09:07:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RJpXP6G5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91630218CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F33F6B0003; Fri, 19 Apr 2019 05:07:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A30A6B0006; Fri, 19 Apr 2019 05:07:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 193496B0007; Fri, 19 Apr 2019 05:07:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D86256B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 05:07:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so3136037pfi.20
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 02:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z3FgX2qYeAVr6a7aOjZTKzD1LI5HjVL2uBhAKfg9pDs=;
        b=QTzGc7S2MDDQeK0fkT5WsgjU0an3cfY7lADmhN/16zBKG0sfqAU1YDeuBbvvZlFbiq
         0xGVHq6mJ6e++yXKM6AohOYHHpVUImBAPFWl0pjZh/bF3XFr0KebI0w0JnpOpUFEBIyc
         pHg/GTgiay80pJUxXoBrHFl6IK/AmfqHNoOT+/PX6hEqo1nkuXPhUtMmgglE2GjZ6tXz
         VWB+HS0YtDHtFEOHzZe4rm/3tOu5WkT7+nOD2UZ4VnSvzVKd6E1N6yZmCxltI3r14hO5
         SlAvJngaVFieaHtyMAI2MDGjebxuokkGyNSK24qhrCmsorQKf84NsVFgfpR1VKaydTEE
         yF0w==
X-Gm-Message-State: APjAAAWJi9h4o+KsymLKEVU8GhFqjjZ315vM0+ilBT/vSfubknM6cTpl
	H2OMXN22J03b8VjydnAtLjj9IND+0I9aPqzbHMcifv7uWP8EpcZOj0Q0xjR2wr4PdDjOkjlyFxl
	FrRJpBJMtYqJW94gTWv8teA4MUw12Bs4FG8IJKPXLNl2bxpYlrclbNI6hpUB7oJxCiQ==
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr2588726pls.293.1555664855194;
        Fri, 19 Apr 2019 02:07:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5bOydWC+YdYtI80E9uls9VLDLa6y2DdKoSvnb1ueOl+cX3tPrVKEPRS5fZPaNAUoPSOx0
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr2588654pls.293.1555664854344;
        Fri, 19 Apr 2019 02:07:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555664854; cv=none;
        d=google.com; s=arc-20160816;
        b=dlk3JvaXj1roNjs7GuKVynBQ15XNwYHbTgg8d/9CUUhqrUNDMpNXFcWe0laXCwGVb5
         l2MGm0sG6mmj9Nz1KFNZiRg0TR3oUJMIH7sFq0yeGHjpJCp+8VK3akBS3WOMeDZ38NPy
         hEJ1oAKbseEuVN+5ppS5EhNeQN7nN6qd/DamMtz3OYiDhGRv6md61cmfiBNnyQ+ljU6x
         hGyMlgqZFIB8YFeDBM2AeH2qH0fkvtYvqjIUZ23kIhZ9aF+qs1buTpHo5D3FxAwfHZ3+
         Az7fADnSgJNCZ4aAIHy7L5griC2yIGxX8q1d1XpP+5J1JnZ/zPle0j/Dce7LvgzgoiwL
         lNsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z3FgX2qYeAVr6a7aOjZTKzD1LI5HjVL2uBhAKfg9pDs=;
        b=v6j7aF7wkcxhGrDLi9/24G0j3DKFnqLl5VT4wsZyNviPk0OoACJexSFXMCf3N+H5ip
         WyDl3ftVYOxvuhn3Q1odMAdMmidQcV2VwVGJk/9/3noFf0fI/LjYO2rNeGB7IUuTYKO2
         ALDhfJicOBJOjGuxKFelOE6AfScz6OYjB7HTK1XkV0A6qfFrS8IFz2AaTU3N8JY6Dj3I
         zEcRweoHng/raH3W66kHc9WX44K2YVSoG8545nNrj33lCCj3XzDLKn+co86xZz+BC1wl
         R0hVaKPT1ylXK+kXMF0EjmhGrSnsF6niIReMfLWic0Z0Eyf0jdQgrcr72MLyc6NcpuPl
         Jjtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RJpXP6G5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l6si14468pgp.489.2019.04.19.02.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 02:07:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RJpXP6G5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z3FgX2qYeAVr6a7aOjZTKzD1LI5HjVL2uBhAKfg9pDs=; b=RJpXP6G57WJQo20w1oN6XV1Sv
	W0L+9FKiKEGCXF0UITD24ixi+tPLIpDsoo3ae5bCC4wswL29O/O1INxloaH4aS+LS5yudtvbT81Fe
	Wyjy7ZPOBCxw1Isgsz4PXKHIt/FoNeftgsdcHKhkwrLmW0UrqT9w+USQ4dwLxmPbn84yeQGclO3a6
	xNsCQIrNih4rri7LJVSPoidSd3rDLti1c9VgyWRiS/K6aGXChzk762fRVgxajeZs/pUD/y03P1xNR
	3LO1qv4gn1QkLcarsdl9Pi02ID3DDYmPnYB9iH/StdK1D5dChx2YdtqtZ/iCpQ/j41edlnb+n3hiR
	7ZbFFPYzQ==;
Received: from [92.65.108.250] (helo=worktop.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHPUT-0001vd-67; Fri, 19 Apr 2019 09:07:25 +0000
Received: by worktop.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0D676984ED8; Fri, 19 Apr 2019 11:07:18 +0200 (CEST)
Date: Fri, 19 Apr 2019 11:07:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>, linux-arch@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>
Subject: Re: [patch V2 28/29] stacktrace: Provide common infrastructure
Message-ID: <20190419090717.GN7905@worktop.programming.kicks-ass.net>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
 <20190419071843.GM4038@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1904191031390.3174@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904191031390.3174@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 10:32:30AM +0200, Thomas Gleixner wrote:
> On Fri, 19 Apr 2019, Peter Zijlstra wrote:
> > On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> > 
> > > +typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
> > > +                                      bool reliable);
> > 
> > > +void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
> > > +		     struct task_struct *task, struct pt_regs *regs);
> > > +int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry, void *cookie,
> > > +			     struct task_struct *task);
> > 
> > This bugs me a little; ideally the _reliable() thing would not exists.
> > 
> > Thomas said that the existing __save_stack_trace_reliable() is different
> > enough for the unification to be non-trivial, but maybe Josh can help
> > out?
> > 
> > >From what I can see the biggest significant differences are:
> > 
> >  - it looks at the regs sets on the stack and for FP bails early
> >  - bails for khreads and idle (after it does all the hard work!?!)
> > 
> > The first (FP checking for exceptions) should probably be reflected in
> > consume_fn(.reliable) anyway -- although that would mean a lot of extra
> > '?' entries where there are none today.
> > 
> > And the second (KTHREAD/IDLE) is something that the generic code can
> > easily do before calling into the arch unwinder.
> 
> And looking at the powerpc version of it, that has even more interesting
> extra checks in that function.

Right, but not fundamentally different from determining @reliable I
think.

Anyway, it would be good if someone knowledgable could have a look at
this.

