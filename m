Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 403B8C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:01:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEA6B2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:01:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="ap4moqJQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEA6B2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793CC6B0003; Tue, 21 May 2019 05:01:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 744736B0005; Tue, 21 May 2019 05:01:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65A556B0006; Tue, 21 May 2019 05:01:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBF46B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:01:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w14so1914445plp.4
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:01:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VXa8qKXM8vx5w5jhb1hWXGT+1/HaN8aUWabF6nAwG1s=;
        b=anhBZgSi/w6K5k3Llomiq9YjF651EHJRfTpaSjpTFuB/3BKBRtI0ygT7Uc6VhFppU6
         X0PKScD6vs8/qFWndyVJ4iw/pPikZvoLofl9u2SjulYLVZzSAB9Moyct8hAbgU6FHiqj
         iRG8xReAS1d5mWBZj5mdxeMRWY5f6sTOQT43ruw3TanXsLJHgFVrXabICgdbPcd6FGbS
         /Yz3TrqUF0/JJEjrsa0BTM07PyV7W2Ip5dZ/yZJys+hDjN3l27RZ+ot/fYLNy34AD33d
         xxsNOvxi+WuyLw++MRtux5o8p054faYr4jB4JcoSoAp8rBrOou8xzzcwHLddjD2zYrsx
         BMNQ==
X-Gm-Message-State: APjAAAWEq6iUPUMX8wzQdKzQTT3Gayfl0UQfX8u1fqdvZXHhkzL1uQlZ
	YntQeePTWgrBhqufQrsNSyFlGq7saoIoBBMm6WI8foeuOc0l0WvNwKWl3yfREZAJgh03ir3Ffp/
	mhodv2lqXAfYknPebUzyqGwraS/TKjxGqyTDbjFFHoS9dbv+6QNVksVg5gAFPcTPW3A==
X-Received: by 2002:a65:5588:: with SMTP id j8mr80858736pgs.306.1558429273371;
        Tue, 21 May 2019 02:01:13 -0700 (PDT)
X-Received: by 2002:a65:5588:: with SMTP id j8mr80858660pgs.306.1558429272473;
        Tue, 21 May 2019 02:01:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558429272; cv=none;
        d=google.com; s=arc-20160816;
        b=Uu6JwjdUGOIDYeA0r2HLF3HFp78xHKTH0OQHbNHxHeKuPS3YVu3Ef8XK5Ru5kO7SCn
         mkmCBVzcvOpdnYm4+N6G7E9N7c4vWJm+YgkmxdN3EBE7u1lWkUAx1AiYA1RESUIPA+4k
         y1c0nh+y+HqosdHXAXxGY/ZHNLE4PhzIk+pntslM1eMw6O4KT7CSS4QfurdIQ3HPe5+f
         GVsBy6EbC3nbFVFuttNjZz4KvpzREJxYP8dSVRfMWMLzsDtmUFSSNB9WHinrNSrGsFF2
         7qFHdwkPUvFTq9BPLxrYd2ye2yzyjA5QKz55hJfF0M89LHQRQWSVRMypRJ0EcdqGSbaL
         xIHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VXa8qKXM8vx5w5jhb1hWXGT+1/HaN8aUWabF6nAwG1s=;
        b=aTUAUrWko3gH82XYNJFgN3B+IPq1mXoP0giT6EQ1kijuRLPFSCKYan9miLT8O2O6mU
         Otb1MPH5WO0bl+Aro0cR7azxkkMMd/8DPL8QgYBw32e4lGP5ZnQ0MjDhnnJ2q8mGy4nr
         YijambT9r1jGY5KlZ3tOmMlghs9YA0aLE7C6wKfEJQ5RcGSIPZpx+Nofe/snk/laDPU5
         ZJHr9YtDMgJKMhauTNUddadfy5FCF5GGT/qZzNuYnGrE4gqzGgWoBtHXCQWlcRqiAqxw
         fIB5/wPsvG0rjAgVYsGL8QRF7gdrjuRk5b8Hv6F+cvKMHQUKVwOyWmGH4z8A78MEmmX2
         J0QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ap4moqJQ;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e21sor14120704pfl.11.2019.05.21.02.01.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 02:01:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ap4moqJQ;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VXa8qKXM8vx5w5jhb1hWXGT+1/HaN8aUWabF6nAwG1s=;
        b=ap4moqJQoZSVJnMxAJFA2Gd3/lgQpTrOdJPzRObXTro1kOAgVtt4jWtT8AIudv19/H
         lxz3hqeX/rhdO+/P8gIqTFBmbdvDqc9UPfxW3qM91M2NJPKmmdWNMJs0faLyWBIfteGN
         +/2JfEl57rlNZgyLn+VowUFpUEOnFsaPanJVATse+mTSHOVCOxNJdiLdeJ5ZpVqEpEnn
         tXLh/cGNaLhGR0mNlBaRiVEP3qySDLYSMY6GXnVMnPVUKDKM/5xN+wCF35NVFryIv0eL
         Rb4YO1KPcNruH1PoHC13d7F/4xmF1JTKNdjfTMAtW9J+OffwY4gLCo9f7Eiq3hW6OysP
         KcMw==
