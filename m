Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30DF1C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB8FB217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P/+Rf3vL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB8FB217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 599056B0003; Tue, 21 May 2019 07:35:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54A4A6B0005; Tue, 21 May 2019 07:35:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C5686B0006; Tue, 21 May 2019 07:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F27836B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:35:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e20so12157293pfn.8
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:35:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y2h8yY1nmbpXT69GC2+fAFJNTD2F5yTSQK2OB0WJFdg=;
        b=n3K/u/fg1hgHKhr2swCn5oVqaj9rGXjqqxqn+/MBvQanXATUu6BpMn3ppuMG+a4QoQ
         I8sgPdQt0P7e3YU7of/f4cNK2St1eEbyk00A0gYPNGKULx84jdwPF3Qdn3mE0P/L0+UP
         cOj/A2qI2Z6YfBdcSPILYjXRndJh62DjZJ87CpFjpiMHCk41A54m4JtvyAoeWezVb6un
         5vdY1jLak33S2GGG+HtFvSdbicu9fYALApv331l/yDMn8O/aJmeC30hPc4l3ulPMtwqF
         w3knZanVLkMdw8iPQ21kgIIxJWIsGOfFUTq90FcjmxErmNAnKkjfuVA+DVY2SfQkePhF
         PvNg==
X-Gm-Message-State: APjAAAX/H8mhAFxXMhhUHY0L7wsARcG8m6aqRhN1867RtBDD9T4B0qo+
	BERckSxGDfGz9C0m8S8zC2cnTlVMNXjp9ufO5oLRsK+w7XbCeD4Qnaf3g/GZI/IXi56olYbPJf3
	XQKuamElZkQNvl1817BE4++/fSRB+S6e/hOfOPE/4MWhaNquBcAiuGK7fcq3u0aY=
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr86981748pfe.242.1558438518616;
        Tue, 21 May 2019 04:35:18 -0700 (PDT)
X-Received: by 2002:a62:1ec5:: with SMTP id e188mr86981659pfe.242.1558438517674;
        Tue, 21 May 2019 04:35:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558438517; cv=none;
        d=google.com; s=arc-20160816;
        b=obGfDdT9uWadPTv2d/Gp3rDZ0SZyLFTC0ONsDjb+S4axCPeZgblO2vOWPxqw3Ur/LH
         bI6Y9aN7QZQ5pcce7RNqizc/ecKondHADS9K4X495oFWH7PTY19/oxpP4aZA033JKGr4
         CCHDJXM5CJNTxJDTXGzmE82ZZRI0L2+XAIXVDitLMm2iPWJpAo9oqNolN3//df//BF4y
         ze6HFg+jyLZ6/ENVGSAst/pMjl9KRr8ShSjIhuSZuu7ZYRFdgHx31NhD1J26BWu8cVbr
         sQwl1Upzx4WnGBb4abZzVmQNAREDUbjVrLDuPZ3wqJH01g0lXozOIudwEDHcv/GLBNuG
         Lmxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=y2h8yY1nmbpXT69GC2+fAFJNTD2F5yTSQK2OB0WJFdg=;
        b=SzMmMuhvdh1bJdFYbsBtqwilhQuybbIFR2hSU1P+lSLqD4E1HXzbn4vCwuF1TZ+NCU
         bvqSQyZUP8GaYvmlDuZjAqxoIJn5+AEPm0WH0yFgDRvs/kxcLSk9e9+LXXAW6uOARqmN
         nlGT7EAOJvPUMVqPmIRb+vwX+ApodCJKx52joLQOR2er4DQlsDTkfFIioB+x0lghbqTQ
         7KaqXdKLjc9rGWBYUEmKJRRjddbWCqF3jCe+HSVjxqYV/PEAbGyowKl+0WlXly9EbayV
         7IkUxh0dO1OvkF1dYUPCicZ97mHfqNNZNjzVy28dLixgFXgj6rPnLqiwSLz0oXutxosr
         9BgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="P/+Rf3vL";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor20586070pgp.16.2019.05.21.04.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="P/+Rf3vL";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=y2h8yY1nmbpXT69GC2+fAFJNTD2F5yTSQK2OB0WJFdg=;
        b=P/+Rf3vLEFCJ9GGi+UiBExXqhQ3XV3vz+RT46PUaPANKnXWspoI2jdiOm0eB/SDebN
         4SUg/3Z34WR+B+7LZbwJuvsWjT+i/FtsP+sywXUHxaBysgBjhHDwScpwj1/76Q9STasn
         xM67JkPb+0lckKUhz+xmSVpFCLtyitFjkkxqmT7T+OkFHvHB1ETmf7RG/Mf2fSvQOwXQ
         CUHTODx09k3UpEoSbhweZR4LuuW4LQY3KAziJqwr1S5EFqhB4eaXWb/RlJTCj4b+4lZ8
         aG5V/xKICRseiGomI7b9+g+yKS7gaqgHnnNmBYkXP+oS2aRWuCbuAAVQ/3TYZw+3YJKa
         P5yw==
