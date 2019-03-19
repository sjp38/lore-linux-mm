Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C56E8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6223A2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:14:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="CNofqyQR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6223A2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D7A76B0005; Tue, 19 Mar 2019 18:14:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 060B66B0006; Tue, 19 Mar 2019 18:14:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1CAF6B0007; Tue, 19 Mar 2019 18:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3DD56B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:14:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so375764qtz.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:14:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Zgq2ou6kKDEdR81YiXwzSXiQtxUhVhVAeYwGNp74yyc=;
        b=Tp/oa5Xnl3aauKs/6UOzhLdmnzJfjqcdSIDqa1yTqhLGvpHEVF7nknm/7r1UvtGECt
         kQOKnqpM5pWUpEE8mqUqnTNn1V4t77JE5+qlVjC8ydoLPInIiS3K61kIwtolHrQtFjR2
         qTvONk10O7XIZCfwDjvshio6NwXe94diUaNoQKNDM4CYAMDhvonXhGdIFRo1iVyl1Wc2
         sTyNUXcGyBo42iC4XuXT0QzGPL2LxbNMEgNrfuzbWD+xYDDiEM8kcGa4N1x/8f57hHVo
         WicGRuFaQDoZA12y6Qgq12Kuvf8yzXX7XfxKdD6ZE5lVNBKd5LgtYGDiZuzTsx1RSESF
         l+3Q==
X-Gm-Message-State: APjAAAWagGq0ZRP5OkJ06YzIIQgrX0GmMMRmvhVFqUfhShWHgVo3O2wM
	pfgnWaztyD3ukOn1Vsnm0nziw+/TXC0wXFfVXCwe1cX21vfB1h3mXKgD3545K9NX6MaMkDUBLdb
	pzX86vmHVycAWVBR2zp0PPHxC6Dto17jrIecF+WKtcEk+ruZbS6BJWSwkqH8W6zN5/Q==
X-Received: by 2002:ae9:edc8:: with SMTP id c191mr3854701qkg.155.1553033663366;
        Tue, 19 Mar 2019 15:14:23 -0700 (PDT)
X-Received: by 2002:ae9:edc8:: with SMTP id c191mr3854624qkg.155.1553033662018;
        Tue, 19 Mar 2019 15:14:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553033662; cv=none;
        d=google.com; s=arc-20160816;
        b=ya+btyX5ofluNHV+00EOZ4JFni1zYoNQLOIMW183QhzEC0jmHFhdTG4afF3RZdMv0x
         oFE9FVzgPzypAZplQtn+WdeHCYeuL7hL6jgq21oaid1iaPM4Ob1AsdiNBfhjaqQQSqd6
         ovJ/Q7kXrHht8KlRxnwM/Ksw3LUb54OpwwRvdS4YsU40qVfB/TNv6H815OLSo4VgTyiJ
         vvT+348+hrGtvaPsJz8pvDyASgqy0d8dwmW/auph50E7t94TWtrRvhWVHgK6S03hGZn3
         ndXy+5gIJW7zcJrpJ7ah4p+GDIjyAbKUwEQ3GaKGuf5wZG1VJ8TsXnw0VyGJE+A/942M
         m1LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Zgq2ou6kKDEdR81YiXwzSXiQtxUhVhVAeYwGNp74yyc=;
        b=MWIA+mfBMKcyypVyd2NsLnNY/z/MPAr8xAazXXhNUkSVe1QItJC8QykQmZnIl53+jD
         05fOBlB6Njde7ezT+XL8aACk68pCRiEgDeWLK9y8ILcidlr6V9765FM2cBDpyACprG1e
         7rLiA6fseAkuA3sTUIjrB+TNnZFSm5dbzk/bhV6cq2aYx7p4+ZXeBJQZNa+GZSNSYVk6
         CXm0hfkLGhqjR9npPFhvBG/2U8me41811xdFUi18bETwLc1orNuztMHM93Sd6ync4uqJ
         KyQUtXmV1i5oR8oYim8rCIN5M2QWntNl+zxu/sqssdz6c3NIhQjhGrH4L4SBCHbyH2My
         A8ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=CNofqyQR;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor498070qtm.8.2019.03.19.15.14.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 15:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=CNofqyQR;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Zgq2ou6kKDEdR81YiXwzSXiQtxUhVhVAeYwGNp74yyc=;
        b=CNofqyQR09fs4ZqNo5ZpC9ByznbyLfCU1396+/T5vFexflRZZxUVzdDOxLiMhBNcJh
         DoD/tUvpXqKMqcJ8RkW9oP0Vaa4dsN9gR7KI9uqrl2S1WzillT+GCWo2JJSvYHPrIhGw
         TaZ7UnRJmXLOUwZa3QgaCXUla2s6wb+9zwdck82R5uTnW+vH6Xfvfo0NcUsiJf3NhcSN
         bp19dQSZq8fGkrFsqdnVbIe7tcksUn8CCf0qaDJopovsBSmhLqMM2KeKjxdDtgLVJw0q
         kOjB9x6rhUfQvudybBe4g59uclYO/cvp1vXBCHpVyt9WETyGCyS0eEkJlQ/SbIsJx32a
         oDvg==
