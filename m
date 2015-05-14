Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id E56986B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 00:19:52 -0400 (EDT)
Received: by qkgy4 with SMTP id y4so42609166qkg.2
        for <linux-mm@kvack.org>; Wed, 13 May 2015 21:19:51 -0700 (PDT)
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [2001:4b98:c:538::197])
        by mx.google.com with ESMTPS id l92si1774484qgf.83.2015.05.13.21.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 13 May 2015 21:19:51 -0700 (PDT)
Date: Wed, 13 May 2015 21:19:41 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [mmotm:master 187/255] arch/s390/kernel/compat_wrapper.c:205:7:
 error: conflicting types for 'sys_clone'
Message-ID: <20150514041941.GA26568@x>
References: <201505141011.OB8iS79o%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505141011.OB8iS79o%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, May 14, 2015 at 10:22:13AM +0800, kbuild test robot wrote:
> >> arch/s390/kernel/compat_wrapper.c:205:7: error: conflicting types for 'sys_clone'
>     COMPAT_SYSCALL_WRAP5(clone, unsigned long, newsp, unsigned long, clone_flags, int __user *, parent_tidptr, int __user *, child_tidptr, int, tls_val);
>           ^
>    In file included from arch/s390/kernel/compat_wrapper.c:7:0:
>    include/linux/syscalls.h:837:7: note: previous declaration of 'sys_clone' was here
>     asmlinkage long sys_clone(unsigned long, unsigned long, int __user *,
>           ^
> 
> vim +/sys_clone +205 arch/s390/kernel/compat_wrapper.c
> 
> 7f6afe87a arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  199  COMPAT_SYSCALL_WRAP2(pipe2, int __user *, fildes, int, flags);
> 7f6afe87a arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  200  COMPAT_SYSCALL_WRAP3(dup3, unsigned int, oldfd, unsigned int, newfd, int, flags);
> 7f6afe87a arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  201  COMPAT_SYSCALL_WRAP1(epoll_create1, int, flags);
> 7f6afe87a arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  202  COMPAT_SYSCALL_WRAP2(tkill, int, pid, int, sig);
> 7f6afe87a arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  203  COMPAT_SYSCALL_WRAP3(tgkill, int, tgid, int, pid, int, sig);
> ab4f8bba1 arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  204  COMPAT_SYSCALL_WRAP5(perf_event_open, struct perf_event_attr __user *, attr_uptr, pid_t, pid, int, cpu, int, group_fd, unsigned long, flags);
> ab4f8bba1 arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01 @205  COMPAT_SYSCALL_WRAP5(clone, unsigned long, newsp, unsigned long, clone_flags, int __user *, parent_tidptr, int __user *, child_tidptr, int, tls_val);
> 00fcb1494 arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  206  COMPAT_SYSCALL_WRAP2(fanotify_init, unsigned int, flags, unsigned int, event_f_flags);
> 00fcb1494 arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  207  COMPAT_SYSCALL_WRAP4(prlimit64, pid_t, pid, unsigned int, resource, const struct rlimit64 __user *, new_rlim, struct rlimit64 __user *, old_rlim);
> 00fcb1494 arch/s390/kernel/compat_wrap.c Heiko Carstens 2014-03-01  208  COMPAT_SYSCALL_WRAP5(name_to_handle_at, int, dfd, const char __user *, name, struct file_handle __user *, handle, int __user *, mnt_id, int, flag);

I had no idea s390 had duplicate prototypes for syscalls.  That's all
kinds of awful.  Obvious incremental patch for -mm:

----- 8< -----
