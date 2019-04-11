Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DAFBC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:30:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C312F2084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:30:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="a9Q0ffwW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C312F2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4666E6B026F; Thu, 11 Apr 2019 06:30:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4171C6B0270; Thu, 11 Apr 2019 06:30:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 306EA6B0271; Thu, 11 Apr 2019 06:30:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D58D26B026F
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:30:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f9so2878124edy.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:30:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fNDpPoKFep30VPB7JAGYM6+zUnmN6SfRDS6DB3QxWpw=;
        b=uX2BFRHbsUU9FoIl/aBwAcEwHggYlmNEGuSsG9R4DydnCsLwksSXdcdctIbq5eMAH5
         cbHkksd8CIRwSTtLKM9zpbqxuAXVBLSq6BXxB/SYQuvN3Fmvi6MZMWNqQNee9CNaOjPP
         +d+tYan8eWW6Gq5KiIknFWesCZ0OCOrXC8QJ8o7skR3S7RxKYmI0rNhctdfeyUmqVCvQ
         5wMIWbkCWjVzat2qcZnUmcBQTJhok+M7Qk6RRnYGDjByVNwxMqCFIYszQUdseb++S2lU
         Hiu+V9YYnJasKG7S8VnprjX0TrIDc8qu2cYljMO/aKJDE4hBbVnyflHr3VLBaiIwfAEa
         o8KA==
X-Gm-Message-State: APjAAAW3bxRkhTxECqkdZW90oQ7Be3Ap/7abG/WDigmBaQ661z0uz0ah
	L/HwrGgchJsHRsKlZYNOeVvyUCtSFj4E8HEWBl9R6mRanFV2tUtsdAA8cTXGBSd3jffbCDWiX/Z
	Y313l6+qkBEr/PU8+ZFEexWHj1kbR3QLUOo1+yVVUUjKuGSAFwrrCsEh7efBaRhydpw==
X-Received: by 2002:a50:aa31:: with SMTP id o46mr29860324edc.6.1554978623206;
        Thu, 11 Apr 2019 03:30:23 -0700 (PDT)
X-Received: by 2002:a50:aa31:: with SMTP id o46mr29860266edc.6.1554978621968;
        Thu, 11 Apr 2019 03:30:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554978621; cv=none;
        d=google.com; s=arc-20160816;
        b=rMQ5iVf8hjzStpGpVCeMRQ66uf24yQtK5vuG24gv6M4fSmyad1Sjj0wNM5M5ZZjxyE
         WbpPq7qOESdfAHVW8kEtERU/5JbWP4W0KwNgwKzjOzGFEHaKunqaYyKrpGEirasZj5fM
         zBk6qFLQ8g9UyMEs+Cs/XX1raeC+E2cDQwyGNUMjr6yj4xg+2qDwPIKzU/W9nRw/jXRq
         WGJl2mczfOTCoBJQOT3xNBw8FPTX4W/Bw3fvCMoBoB/RCXvPGQpRlBMM0xwDneSNm31E
         F1QpnWInfAxB+RqoKSlDHm+MVrOFjyVuTueXlLzB6JlaWxPILOsKwJjbTyson1VzRuFh
         ilOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fNDpPoKFep30VPB7JAGYM6+zUnmN6SfRDS6DB3QxWpw=;
        b=As4NsQq0dkf4UDJghbVechBxYKj7i5euFKUZylVGpmmujHNZ4zFHDQtzopk3jfoBQ6
         oKVQaOeuAV6e+7Eib78p5lvCnJNn8JyVMh3R/OPCT5ADeCnJ5XBCN8FMfYrDeIbJfNBT
         RwHAb3EchSrEHh/w8fBjbYhaQTULmNCqNfwzz/tdhKrXza8wmHAt6as0PpenNWKUrbck
         cpDWRpL/UW91qCPeFHwR0CK/KbRn3gdKzvn8iu3Ak1+ynOe6q3mjWWUu7nzNS44uk27c
         MOjmjiuVBwfVmJk2Uif135AIZS/L6/asJy8Hm8/SPldfHZZGOYM22SNGGH2AeB+SqqTD
         zFjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=a9Q0ffwW;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bs22sor10989447ejb.8.2019.04.11.03.30.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 03:30:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=a9Q0ffwW;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fNDpPoKFep30VPB7JAGYM6+zUnmN6SfRDS6DB3QxWpw=;
        b=a9Q0ffwWOPvjKqnKc+aHFbME7BZiGXtUXfdUmypbgs0lIl+JJj76rhF/poZA5jbQST
         OxPcmt9nKeNWcULwaEx0H6JFik2XpHxrfnyfe8M/w6K4NZZLUH/Qq6rU1silQmCx64rE
         X7QMG/2Ttho7nY/I8A32toEONsZmDw2OjgmvsR/ZTY/DzBW8xWma4ZUP702c2/IHwJkv
         mZEfktNMMWc+gNOAtxzhfJF1sKKiAcswkYtYpnIBVQDhWqvjoUsQ6KRht90H7xgPJ0rO
         hHnwrw7lJQUSTa6Cx8W1bAQBYjQr2+ZAV7EtFdWf5mYzwtTXIpc+eGGhnQbBEbM4oc0T
         HCBA==
