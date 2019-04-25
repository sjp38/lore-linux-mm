Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C19EC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 137A0212F5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:29:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 137A0212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D5716B0008; Thu, 25 Apr 2019 09:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 785C66B000A; Thu, 25 Apr 2019 09:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6746A6B000C; Thu, 25 Apr 2019 09:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4169F6B0008
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:29:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k7so4103487qtg.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:29:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dOXWWWDkOJL9gmPvZN+tjdw5yq9s62smKpoaJgbFSeU=;
        b=rDObsfYzwzoo3xgKFokX3pe1LnqtxNavO5i0r4f/jt0k3aVrcho+BouJSHMl3kGejA
         XrfaD5BAYQbYTDrUw36O22ec9RXQFNHKQYEbBDIenVNa2RPnb7+C17V0BAuQtozknuU5
         ZnjSaI0HuT381W3AGSZehqIHxpMu/kzuO7wA8x1siOghChk+l8jHCetTDio1r1oCZIO6
         i05taCvKhEiz0Y0ufXF/jEGVpaH50zrAGDgqNlZtkU3ku8F2QQRlieNr3QkNyCmtSqYM
         riD4fzUrKhYvpSi4v/l3Cdb7Vf9kPTppUOU0WuoNv1DjiJJToQUNLOHSZAOzHRH+faws
         jezQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAULf4OH8DHCPmYAtCkb+F6kmLog2iuEJIxjTzDJ2zUnkZFaE6MY
	pwzsozEHYvHOmqCPPu/CR41prCq54r/edHsCG8wb56fKx0tRN6RigIs48Ip4vHcv86rnMxAV80O
	Pcmi2Gu3pREiPmMUZk66gpxK/94IPGHOPZKfw5q2l7Adpa491gAx+DlfvoI3vsgB9MQ==
X-Received: by 2002:ac8:3758:: with SMTP id p24mr17504846qtb.3.1556198993004;
        Thu, 25 Apr 2019 06:29:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVlm4fHNo9qGVA3mWUxy0+F9MFTAgUOVxXu4yQv9Cy918jOxsGS1PYPCqRotHyoLOZtjH4
X-Received: by 2002:ac8:3758:: with SMTP id p24mr17504788qtb.3.1556198992159;
        Thu, 25 Apr 2019 06:29:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556198992; cv=none;
        d=google.com; s=arc-20160816;
        b=G5WlXQ77ZUdhWqr3wqDrdyg3R+GBfuysYcbV5y4O1Z/r7jmejmSwYBy9xYe/3+rbIj
         +zvV/F2qYVbcVg1Eh3lxSz9yPQJncmQ24HGGfQwleBPWcTU6X6QA9oDREXzxsgN1bkVK
         Ewz+4MYJmLZ4bR1K1y41wx7BkPqlYwbremGvBD4YW6xut46t4MTBNQJOyqmdbLrIUaem
         miRhnQBLqolyyv6kr+K6FcZx0YsGBPmfRTD5YCWJsiFPsfMljs3xgA73txeQZ0aiwz1X
         tufOW0gB85AdRhbXRtRWQPU8bi2llutR9JOD0/Nud5L9t2IDxQGscsqG+ehZ88/Gv1AF
         4R8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dOXWWWDkOJL9gmPvZN+tjdw5yq9s62smKpoaJgbFSeU=;
        b=du+uk/EMkBTsgcaxF6i/r448pIrabpVkMEACJkNu7uqqrLfc+zGnV2aeDFMRk90CQC
         WjzvQETSZgnZSlGpnRwuKPdu6DIeBO4ODEv/xUeQXqbe2jRBiBEX8Q+k57fSCDewc1RL
         YoOYJegAW6Kpc0WdGoZk1NHCsQtS1rxCud5GUi//A3zUcVEYXar/S1NR77XR7qbHOlNs
         UXv2gtq94c9D4HLYXJ/OFk74tdiaouziS65CuMYzvPZEF+gDP7lrt5B3moLxTWl9HrKM
         vsJaukK+wK5kKlfCy2E2xLfnFTFd+g8d8Iubx8vrFMQXoXwFKH5GOUls+Pv6OWgQdTVx
         W6ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x22si1088778qvc.42.2019.04.25.06.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 06:29:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B577307B4B0;
	Thu, 25 Apr 2019 13:29:50 +0000 (UTC)
