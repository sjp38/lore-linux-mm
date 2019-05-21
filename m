Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9239CC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C7CE21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="K2u0HR8G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C7CE21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D93266B000A; Tue, 21 May 2019 10:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D42DB6B000D; Tue, 21 May 2019 10:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0AEB6B000E; Tue, 21 May 2019 10:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0786B000A
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:48:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so30957669edl.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=7IOMcNShzp88plVKB970+NE4F+uWKbqTavdIwV9VTZU=;
        b=HVfldeCa4WOd16pwQZ66AHbVHg4T5EiJvOPcogzApiIOBJmGs94xQDMmlUYEjd8o1d
         BN5yvfP/+tI2hpVKJcXNvUQe+btrPl78y9u6o1vzCJuq0vbe+BkLYUqN6cn46bBB43aW
         hTFIbfTgplfadMnRx2SKEOsodiV4zI9o3bQpUXVQOgouEwy3L/H4jNyfLoGvwjiwOrTy
         YlZnpwg13YtvfrLk7vQ3lqboK4sTOTPgQjxh/aXg5OkYPhPv9fROV4ulk7UOOmufNzC/
         4zvggTdLLsv7wzSSt+o93jAE24uRxsiKGaJSfzpXm71jPX5SDPPQKtC2c7pYJnnbpz0C
         FaxQ==
X-Gm-Message-State: APjAAAXSMF5pL2YX1Jw8oCVyq1ODWb6ETBA0wyQdLZgobOtrRCoVAJ4A
	HgxYAhAtN3PMjqTh1yqUxOEAmgZgYE+ocnTtSlcwEqYDnkfAJSxVEg1vjz8utKThGfWurYXupJP
	faBfes4lxW7VfpQVsz9UjoBp4OLB5bRm88PV99eqPxA/0Pt0VB3o26Ubc30r8556PzQ==
X-Received: by 2002:a17:906:f84a:: with SMTP id ks10mr47679422ejb.65.1558450138964;
        Tue, 21 May 2019 07:48:58 -0700 (PDT)
X-Received: by 2002:a17:906:f84a:: with SMTP id ks10mr47679345ejb.65.1558450137998;
        Tue, 21 May 2019 07:48:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558450137; cv=none;
        d=google.com; s=arc-20160816;
        b=xoV7oWJLzg+V+YONFjtj8jx0ZAkH7SUil3rRooJ9bHhKHQSJSDjdvBu5HjrkneG39D
         XxZgrx6W0XrW3xgFZaEBw5yyaxdWBPvB8m7OcaiHvE62ybWAonzS4og7NFcC/u/3OP9n
         Sr8A1mea0FzIXmzGo9yLBP81YRz911Q6rZkUpc3XacZqSsE1YXmgbPWZ3nI93jFqEeGr
         mzYEa3rMUjtX4+KGaunYgil0Dh/AQGztKtw3zI5iODVW7VxICATS26J/wQTPkICAwJCb
         vAoo/XVJwUf7SAjVNPgLS89o5jpwbd64kSf6SqzzLeWvwP/HlEazBZWwV+A20FwRQltn
         O2Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:mail-followup-to
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=7IOMcNShzp88plVKB970+NE4F+uWKbqTavdIwV9VTZU=;
        b=ly7DjuMdfXhZulkQSvWgj1mdKQ8gFtfhtbHQ5bQnlAPRPxNw+6h+m7JS/gj6+IDh1Y
         sml68HhKfq9XNQSh0+o95rMD4WPv8rGqMsg4UP3YAsfefi+PKxcCodVhKAa3L4ulGUcG
         jsv5VIi0DSr5itkV3oaFvcFhnRLgNt8AJC3/dL/oZr0GZX5wUi4nwh9tm2Az1o1R5WPL
         rnIJz3BhBkex3busAVzyeUBuSOgnFigvAZz/mwmCcuTrQcCbpvjQaUSPzh39W8ncWVKk
         twoXMSAEvXTppOQSf20THCohHi4O80haeg2oxKgdbnBe7EdQb4z4R541NwRtl852zxTz
         3HFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=K2u0HR8G;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor2138409eds.23.2019.05.21.07.48.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 07:48:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=K2u0HR8G;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7IOMcNShzp88plVKB970+NE4F+uWKbqTavdIwV9VTZU=;
        b=K2u0HR8GjjPph9aWDUMgbUTkdaGHORgnlhQ5O+jE9OPB0bYVQnJ1ODz4blADryQtdX
         pa0G0gEFYE0rz9UvMpOgqbe+rbO0ivH/HD50iXsv/+brZ/19ysThpf/RfyS0dqkSUiG2
         Of+EbAXOcS1PLLjYqc3MNnAPJwN2wV4XxglRA=