X-Google-Smtp-Source: APXvYqxYMluNysavzXmGF1NhFGtmkRkB6gD+HAq+x3NHnRkzH8PpV25/ta4TAPcQpHjR+TN4Qm3vCw==
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr2694240ejv.57.1554978621486;
        Thu, 11 Apr 2019 03:30:21 -0700 (PDT)
Received: from brauner.io ([212.91.227.56])
        by smtp.gmail.com with ESMTPSA id j26sm10922122edr.66.2019.04.11.03.30.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Apr 2019 03:30:20 -0700 (PDT)
Date: Thu, 11 Apr 2019 12:30:19 +0200
From: Christian Brauner <christian@brauner.io>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com,
	willy@infradead.org, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com, hannes@cmpxchg.org,
	penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, minchan@kernel.org, timmurray@google.com,
	dancol@google.com, joel@joelfernandes.org, jannh@google.com,
	linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kernel-team@android.com
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190411103018.tcsinifuj7klh6rp@brauner.io>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190411014353.113252-3-surenb@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> pidfd_send_signal() syscall to allow expedited memory reclaim of the
> victim process. The usage of this flag is currently limited to SIGKILL
> signal and only to privileged users.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  include/linux/sched/signal.h |  3 ++-
>  include/linux/signal.h       | 11 ++++++++++-
>  ipc/mqueue.c                 |  2 +-
>  kernel/signal.c              | 37 ++++++++++++++++++++++++++++--------
>  kernel/time/itimer.c         |  2 +-
>  5 files changed, 43 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
> index e412c092c1e8..8a227633a058 100644
> --- a/include/linux/sched/signal.h
> +++ b/include/linux/sched/signal.h
> @@ -327,7 +327,8 @@ extern int send_sig_info(int, struct kernel_siginfo *, struct task_struct *);
>  extern void force_sigsegv(int sig, struct task_struct *p);
>  extern int force_sig_info(int, struct kernel_siginfo *, struct task_struct *);
>  extern int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp);
> -extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid);
> +extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> +				bool expedite);
>  extern int kill_pid_info_as_cred(int, struct kernel_siginfo *, struct pid *,
>  				const struct cred *);
>  extern int kill_pgrp(struct pid *pid, int sig, int priv);
> diff --git a/include/linux/signal.h b/include/linux/signal.h
> index 9702016734b1..34b7852aa4a0 100644
> --- a/include/linux/signal.h
> +++ b/include/linux/signal.h
> @@ -446,8 +446,17 @@ int __save_altstack(stack_t __user *, unsigned long);
>  } while (0);
>  
>  #ifdef CONFIG_PROC_FS
> +
> +/*
> + * SS_FLAGS values used in pidfd_send_signal:
> + *
> + * SS_EXPEDITE indicates desire to expedite the operation.
> + */
> +#define SS_EXPEDITE	0x00000001

Does this make sense as an SS_* flag?
How does this relate to the signal stack?
Is there any intention to ever use this flag with stack_t?

New flags should be PIDFD_SIGNAL_*. (E.g. the thread flag will be
PIDFD_SIGNAL_THREAD.)
And since this is exposed to userspace in contrast to the mm internal
naming it should be something more easily understandable like
PIDFD_SIGNAL_MM_RECLAIM{_FASTER} or something.