X-Google-Smtp-Source: APXvYqxIg2NzKN9Ww8BQRAwM23pm6lHl3tOL60nhyqlPEuxV9GfjkibOA7mkBUweGT2TBfjsVzMk8Q==
X-Received: by 2002:aed:20e4:: with SMTP id 91mr3885805qtb.362.1553033661511;
        Tue, 19 Mar 2019 15:14:21 -0700 (PDT)
Received: from brauner.io ([38.127.230.10])
        by smtp.gmail.com with ESMTPSA id z140sm150198qka.81.2019.03.19.15.14.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 15:14:20 -0700 (PDT)
Date: Tue, 19 Mar 2019 23:14:17 +0100
From: Christian Brauner <christian@brauner.io>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
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
Message-ID: <20190319221415.baov7x6zoz7hvsno@brauner.io>
References: <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190318235052.GA65315@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 07:50:52PM -0400, Joel Fernandes wrote:
> On Mon, Mar 18, 2019 at 01:29:51AM +0100, Christian Brauner wrote:
> > On Sun, Mar 17, 2019 at 08:40:19AM -0700, Daniel Colascione wrote:
> > > On Sun, Mar 17, 2019 at 4:42 AM Christian Brauner <christian@brauner.io> wrote:
> > > >
> > > > On Sat, Mar 16, 2019 at 09:53:06PM -0400, Joel Fernandes wrote:
> > > > > On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> > > > > > On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> > > > > > >
> > > > > > > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > > > > > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > > > > >
> > > > > > > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > > > > > >
> > > > > > > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > > > > > > [..]
> > > > > > > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > > > > > > needed then, let me know if I missed something?
> > > > > > > > > > >
> > > > > > > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > > > > > > >
> > > > > > > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > > > > > > reasoning about avoiding a notification about process death through proc
> > > > > > > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > > > > > > >
> > > > > > > > > > May be a dedicated syscall for this would be cleaner after all.
> > > > > > > > >
> > > > > > > > > Ah, I wish I've seen that discussion before...
> > > > > > > > > syscall makes sense and it can be non-blocking and we can use
> > > > > > > > > select/poll/epoll if we use eventfd.
> > > > > > > >
> > > > > > > > Thanks for taking a look.
> > > > > > > >
> > > > > > > > > I would strongly advocate for
> > > > > > > > > non-blocking version or at least to have a non-blocking option.
> > > > > > > >
> > > > > > > > Waiting for FD readiness is *already* blocking or non-blocking
> > > > > > > > according to the caller's desire --- users can pass options they want
> > > > > > > > to poll(2) or whatever. There's no need for any kind of special
> > > > > > > > configuration knob or non-blocking option. We already *have* a
> > > > > > > > non-blocking option that works universally for everything.
> > > > > > > >
> > > > > > > > As I mentioned in the linked thread, waiting for process exit should
> > > > > > > > work just like waiting for bytes to appear on a pipe. Process exit
> > > > > > > > status is just another blob of bytes that a process might receive. A
> > > > > > > > process exit handle ought to be just another information source. The
> > > > > > > > reason the unix process API is so awful is that for whatever reason
> > > > > > > > the original designers treated processes as some kind of special kind
> > > > > > > > of resource instead of fitting them into the otherwise general-purpose
> > > > > > > > unix data-handling API. Let's not repeat that mistake.
> > > > > > > >
> > > > > > > > > Something like this:
> > > > > > > > >
> > > > > > > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > > > > > > // register eventfd to receive death notification
> > > > > > > > > pidfd_wait(pid_to_kill, evfd);
> > > > > > > > > // kill the process
> > > > > > > > > pidfd_send_signal(pid_to_kill, ...)
> > > > > > > > > // tend to other things
> > > > > > > >
> > > > > > > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > > > > > > an eventfd.
> > > > > > > >
> > > > > >
> > > > > > Ok, I probably misunderstood your post linked by Joel. I though your
> > > > > > original proposal was based on being able to poll a file under
> > > > > > /proc/pid and then you changed your mind to have a separate syscall
> > > > > > which I assumed would be a blocking one to wait for process exit.
> > > > > > Maybe you can describe the new interface you are thinking about in
> > > > > > terms of userspace usage like I did above? Several lines of code would
> > > > > > explain more than paragraphs of text.
> > > > >
> > > > > Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
> > > > > from Daniel here is to wait for process death and exit events by just
> > > > > referring to a stable fd, independent of whatever is going on in /proc.
> > > > >
> > > > > What is needed is something like this (in highly pseudo-code form):
> > > > >
> > > > > pidfd = opendir("/proc/<pid>",..);
> > > > > wait_fd = pidfd_wait(pidfd);
> > > > > read or poll wait_fd (non-blocking or blocking whichever)
> > > > >
> > > > > wait_fd will block until the task has either died or reaped. In both these
> > > > > cases, it can return a suitable string such as "dead" or "reaped" although an
> > > > > integer with some predefined meaning is also Ok.
> > > 
> > > I want to return a siginfo_t: we already use this structure in other
> > > contexts to report exit status.
> > > 
> 
> Fine with me. I did a prototype (code is below) as a string but I can change
> that to siginfo_t in the future.
> 
> > > > Having pidfd_wait() return another fd will make the syscall harder to
> > > > swallow for a lot of people I reckon.
> > > > What exactly prevents us from making the pidfd itself readable/pollable
> > > > for the exit staus? They are "special" fds anyway. I would really like
> > > > to avoid polluting the api with multiple different types of fds if possible.
> > > 
> > > If pidfds had been their own file type, I'd agree with you. But pidfds
> > > are directories, which means that we're beholden to make them behave
> > > like directories normally do. I'd rather introduce another FD than
> > > heavily overload the semantics of a directory FD in one particular
> > > context. In no other circumstances are directory FDs also weird
> > > IO-data sources. Our providing a facility to get a new FD to which we
> > > *can* give pipe-like behavior does no harm and *usage* cleaner and
> > > easier to reason about.
> > 
> > I have two things I'm currently working on:
> > - hijacking translate_pid()
> > - pidfd_clone() essentially
> > 
> > My first goal is to talk to Eric about taking the translate_pid()
> > syscall that has been sitting in his tree and expanding it.
> > translate_pid() currently allows you to either get an fd for the pid
> > namespace a pid resides in or the pid number of a given process in
> > another pid namespace relative to a passed in pid namespace fd.
> 
> That's good to know. More comments below:

