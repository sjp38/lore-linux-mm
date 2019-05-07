Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0A43C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6475E206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:32:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6475E206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3D826B0007; Tue,  7 May 2019 11:32:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7566B0008; Tue,  7 May 2019 11:32:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A42D46B000A; Tue,  7 May 2019 11:32:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB226B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 11:32:07 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p190so10790213qke.10
        for <linux-mm@kvack.org>; Tue, 07 May 2019 08:32:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5pI5PWgKV+F3OehC1OfcnlFzaNkCdk4j+T3RVss1qZ4=;
        b=RrcaSk2vyzGviTU0KkAtQMufw6K/OFX9kwYtzu+aaaS2DCtBS8gv9DO8QVSB5xuSE9
         g/wt4zud2TptdJiQHHrwaBrau4Gu6OdEI4i2qoF/Ws8SjNC25Nk/lwxwCCgfgYqSyA7G
         AQdhymMNJUY1A+rC1KCp7zZisZKpelSyk32CmJ/8jP127WhIGHmIb1r85EZw9mX5pXBy
         bXu9YGS8CJ/hYPltS6ptGLyM60n2h8p5k2PWa98XYOBefqMcTxRVlqnqMkLYCl3Lnndq
         u8MI1bicjQ9kYYkNqFTu5On/M3727bPiUDE0HDVSdrHXjXEf4QWOzDFrBnpF+IqXDRAx
         +fKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUaqcmzZfW6b8U5wO2hJrniOTWQ4/PQoeLBXQqapNZzAZzFi7Kw
	9G85gQyDNeclV90kPs4LaZB2XB6UWqpQkw6FTkWj4h8+seNjqm3ENFBPVbgQboXD3XPJwcf+d8q
	Zc56TBazpnqyStaTlag3BG4jX6TDrazbAi2r881jrNCzz7a+mXo0LdcFGhWosbf2g8Q==
X-Received: by 2002:ad4:53c4:: with SMTP id k4mr26461646qvv.111.1557243127285;
        Tue, 07 May 2019 08:32:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytqJEdDRNRvrDWNZ8L/utUppAlIPa9ORoZ/V4LhvlNZ6RtfV5X+Zm97RzMFnLMwghJeoef
X-Received: by 2002:ad4:53c4:: with SMTP id k4mr26461152qvv.111.1557243121322;
        Tue, 07 May 2019 08:32:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557243121; cv=none;
        d=google.com; s=arc-20160816;
        b=Ywlvw9COSZdjrJRSBwH2qQSAqr1XsDlFmiBmdQ6Xw8uSkfeYTyzdVEj7eDUvLVfYSM
         oMzaQD4OoIuuVTw0w0M507csT9leVR45/AuB77HjzrhkPJMxDuwCRCkFyFg58O5gIX7w
         moyiV/1U6Qq0DLhT7YNKebeny85/kybvDgF2eyy7ASi0O4bTHAwCip/4eSkZLUvQ45T4
         qwXayDLyDcCy4ZaYn7wdKvxzJc45gSlDsIez1k1u6fBFABc24EnR6EjCFO8Np0zRXMN0
         R/3AR7kY4YIMER1A7r8d7VHz6p3LTRD5QQFWPFbeyKSkm0YkjiGx9DHZiYOAajJJwKvO
         AWbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5pI5PWgKV+F3OehC1OfcnlFzaNkCdk4j+T3RVss1qZ4=;
        b=dg9LjYG4AAqeBrxN30S865C2kAa7kxqQW/6xej4U58sDNMAYRi4KJo6ImlZk+mEocu
         YT0pvxQoC+4GrItmaNiSoB2T9QgIs9GoIePOrkh2YxxU9iYJmVyFjoQ6cFsUYCUjz4Pz
         /yu5+6v3X/qCHGUgbiGK1+PEBjGgUo1tMoyezTIBhUf+lK8iUGHUPDOSRnT0shE9a6aI
         ZfiTz1bhf0i+I6jS+5OAVkiFDWoaQpvL3JWdxBp6BGcIwvr5O/ZGIV8rWUB9Q28X3e7e
         QLMZZMofRxrZlC2Iq5N/6E6gchgavJXtbwo9kN3NvZn39H1zydc4stpyU+QrlYgd+lHy
         eKDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si7388078qta.5.2019.05.07.08.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 08:32:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BB055308424E;
	Tue,  7 May 2019 15:31:59 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 648915C225;
	Tue,  7 May 2019 15:31:55 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue,  7 May 2019 17:31:59 +0200 (CEST)
Date: Tue, 7 May 2019 17:31:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507153154.GA5750@redhat.com>
References: <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507021622.GA27300@sultan-box.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 07 May 2019 15:32:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I am not going to comment the intent, but to be honest I am skeptical too.

