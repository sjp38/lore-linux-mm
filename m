Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61ABFC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:10:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FEFE216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:10:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FEFE216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C27FA6B02AB; Fri, 10 May 2019 11:10:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD8806B02AC; Fri, 10 May 2019 11:10:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA0446B02AD; Fri, 10 May 2019 11:10:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6D96B02AB
	for <linux-mm@kvack.org>; Fri, 10 May 2019 11:10:36 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s46so6535515qtj.4
        for <linux-mm@kvack.org>; Fri, 10 May 2019 08:10:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=q5vcq0afF5GG5zR0EtmsW0Ule6BB1C257to94buYw2U=;
        b=Cm5e+ZhQMVYQU7tA9SVjv9puHfVT9AjJRBd5YIIw0i8Y4MmKuKEYv4rTYMcbvh9PQ3
         K4ckLFoYEO5k70npJPjQAHv3MQDeg4fbiyz8GGkm0LzAIYiEOumTzGcqYtVoFo3iQUUk
         uOCsfVdieIRTwFEUVDdNya6mDLejAlWU+8KoS4bM3aVGNZD4Hi0Sv+Ll+Zg7xQCjfyhO
         /lk6AG7Q3z4+gnoApDiR+tbIwFF1/sRk1W7u1iQq39bow0bOKwYy81TJxW+6lEb/QQxW
         +f3S5B7TnTL8z2CqJ8/v8iDuCMefBInGD1yU4CeR1VzQH4Z0D12CFqd2LUjkSH6K4baN
         bzCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7b/GZjvySCAVPjh0xSFCbJpLXM/gAXRfCWsU3+4WKgQoaMRFc
	BB6JwXO/3r/fQ1O7BKPAf3dY+iLBozqm1ublVvs6krHh6GGFNhKbBnPuSGoYto/c19wqkH2JJ82
	XFm7I7ZzxIAwitvuMP2EDMPKOZUZutIvHQ9hYQIQ/virg8e0AvRqvAg5Y5s1Cnbh9Mg==
X-Received: by 2002:a37:7986:: with SMTP id u128mr9652367qkc.45.1557501036222;
        Fri, 10 May 2019 08:10:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAi1bDfvkv0AffBhVNcgX/6YT+im/U9VtqL2x8Bak/HybrptmjMrObyCSGGRj/I03L+X6z
X-Received: by 2002:a37:7986:: with SMTP id u128mr9652305qkc.45.1557501035528;
        Fri, 10 May 2019 08:10:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557501035; cv=none;
        d=google.com; s=arc-20160816;
        b=s/jXBV9QJzAEUpbzDZYzSoZUFvoZo/11YolLdNIwBWh9FgpkmbgHgbj3TyuA1oldMr
         qalel9+jIO8GYdYTRul87voD+ceAT4OT2C5pMDE3uknyVPHSYvWPkdwI7UyjWQda2YyX
         x3lDxYU4CjZtbtYMkcQYQ8YDjF7tRmxv7V41EnwCjb3BH44+9yWeKw3Bws8Uf+LK/0CI
         Qk5ZdBz7lhgOcOkScUGaCWKC/8B+7JIs476Ywdh6q0Z+afGWa9CCrm5dsouXmaThXE2C
         Aj9F3ecDDdWIVdaxS+mnGifXiSVC/+V1LkUF2vlEeS7Aud3E6obPbThZXst27wOGoRwh
         fugg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=q5vcq0afF5GG5zR0EtmsW0Ule6BB1C257to94buYw2U=;
        b=Q1ySgdly+4ZTD1pzRTYZIAFt9h8B6EiWrZwEadSuPMDP+952MFGDCiOnAKUCKMvBBG
         Ll7VAKk3IaC39HgifrlRtsp8Ndtz0FNEZxVkREIhAur1QhEgbTB9T2UJ3Yzpof7kEm7J
         M1NjR6x8D3vB994d+VjWRfwLYEZNjU2uk3eG+FPmBFdy4uZSrXxgGSh6wRbXEZFyVgtN
         GUq0PsHcLbAHQigxbqnCNEQMWhSk3MZzTyxvwEvfFwSt+879Q+7PT1jaTVhw2Y4A6V3j
         EZpmUk51/yQdl3mCWeCNaQ6k1vDa5qTN0MDl9LCJXX49IO5GAN3kwtCaMWebSzvTlB+I
         VvZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si2602025qkn.75.2019.05.10.08.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 08:10:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3C50C86679;
	Fri, 10 May 2019 15:10:34 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id EDF0E5D9D5;
	Fri, 10 May 2019 15:10:27 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri, 10 May 2019 17:10:32 +0200 (CEST)
Date: Fri, 10 May 2019 17:10:25 +0200
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
Message-ID: <20190510151024.GA21421@redhat.com>
References: <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
 <20190509183353.GA13018@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509183353.GA13018@sultan-box.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 10 May 2019 15:10:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/09, Sultan Alsawaf wrote:
>
> On Thu, May 09, 2019 at 05:56:46PM +0200, Oleg Nesterov wrote:
> > Impossible ;) I bet lockdep should report the deadlock as soon as find_victims()
> > calls find_lock_task_mm() when you already have a locked victim.
>
> I hope you're not a betting man ;)

I am starting to think I am ;)

If you have task1 != task2 this code

	task_lock(task1);
	task_lock(task2);

should trigger print_deadlock_bug(), task1->alloc_lock and task2->alloc_lock are
the "same" lock from lockdep pov, held_lock's will have the same hlock_class().

> CONFIG_PROVE_LOCKING=y

OK,

> And a printk added in vtsk_is_duplicate() to print when a duplicate is detected,

in this case find_lock_task_mm() won't be called, and this is what saves us from
the actual deadlock.


> and my phone's memory cut in half to make simple_lmk do something, this is what
> I observed:
> taimen:/ # dmesg | grep lockdep
> [    0.000000] \x09RCU lockdep checking is enabled.

this reports that CONFIG_PROVE_RCU is enabled ;)

> taimen:/ # dmesg | grep simple_lmk
> [   23.211091] simple_lmk: Killing android.carrier with adj 906 to free 37420 kiB
> [   23.211160] simple_lmk: Killing oadcastreceiver with adj 906 to free 36784 kiB

yes, looks like simple_lmk has at least 2 locked victims. And I have no idea why
you do not see anything else in dmesg. May be debug_locks_off() was already called.

But see above, "grep lockdep" won't work.  Perhaps you can do
"grep -e WARNING -e BUG -e locking".

Oleg.

