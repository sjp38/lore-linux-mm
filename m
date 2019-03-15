Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFEABC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74CEE218AC
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:24:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="f5EeRTy7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74CEE218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B318B6B029F; Fri, 15 Mar 2019 14:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADF0A6B02A0; Fri, 15 Mar 2019 14:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A7706B02A1; Fri, 15 Mar 2019 14:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4360A6B029F
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:24:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t4so4090067eds.1
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=seT4TFi1RcdFb9g62VHCpX5ppyQ+lPqF9G727Y0W53c=;
        b=LjGq7tuuX413x/HxeJNV/hKfDgJOS+Piuoy2jM32d9SXDfhcYNtvUpw+DvUdcujENI
         Myhv6sm7u0y9i/I8HPWPW1YeeRH9lcmcVO77PLwoFXO1IFlSKsRhvenFpeY/MYpfrxeB
         LK7W+3PjjSxh5Z10uAvRy1ehIZqUqMaesRCEqjo1QIyyltf24ixoeEH0ux4LBoriXKad
         FWWZf/UXKldKIdM3S4LKUkdtSsgJpHnWg5FUtNVolrHmwJv/KiaQr8Dqk+LUXUFF8upd
         X/10D/leIGPMePP7wntdUebwnsq8cGkG5UkfQ+EBOJaBTIqYH7+eCuWzrWLwTSUveCNW
         Y/lQ==
X-Gm-Message-State: APjAAAXsJHsVIRLsdB+xH+A55nqKLGal1l1ekAMPNZ6Bfva3eHETnk4V
	CJpAqbPrznwpuHDKXrUsLxzFaP7aLerpernsP6raqpPiYBg5Sp+tJHYvAScTItESYgtiY2UqYyt
	EnYbf6PBvwS7CmjDBM8QKMsA+PlhFCdut8sMFhPj3xna0BD90WgLGpdaM7C7w3Lv9gA==
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr3697026ede.196.1552674271749;
        Fri, 15 Mar 2019 11:24:31 -0700 (PDT)
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr3696968ede.196.1552674270488;
        Fri, 15 Mar 2019 11:24:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552674270; cv=none;
        d=google.com; s=arc-20160816;
        b=m6f56lhTT8jtba8E7leHquPzliuHSnbFPSzhTt5RaS4GywJDMPELO9dLR7xnKBCy9W
         MVvQSyfTIGYcqrXNs8ZQOjbfqNfAU6stny13y3xMcTLtBCfRhjWDgnd5shfeMebBCVWg
         lTExu7EYIcCHZIfapWj5fW8pJtQCWAbGC78d7Wryfc4iViCwoQYjY5jhQ2yw57qg6dcG
         ch5aF0zY42nBuN7M9e1Ts0zHOSSS0ACecxKjkI9dctEm4I0yFi2knHVxVMRtGt1Iy+D4
         f6FsQvFRus9ezAntylTsE/1nKd5SZQtv10LiWyeI5O62RPNYKNiwPFdC0ahKwUeYf0YN
         zulg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=seT4TFi1RcdFb9g62VHCpX5ppyQ+lPqF9G727Y0W53c=;
        b=mil+IzqHAPNd2RwkE6Q/NH0L4pepCnEsDVwetypB0rxAyjhMmIWj0ojBqq+qPvRuB/
         RoRfnQKF6Vgpeb/5CEldgwCR/g4sbCc3iTjyYySPKetVEtTzbMuQu1lSILpr93tt0dRz
         ywPBHPk2aIFsa+tdi1E/9v20U0/efrxI+zzM+kHmzyslL/kZnJlKWlyQh3CZmwnMBx4Q
         OvLyndJZ1cMSI1IlQydqlKQqxBuoRVSu7fkJbUyICcPbwN2CVYBFYOZ05mYHqCwGREry
         ctP7hzmjKgHQTm6juamrseVslSYUPG7Ql0jG4uWmAX6VzWrUhBHPovzIdz1R+I5YYR5S
         KUYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=f5EeRTy7;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3sor903004eja.15.2019.03.15.11.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 11:24:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=f5EeRTy7;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=seT4TFi1RcdFb9g62VHCpX5ppyQ+lPqF9G727Y0W53c=;
        b=f5EeRTy7jU1X3Z3hmqmDbEF/y9isrUEz9Jev4s64tBraL9Zo6gvA97QtmEfWXX6hbg
         ZUsqLm9a70iyu8Tzl21XPoBZa/TKhlcYHf2rW8VGO7VkMojFuRDgyVTaYv/tHbQqkxUs
         RDJIfe1RqTqDVVGk7frM2aWxaQbbzLSXabL+MfA9Cj7eD/hRYinK+JBUvL4RcpETcZMF
         6j5wr55UjL2UAK8gIUbjovdNdubk7l3PcApu7a3ISJylBVplBpKcqxy86XSJTPZGa+m9
         RtlsS3pdCUvN3AEZ9A6lkC9Lwdx/8umFrGqSwovHMf4eV1EWj2sNNetjzHbsJrbbFd+g
         Jn4w==