> +
>  struct seq_file;
>  extern void render_sigset_t(struct seq_file *, const char *, sigset_t *);
> -#endif
> +
> +#endif /* CONFIG_PROC_FS */
>  
>  #endif /* _LINUX_SIGNAL_H */
> diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> index aea30530c472..27c66296e08e 100644
> --- a/ipc/mqueue.c
> +++ b/ipc/mqueue.c
> @@ -720,7 +720,7 @@ static void __do_notify(struct mqueue_inode_info *info)
>  			rcu_read_unlock();
>  
>  			kill_pid_info(info->notify.sigev_signo,
> -				      &sig_i, info->notify_owner);
> +				      &sig_i, info->notify_owner, false);
>  			break;
>  		case SIGEV_THREAD:
>  			set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
> diff --git a/kernel/signal.c b/kernel/signal.c
> index f98448cf2def..02ed4332d17c 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -43,6 +43,7 @@
>  #include <linux/compiler.h>
>  #include <linux/posix-timers.h>
>  #include <linux/livepatch.h>
> +#include <linux/oom.h>
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/signal.h>
> @@ -1394,7 +1395,8 @@ int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp)
>  	return success ? 0 : retval;
>  }
>  
> -int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
> +int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> +				  bool expedite)
>  {
>  	int error = -ESRCH;
>  	struct task_struct *p;
> @@ -1402,8 +1404,17 @@ int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
>  	for (;;) {
>  		rcu_read_lock();
>  		p = pid_task(pid, PIDTYPE_PID);
> -		if (p)
> +		if (p) {
>  			error = group_send_sig_info(sig, info, p, PIDTYPE_TGID);
> +
> +			/*
> +			 * Ignore expedite_reclaim return value, it is best
> +			 * effort only.
> +			 */
> +			if (!error && expedite)
> +				expedite_reclaim(p);

SIGKILL will take the whole thread group down so the reclaim should make
sense here.

> +		}
> +
>  		rcu_read_unlock();
>  		if (likely(!p || error != -ESRCH))
>  			return error;
> @@ -1420,7 +1431,7 @@ static int kill_proc_info(int sig, struct kernel_siginfo *info, pid_t pid)
>  {
>  	int error;
>  	rcu_read_lock();
> -	error = kill_pid_info(sig, info, find_vpid(pid));
> +	error = kill_pid_info(sig, info, find_vpid(pid), false);
>  	rcu_read_unlock();
>  	return error;
>  }
> @@ -1487,7 +1498,7 @@ static int kill_something_info(int sig, struct kernel_siginfo *info, pid_t pid)
>  
>  	if (pid > 0) {
>  		rcu_read_lock();
> -		ret = kill_pid_info(sig, info, find_vpid(pid));
> +		ret = kill_pid_info(sig, info, find_vpid(pid), false);
>  		rcu_read_unlock();
>  		return ret;
>  	}
> @@ -1704,7 +1715,7 @@ EXPORT_SYMBOL(kill_pgrp);
>  
>  int kill_pid(struct pid *pid, int sig, int priv)
>  {
> -	return kill_pid_info(sig, __si_special(priv), pid);
> +	return kill_pid_info(sig, __si_special(priv), pid, false);
>  }
>  EXPORT_SYMBOL(kill_pid);
>  
> @@ -3577,10 +3588,20 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
>  	struct pid *pid;
>  	kernel_siginfo_t kinfo;
>  
> -	/* Enforce flags be set to 0 until we add an extension. */
> -	if (flags)
> +	/* Enforce no unknown flags. */
> +	if (flags & ~SS_EXPEDITE)
>  		return -EINVAL;
>  
> +	if (flags & SS_EXPEDITE) {
> +		/* Enforce SS_EXPEDITE to be used with SIGKILL only. */
> +		if (sig != SIGKILL)
> +			return -EINVAL;

Not super fond of this being a SIGKILL specific flag but I get why.

> +
> +		/* Limit expedited killing to privileged users only. */
> +		if (!capable(CAP_SYS_NICE))
> +			return -EPERM;

Do you have a specific (DOS or other) attack vector in mind that renders
ns_capable unsuitable?

> +	}
> +
>  	f = fdget_raw(pidfd);
>  	if (!f.file)
>  		return -EBADF;
> @@ -3614,7 +3635,7 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
>  		prepare_kill_siginfo(sig, &kinfo);
>  	}
>  
> -	ret = kill_pid_info(sig, &kinfo, pid);
> +	ret = kill_pid_info(sig, &kinfo, pid, (flags & SS_EXPEDITE) != 0);
>  
>  err:
>  	fdput(f);
> diff --git a/kernel/time/itimer.c b/kernel/time/itimer.c
> index 02068b2d5862..c926483cdb53 100644
> --- a/kernel/time/itimer.c
> +++ b/kernel/time/itimer.c
> @@ -140,7 +140,7 @@ enum hrtimer_restart it_real_fn(struct hrtimer *timer)
>  	struct pid *leader_pid = sig->pids[PIDTYPE_TGID];
>  
>  	trace_itimer_expire(ITIMER_REAL, leader_pid, 0);
> -	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid);
> +	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid, false);
>  
>  	return HRTIMER_NORESTART;
>  }
> -- 
> 2.21.0.392.gf8f6787159e-goog
> 