On 05/06, Sultan Alsawaf wrote:
>
> +static unsigned long find_victims(struct victim_info *varr, int *vindex,
> +				  int vmaxlen, int min_adj, int max_adj)
> +{
> +	unsigned long pages_found = 0;
> +	int old_vindex = *vindex;
> +	struct task_struct *tsk;
> +
> +	for_each_process(tsk) {
> +		struct task_struct *vtsk;
> +		unsigned long tasksize;
> +		short oom_score_adj;
> +
> +		/* Make sure there's space left in the victim array */
> +		if (*vindex == vmaxlen)
> +			break;
> +
> +		/* Don't kill current, kthreads, init, or duplicates */
> +		if (same_thread_group(tsk, current) ||
> +		    tsk->flags & PF_KTHREAD ||
> +		    is_global_init(tsk) ||
> +		    vtsk_is_duplicate(varr, *vindex, tsk))
> +			continue;
> +
> +		vtsk = find_lock_task_mm(tsk);

Did you test this patch with lockdep enabled?

If I read the patch correctly, lockdep should complain. vtsk_is_duplicate()
ensures that we do not take the same ->alloc_lock twice or more, but lockdep
can't know this.

> +static void scan_and_kill(unsigned long pages_needed)
> +{
> +	static DECLARE_WAIT_QUEUE_HEAD(victim_waitq);
> +	struct victim_info victims[MAX_VICTIMS];
> +	int i, nr_to_kill = 0, nr_victims = 0;
> +	unsigned long pages_found = 0;
> +	atomic_t victim_count;
> +
> +	/*
> +	 * Hold the tasklist lock so tasks don't disappear while scanning. This
> +	 * is preferred to holding an RCU read lock so that the list of tasks
> +	 * is guaranteed to be up to date. Keep preemption disabled until the
> +	 * SIGKILLs are sent so the victim kill process isn't interrupted.
> +	 */
> +	read_lock(&tasklist_lock);
> +	preempt_disable();

read_lock() disables preemption, every task_lock() too, so this looks
unnecessary.

> +	for (i = 1; i < ARRAY_SIZE(adj_prio); i++) {
> +		pages_found += find_victims(victims, &nr_victims, MAX_VICTIMS,
> +					    adj_prio[i], adj_prio[i - 1]);
> +		if (pages_found >= pages_needed || nr_victims == MAX_VICTIMS)
> +			break;
> +	}
> +
> +	/*
> +	 * Calculate the number of tasks that need to be killed and quickly
> +	 * release the references to those that'll live.
> +	 */
> +	for (i = 0, pages_found = 0; i < nr_victims; i++) {
> +		struct victim_info *victim = &victims[i];
> +		struct task_struct *vtsk = victim->tsk;
> +
> +		/* The victims' mm lock is taken in find_victims; release it */
> +		if (pages_found >= pages_needed) {
> +			task_unlock(vtsk);
> +			continue;
> +		}
> +
> +		/*
> +		 * Grab a reference to the victim so it doesn't disappear after
> +		 * the tasklist lock is released.
> +		 */
> +		get_task_struct(vtsk);

The comment doesn't look correct. the victim can't dissapear until task_unlock()
below, it can't pass exit_mm().

> +		pages_found += victim->size;
> +		nr_to_kill++;
> +	}
> +	read_unlock(&tasklist_lock);
> +
> +	/* Kill the victims */
> +	victim_count = (atomic_t)ATOMIC_INIT(nr_to_kill);
> +	for (i = 0; i < nr_to_kill; i++) {
> +		struct victim_info *victim = &victims[i];
> +		struct task_struct *vtsk = victim->tsk;
> +
> +		pr_info("Killing %s with adj %d to free %lu kiB\n", vtsk->comm,
> +			vtsk->signal->oom_score_adj,
> +			victim->size << (PAGE_SHIFT - 10));
> +
> +		/* Configure the victim's mm to notify us when it's freed */
> +		vtsk->mm->slmk_waitq = &victim_waitq;
> +		vtsk->mm->slmk_counter = &victim_count;
> +
> +		/* Accelerate the victim's death by forcing the kill signal */
> +		do_send_sig_info(SIGKILL, SIG_INFO_TYPE, vtsk, true);
                                                               ^^^^
this should be PIDTYPE_TGID

> +
> +		/* Finally release the victim's mm lock */
> +		task_unlock(vtsk);
> +	}
> +	preempt_enable_no_resched();

See above. And I don't understand how can _no_resched() really help...

> +
> +	/* Try to speed up the death process now that we can schedule again */
> +	for (i = 0; i < nr_to_kill; i++) {
> +		struct task_struct *vtsk = victims[i].tsk;
> +
> +		/* Increase the victim's priority to make it die faster */
> +		set_user_nice(vtsk, MIN_NICE);
> +
> +		/* Allow the victim to run on any CPU */
> +		set_cpus_allowed_ptr(vtsk, cpu_all_mask);
> +
> +		/* Finally release the victim reference acquired earlier */
> +		put_task_struct(vtsk);
> +	}
> +
> +	/* Wait until all the victims die */
> +	wait_event(victim_waitq, !atomic_read(&victim_count));

Can't we avoid the new slmk_waitq/slmk_counter members in mm_struct?

I mean, can't we export victim_waitq and victim_count and, say, set/test
MMF_OOM_VICTIM. In fact I think you should try to re-use mark_oom_victim()
at least.

Oleg.

