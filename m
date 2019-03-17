Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE567C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:35:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7546F21019
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:35:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7546F21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18E6D6B02FA; Sun, 17 Mar 2019 12:35:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 119DA6B02FC; Sun, 17 Mar 2019 12:35:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F22B96B02FD; Sun, 17 Mar 2019 12:35:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9900C6B02FA
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:35:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 6so6567466wrh.1
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:35:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C+99fkKl3MQ1HpmYHzAB5zcAFajOxfiG1OcH0i5YrKc=;
        b=PhZs1utF0FEqp9WdxTxtTtnIlcXebK+LUEJekTo0iSKTf/EyUXVXYNSkurAcYbjeNh
         hptLS2OfSyyUc+OcUHiepbFTIfdy4QD7KyAK14IpcC6dBwutc/KWIabkSU+PLQ+7mJua
         WNFCViXTfRIFi9goAV3uhLOWZVymxEAMmGzU+bDF48BiUm4Yq0HksNm7BIM1nZh7AVL2
         v72o1/WiE4ysCXTpHbQU/RdaJ7eQcaiXfrfCqILAuZs49ssnyyBuae2yP91dryKCBclP
         H/A2OLhYd/wOL9MD/L9Gdaa/tBV3Scc1M+OROUtve+jem1HgcErnS/mUF76N+syg3sCz
         l3cA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
X-Gm-Message-State: APjAAAUtOTfZzrZFFD7GVYLThxpfm1FGnd0fYwKuLdVpgjtmRVgr1jnh
	yJNT8CEf+CXdALGC7tqA5NbjzHt/cdC1eiVebg3KBV2P9/lVBRIVqwGrVIo6jI/RPeoUDSnGyav
	R0kZo6XJE5NzcTbo3uCZdbRuUDv+wd/BgH+23bAE+f3/kywONAsIcksR60EsDl+XnVQ==
X-Received: by 2002:a1c:d189:: with SMTP id i131mr1055937wmg.151.1552840507094;
        Sun, 17 Mar 2019 09:35:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywsPaJALKlK6FBMQaIscUGGxoPAAGlleV+vFf4p4O+9XyctHgvtUGoz/Ky/gT1O0454pTL
X-Received: by 2002:a1c:d189:: with SMTP id i131mr1055904wmg.151.1552840505892;
        Sun, 17 Mar 2019 09:35:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840505; cv=none;
        d=google.com; s=arc-20160816;
        b=VYdP0kZesIDS6/IaytVcYMgU3S2wGLIzeIqpWFmMThU6MPookN3vDmH/pSaz4jKihN
         02WTkThP/rHhHtU0u4TY+AuQj0GgQUuApQFOTGqEkUeXVIYe0emlGA05811lQ4mEEwlW
         0ww96Ea6DsqemY2+cnjJQoAMn68LVrmAqi94ayAic/GfgFF1ZTn605Pf/TlNRFQVXTvD
         +f3dEARQlYfyl8+Y/D7qAi8wcQhX19MoiLYkfYk6FClk/Ny37qKoMz1MUock3jqaZaiQ
         uPm77zQ9PRrTUDAh3x5fApYdZJls1hQvrVF7v9tLN5hWft2UxoEQ73dEbEkdUrCPHUWt
         s2zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C+99fkKl3MQ1HpmYHzAB5zcAFajOxfiG1OcH0i5YrKc=;
        b=qYpSv46ip5ZtZMVhZZMez3pwI6XlQYVwoj9dMIgQUx8vpbgPqwoclxhlwijhFFhDd6
         ex0+r55KuLmFd2f3Bvp9M5j4OlZwwXNuu2sa7rREUE+/M5m7ohptz6l+GWitTyIYHs16
         aRVd387ivF1VGt8wggnZ3zfKtrr5kafBOczSGRo+W6kNISqwRDg72OMki+Q1fBo31QH2
         aLVsIYbYmE+uXwMCvIdAbfTb9Ze10+8+LHfVgP6RXffirKESqLooTb7AHaJK/udyFAsJ
         zyZeoEJA9dLki9WubDXRb401LONIMemZwfuxFR+w7hOr/et9ZWny5XaiSb6MJyZ+aqqr
         hVnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: from mail.hallyn.com (mail.hallyn.com. [178.63.66.53])
        by mx.google.com with ESMTPS id y11si4638518wmd.122.2019.03.17.09.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:35:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) client-ip=178.63.66.53;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 498DAB01; Sun, 17 Mar 2019 11:35:05 -0500 (CDT)
Date: Sun, 17 Mar 2019 11:35:05 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian@brauner.io>
Cc: Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
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
	kernel-team <kernel-team@android.com>, oleg@redhat.com,
	luto@amacapital.net, serge@hallyn.com
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190317163505.GA9904@mail.hallyn.com>
References: <20190315180306.sq3z645p3hygrmt2@brauner.io>
 <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io>
 <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190317114238.ab6tvvovpkpozld5@brauner.io>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 12:42:40PM +0100, Christian Brauner wrote:
> On Sat, Mar 16, 2019 at 09:53:06PM -0400, Joel Fernandes wrote:
> > On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> > > On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> > > >
> > > > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > >
> > > > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > > >
> > > > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > > > [..]
> > > > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > > > needed then, let me know if I missed something?
> > > > > > > >
> > > > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > > > >
> > > > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > > > reasoning about avoiding a notification about process death through proc
> > > > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > > > >
> > > > > > > May be a dedicated syscall for this would be cleaner after all.
> > > > > >
> > > > > > Ah, I wish I've seen that discussion before...
> > > > > > syscall makes sense and it can be non-blocking and we can use
> > > > > > select/poll/epoll if we use eventfd.
> > > > >
> > > > > Thanks for taking a look.
> > > > >
> > > > > > I would strongly advocate for
> > > > > > non-blocking version or at least to have a non-blocking option.
> > > > >
> > > > > Waiting for FD readiness is *already* blocking or non-blocking
> > > > > according to the caller's desire --- users can pass options they want
> > > > > to poll(2) or whatever. There's no need for any kind of special
> > > > > configuration knob or non-blocking option. We already *have* a
> > > > > non-blocking option that works universally for everything.
> > > > >
> > > > > As I mentioned in the linked thread, waiting for process exit should
> > > > > work just like waiting for bytes to appear on a pipe. Process exit
> > > > > status is just another blob of bytes that a process might receive. A
> > > > > process exit handle ought to be just another information source. The
> > > > > reason the unix process API is so awful is that for whatever reason
> > > > > the original designers treated processes as some kind of special kind
> > > > > of resource instead of fitting them into the otherwise general-purpose
> > > > > unix data-handling API. Let's not repeat that mistake.
> > > > >
> > > > > > Something like this:
> > > > > >
> > > > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > > > // register eventfd to receive death notification
> > > > > > pidfd_wait(pid_to_kill, evfd);
> > > > > > // kill the process
> > > > > > pidfd_send_signal(pid_to_kill, ...)
> > > > > > // tend to other things
> > > > >
> > > > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > > > an eventfd.
> > > > >
> > > 
> > > Ok, I probably misunderstood your post linked by Joel. I though your
> > > original proposal was based on being able to poll a file under
> > > /proc/pid and then you changed your mind to have a separate syscall
> > > which I assumed would be a blocking one to wait for process exit.
> > > Maybe you can describe the new interface you are thinking about in
> > > terms of userspace usage like I did above? Several lines of code would
> > > explain more than paragraphs of text.
> > 
> > Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
> > from Daniel here is to wait for process death and exit events by just
> > referring to a stable fd, independent of whatever is going on in /proc.
> > 
> > What is needed is something like this (in highly pseudo-code form):
> > 
> > pidfd = opendir("/proc/<pid>",..);
> > wait_fd = pidfd_wait(pidfd);
> > read or poll wait_fd (non-blocking or blocking whichever)
> > 
> > wait_fd will block until the task has either died or reaped. In both these
> > cases, it can return a suitable string such as "dead" or "reaped" although an
> > integer with some predefined meaning is also Ok.
> > 
> > What that guarantees is, even if the task's PID has been reused, or the task
> > has already died or already died + reaped, all of these events cannot race
> > with the code above and the information passed to the user is race-free and
> > stable / guaranteed.
> > 
> > An eventfd seems to not fit well, because AFAICS passing the raw PID to
> > eventfd as in your example would still race since the PID could have been
> > reused by another process by the time the eventfd is created.
> > 
> > Also Andy's idea in [1] seems to use poll flags to communicate various tihngs
> > which is still not as explicit about the PID's status so that's a poor API
> > choice compared to the explicit syscall.
> > 
> > I am planning to work on a prototype patch based on Daniel's idea and post something
> > soon (chatted with Daniel about it and will reference him in the posting as
> > well), during this posting I will also summarize all the previous discussions
> > and come up with some tests as well.  I hope to have something soon.
> 
> Having pidfd_wait() return another fd will make the syscall harder to
> swallow for a lot of people I reckon.
> What exactly prevents us from making the pidfd itself readable/pollable
> for the exit staus? They are "special" fds anyway. I would really like
> to avoid polluting the api with multiple different types of fds if possible.
> 
> ret = pidfd_wait(pidfd);
> read or poll pidfd

I'm not quite clear on what the two steps are doing here.  Is pidfd_wait()
doing a waitpid(2), and the read gets exit status info?

> (Note that I'm traveling so my responses might be delayed quite a bit.)
> (Ccing a few people that might have an opinion here.)
> 
> Christian

On its own, what you (Christian) show seems nicer.  But think about a main event
loop (like in lxc), where we just loop over epoll_wait() on various descriptors.
If we want to wait for any of several types of events - maybe a signalfd, socket
traffic, or a process death - it would be nice if we can treat them all the same
way, without having to setup a separate thread to watch the pidfd and send
data over another fd.  Is there a nice way we can provide that with what you've
got above?

-serge