X-Google-Smtp-Source: APXvYqytIZu/6anacKvD69vhQKlzZMTSzIMEvW9ZHTiye+AtpdGee4CjEbWTItKCYEIqDaw+ejs+4Q==
X-Received: by 2002:a50:8808:: with SMTP id b8mr54195428edb.202.1558450137617;
        Tue, 21 May 2019 07:48:57 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id t19sm3558423ejq.51.2019.05.21.07.48.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 07:48:56 -0700 (PDT)
Date: Tue, 21 May 2019 16:48:54 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH] kernel.h: Add non_block_start/end()
Message-ID: <20190521144854.GP21222@phenom.ffwll.local>
Mail-Followup-To: Michal Hocko <mhocko@kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
 <20190521104638.GO32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521104638.GO32329@dhcp22.suse.cz>
X-Operating-System: Linux phenom 4.14.0-3-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:46:38PM +0200, Michal Hocko wrote:
> On Tue 21-05-19 12:06:11, Daniel Vetter wrote:
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> > 
> > This will be used in the oom paths of mmu-notifiers, where blocking is
> > not allowed to make sure there's forward progress. Quoting Michal:
> > 
> > "The notifier is called from quite a restricted context - oom_reaper -
> > which shouldn't depend on any locks or sleepable conditionals. The code
> > should be swift as well but we mostly do care about it to make a forward
> > progress. Checking for sleepable context is the best thing we could come
> > up with that would describe these demands at least partially."
> > 
> > Peter also asked whether we want to catch spinlocks on top, but Michal
> > said those are less of a problem because spinlocks can't have an
> > indirect dependency upon the page allocator and hence close the loop
> > with the oom reaper.
> > 
> > Suggested by Michal Hocko.
> > 
> > v2:
> > - Improve commit message (Michal)
> > - Also check in schedule, not just might_sleep (Peter)
> > 
> > v3: It works better when I actually squash in the fixup I had lying
> > around :-/
> > 
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: "Christian König" <christian.koenig@amd.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "Jérôme Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Cc: Wei Wang <wvw@google.com>
> > Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Jann Horn <jannh@google.com>
> > Cc: Feng Tang <feng.tang@intel.com>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: linux-kernel@vger.kernel.org
> > Acked-by: Christian König <christian.koenig@amd.com> (v1)
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> 
> I like this in general. The implementation looks reasonable to me but I
> didn't check deeply enough to give my R-by or A-by.

Thanks for all your comments. I'll ask Jerome Glisse to look into this, I
think it'd could be useful for all the HMM work too.

And I sent this out without reply-to the patch it's supposed to replace,
will need to do that again so patchwork and 0day pick up the correct
series. Sry about that noise :-/
-Daniel

