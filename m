Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C83C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 16:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 745E7208C0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 16:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 745E7208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D241D6B0003; Fri, 19 Apr 2019 12:17:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD1076B0006; Fri, 19 Apr 2019 12:17:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFBE6B0007; Fri, 19 Apr 2019 12:17:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1FF6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 12:17:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k68so2253850qkd.21
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:17:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VeS9ma+wicF8zbgwRvzdQ+Xy7920m5g7okRsCiGb38Y=;
        b=bjeH5+D8jbjLLF15OrYWp8aysv//jiKCEXzKoh1Pcp2ZFcjvadF4jBM85O95nbr16n
         gBkn+TKwF2gJEU21SfgPL7PEcAHyDSrnS0y7FwhiZ32En7wi7mxF6ZZZvetV2HoDFHmo
         EwAHsJdzQy5QzQG85JMgEKBPkHTmV0kB8a3e2UUOVovvYCmYMkkpciL5LXe4Ss3mQWRU
         vbMH2FEFalmuw7IQcvS4YNp/LHLbcXPfml0E0zo/GY+CjYxqqblILjS1nWNlfzUo0mte
         Hc4j2t5npkp/60L8ASexEVIICmt/+QVQcpUwybIke982FRQi4GwqSzsTSuvUkCa1Csgz
         GKjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUtXTcKYG/CPsdN6zfcnO5YyJKmz45eKbJJ6tcBvccYwOhKRFCl
	ki/f1Oe3/WKXogJk1XE+infwxbRPvx2MOHzshg9O4NZVjjFqe5ufbFyYjvMzGnSlpCQ8b31TIRP
	6Qx9NVGK9Z5OUfM6G8QCGV2Mu6Lq+EXrNeeqnnGvcgqlm9HMsSqtrl+ywpYH3svf75Q==
X-Received: by 2002:ac8:544c:: with SMTP id d12mr3980990qtq.199.1555690664367;
        Fri, 19 Apr 2019 09:17:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOEM7akI1UKrngN40+FW2bmxO7WeZCr7hrQVRehqrFUalSk1ZyxjdY8xa9A2lxcLMDaQb0
X-Received: by 2002:ac8:544c:: with SMTP id d12mr3980938qtq.199.1555690663637;
        Fri, 19 Apr 2019 09:17:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555690663; cv=none;
        d=google.com; s=arc-20160816;
        b=KYR3DgR6cUyZiKyFtJRV1nJX2txCR82TvboKgQv45IFIsgTtUHnoKhGcJL/MoHt4Wu
         KvGdl9ZEJ43Q4e5nLxQarOSNX8ABnJQ+cQAknLN2Z23dQDxKSZeve9nOS9cxrmCjalb6
         g+omFMYzWB4vFXhPGpnfDHNoqZAmpkP7H0wr0pYyGRUTCzooQ3F56nAfq9yTZcerQ7Iy
         a5w1fOu5y7MJugZHQnXigphRup3fq/zxbvnvWDR3bn+d85PbRhyptytGnejqtWlHfub9
         WY+bf4cuPDwTqJCgwUb7k2RjQFGFFzS44mEf+RbQzHJBa9s4DMvyE/eTSjgG5uFXfCvd
         FnQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VeS9ma+wicF8zbgwRvzdQ+Xy7920m5g7okRsCiGb38Y=;
        b=Q7nCUZM5gS0Yj5+86Pc3iMEzIl+b7PMJU5fudbkv/CFLU+L4OaEcfK3aPPBAYxHPm5
         zUBGe4wFewxacrX9l7l+m2xpfFLviOHSaNlkSIpcSCccdJ/bV3ymNn9P9e7dLmXchJAo
         5925P4TxJ+GQKzcIQtYVbYL8MnvKU+HQ1q1QxxJESVy2FT7wI9z3S90IB02Q6qv3x3FE
         6jNOzlCBQ2lwHJhxHcZGNphI3uOrGmwo5ylOjkPdsipDSRmMBYpexqL9tpMvdOW2Gen2
         lqgn2OqoYgvYId6iWvzp/xBctAypEKklGxI5mTwLR6KwU/dQ78TQ1lRQonmrh5P/Mu8s
         2NkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a20si127673qvd.39.2019.04.19.09.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 09:17:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B05EF85541;
	Fri, 19 Apr 2019 16:17:41 +0000 (UTC)
Received: from treble (ovpn-124-190.rdu2.redhat.com [10.10.124.190])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8459E5D9D2;
	Fri, 19 Apr 2019 16:17:32 +0000 (UTC)
Date: Fri, 19 Apr 2019 11:17:30 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
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
Message-ID: <20190419161730.zgpa3e5fhny42wq7@treble>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
 <20190419071843.GM4038@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1904191031390.3174@nanos.tec.linutronix.de>
 <20190419090717.GN7905@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190419090717.GN7905@worktop.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 19 Apr 2019 16:17:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 11:07:17AM +0200, Peter Zijlstra wrote:
> On Fri, Apr 19, 2019 at 10:32:30AM +0200, Thomas Gleixner wrote:
> > On Fri, 19 Apr 2019, Peter Zijlstra wrote:
> > > On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> > > 
> > > > +typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
> > > > +                                      bool reliable);
> > > 
> > > > +void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
> > > > +		     struct task_struct *task, struct pt_regs *regs);
> > > > +int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry, void *cookie,
> > > > +			     struct task_struct *task);
> > > 
> > > This bugs me a little; ideally the _reliable() thing would not exists.
> > > 
> > > Thomas said that the existing __save_stack_trace_reliable() is different
> > > enough for the unification to be non-trivial, but maybe Josh can help
> > > out?
> > > 
> > > >From what I can see the biggest significant differences are:
> > > 
> > >  - it looks at the regs sets on the stack and for FP bails early
> > >  - bails for khreads and idle (after it does all the hard work!?!)

That's done for a reason, see the "Success path" comments.

> > > The first (FP checking for exceptions) should probably be reflected in
> > > consume_fn(.reliable) anyway -- although that would mean a lot of extra
> > > '?' entries where there are none today.
> > > 
> > > And the second (KTHREAD/IDLE) is something that the generic code can
> > > easily do before calling into the arch unwinder.
> > 
> > And looking at the powerpc version of it, that has even more interesting
> > extra checks in that function.
> 
> Right, but not fundamentally different from determining @reliable I
> think.
> 
> Anyway, it would be good if someone knowledgable could have a look at
> this.

Yeah, we could probably do that.

The flow would need to be changed a bit -- some of the errors are soft
errors which most users don't care about because they just want a best
effort.  The soft errors can be remembered without breaking out of the
loop, and just returned at the end.  Most users could just ignore the
return code.

The only thing I'd be worried about is performance for the non-livepatch
users, but I guess those checks don't look very expensive.  And the x86
unwinders are already pretty slow anyway...

-- 
Josh