X-Google-Smtp-Source: APXvYqyxR8EXt9zlV0d3tT3FEX90fHbIHPdhfJMjAqfANtUmS54/DDpKsjUgcdyor60Y9SM0FlNK0A==
X-Received: by 2002:a63:18e:: with SMTP id 136mr52432280pgb.277.1558438517231;
        Tue, 21 May 2019 04:35:17 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a8sm11389752pfk.14.2019.05.21.04.35.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:35:16 -0700 (PDT)
Date: Tue, 21 May 2019 20:35:10 +0900
From: Minchan Kim <minchan@kernel.org>
To: Christian Brauner <christian@brauner.io>
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
Message-ID: <20190521113510.GI219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521090058.mdx4qecmdbum45t2@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521090058.mdx4qecmdbum45t2@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:01:01AM +0200, Christian Brauner wrote:
> Cc: Jann and Oleg too
> 
> On Mon, May 20, 2019 at 12:52:52PM +0900, Minchan Kim wrote:
> > There is some usecase that centralized userspace daemon want to give
> > a memory hint like MADV_[COOL|COLD] to other process. Android's
> > ActivityManagerService is one of them.
> > 
> > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > required to make the reclaim decision is not known to the app. Instead,
> > it is known to the centralized userspace daemon(ActivityManagerService),
> > and that daemon must be able to initiate reclaim on its own without
> > any app involvement.
> > 
> > To solve the issue, this patch introduces new syscall process_madvise(2)
> > which works based on pidfd so it could give a hint to the exeternal
> > process.
> > 
> > int process_madvise(int pidfd, void *addr, size_t length, int advise);
> > 
> > All advises madvise provides can be supported in process_madvise, too.
> > Since it could affect other process's address range, only privileged
> > process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> > gives it the right to ptrrace the process could use it successfully.
> > 
> > Please suggest better idea if you have other idea about the permission.
> > 
> > * from v1r1
> >   * use ptrace capability - surenb, dancol
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
> >  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
> >  include/linux/proc_fs.h                |  1 +
> >  include/linux/syscalls.h               |  2 ++
> >  include/uapi/asm-generic/unistd.h      |  2 ++
> >  kernel/signal.c                        |  2 +-
> >  kernel/sys_ni.c                        |  1 +
> >  mm/madvise.c                           | 45 ++++++++++++++++++++++++++
> >  8 files changed, 54 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> > index 4cd5f982b1e5..5b9dd55d6b57 100644
> > --- a/arch/x86/entry/syscalls/syscall_32.tbl
> > +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> > @@ -438,3 +438,4 @@
> >  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
> >  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
> >  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> > +428	i386	process_madvise		sys_process_madvise		__ia32_sys_process_madvise
> > diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> > index 64ca0d06259a..0e5ee78161c9 100644
> > --- a/arch/x86/entry/syscalls/syscall_64.tbl
> > +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> > @@ -355,6 +355,7 @@
> >  425	common	io_uring_setup		__x64_sys_io_uring_setup
> >  426	common	io_uring_enter		__x64_sys_io_uring_enter
> >  427	common	io_uring_register	__x64_sys_io_uring_register
> > +428	common	process_madvise		__x64_sys_process_madvise
> >  
> >  #
> >  # x32-specific system call numbers start at 512 to avoid cache impact
> > diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> > index 52a283ba0465..f8545d7c5218 100644
> > --- a/include/linux/proc_fs.h
> > +++ b/include/linux/proc_fs.h
> > @@ -122,6 +122,7 @@ static inline struct pid *tgid_pidfd_to_pid(const struct file *file)
> >  
> >  #endif /* CONFIG_PROC_FS */
> >  
> > +extern struct pid *pidfd_to_pid(const struct file *file);
> >  struct net;
> >  
> >  static inline struct proc_dir_entry *proc_net_mkdir(
> > diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> > index e2870fe1be5b..21c6c9a62006 100644
> > --- a/include/linux/syscalls.h
> > +++ b/include/linux/syscalls.h
> > @@ -872,6 +872,8 @@ asmlinkage long sys_munlockall(void);
> >  asmlinkage long sys_mincore(unsigned long start, size_t len,
> >  				unsigned char __user * vec);
> >  asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
> > +asmlinkage long sys_process_madvise(int pid_fd, unsigned long start,
> > +				size_t len, int behavior);
> >  asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
> >  			unsigned long prot, unsigned long pgoff,
> >  			unsigned long flags);
> > diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> > index dee7292e1df6..7ee82ce04620 100644
> > --- a/include/uapi/asm-generic/unistd.h
> > +++ b/include/uapi/asm-generic/unistd.h
> > @@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
> >  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
> >  #define __NR_io_uring_register 427
> >  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> > +#define __NR_process_madvise 428
> > +__SYSCALL(__NR_process_madvise, sys_process_madvise)
> >  
> >  #undef __NR_syscalls
> >  #define __NR_syscalls 428
> > diff --git a/kernel/signal.c b/kernel/signal.c
> > index 1c86b78a7597..04e75daab1f8 100644
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -3620,7 +3620,7 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
> >  	return copy_siginfo_from_user(kinfo, info);
> >  }
> >  
> > -static struct pid *pidfd_to_pid(const struct file *file)
> > +struct pid *pidfd_to_pid(const struct file *file)
> >  {
> >  	if (file->f_op == &pidfd_fops)
> >  		return file->private_data;
> > diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> > index 4d9ae5ea6caf..5277421795ab 100644
> > --- a/kernel/sys_ni.c
> > +++ b/kernel/sys_ni.c
> > @@ -278,6 +278,7 @@ COND_SYSCALL(mlockall);
> >  COND_SYSCALL(munlockall);
> >  COND_SYSCALL(mincore);
> >  COND_SYSCALL(madvise);
> > +COND_SYSCALL(process_madvise);
> >  COND_SYSCALL(remap_file_pages);
> >  COND_SYSCALL(mbind);
> >  COND_SYSCALL_COMPAT(mbind);
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 119e82e1f065..af02aa17e5c1 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -9,6 +9,7 @@
> >  #include <linux/mman.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/page_idle.h>
> > +#include <linux/proc_fs.h>
> >  #include <linux/syscalls.h>
> >  #include <linux/mempolicy.h>
> >  #include <linux/page-isolation.h>
> > @@ -16,6 +17,7 @@
> >  #include <linux/hugetlb.h>
> >  #include <linux/falloc.h>
> >  #include <linux/sched.h>
> > +#include <linux/sched/mm.h>
> >  #include <linux/ksm.h>
> >  #include <linux/fs.h>
> >  #include <linux/file.h>
> > @@ -1140,3 +1142,46 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> >  {
> >  	return madvise_core(current, start, len_in, behavior);
> >  }
> > +
> > +SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> > +		size_t, len_in, int, behavior)
> > +{
> > +	int ret;
> > +	struct fd f;
> > +	struct pid *pid;
> > +	struct task_struct *tsk;
> > +	struct mm_struct *mm;
> > +
> > +	f = fdget(pidfd);
> > +	if (!f.file)
> > +		return -EBADF;
> > +
> > +	pid = pidfd_to_pid(f.file);
> 
> pidfd_to_pid() should not be directly exported since this allows
> /proc/<pid> fds to be used too. That's something we won't be going
> forward with. All new syscalls should only allow to operate on pidfds
> created through CLONE_PIDFD or pidfd_open() (cf. [1]).

Thanks for the information.

> 
> So e.g. please export a simple helper like
> 
> struct pid *pidfd_to_pid(const struct file *file)
> {
>         if (file->f_op == &pidfd_fops)
>                 return file->private_data;
> 
>         return NULL;
> }
> 
> turning the old pidfd_to_pid() into something like:
> 
> static struct pid *__fd_to_pid(const struct file *file)
> {
>         struct pid *pid;
> 
>         pid = pidfd_to_pid(file);
>         if (pid)
>                 return pid;
> 
>         return tgid_pidfd_to_pid(file);
> }

So, I want to clarify what you suggest here.

1. modify pidfd_to_pid as what you described above(ie, return NULL
instead of returning tgid_pidfd_to_pid(file);
2. never export pidfd_to_pid
3. create wrapper __fd_to_pid which calls pidfd_to_pid internally
4. export __fd_to_pid and use it

Correct?

Thanks.

> 
> All new syscalls should only be using anon inode pidfds since they can
> actually have a clean security model built around them in the future.
> Note, pidfd_open() will be sent out together with making pidfds pollable
> for the 5.3 merge window.
> 
> [1]: https://lore.kernel.org/lkml/20190520155630.21684-1-christian@brauner.io/
> 
> Thanks!
> Christian

