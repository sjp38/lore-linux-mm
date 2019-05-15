Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F000AC04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:32:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA272084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 18:32:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA272084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AE306B0005; Wed, 15 May 2019 14:32:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 236F76B0006; Wed, 15 May 2019 14:32:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FF416B0007; Wed, 15 May 2019 14:32:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD0B66B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 14:32:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so368141pll.16
        for <linux-mm@kvack.org>; Wed, 15 May 2019 11:32:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dUC2a3jB0+5/g8cV2hL7m5tmIeb5vZOWc/mOTmulY1k=;
        b=Li8T6Ge0yo2TX+gFc8/VbmhibYmyaqQdM5dEMbevFNd8Qw8dKZnXuRJIjUkSVhIkvN
         Psy1vGw+yb7IbHHm9u73xbkArhGIU0mcKGOK6g0r+x0+/jgzdhFvokQLHTQ7uNFh8g9c
         qjBS5o9vEU242ivWTCPw11W6TafSeHS0Jj+i0/mop6Pp07flvrCRz0ZLyzJ9IFVlXzRa
         awICHsIRbdepH/lOf/SSY93o/PGdX3S4xJ/Z/iKvV6/RN6j4wLH/u19NkLg5Y5aMvtoB
         soHaVix+ri2GIOUCTsU7cDL6buFO9ilKAs6wF7L7tgNzBScIFbSuxtYHXUip06kv4lUm
         9FXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAV/lZSu1Zxe9NOTiHMXE174Zg0XqXdkhcXNcGM1dlayqAkMrs+b
	IEIBNUvD4TZpdTxhnYqA4lTDiuN+jpW8iPOTG2YF1YxFJ2MATHlpwCj+4GnYoHYJTD1Z8N06O9e
	QzMgGvWLKAbHmQMAxqveLIw4hj8XiRKQ6Ub6oBU/qriaae2WZHbE9DiR9QQ2HB/8=
X-Received: by 2002:aa7:9203:: with SMTP id 3mr49081749pfo.123.1557945170445;
        Wed, 15 May 2019 11:32:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU6h9vDoMtNoOfQW3ozfzmPYUzqEOcdHq69GcUYT1yCrrVJIWePCroqFpJkgwl9Huwrl4t
X-Received: by 2002:aa7:9203:: with SMTP id 3mr49081679pfo.123.1557945169601;
        Wed, 15 May 2019 11:32:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557945169; cv=none;
        d=google.com; s=arc-20160816;
        b=rIYJUkBP/WX3zh1P5Hn/vbuzXpNXlLGcEdFQPdcGNdZUbXJO5v26aPoUk27+pJ1kpB
         2ieeYveGl1IE7hnkwJHYpUeQBDcxkSkO/9SQBYDCBquEOrd3ZWKr3yB7DjV1qtNVYUA/
         fEULE8m5cv1kRKQww+KFQOl5pFbbsBqLif9/NNH22TZrIqEjBW4VyUT4AIpozUF3yn3p
         RdKwtHjp95HqitNLWLj9efT7D/TXRbY4SFRjcTpspAMuzZDJFzTWd1tU/Y1mOnjN8SFk
         gty1KxYOwloOBrOwiu3IYluMpA09QOSoDhPzrYCyyZxZBh4KpvTqCKI1KZyJxUi/B+CZ
         4InA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=dUC2a3jB0+5/g8cV2hL7m5tmIeb5vZOWc/mOTmulY1k=;
        b=fDks0Y5eULNOc5AzPb4kdBPpEIMg9MjUdVIHmvkeEMxMs6uCMOB5ypQuQZbpFdxRe0
         7vAk2NHANTo7r49R9tuF1C2x8nKomMAVAo4SOzvl2DcsgELPj573Ydy22qfhwa1z2F7T
         gioy+fAwlDGAc96zRtjINRuUGtB1/x389t50WhDUjHUX/cIairIYumr1Ko2U5qb+IaWD
         Xx0ApdYDuhEIQh9twwP93U5xQWYJcTxHSuoQn8sdMRhxJV48v2VovTlbbESFEXGp7tMF
         9KbFRfhSX4mZa1+hEGSxWHKfnfpdaTX1WiS4Jp45vr6RTNSDRWsLhB0T5TKtGg2aYRsf
         H4tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v23si2413460pgi.527.2019.05.15.11.32.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 11:32:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=ytuu=tp=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=yTUU=TP=goodmis.org=rostedt@kernel.org"
Received: from oasis.local.home (50-204-120-225-static.hfc.comcastbusiness.net [50.204.120.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9887720843;
	Wed, 15 May 2019 18:32:48 +0000 (UTC)
Date: Wed, 15 May 2019 14:32:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Christian Brauner
 <christian@brauner.io>, Daniel Colascione <dancol@google.com>, Suren
 Baghdasaryan <surenb@google.com>, Tim Murray <timmurray@google.com>, Michal
 Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Todd Kjos
 <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, LKML
 <linux-kernel@vger.kernel.org>, "open list:ANDROID DRIVERS"
 <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, kernel-team
 <kernel-team@android.com>, Andy Lutomirski <luto@amacapital.net>, "Serge E.
 Hallyn" <serge@hallyn.com>, Kees Cook <keescook@chromium.org>, Joel
 Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for
 Android
Message-ID: <20190515143248.17b827d0@oasis.local.home>
In-Reply-To: <20190515172728.GA14047@sultan-box.localdomain>
References: <20190319231020.tdcttojlbmx57gke@brauner.io>
	<20190320015249.GC129907@google.com>
	<20190507021622.GA27300@sultan-box.localdomain>
	<20190507153154.GA5750@redhat.com>
	<20190507163520.GA1131@sultan-box.localdomain>
	<20190509155646.GB24526@redhat.com>
	<20190509183353.GA13018@sultan-box.localdomain>
	<20190510151024.GA21421@redhat.com>
	<20190513164555.GA30128@sultan-box.localdomain>
	<20190515145831.GD18892@redhat.com>
	<20190515172728.GA14047@sultan-box.localdomain>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 May 2019 10:27:28 -0700
Sultan Alsawaf <sultan@kerneltoast.com> wrote:

> On Wed, May 15, 2019 at 04:58:32PM +0200, Oleg Nesterov wrote:
> > Could you explain in detail what exactly did you do and what do you see in dmesg?
> > 
> > Just in case, lockdep complains only once, print_circular_bug() does debug_locks_off()
> > so it it has already reported another false positive __lock_acquire() will simply
> > return after that.
> > 
> > Oleg.  
> 
> This is what I did:
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 774ab79d3ec7..009e7d431a88 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -3078,6 +3078,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
>         int class_idx;
>         u64 chain_key;
> 
> +       BUG_ON(!debug_locks || !prove_locking);
>         if (unlikely(!debug_locks))
>                 return 0;
> 
> diff --git a/lib/debug_locks.c b/lib/debug_locks.c
> index 124fdf238b3d..4003a18420fb 100644
> --- a/lib/debug_locks.c
> +++ b/lib/debug_locks.c
> @@ -37,6 +37,7 @@ EXPORT_SYMBOL_GPL(debug_locks_silent);
>   */
>  int debug_locks_off(void)
>  {
> +       return 0;

I'm confused why you did this?

-- Steve

>         if (debug_locks && __debug_locks_off()) {
>                 if (!debug_locks_silent) {
>                         console_verbose();
> 
>

