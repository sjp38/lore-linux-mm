Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B439C072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:18:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03EF120862
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:18:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03EF120862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79FF36B0005; Mon, 20 May 2019 05:18:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 750DC6B0006; Mon, 20 May 2019 05:18:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F0C36B0007; Mon, 20 May 2019 05:18:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9166B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:18:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d15so24237080edm.7
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:18:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+blINTze9+RYdMOQcPpOBYvgU9ci/l+RzsZOcZjhJUM=;
        b=QzYEi/rsxMKn6Eb4MYft3LJAmv757KeNmGeDkjs2ULM72gFzvZZd1BShCiUXxNVoNG
         nHqXNz2XHgM/DdKT7L97jjCxdLDd9x2yTDgYOjRAnNKN7i7wfmRljtYarwB5HzTufVt+
         VFI3/RTLsUiACJjBuxUF8f7tbdqaQkpyUjdTndlObRUFdXESaBa5wSxNB+iz+2Q0X7CZ
         UscYEkzAQy96yQdkqyRDaTiN6Na/J0Mpxpk1n4VNcN5SDfvjuHOg7uKghDRzJ0y+PKH3
         Gje/7uW4CvvI/UlBTm5gIrCAA2ie6oe809zcq/ZK/kQLMiHyUUpAJTFyN0FSvBgc83RJ
         7YYw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU//03RgtseyV8vPIr9zAYSQ+/iUG5u2YepQC78ZshaGW6IiyIU
	K9MEGA/qcdGarUdCzLuVHW6bjAcEGOLByO+f5emDi3WprK62YMkcHnb0x1ZbiwX68ut4L598jcV
	WcwrYEV8NfLwIrW6I9V7IqT/TpcirZHawdL3OcXOxtmwIHkaFa2XRx/ACR0dKz40=
X-Received: by 2002:a17:906:944a:: with SMTP id z10mr39304977ejx.159.1558343912470;
        Mon, 20 May 2019 02:18:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5JKbzDQo2O4JiRxFBucAmg+pdIn6FFJ+WSn9kSVUogtIotgmyiTL4NHTSJ4q9XJcMnMsG
X-Received: by 2002:a17:906:944a:: with SMTP id z10mr39304894ejx.159.1558343911261;
        Mon, 20 May 2019 02:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558343911; cv=none;
        d=google.com; s=arc-20160816;
        b=b+KAKcWhtf0MxAuonZ8niXq6fFPWqrNYsMNYY7mW4qj6kews6VKj/gbxlwqYXjz8N2
         WXVIM8ilySerMPUbjY8ELTfW29d7uBk9Omgsly5gs32wMidemVsNUNekPa0vypCyRb7W
         A8YZaxNhRnbD0/rWpxcifl8d1j53f0zYFYB6qF5/kqQ995jnnCTmwLByqnecfN7Co1Jn
         IOIb/d70nWPe29uWggWL0V/R6bxDe65grLC6NWc7F4d3Hjp05aVPLP4AvaYybD35/iS1
         llpLY/d7tgt07iCRpOkxRKIiizTmoLX1yCojaUqIf8o76oKRmWMZ5iTJrCQCRQs6FMpx
         MKzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+blINTze9+RYdMOQcPpOBYvgU9ci/l+RzsZOcZjhJUM=;
        b=F00zJHafsv7tp8mCyZ95gn4Qmf5R130Hg7xk9zdFqd+tBFtrfpLP/d5q6VSakNyVv3
         fzPiKYe+v4RQGyjAn2xfmHT//a7aBR0YWo1ABpElzKjZTuais4GvP7xx6sKi7myBqT1Y
         dhxJvU0jADNrNvRl4mGU4RrqkCFW39B2So0PkZolGOFChyEx8qKk2v2hXEdIZe108RHB
         gugVembtry+wVFWxIFgNa8/WIsUqu8E+uptbVJugtCWLNtXa4uuMtztgAmvVPRBZCRkM
         K2f8xXo5hdP+P0FTiEcogs+vMBZTC3BES4oPa25TlGJuwXW8sG6yrnLHVxalWEIFy79m
         EDYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w22si131863eju.323.2019.05.20.02.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:18:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7089AAE4B;
	Mon, 20 May 2019 09:18:30 +0000 (UTC)
Date: Mon, 20 May 2019 11:18:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190520091829.GY6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-6-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api]

On Mon 20-05-19 12:52:52, Minchan Kim wrote:
> There is some usecase that centralized userspace daemon want to give
> a memory hint like MADV_[COOL|COLD] to other process. Android's
> ActivityManagerService is one of them.
> 
> It's similar in spirit to madvise(MADV_WONTNEED), but the information
> required to make the reclaim decision is not known to the app. Instead,
> it is known to the centralized userspace daemon(ActivityManagerService),
> and that daemon must be able to initiate reclaim on its own without
> any app involvement.

Could you expand some more about how this all works? How does the
centralized daemon track respective ranges? How does it synchronize
against parallel modification of the address space etc.

> To solve the issue, this patch introduces new syscall process_madvise(2)
> which works based on pidfd so it could give a hint to the exeternal
> process.
> 
> int process_madvise(int pidfd, void *addr, size_t length, int advise);

OK, this makes some sense from the API point of view. When we have
discussed that at LSFMM I was contemplating about something like that
except the fd would be a VMA fd rather than the process. We could extend
and reuse /proc/<pid>/map_files interface which doesn't support the
anonymous memory right now. 

I am not saying this would be a better interface but I wanted to mention
it here for a further discussion. One slight advantage would be that
you know the exact object that you are operating on because you have a
fd for the VMA and we would have a more straightforward way to reject
operation if the underlying object has changed (e.g. unmapped and reused
for a different mapping).

> All advises madvise provides can be supported in process_madvise, too.
> Since it could affect other process's address range, only privileged
> process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> gives it the right to ptrrace the process could use it successfully.

proc_mem_open model we use for accessing address space via proc sounds
like a good mode. You are doing something similar.

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
> +	if (IS_ERR(pid)) {
> +		ret = PTR_ERR(pid);
> +		goto err;
> +	}
> +
> +	ret = -EINVAL;
> +	rcu_read_lock();
> +	tsk = pid_task(pid, PIDTYPE_PID);
> +	if (!tsk) {
> +		rcu_read_unlock();
> +		goto err;
> +	}
> +	get_task_struct(tsk);
> +	rcu_read_unlock();
> +	mm = mm_access(tsk, PTRACE_MODE_ATTACH_REALCREDS);
> +	if (!mm || IS_ERR(mm)) {
> +		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
> +		if (ret == -EACCES)
> +			ret = -EPERM;
> +		goto err;
> +	}
> +	ret = madvise_core(tsk, start, len_in, behavior);
> +	mmput(mm);
> +	put_task_struct(tsk);
> +err:
> +	fdput(f);
> +	return ret;
> +}
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

-- 
Michal Hocko
SUSE Labs

