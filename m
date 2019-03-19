Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2487BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:26:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B89812146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:26:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="A2gNd4cL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B89812146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674BE6B0005; Tue, 19 Mar 2019 18:26:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 621F96B0006; Tue, 19 Mar 2019 18:26:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 511A26B0007; Tue, 19 Mar 2019 18:26:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2A16B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:26:56 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k29so19190974qkl.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:26:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HzoYzrsLg5B5gLgKw7GHM9JbUp9EVXgL6mdkso+jioQ=;
        b=LXBnjdFPQ8n+jcrVqbmqynwdWMv/ZO+N7YLN/GHCCcL+ZRamk8xe0wP6acr3B1E9fK
         E2yrqVKMYGsD2FT4h7iV32cnAEU9o0VfQVhA1fOb4Ppwp6upaQnMLN/92TG0BRQQjIFg
         VJJkA8P2pbbu6o+NXozkbOiGgsahHy1IQV5+cx7sEcfb50lWmfBJl6cm1MqxgSaEBrup
         i4TGUcBAqzk80dxFdqTQlDvLCXTQJy41d0zxXh3x6FUneD+l3/7D5/Y3Qxwb/1QzXZFr
         8Sb4PCHeNZSGED0kV7M8Om95k7bOEy4ocRiObO2QArGB378VNNLR7C0c4uwHjT3KsdKa
         WPTA==
X-Gm-Message-State: APjAAAUz4fhhQ4XtDkAEDd68rEZr/IraZSl/Rfgul9eYMcrL9e1Ry6Wy
	XarORdWUB/IoLm0tZkSIOPf3EOHNB5qVv0nsreTEFRVeyjZAb/uCCKSRv3sDCSBqcPUswN5vjdJ
	CpFzJk5c4Q550lmuNp2yfJ9fHy6nNwIBQMZ01UnRXPlTEAuZwK2RSJLE9/QuaYGHCDA==
X-Received: by 2002:ac8:28d0:: with SMTP id j16mr4521244qtj.15.1553034415895;
        Tue, 19 Mar 2019 15:26:55 -0700 (PDT)
X-Received: by 2002:ac8:28d0:: with SMTP id j16mr4521184qtj.15.1553034415036;
        Tue, 19 Mar 2019 15:26:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553034415; cv=none;
        d=google.com; s=arc-20160816;
        b=L/EVMRyDIotb+NNhHVSh+WNXMIfgMSQWG1loPT9vB+0sWlJYaxqhRYd24c6DG78n+m
         zbpIlEtoCQASrCHAYjLwG374/GmrqxS0ozUHMeGCGZn2DqxPNB/WIM6OhHikPl1kvFrg
         i+KWbCZAIPeZZHQqJk4mGAxoH9+ODAlyuXM+G3J9RojHN6ZXNPdgsu07PcpqVaIJMgF7
         LgYhyr9jj1EOQ7DbjSPUdB+L8Pg52TLgcZgs15TG7WF0HSSWsMQ3dp0zzLNjutTMpXPo
         YnFboyOpKobdz9gO3o6rzeB8bxnfu0qrjGhWRlFG8m3B+ciPfib3XtBEwsusPVzsuEl5
         WsBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HzoYzrsLg5B5gLgKw7GHM9JbUp9EVXgL6mdkso+jioQ=;
        b=K6XY4Bu/jrDx2tVjDzpCYbAmbLyvBDFDpjmiRZbgZVq+CN0AsaD/8KLCyuUmDJpA6/
         1/vZnM3p7Dr+wWgFB+R4ocoomwAvmfuY1gpzGDY0IpcdBG/QlrRnd5vvWTlfYWB49sql
         qjHiT9XzvMKBD2Pxzi9gab/GO0LsqA873HWDxE7/tVgG/ed0yNmwX7YJJxx41aXR2Jqi
         7hPK/gs992RQnorW0d7DFXR9DlOkwtoAsFUr3Ot/555Ebsv6iYgR2rxfe1SYvk6QldTD
         SCHvDVceeunYvlxmTsDXr16q2XpPzhxbmpXKah55t/C0gW8NGuplMS8yOpomSo7IehnM
         ZE3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=A2gNd4cL;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y51sor108391qvc.23.2019.03.19.15.26.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 15:26:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=A2gNd4cL;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HzoYzrsLg5B5gLgKw7GHM9JbUp9EVXgL6mdkso+jioQ=;
        b=A2gNd4cLJocGajWw4GyY+/GHddeivArYInHbh3QIoc3viu0SEoXje37+SKbckdtf15
         GH8GRMiNxYwzTx7YQR7rCXuC140wfyc02yiDTW4dhU2FtrSI0fmZuXJqym4oiEFQPsJo
         HKglpYCUHvJtDZApXm7JFkx2GI3MpxWI8cVhA=
