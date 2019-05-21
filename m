Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E116C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44296217D7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:51:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="I2SlfVLI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44296217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1CD56B0003; Tue, 21 May 2019 07:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA5F36B0006; Tue, 21 May 2019 07:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20876B0007; Tue, 21 May 2019 07:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 648F76B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:51:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r75so12177872pfc.15
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:51:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UtDqUNgJnZynvBlOnHH9iSsJaf+tEnVzROAfsvS8DBE=;
        b=MFjgrTiPVgb+3gam3bh9gUqmfGSXT9miwQYzKVvg7uW3A/rjMRo/8Go0We3gH0KqeL
         7t1c68myIJdw0h7zYyWW1JW8Heag6aXmXKpf1HfcFMGdCNYfR8HRA/P3giCb17f5AiIm
         8iOiswyN+6QNCTbjmP8XC4hRIO+s+FPzIYvwxRBdbaOhcW7VpBAcBVmtzZXkkyCZMzum
         Ien7p5U0iPBg8zZXOTtykRPMz/H3Y1VljpkS0yyVgUENngzex4/G0brnvSTwmlCzirEP
         EfKO9ozuh4cdmOKZn9h63xuqJGdT9xpuO+nDYW4qVGVU/ZgrMXNoICx6v/hrJEe0qAxs
         4dzA==
X-Gm-Message-State: APjAAAVV1+RwIDrJnhZwdtXGuHu1OAYa28N+EWR94MqtEr7RPh20p8N6
	dhYUdtZpYaAZwEolU+l45e/n5RLTtjwljSevnrzkWThNQwNxQnoGqNZp4g42qBwfAh4xERamXU8
	1/e2HJjH+Qt4lIV9PXqRUCNrYuZGo5Tt+a4IiszGAwRuvUqSX5YVJ6co3IeW9z7iJeg==
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr84929509pfo.85.1558439508019;
        Tue, 21 May 2019 04:51:48 -0700 (PDT)
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr84929428pfo.85.1558439506893;
        Tue, 21 May 2019 04:51:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558439506; cv=none;
        d=google.com; s=arc-20160816;
        b=mHjYWk1Nicys9bw3juR01CJpat5sVlvyZylZ7upfP29eQgnWMGmHQQJybQfEa+FxGs
         6EcgKPWaH7yT5hPP9XRPI9hiCtIOnF6pL/cdx2bvPBtHEJkVEl1u/PmtpsEzj36XkMeb
         G7Bdx+r6iLWG+Z36BZjjOtV11W50dGnON6x/lIhTXBkr9ZpStAA0cAnzWwbhLh47nH4T
         fB1kya87+zHmK5N2gOnzX7ed12T1GwggJWrCorwH5MYnpaDr+gYh5diGITCNyC5ybSLR
         2XCUvXbB4DQvRP7qOp2ZfuQgtI0bXmG3xEWzvRCtaC9goO2RJi85kKFEi5WcTeEVJKE6
         YEfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UtDqUNgJnZynvBlOnHH9iSsJaf+tEnVzROAfsvS8DBE=;
        b=MSkgT3UidhR1z06XvZVnLJiAJNfjkLmkqfq7poawoL5ySthnkkmWFui3ZqgzFXZTcG
         kAzOLhUEYs68vW9gCGXOlyqxb2LnGqz+ngG76UvSAZpOOd59GQ89wfL8HMFGyH/tQe1H
         ralhnIC3+jrYSyzT0H1RxxkiThK5u7jJwF6USzLcUXCc2UDWsBsMqKEe37+DRR1C/fmV
         fFgojaOMe7v8G146dFnOallUgtfM9XBKyM6+hdMXTN6PQO0NzfBsBL+BvaP3NYo0fYmj
         Chr9gjwMTQ203vJeYPT7TAez8InNe/U6t7JvyWGp6btR+nNmAALNCBBwkPWmHpykRb+R
         YboQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=I2SlfVLI;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t25sor7699847pfh.57.2019.05.21.04.51.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:51:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=I2SlfVLI;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UtDqUNgJnZynvBlOnHH9iSsJaf+tEnVzROAfsvS8DBE=;
        b=I2SlfVLIPpeoN83/RVrIDZ2txEnNA5/ACU8WMfVJGvRRYeZHhJySKHjwhWV/Bn5LJm
         +AmEBzMgvcsaSN80G2haPXgR93//O72qJf3u00s1Lc49RDald+0XCvtiLunT8uN4SzfK
         3nzT6LPSjwfmpTlI4jYN/Zrt/8fBget25T1htvMTEqJMoQGulRy7aRQKGfemlBvsamMV
         o3cxKBFERwOrGDOEYVv8JGqp+46X/kmpcRFsNuN2BuuTY2vQRfosbUAKnxe86l+4fDI0
         fn9C+x+qSs1SOPXkwCmesLYZU4PPDRMHNq2meRvHYQGuFwUhCvt0/uF2R5N2PXaI/H8Z
         UHRg==
