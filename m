Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C74C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E064920657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:54:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E064920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64AC96B0007; Thu, 16 May 2019 09:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FA1F6B0008; Thu, 16 May 2019 09:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49A7C6B000A; Thu, 16 May 2019 09:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDB6B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:54:44 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t63so2832879qkh.0
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xxVByyzHqcwQo9d/DUy2hcnoWGN77Aq/V3FYya0ZW/s=;
        b=fOITd4D8wUO5ILgg15CEHWS06WesBVE2KlPh2traepvLVMFtKTyP2TI54DXyKc+5Pu
         MkVJEoX/cV8Yy2WPwF8GWOujZBTXHxlnBzSJOMkNCYLLfIvkr3Oon+BNe8uyYTjDy/Z4
         RrRUhWos++x3mqMGYUiO1rYeyNUZ7OuJISAVcJAro9QY7mU30mpTpRvwvyCzHhryUZoG
         c+6idZo9EAlTSpEtEtGrynnmEHHfUxZsRhBPqQAU6G/hsugz8EJmV2ANxhQXrxfOWuxx
         Zw9TzZ/quH2ge8hl6F9m96kJV1dC8cAb+b/viWh8gULHfu72wj2pFQpDRPQIavcGh88C
         Jtog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWol+M6n/Hp4nWqYZYLhiN8EY4ibCd+rJ8ibjRTaa9ztblWxO65
	5232CqygbjnbzWeiQ6AMTMA/ob8mhBWiN8wfqFNxoS9R3cYvPBwpJPL7RjUa2yhAyPhdnh+471Y
	GWEQfgCVLoSL3yYPu3vOfu3DsQpvKVYd/vOyTLdJQOTVTv9Siuzb5ixqcsLZYumwx8g==
X-Received: by 2002:a37:8843:: with SMTP id k64mr38744611qkd.8.1558014883868;
        Thu, 16 May 2019 06:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjr0Eciqcr1DUAcUNy4fK+mu4mhd//WVMrPwactKh0SujNmMrF4mRQB1Z+N/7psJapmER/
X-Received: by 2002:a37:8843:: with SMTP id k64mr38744553qkd.8.1558014883116;
        Thu, 16 May 2019 06:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558014883; cv=none;
        d=google.com; s=arc-20160816;
        b=CZc2A/ikTpIJriKZIKaMnqaZaIfv/CBYMepWTV3meSsMrxmcQqfRUMh9ujUgQpOXIy
         UFw1FXzLbHtgbyvx+qY8KKTBKvUVySrVOwqpTW7uy565B1szuUu7GxjcFyfkW+JxuRMh
         TTGNiuXQ0M0X7LO6AB/dgLqfVGbtqLQmSK9o+g0ji6shgxLfHg8gjsUb85Eqo+EhyhzN
         Yek6XUr355wGq38b6+PxaJ5sAxAujxmReHGO5Ih9bHcUuOsYawFk0kl41fG28IBNols8
         4VMwIIb0riCto59sgEXI/k/DgmQHbERWfMd2+69AZW45o7YUcGOUpizaVoB4D0GjVJkW
         JSIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xxVByyzHqcwQo9d/DUy2hcnoWGN77Aq/V3FYya0ZW/s=;
        b=OhVjsvOE2Ci5eFPKz+n74XDYdB9ofg9YOCFEdqD5BcHIK5HBwTno7oMwEaViwWCd89
         UzBdIrVuTMky6jAfdHaBy07T5AXkJKPC7K4QvK/xSS4elGg6pfRPqZbgacjm+kiLnY/8
         BTMbw1UNpE+YaJvVjoUgVjgK0amJTQFBfKBcJRzEItnWmHUbxrXE4mBRlz/cfFOKXSTF
         f0NjUn3kSs4nDW2hokDHkI4i0Wga3FJ0LNhVfaymFEiVDLZr9oEHcvDksrWKhTMeD6hc
         b3ya5TeRB9eQN1VJfe1SX8YfHcEcEsILWvCkCmNR1Vhsfe3Fggg74gQgWlRqwmV8Vbo+
         aLjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x37si3795330qtc.286.2019.05.16.06.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C4ED73082B22;
	Thu, 16 May 2019 13:54:41 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id CF85D5D6A9;
	Thu, 16 May 2019 13:54:37 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu, 16 May 2019 15:54:40 +0200 (CEST)
Date: Thu, 16 May 2019 15:54:36 +0200
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
Message-ID: <20190516135435.GA22564@redhat.com>
References: <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
 <20190509183353.GA13018@sultan-box.localdomain>
 <20190510151024.GA21421@redhat.com>
 <20190513164555.GA30128@sultan-box.localdomain>
 <20190515145831.GD18892@redhat.com>
 <20190515172728.GA14047@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515172728.GA14047@sultan-box.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 16 May 2019 13:54:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/15, Sultan Alsawaf wrote:
>
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
>         if (debug_locks && __debug_locks_off()) {
>                 if (!debug_locks_silent) {
>                         console_verbose();

OK, this means that debug_locks_off() always returns 0, as if debug_locks was already
cleared.

Thus print_deadlock_bug() will do nothing, it does

	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
		return 0;

iow this means that even if lockdep finds a problem, the problem won't be reported.

> [    1.492128] BUG: key 0000000000000000 not in .data!
> [    1.492141] BUG: key 0000000000000000 not in .data!
> [    1.492152] BUG: key 0000000000000000 not in .data!
> [    1.492228] BUG: key 0000000000000000 not in .data!
> [    1.492238] BUG: key 0000000000000000 not in .data!
> [    1.492248] BUG: key 0000000000000000 not in .data!

I guess this is lockdep_init_map() which does printk("BUG:") itself, but due to your
change above it doesn't do WARN(1) and thus there is no call trace.

Oleg.