X-Google-Smtp-Source: APXvYqwiPEuTQW24lNgrLxshbki5jYwjBJyGemSdADvmx+PDINAmtZ98NXEPyAhz0SpDdxyA9y4qmQ==
X-Received: by 2002:a62:e10f:: with SMTP id q15mr85381949pfh.56.1558429271893;
        Tue, 21 May 2019 02:01:11 -0700 (PDT)
Received: from brauner.io ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id f36sm21146595pgb.76.2019.05.21.02.01.04
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 02:01:10 -0700 (PDT)
Date: Tue, 21 May 2019 11:01:01 +0200
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
Message-ID: <20190521090058.mdx4qecmdbum45t2@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-6-minchan@kernel.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: Jann and Oleg too

On Mon, May 20, 2019 at 12:52:52PM +0900, Minchan Kim wrote:
> There is some usecase that centralized userspace daemon want to give
> a memory hint like MADV_[COOL|COLD] to other process. Android's
> ActivityManagerService is one of them.
> 
> It's similar in spirit to madvise(MADV_WONTNEED), but the information
> required to make the reclaim decision is not known to the app. Instead,
> it is known to the centralized userspace daemon(ActivityManagerService),
> and that daemon must be able to initiate reclaim on its own without
> any app involvement.
> 
> To solve the issue, this patch introduces new syscall process_madvise(2)
> which works based on pidfd so it could give a hint to the exeternal
> process.
> 
> int process_madvise(int pidfd, void *addr, size_t length, int advise);
> 
> All advises madvise provides can be supported in process_madvise, too.
> Since it could affect other process's address range, only privileged
> process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> gives it the right to ptrrace the process could use it successfully.
> 
> Please suggest better idea if you have other idea about the permission.
> 
> * from v1r1
>   * use ptrace capability - surenb, dancol
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
>  include/linux/proc_fs.h                |  1 +
>  include/linux/syscalls.h               |  2 ++
>  include/uapi/asm-generic/unistd.h      |  2 ++
>  kernel/signal.c                        |  2 +-
>  kernel/sys_ni.c                        |  1 +
>  mm/madvise.c                           | 45 ++++++++++++++++++++++++++
>  8 files changed, 54 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 4cd5f982b1e5..5b9dd55d6b57 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -438,3 +438,4 @@
>  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
>  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
>  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> +428	i386	process_madvise		sys_process_madvise		__ia32_sys_process_madvise
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 64ca0d06259a..0e5ee78161c9 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -355,6 +355,7 @@
>  425	common	io_uring_setup		__x64_sys_io_uring_setup
>  426	common	io_uring_enter		__x64_sys_io_uring_enter
>  427	common	io_uring_register	__x64_sys_io_uring_register
> +428	common	process_madvise		__x64_sys_process_madvise
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 52a283ba0465..f8545d7c5218 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -122,6 +122,7 @@ static inline struct pid *tgid_pidfd_to_pid(const struct file *file)
>  
>  #endif /* CONFIG_PROC_FS */
>  
> +extern struct pid *pidfd_to_pid(const struct file *file);
>  struct net;
>  
>  static inline struct proc_dir_entry *proc_net_mkdir(
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index e2870fe1be5b..21c6c9a62006 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -872,6 +872,8 @@ asmlinkage long sys_munlockall(void);
>  asmlinkage long sys_mincore(unsigned long start, size_t len,
>  				unsigned char __user * vec);
>  asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
> +asmlinkage long sys_process_madvise(int pid_fd, unsigned long start,
> +				size_t len, int behavior);
>  asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
>  			unsigned long prot, unsigned long pgoff,
>  			unsigned long flags);
> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> index dee7292e1df6..7ee82ce04620 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
>  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
>  #define __NR_io_uring_register 427
>  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> +#define __NR_process_madvise 428
> +__SYSCALL(__NR_process_madvise, sys_process_madvise)
>  
>  #undef __NR_syscalls
>  #define __NR_syscalls 428
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 1c86b78a7597..04e75daab1f8 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -3620,7 +3620,7 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
>  	return copy_siginfo_from_user(kinfo, info);
>  }
>  
> -static struct pid *pidfd_to_pid(const struct file *file)
> +struct pid *pidfd_to_pid(const struct file *file)
>  {
>  	if (file->f_op == &pidfd_fops)
>  		return file->private_data;
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 4d9ae5ea6caf..5277421795ab 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -278,6 +278,7 @@ COND_SYSCALL(mlockall);
>  COND_SYSCALL(munlockall);
>  COND_SYSCALL(mincore);
>  COND_SYSCALL(madvise);
> +COND_SYSCALL(process_madvise);
>  COND_SYSCALL(remap_file_pages);
>  COND_SYSCALL(mbind);
>  COND_SYSCALL_COMPAT(mbind);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 119e82e1f065..af02aa17e5c1 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -9,6 +9,7 @@
>  #include <linux/mman.h>
>  #include <linux/pagemap.h>
>  #include <linux/page_idle.h>
> +#include <linux/proc_fs.h>
>  #include <linux/syscalls.h>
>  #include <linux/mempolicy.h>
>  #include <linux/page-isolation.h>
> @@ -16,6 +17,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/falloc.h>
>  #include <linux/sched.h>
> +#include <linux/sched/mm.h>
>  #include <linux/ksm.h>
>  #include <linux/fs.h>
>  #include <linux/file.h>
> @@ -1140,3 +1142,46 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  {
>  	return madvise_core(current, start, len_in, behavior);
>  }
> +
> +SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> +		size_t, len_in, int, behavior)
> +{
> +	int ret;
> +	struct fd f;
> +	struct pid *pid;
> +	struct task_struct *tsk;
> +	struct mm_struct *mm;
> +
> +	f = fdget(pidfd);
> +	if (!f.file)
> +		return -EBADF;
> +
> +	pid = pidfd_to_pid(f.file);

pidfd_to_pid() should not be directly exported since this allows
/proc/<pid> fds to be used too. That's something we won't be going
forward with. All new syscalls should only allow to operate on pidfds
created through CLONE_PIDFD or pidfd_open() (cf. [1]).

So e.g. please export a simple helper like

struct pid *pidfd_to_pid(const struct file *file)
{
        if (file->f_op == &pidfd_fops)
                return file->private_data;

        return NULL;
}

turning the old pidfd_to_pid() into something like:

static struct pid *__fd_to_pid(const struct file *file)
{
        struct pid *pid;

        pid = pidfd_to_pid(file);
        if (pid)
                return pid;

        return tgid_pidfd_to_pid(file);
}

All new syscalls should only be using anon inode pidfds since they can
actually have a clean security model built around them in the future.
Note, pidfd_open() will be sent out together with making pidfds pollable
for the 5.3 merge window.

[1]: https://lore.kernel.org/lkml/20190520155630.21684-1-christian@brauner.io/

Thanks!
Christian