X-Google-Smtp-Source: APXvYqxwBOSWJEMRcvHNYsRrBuvRE2pd7mCR246ZSKaj0U+KVxB50kK7Q1hhv/RETEVLpHC3pQJLbQ==
X-Received: by 2002:a17:906:c406:: with SMTP id u6mr3010081ejz.95.1552674269944;
        Fri, 15 Mar 2019 11:24:29 -0700 (PDT)
Received: from brauner.io ([2a02:8109:b6c0:76e:dd26:cbb7:1dbc:50af])
        by smtp.gmail.com with ESMTPSA id u21sm568000ejm.45.2019.03.15.11.24.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 15 Mar 2019 11:24:29 -0700 (PDT)
Date: Fri, 15 Mar 2019 19:24:28 +0100
From: Christian Brauner <christian@brauner.io>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315182426.sujcqbzhzw4llmsa@brauner.io>
References: <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io>
 <20190315181324.GA248160@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190315181324.GA248160@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 02:13:24PM -0400, Joel Fernandes wrote:
> On Fri, Mar 15, 2019 at 07:03:07PM +0100, Christian Brauner wrote:
> > On Thu, Mar 14, 2019 at 09:36:43PM -0700, Daniel Colascione wrote:
> > > On Thu, Mar 14, 2019 at 8:16 PM Steven Rostedt <rostedt@goodmis.org> wrote:
> > > >
> > > > On Thu, 14 Mar 2019 13:49:11 -0700
> > > > Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> > > >
> > > > > Perhaps I'm missing something, but if you want to know when a process has died
> > > > > after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> > > > > block until the process has died completely? It'd be rather trivial to just
> > > > > store a pointer to an onstack completion inside the victim process' task_struct,
> > > > > and then complete it in free_task().
> > > >
> > > > How would you implement such a method in userspace? kill() doesn't take
> > > > any parameters but the pid of the process you want to send a signal to,
> > > > and the signal to send. This would require a new system call, and be
> > > > quite a bit of work.
> > > 
> > > That's what the pidfd work is for. Please read the original threads
> > > about the motivation and design of that facility.
> > > 
> > > > If you can solve this with an ebpf program, I
> > > > strongly suggest you do that instead.
> > > 
> > > Regarding process death notification: I will absolutely not support
> > > putting aBPF and perf trace events on the critical path of core system
> > > memory management functionality. Tracing and monitoring facilities are
> > > great for learning about the system, but they were never intended to
> > > be load-bearing. The proposed eBPF process-monitoring approach is just
> > > a variant of the netlink proposal we discussed previously on the pidfd
> > > threads; it has all of its drawbacks. We really need a core system
> > > call  --- really, we've needed robust process management since the
> > > creation of unix --- and I'm glad that we're finally getting it.
> > > Adding new system calls is not expensive; going to great lengths to
> > > avoid adding one is like calling a helicopter to avoid crossing the
> > > street. I don't think we should present an abuse of the debugging and
> > > performance monitoring infrastructure as an alternative to a robust
> > > and desperately-needed bit of core functionality that's neither hard
> > > to add nor complex to implement nor expensive to use.
> > > 
> > > Regarding the proposal for a new kernel-side lmkd: when possible, the
> > > kernel should provide mechanism, not policy. Putting the low memory
> > > killer back into the kernel after we've spent significant effort
> > > making it possible for userspace to do that job. Compared to kernel
> > > code, more easily understood, more easily debuggable, more easily
> > > updated, and much safer. If we *can* move something out of the kernel,
> > > we should. This patch moves us in exactly the wrong direction. Yes, we
> > > need *something* that sits synchronously astride the page allocation
> > > path and does *something* to stop a busy beaver allocator that eats
> > > all the available memory before lmkd, even mlocked and realtime, can
> > > respond. The OOM killer is adequate for this very rare case.
> > > 
> > > With respect to kill timing: Tim is right about the need for two
> > > levels of policy: first, a high-level process prioritization and
> > > memory-demand balancing scheme (which is what OOM score adjustment
> > > code in ActivityManager amounts to); and second, a low-level
> > > process-killing methodology that maximizes sustainable memory reclaim
> > > and minimizes unwanted side effects while killing those processes that
> > > should be dead. Both of these policies belong in userspace --- because
> > > they *can* be in userspace --- and userspace needs only a few tools,
> > > most of which already exist, to do a perfectly adequate job.
> > > 
> > > We do want killed processes to die promptly. That's why I support
> > > boosting a process's priority somehow when lmkd is about to kill it.
> > > The precise way in which we do that --- involving not only actual
> > > priority, but scheduler knobs, cgroup assignment, core affinity, and
> > > so on --- is a complex topic best left to userspace. lmkd already has
> > > all the knobs it needs to implement whatever priority boosting policy
> > > it wants.
> > > 
> > > Hell, once we add a pidfd_wait --- which I plan to work on, assuming
> > > nobody beats me to it, after pidfd_send_signal lands --- you can
> > 
> > Daniel,
> > 
> > I've just been talking to Joel.
> > I actually "expected" you to work pidfd_wait() after prior
> > conversations we had on the pidfd_send_signal() patchsets. :) That's why
> > I got a separate git tree on kernel.org since I expect a lot more work
> > to come. I hope that Linus still decides to pull pidfd_send_signal()
> > before Sunday (For the ones who have missed the link in a prior response
> > of mine:
> > https://lkml.org/lkml/2019/3/12/439
> > 
> > This is the first merge window I sent this PR.
> > 
> > The pidfd tree has a branch for-next that is already tracked by Stephen
> > in linux-next since the 5.0 merge window. The patches for
> > pidfd_send_signal() sit in the pidfd branch.
> > I'd be happy to share the tree with you and Joel (We can rename it if
> > you prefer I don't care).
> > I would really like to centralize this work so that we sort of have a
> > "united front" and end up with a coherent api and can send PRs from a
> > centralized place:
> > https://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux.git/
> 
> I am totally onboard with working together / reviewing this work with you all
> on a common tree somewhere (Christian's pidfd tree is fine). I was curious,

Excellent.

> why do we want to add a new syscall (pidfd_wait) though? Why not just use
> standard poll/epoll interface on the proc fd like Daniel was suggesting.
> AFAIK, once the proc file is opened, the struct pid is essentially pinned
> even though the proc number may be reused. Then the caller can just poll.
> We can add a waitqueue to struct pid, and wake up any waiters on process
> death (A quick look shows task_struct can be mapped to its struct pid) and
> also possibly optimize it using Steve's TIF flag idea. No new syscall is
> needed then, let me know if I missed something?

Huh, I thought that Daniel was against the poll/epoll solution?
I have no clear opinion on what is better at the moment since I have
been mostly concerned with getting pidfd_send_signal() into shape and
was reluctant to put more ideas/work into this if it gets shutdown.
Once we have pidfd_send_signal() the wait discussion makes sense.

Thanks!
Christian