X-Google-Smtp-Source: APXvYqzr1avXNk2G8iCIYQjiNez5QEKz1m/olPEdcCKuQ42svHTeNzHGPGAsJX7yX46WpKAuKK1WRA==
X-Received: by 2002:a0c:d07b:: with SMTP id d56mr3903106qvh.89.1553034414443;
        Tue, 19 Mar 2019 15:26:54 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id n24sm159631qtc.21.2019.03.19.15.26.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 15:26:53 -0700 (PDT)
Date: Tue, 19 Mar 2019 18:26:52 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
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
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>, keescook@chromium.org
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190319222652.GA105485@google.com>
References: <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319221415.baov7x6zoz7hvsno@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 11:14:17PM +0100, Christian Brauner wrote:
[snip] 
> > 
> > ---8<-----------------------
> > 
> > From: Joel Fernandes <joelaf@google.com>
> > Subject: [PATCH] Partial skeleton prototype of pidfd_wait frontend
> > 
> > Signed-off-by: Joel Fernandes <joelaf@google.com>
> > ---
> >  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
> >  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
> >  include/linux/syscalls.h               |  1 +
> >  include/uapi/asm-generic/unistd.h      |  4 +-
> >  kernel/signal.c                        | 62 ++++++++++++++++++++++++++
> >  kernel/sys_ni.c                        |  3 ++
> >  6 files changed, 71 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> > index 1f9607ed087c..2a63f1896b63 100644
> > --- a/arch/x86/entry/syscalls/syscall_32.tbl
> > +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> > @@ -433,3 +433,4 @@
> >  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
> >  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
> >  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> > +428	i386	pidfd_wait		sys_pidfd_wait			__ia32_sys_pidfd_wait
> > diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> > index 92ee0b4378d4..cf2e08a8053b 100644
> > --- a/arch/x86/entry/syscalls/syscall_64.tbl
> > +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> > @@ -349,6 +349,7 @@
> >  425	common	io_uring_setup		__x64_sys_io_uring_setup
> >  426	common	io_uring_enter		__x64_sys_io_uring_enter
> >  427	common	io_uring_register	__x64_sys_io_uring_register
> > +428	common	pidfd_wait		__x64_sys_pidfd_wait
> >  
> >  #
> >  # x32-specific system call numbers start at 512 to avoid cache impact
> > diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> > index e446806a561f..62160970ed3f 100644
> > --- a/include/linux/syscalls.h
> > +++ b/include/linux/syscalls.h
> > @@ -988,6 +988,7 @@ asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
> >  asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
> >  				       siginfo_t __user *info,
> >  				       unsigned int flags);
> > +asmlinkage long sys_pidfd_wait(int pidfd);
> >  
> >  /*
> >   * Architecture-specific system calls
> > diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> > index dee7292e1df6..137aa8662230 100644
> > --- a/include/uapi/asm-generic/unistd.h
> > +++ b/include/uapi/asm-generic/unistd.h
> > @@ -832,9 +832,11 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
> >  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
> >  #define __NR_io_uring_register 427
> >  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> > +#define __NR_pidfd_wait 428
> > +__SYSCALL(__NR_pidfd_wait, sys_pidfd_wait)
> >  
> >  #undef __NR_syscalls
> > -#define __NR_syscalls 428
> > +#define __NR_syscalls 429
> >  
> >  /*
> >   * 32 bit systems traditionally used different
> > diff --git a/kernel/signal.c b/kernel/signal.c
> > index b7953934aa99..ebb550b87044 100644
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -3550,6 +3550,68 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
> >  	return copy_siginfo_from_user(kinfo, info);
> >  }
> >  
> > +static ssize_t pidfd_wait_read_iter(struct kiocb *iocb, struct iov_iter *to)
> > +{
> > +	/*
> > +	 * This is just a test string, it will contain the actual
> > +	 * status of the pidfd in the future.
> > +	 */
> > +	char buf[] = "status";
> > +
> > +	return copy_to_iter(buf, strlen(buf)+1, to);
> > +}
> > +
> > +static const struct file_operations pidfd_wait_file_ops = {
> > +	.read_iter	= pidfd_wait_read_iter,
> > +};
> > +
> > +static struct inode *pidfd_wait_get_inode(struct super_block *sb)
> > +{
> > +	struct inode *inode = new_inode(sb);
> > +
> > +	inode->i_ino = get_next_ino();
> > +	inode_init_owner(inode, NULL, S_IFREG);
> > +
> > +	inode->i_op		= &simple_dir_inode_operations;
> > +	inode->i_fop		= &pidfd_wait_file_ops;
> > +
> > +	return inode;
> > +}
> > +
> > +SYSCALL_DEFINE1(pidfd_wait, int, pidfd)
> > +{
> > +	struct fd f;
> > +	struct inode *inode;
> > +	struct file *file;
> > +	int new_fd;
> > +	struct pid_namespace *pid_ns;
> > +	struct super_block *sb;
> > +	struct vfsmount *mnt;
> > +
> > +	f = fdget_raw(pidfd);
> > +	if (!f.file)
> > +		return -EBADF;
> > +
> > +	sb = file_inode(f.file)->i_sb;
> > +	pid_ns = sb->s_fs_info;
> > +
> > +	inode = pidfd_wait_get_inode(sb);
> > +
> > +	mnt = pid_ns->proc_mnt;
> > +
> > +	file = alloc_file_pseudo(inode, mnt, "pidfd_wait", O_RDONLY,
> > +			&pidfd_wait_file_ops);
> 
> So I dislike the idea of allocating new inodes from the procfs super
> block. I would like to avoid pinning the whole pidfd concept exclusively
> to proc. The idea is that the pidfd API will be useable through procfs
> via open("/proc/<pid>") because that is what users expect and really
> wanted to have for a long time. So it makes sense to have this working.
> But it should really be useable without it. That's why translate_pid()
> and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> api is "complete" you should be able to set CONFIG_PROCFS=N - even
> though that's crazy - and still be able to use pidfds. This is also a
> point akpm asked about when I did the pidfd_send_signal work.

Oh, ok. Somehow 'proc' and 'pid' sound very similar in terminology so
naturally I felt the proc fs superblock would be a fit, but I see your point.

> So instead of going throught proc we should probably do what David has
> been doing in the mount API and come to rely on anone_inode. So
> something like:
> 
> fd = anon_inode_getfd("pidfd", &pidfd_fops, file_priv_data, flags);
> 
> and stash information such as pid namespace etc. in a pidfd struct or
> something that we then can stash file->private_data of the new file.
> This also lets us avoid all this open coding done here.
> Another advantage is that anon_inodes is its own kernel-internal
> filesystem.

Thanks for the suggestion! Agreed this is better and will do it this way then. 

thanks,

 - Joel