> 
> > ---
> >  include/linux/kernel.h | 10 +++++++++-
> >  include/linux/sched.h  |  4 ++++
> >  kernel/sched/core.c    | 19 ++++++++++++++-----
> >  3 files changed, 27 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> > index 74b1ee9027f5..b5f2c2ff0eab 100644
> > --- a/include/linux/kernel.h
> > +++ b/include/linux/kernel.h
> > @@ -214,7 +214,9 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
> >   * might_sleep - annotation for functions that can sleep
> >   *
> >   * this macro will print a stack trace if it is executed in an atomic
> > - * context (spinlock, irq-handler, ...).
> > + * context (spinlock, irq-handler, ...). Additional sections where blocking is
> > + * not allowed can be annotated with non_block_start() and non_block_end()
> > + * pairs.
> >   *
> >   * This is a useful debugging help to be able to catch problems early and not
> >   * be bitten later when the calling function happens to sleep when it is not
> > @@ -230,6 +232,10 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
> >  # define cant_sleep() \
> >  	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
> >  # define sched_annotate_sleep()	(current->task_state_change = 0)
> > +# define non_block_start() \
> > +	do { current->non_block_count++; } while (0)
> > +# define non_block_end() \
> > +	do { WARN_ON(current->non_block_count-- == 0); } while (0)
> >  #else
> >    static inline void ___might_sleep(const char *file, int line,
> >  				   int preempt_offset) { }
> > @@ -238,6 +244,8 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
> >  # define might_sleep() do { might_resched(); } while (0)
> >  # define cant_sleep() do { } while (0)
> >  # define sched_annotate_sleep() do { } while (0)
> > +# define non_block_start() do { } while (0)
> > +# define non_block_end() do { } while (0)
> >  #endif
> >  
> >  #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 11837410690f..7f5b293e72df 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -908,6 +908,10 @@ struct task_struct {
> >  	struct mutex_waiter		*blocked_on;
> >  #endif
> >  
> > +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> > +	int				non_block_count;
> > +#endif
> > +
> >  #ifdef CONFIG_TRACE_IRQFLAGS
> >  	unsigned int			irq_events;
> >  	unsigned long			hardirq_enable_ip;
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index 102dfcf0a29a..ed7755a28465 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -3264,13 +3264,22 @@ static noinline void __schedule_bug(struct task_struct *prev)
> >  /*
> >   * Various schedule()-time debugging checks and statistics:
> >   */
> > -static inline void schedule_debug(struct task_struct *prev)
> > +static inline void schedule_debug(struct task_struct *prev, bool preempt)
> >  {
> >  #ifdef CONFIG_SCHED_STACK_END_CHECK
> >  	if (task_stack_end_corrupted(prev))
> >  		panic("corrupted stack end detected inside scheduler\n");
> >  #endif
> >  
> > +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> > +	if (!preempt && prev->state && prev->non_block_count) {
> > +		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i\n",
> > +			prev->comm, prev->pid, prev->non_block_count);
> > +		dump_stack();
> > +		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
> > +	}
> > +#endif
> > +
> >  	if (unlikely(in_atomic_preempt_off())) {
> >  		__schedule_bug(prev);
> >  		preempt_count_set(PREEMPT_DISABLED);
> > @@ -3377,7 +3386,7 @@ static void __sched notrace __schedule(bool preempt)
> >  	rq = cpu_rq(cpu);
> >  	prev = rq->curr;
> >  
> > -	schedule_debug(prev);
> > +	schedule_debug(prev, preempt);
> >  
> >  	if (sched_feat(HRTICK))
> >  		hrtick_clear(rq);
> > @@ -6102,7 +6111,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
> >  	rcu_sleep_check();
> >  
> >  	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
> > -	     !is_idle_task(current)) ||
> > +	     !is_idle_task(current) && !current->non_block_count) ||
> >  	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
> >  	    oops_in_progress)
> >  		return;
> > @@ -6118,8 +6127,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
> >  		"BUG: sleeping function called from invalid context at %s:%d\n",
> >  			file, line);
> >  	printk(KERN_ERR
> > -		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
> > -			in_atomic(), irqs_disabled(),
> > +		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
> > +			in_atomic(), irqs_disabled(), current->non_block_count,
> >  			current->pid, current->comm);
> >  
> >  	if (task_stack_end_corrupted(current))
> > -- 
> > 2.20.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