Received: from treble (ovpn-123-99.rdu2.redhat.com [10.10.123.99])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 390A060141;
	Thu, 25 Apr 2019 13:29:39 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:29:35 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Miroslav Benes <mbenes@suse.cz>, linux-arch@vger.kernel.org
Subject: Re: [patch V3 21/29] tracing: Use percpu stack trace buffer more
 intelligently
Message-ID: <20190425132935.ae35l5oybby5ddgl@treble>
References: <20190425094453.875139013@linutronix.de>
 <20190425094803.066064076@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190425094803.066064076@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 25 Apr 2019 13:29:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 11:45:14AM +0200, Thomas Gleixner wrote:
> @@ -2788,29 +2798,32 @@ static void __ftrace_trace_stack(struct
>  	 */
>  	preempt_disable_notrace();
>  
> -	use_stack = __this_cpu_inc_return(ftrace_stack_reserve);
> +	stackidx = __this_cpu_inc_return(ftrace_stack_reserve);
> +
> +	/* This should never happen. If it does, yell once and skip */
> +	if (WARN_ON_ONCE(stackidx >= FTRACE_KSTACK_NESTING))
> +		goto out;
> +
>  	/*
> -	 * We don't need any atomic variables, just a barrier.
> -	 * If an interrupt comes in, we don't care, because it would
> -	 * have exited and put the counter back to what we want.
> -	 * We just need a barrier to keep gcc from moving things
> -	 * around.
> +	 * The above __this_cpu_inc_return() is 'atomic' cpu local. An
> +	 * interrupt will either see the value pre increment or post
> +	 * increment. If the interrupt happens pre increment it will have
> +	 * restored the counter when it returns.  We just need a barrier to
> +	 * keep gcc from moving things around.
>  	 */
>  	barrier();
> -	if (use_stack == 1) {
> -		trace.entries		= this_cpu_ptr(ftrace_stack.calls);
> -		trace.max_entries	= FTRACE_STACK_MAX_ENTRIES;
> -
> -		if (regs)
> -			save_stack_trace_regs(regs, &trace);
> -		else
> -			save_stack_trace(&trace);
> -
> -		if (trace.nr_entries > size)
> -			size = trace.nr_entries;
> -	} else
> -		/* From now on, use_stack is a boolean */
> -		use_stack = 0;
> +
> +	fstack = this_cpu_ptr(ftrace_stacks.stacks) + (stackidx - 1);

nit: it would be slightly less surprising if stackidx were 0-based:

diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index d3f6ec7eb729..4fc93004feab 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2798,10 +2798,10 @@ static void __ftrace_trace_stack(struct ring_buffer *buffer,
 	 */
 	preempt_disable_notrace();
 
-	stackidx = __this_cpu_inc_return(ftrace_stack_reserve);
+	stackidx = __this_cpu_inc_return(ftrace_stack_reserve) - 1;
 
 	/* This should never happen. If it does, yell once and skip */
-	if (WARN_ON_ONCE(stackidx >= FTRACE_KSTACK_NESTING))
+	if (WARN_ON_ONCE(stackidx > FTRACE_KSTACK_NESTING))
 		goto out;
 
 	/*
@@ -2813,7 +2813,7 @@ static void __ftrace_trace_stack(struct ring_buffer *buffer,
 	 */
 	barrier();
 
-	fstack = this_cpu_ptr(ftrace_stacks.stacks) + (stackidx - 1);
+	fstack = this_cpu_ptr(ftrace_stacks.stacks) + stackidx;
 	trace.entries		= fstack->calls;
 	trace.max_entries	= FTRACE_KSTACK_ENTRIES;
 