Sorry for the delay I'm still traveling. I'll be back on a fully
functional schedule starting Monday.

> 
> > I would
> > like to make it possible for this syscall to also give us back pidfds.
> > One question I'm currently struggling with is exactly what you said
> > above: what type of file descriptor these are going to give back to us.
> > It seems that a regular file instead of directory would make the most
> > sense and would lead to a nicer API and I'm very much leaning towards
> > that.
> 
> How about something like the following? We can plumb the new file as a pseudo
> file that is invisible and linked to the fd. This is extremely rough (does
> not do error handling, synchronizatoin etc) but just wanted to share the idea
> of what the "frontend" could look like. It is also missing all the actual pid
> status messages. It just takes care of the creating new fd from the pidfd
> part and providing file read ops returning the "status" string.  It is also
> written in signal.c and should likely go into proc fs files under fs.
> Appreciate any suggestions (a test program did prove it works).
> 
> Also, I was able to translate a pidfd to a pid_namespace by referring to some
> existing code but perhaps you may be able to suggest something better for
> such translation..

Yeah, there's better ways but I think there's another issue. See below.

> 
> ---8<-----------------------
> 
> From: Joel Fernandes <joelaf@google.com>
> Subject: [PATCH] Partial skeleton prototype of pidfd_wait frontend
> 
> Signed-off-by: Joel Fernandes <joelaf@google.com>
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
>  include/linux/syscalls.h               |  1 +
>  include/uapi/asm-generic/unistd.h      |  4 +-
>  kernel/signal.c                        | 62 ++++++++++++++++++++++++++
>  kernel/sys_ni.c                        |  3 ++
>  6 files changed, 71 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 1f9607ed087c..2a63f1896b63 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -433,3 +433,4 @@
>  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
>  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
>  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> +428	i386	pidfd_wait		sys_pidfd_wait			__ia32_sys_pidfd_wait
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 92ee0b4378d4..cf2e08a8053b 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -349,6 +349,7 @@
>  425	common	io_uring_setup		__x64_sys_io_uring_setup
>  426	common	io_uring_enter		__x64_sys_io_uring_enter
>  427	common	io_uring_register	__x64_sys_io_uring_register
> +428	common	pidfd_wait		__x64_sys_pidfd_wait
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index e446806a561f..62160970ed3f 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -988,6 +988,7 @@ asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
>  asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
>  				       siginfo_t __user *info,
>  				       unsigned int flags);
> +asmlinkage long sys_pidfd_wait(int pidfd);
>  
>  /*
>   * Architecture-specific system calls
> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> index dee7292e1df6..137aa8662230 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -832,9 +832,11 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
>  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
>  #define __NR_io_uring_register 427
>  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> +#define __NR_pidfd_wait 428
> +__SYSCALL(__NR_pidfd_wait, sys_pidfd_wait)
>  
>  #undef __NR_syscalls
> -#define __NR_syscalls 428
> +#define __NR_syscalls 429
>  
>  /*
>   * 32 bit systems traditionally used different
> diff --git a/kernel/signal.c b/kernel/signal.c
> index b7953934aa99..ebb550b87044 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -3550,6 +3550,68 @@ static int copy_siginfo_from_user_any(kernel_siginfo_t *kinfo, siginfo_t *info)
>  	return copy_siginfo_from_user(kinfo, info);
>  }
>  
> +static ssize_t pidfd_wait_read_iter(struct kiocb *iocb, struct iov_iter *to)
> +{
> +	/*
> +	 * This is just a test string, it will contain the actual
> +	 * status of the pidfd in the future.
> +	 */
> +	char buf[] = "status";
> +
> +	return copy_to_iter(buf, strlen(buf)+1, to);
> +}
> +
> +static const struct file_operations pidfd_wait_file_ops = {
> +	.read_iter	= pidfd_wait_read_iter,
> +};
> +
> +static struct inode *pidfd_wait_get_inode(struct super_block *sb)
> +{
> +	struct inode *inode = new_inode(sb);
> +
> +	inode->i_ino = get_next_ino();
> +	inode_init_owner(inode, NULL, S_IFREG);
> +
> +	inode->i_op		= &simple_dir_inode_operations;
> +	inode->i_fop		= &pidfd_wait_file_ops;
> +
> +	return inode;
> +}
> +
> +SYSCALL_DEFINE1(pidfd_wait, int, pidfd)
> +{
> +	struct fd f;
> +	struct inode *inode;
> +	struct file *file;
> +	int new_fd;
> +	struct pid_namespace *pid_ns;
> +	struct super_block *sb;
> +	struct vfsmount *mnt;
> +
> +	f = fdget_raw(pidfd);
> +	if (!f.file)
> +		return -EBADF;
> +
> +	sb = file_inode(f.file)->i_sb;
> +	pid_ns = sb->s_fs_info;
> +
> +	inode = pidfd_wait_get_inode(sb);
> +
> +	mnt = pid_ns->proc_mnt;
> +
> +	file = alloc_file_pseudo(inode, mnt, "pidfd_wait", O_RDONLY,
> +			&pidfd_wait_file_ops);

So I dislike the idea of allocating new inodes from the procfs super
block. I would like to avoid pinning the whole pidfd concept exclusively
to proc. The idea is that the pidfd API will be useable through procfs
via open("/proc/<pid>") because that is what users expect and really
wanted to have for a long time. So it makes sense to have this working.
But it should really be useable without it. That's why translate_pid()
and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
api is "complete" you should be able to set CONFIG_PROCFS=N - even
though that's crazy - and still be able to use pidfds. This is also a
point akpm asked about when I did the pidfd_send_signal work.

So instead of going throught proc we should probably do what David has
been doing in the mount API and come to rely on anone_inode. So
something like:

fd = anon_inode_getfd("pidfd", &pidfd_fops, file_priv_data, flags);

and stash information such as pid namespace etc. in a pidfd struct or
something that we then can stash file->private_data of the new file.
This also lets us avoid all this open coding done here.
Another advantage is that anon_inodes is its own kernel-internal
filesystem.

Christian

> +
> +	file->f_mode |= FMODE_PREAD;
> +
> +	new_fd = get_unused_fd_flags(0);
> +	fd_install(new_fd, file);
> +
> +	fdput(f);
> +
> +	return new_fd;
> +}
> +
>  /**
>   * sys_pidfd_send_signal - send a signal to a process through a task file
>   *                          descriptor
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index d21f4befaea4..f52c4d864038 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -450,3 +450,6 @@ COND_SYSCALL(setuid16);
>  
>  /* restartable sequence */
>  COND_SYSCALL(rseq);
> +
> +/* pidfd */
> +COND_SYSCALL(pidfd_wait);
> -- 
> 2.21.0.225.g810b269d1ac-goog
> 

