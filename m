Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2378EC04AB2
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 15:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24C72175B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 15:56:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24C72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2347C6B0007; Thu,  9 May 2019 11:56:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BD586B0008; Thu,  9 May 2019 11:56:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0850F6B000A; Thu,  9 May 2019 11:56:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E08C16B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 11:56:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s46so3069410qtj.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 08:56:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZZ8fCHB8eclIGo1V1jbuvKP9A8tuFZPXbwG0DpdC7Ww=;
        b=bvlsRFHzOmUiFQj6i9kmZ3VEDm7aMwKtiazPvYH3Ob7Jw8kCO5WlkF+T2a94xoCVv2
         +6ZCnbXjU3PTMOBjwREYw2X1SNCqr4cVSKh82lRCmT0+3WE/yzqnjgetulah7t+dW0N+
         VVDFrfPuvj1uvO8AACqeIHRV9reDV0xgEDpu+tC49qbI7s4oNLpW6ecnEFbLUOvEyI4c
         9KD/QoTH9Sw7lc2HHz3f/tPReGY+BFz7ckrEL7wGxsTDpPucZHOx0FztDydyEOWTY2aO
         ZY4TekHXgV+5LhnPCI8LSzKqBoXHZVjWd7NzztUlfIN0zxYt3bgG89xKy9uhtmApfroF
         FZEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU1xAxHf0WAUPdwzflOePws0y6Jebj3AwB8EhSCzIJKlfnf2ZBC
	sn49rsopb7uoirsUZnJPOeIlF+BMv2dGt4mFtV1YrGiwdvLAXOW6/GbKf9t2pLJygDwUrmBzTX2
	dG4LulcZxV/tTKgATwy4ijcbZP9MYSdqqlFK01pK2jxI0ocwNBSiW2+s5MhfoIAiBIA==
X-Received: by 2002:a37:4ad4:: with SMTP id x203mr3956653qka.21.1557417415662;
        Thu, 09 May 2019 08:56:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzBs0XnrkTJwWk3VfpDZNC23cqoQHNBGmXmrSbrEMC5bSbTljTEZT+MbldsktNlCrT1pCf
X-Received: by 2002:a37:4ad4:: with SMTP id x203mr3956601qka.21.1557417414819;
        Thu, 09 May 2019 08:56:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557417414; cv=none;
        d=google.com; s=arc-20160816;
        b=GiZ3j79CwI6hO97d1jEG64qw19qer3XlNbmubjDeHN6pwrMIrk+VaS8daS/zteXhDC
         +vK7b3EyLHT+3pk3QSK+v0U9tFnGAIP8+anwOmxwGpfvTrEykyrSLMK03k0hBTlMNAIx
         jMwK9LB2W27RbFiPPYbRhe1ll6Zw7H4xLNgRTDhavJMkV46IvtRNEZz51VIxnzIVhOAp
         k5cLC9fnRHGHBIhTXFkb0XOWmsK6qQ2wCgUP9MSywUwTGMLbAVGS5b+R2jYEKV8VoZRU
         KKkEuLOKLPJj2SLGkgZOElatyRs1QuXmiZZQJKt4DpPlUoY22paKzIWQW/+Fkl4q/g8J
         6DvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZZ8fCHB8eclIGo1V1jbuvKP9A8tuFZPXbwG0DpdC7Ww=;
        b=QchVPkL+AGSOBeCH//02FO2s7i50dzRNm4ZT2k5Yo0poRdehSvUMmLdeVrGyiBEc3r
         513G134Ljh0O5CD8ho0AcoX6YY26BMsH38ezcch/qxhkaoSUaT9Dl7paO8BB61X/T2sE
         UjGo+nnAWp9szHFw5TtpG/KxQmZvEvlZHmEsPKz+784sOi0GsZ9ISp1XXNzVH9LsbODs
         pR7nJCFZdZ0hSVJPAyUwMpMGGpjA4nrq+rF2P1kO6mBoHUIsPLDuCDTfH9D/SRzPeS1o
         XskjtfuWbcYVwI9QHx7yDa/1NFZgBQuPR+G+YjajIYYTkqfaT70D0hM40hl9y+6hK4Z2
         /qvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e27si1280148qte.57.2019.05.09.08.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 08:56:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF84BDBD6F;
	Thu,  9 May 2019 15:56:52 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 4B9EC27BCD;
	Thu,  9 May 2019 15:56:48 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  9 May 2019 17:56:51 +0200 (CEST)
Date: Thu, 9 May 2019 17:56:46 +0200
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
Message-ID: <20190509155646.GB24526@redhat.com>
References: <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507163520.GA1131@sultan-box.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 09 May 2019 15:56:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/07, Sultan Alsawaf wrote:
>
> On Tue, May 07, 2019 at 05:31:54PM +0200, Oleg Nesterov wrote:
>
> > Did you test this patch with lockdep enabled?
> >
> > If I read the patch correctly, lockdep should complain. vtsk_is_duplicate()
> > ensures that we do not take the same ->alloc_lock twice or more, but lockdep
> > can't know this.
>
> Yeah, lockdep is fine with this, at least on 4.4.

Impossible ;) I bet lockdep should report the deadlock as soon as find_victims()
calls find_lock_task_mm() when you already have a locked victim.

Nevermind, I guess this code won't run with lockdep enabled...


As for https://github.com/kerneltoast/android_kernel_google_wahoo/commit/afc8c9bf2dbde95941253c168d1adb64cfa2e3ad
Well,

	mmdrop(mm);
	simple_lmk_mm_freed(mm);

looks racy because mmdrop(mm) can free this mm_struct. Yes, simple_lmk_mm_freed()
does not dereference this pointer, but the same memory can be re-allocated as
another ->mm for the new task which can be found by find_victims(), and _in theory_
this all can happen in between, so the "victims[i].mm == mm" can be false positive.

And this also means that simple_lmk_mm_freed() should clear victims[i].mm when
it detects "victims[i].mm == mm", otherwise we have the same theoretical race,
victims_to_kill is only cleared when the last victim goes away.


Another nit... you can drop tasklist_lock right after the 1st "find_victims" loop.

And it seems that you do not really need to walk the "victims" array twice after that,
you can do everything in a single loop, but this is cosmetic.

Oleg.