X-Google-Smtp-Source: APXvYqzVAPpLqpOw3CzPXblES0fZoluJzsflh2rJavwNsVzz1QjsTvWNUJgpYR5jM9xP6oesamRJVA==
X-Received: by 2002:a65:5588:: with SMTP id j8mr81657084pgs.306.1558439506334;
        Tue, 21 May 2019 04:51:46 -0700 (PDT)
Received: from brauner.io ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id t25sm34940175pfq.91.2019.05.21.04.51.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:51:45 -0700 (PDT)
Date: Tue, 21 May 2019 13:51:36 +0200
From: Christian Brauner <christian@brauner.io>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190521115134.rzknm4q2r5cpr6az@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521090058.mdx4qecmdbum45t2@brauner.io>
 <20190521113510.GI219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190521113510.GI219653@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:35:10PM +0900, Minchan Kim wrote:
> On Tue, May 21, 2019 at 11:01:01AM +0200, Christian Brauner wrote:
> > Cc: Jann and Oleg too
> > 
> > On Mon, May 20, 2019 at 12:52:52PM +0900, Minchan Kim wrote:
> > > There is some usecase that centralized userspace daemon want to give
> > > a memory hint like MADV_[COOL|COLD] to other process. Android's
> > > ActivityManagerService is one of them.
> > > 
> > > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > > required to make the reclaim decision is not known to the app. Instead,
> > > it is known to the centralized userspace daemon(ActivityManagerService),
> > > and that daemon must be able to initiate reclaim on its own without
> > > any app involvement.
> > > 
> > > To solve the issue, this patch introduces new syscall process_madvise(2)
> > > which works based on pidfd so it could give a hint to the exeternal
> > > process.
> > > 
> > > int process_madvise(int pidfd, void *addr, size_t length, int advise);
> > > 
> > > All advises madvise provides can be supported in process_madvise, too.
> > > Since it could affect other process's address range, only privileged
> > > process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> > > gives it the right to ptrrace the process could use it successfully.
> > > 
> > > Please suggest better idea if you have other idea about the permission.
> > > 
> > > * from v1r1
> > >   * use ptrace capability - surenb, dancol
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
> > >  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
> > >  include/linux/proc_fs.h                |  1 +
> > >  include/linux/syscalls.h               |  2 ++
> > >  include/uapi/asm-generic/unistd.h      |  2 ++
> > >  kernel/signal.c                        |  2 +-
> > >  kernel/sys_ni.c                        |  1 +
> > >  mm/madvise.c                           | 45 ++++++++++++++++++++++++++
> > >  8 files changed, 54 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> > > index 4cd5f982b1e5..5b9dd55d6b57 100644
> > > --- a/arch/x86/entry/syscalls/syscall_32.tbl
> > > +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> > > @@ -438,3 +438,4 @@
> > >  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
> > >  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
> > >  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> > > +428	i386	process_madvise		sys_process_madvise		__ia32_sys_process_madvise
> > > diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> > > index 64ca0d06259a..0e5ee78161c9 100644
> > > --- a/arch/x86/entry/syscalls/syscall_64.tbl
> > > +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> > > @@ -355,6 +355,7 @@
> > >  425	common	io_uring_setup		__x64_sys_io_uring_setup
> > >  426	common	io_uring_enter		__x64_sys_io_uring_enter
> > >  427	common	io_uring_register	__x64_sys_io_uring_register
> > > +428	common	process_madvise		__x64_sys_process_madvise
> > >  
> > >  #
> > >  # x32-specific system call numbers start at 512 to avoid cache impact
> > > diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> > > index 52a283ba0465..f8545d7c5218 100644
> > > --- a/include/linux/proc_fs.h
> > > +++ b/include/linux/proc_fs.h
> > > @@ -122,6 +122,7 @@ static inline struct pid *tgid_pidfd_to_pid(const struct file *file)
> > >  
> > >  #endif /* CONFIG_PROC_FS */
> > >  
> > > +extern struct pid *pidfd_to_pid(const struct file *file);
> > >  struct net;
> > >  
> > >  static inline struct proc_dir_entry *proc_net_mkdir(
> > > diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> > > index e2870fe1be5b..21c6c9a62006 100644
> > > --- a/include/linux/syscalls.h
> > > +++ b/include/linux/syscalls.h
> > > @@ -872,6 +872,8 @@ asmlinkage long sys_munlockall(void);
> > >  asmlinkage long sys_mincore(unsigned long start, size_t len,
> > >  				unsigned char __user * vec);
> > >  asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
> > > +asmlinkage long sys_process_madvise(int pid_fd, unsigned long start,
> > > +				size_t len, int behavior);
> > >  asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
> > >  			unsigned long prot, unsigned long pgoff,
> > >  			unsigned long flags);
> > > diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> > > index dee7292e1df6..7ee82ce04620 100644
> > > --- a/include/uapi/asm-generic/unistd.h
> > > +++ b/include/uapi/asm-generic/unistd.h
> > > @@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
> > >  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
> > >  #define __NR_io_uring_register 427
> > >  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> > > +#define __NR_process_madvise 428
> > > +__SYSCALL(__NR_process_madvise, sys_process_madvise)
> > >  
> > >  #undef __NR_syscalls
> > >  #define __NR_syscalls 428
> > > diff --git a/kernel/signal.c b/kernel/signal.c
> > > index 1c86b78a7597..04e75daab1f8 100644
> > > --- a/kernel/signal.c
> > > +++ b/kernel/signal.c
> > > @@ -3620,7 +3620,7 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
> > >  	return copy_siginfo_from_user(kinfo, info);
> > >  }
> > >  
> > > -static struct pid *pidfd_to_pid(const struct file *file)
> > > +struct pid *pidfd_to_pid(const struct file *file)
> > >  {
> > >  	if (file->f_op == &pidfd_fops)
> > >  		return file->private_data;
> > > diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> > > index 4d9ae5ea6caf..5277421795ab 100644
> > > --- a/kernel/sys_ni.c
> > > +++ b/kernel/sys_ni.c
> > > @@ -278,6 +278,7 @@ COND_SYSCALL(mlockall);
> > >  COND_SYSCALL(munlockall);
> > >  COND_SYSCALL(mincore);
> > >  COND_SYSCALL(madvise);
> > > +COND_SYSCALL(process_madvise);
> > >  COND_SYSCALL(remap_file_pages);
> > >  COND_SYSCALL(mbind);
> > >  COND_SYSCALL_COMPAT(mbind);
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 119e82e1f065..af02aa17e5c1 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -9,6 +9,7 @@
> > >  #include <linux/mman.h>
> > >  #include <linux/pagemap.h>
> > >  #include <linux/page_idle.h>
> > > +#include <linux/proc_fs.h>
> > >  #include <linux/syscalls.h>
> > >  #include <linux/mempolicy.h>
> > >  #include <linux/page-isolation.h>
> > > @@ -16,6 +17,7 @@
> > >  #include <linux/hugetlb.h>
> > >  #include <linux/falloc.h>
> > >  #include <linux/sched.h>
> > > +#include <linux/sched/mm.h>
> > >  #include <linux/ksm.h>
> > >  #include <linux/fs.h>
> > >  #include <linux/file.h>
> > > @@ -1140,3 +1142,46 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> > >  {
> > >  	return madvise_core(current, start, len_in, behavior);
> > >  }
> > > +
> > > +SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> > > +		size_t, len_in, int, behavior)
> > > +{
> > > +	int ret;
> > > +	struct fd f;
> > > +	struct pid *pid;
> > > +	struct task_struct *tsk;
> > > +	struct mm_struct *mm;
> > > +
> > > +	f = fdget(pidfd);
> > > +	if (!f.file)
> > > +		return -EBADF;
> > > +
> > > +	pid = pidfd_to_pid(f.file);
> > 
> > pidfd_to_pid() should not be directly exported since this allows
> > /proc/<pid> fds to be used too. That's something we won't be going
> > forward with. All new syscalls should only allow to operate on pidfds
> > created through CLONE_PIDFD or pidfd_open() (cf. [1]).
> 
> Thanks for the information.
> 
> > 
> > So e.g. please export a simple helper like
> > 
> > struct pid *pidfd_to_pid(const struct file *file)
> > {
> >         if (file->f_op == &pidfd_fops)
> >                 return file->private_data;
> > 
> >         return NULL;
> > }
> > 
> > turning the old pidfd_to_pid() into something like:
> > 
> > static struct pid *__fd_to_pid(const struct file *file)
> > {
> >         struct pid *pid;
> > 
> >         pid = pidfd_to_pid(file);
> >         if (pid)
> >                 return pid;
> > 
> >         return tgid_pidfd_to_pid(file);
> > }
> 
> So, I want to clarify what you suggest here.
> 
> 1. modify pidfd_to_pid as what you described above(ie, return NULL
> instead of returning tgid_pidfd_to_pid(file);
> 2. never export pidfd_to_pid
> 3. create wrapper __fd_to_pid which calls pidfd_to_pid internally
> 4. export __fd_to_pid and use it

Sorry, seems I was not clear enough. :)
What I meant was something along the lines of (not compile tested):

diff --git a/include/linux/pid.h b/include/linux/pid.h
index 3c8ef5a199ca..3ccc07010603 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -68,6 +68,10 @@ extern struct pid init_struct_pid;
 
 extern const struct file_operations pidfd_fops;
 
+struct file;
+
+extern struct pid *pidfd_pid(const struct file *file);
+
 static inline struct pid *get_pid(struct pid *pid)
 {
 	if (pid)
diff --git a/kernel/fork.c b/kernel/fork.c
index b4cba953040a..0fcfffaf5fdc 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1711,6 +1711,14 @@ const struct file_operations pidfd_fops = {
 #endif
 };
 
+struct pid *pidfd_pid(const struct file *file)
+{
+	if (file->f_op == &pidfd_fops)
+		return file->private_data;
+
+	return ERR_PTR(-EBADF);
+}
+
 /**
  * pidfd_create() - Create a new pid file descriptor.
  *
diff --git a/kernel/signal.c b/kernel/signal.c
index a1eb44dc9ff5..7fca9d7e1633 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3611,8 +3611,11 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
 
 static struct pid *pidfd_to_pid(const struct file *file)
 {
-	if (file->f_op == &pidfd_fops)
-		return file->private_data;
+	struct pid *pid;
+
+	pid = pidfd_pid(file);
+	if (pid)
+		return pid;
 
 	return tgid_pidfd_to_pid(file);
 }

