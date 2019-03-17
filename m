Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19563C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 17:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B141D2087C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 17:16:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B141D2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51C2C6B02E7; Sun, 17 Mar 2019 13:16:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A1446B02E8; Sun, 17 Mar 2019 13:16:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345A36B02E9; Sun, 17 Mar 2019 13:16:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA3326B02E7
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 13:16:54 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 8so2829108wmg.7
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 10:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mTubp++F7Yq3tzjD+Ii++Z3hoDP3hp8hbSezQabnf68=;
        b=lI2RtbJtXsqcA2um7fHtrIO5elOMnX+ULOYBGk3BaTZG+2TuaFQzWLm3SWmtC94sSA
         x2xQ6dBc66LifZH88ae8WLrpbDI9jd5WcsPyNMD7b938o1v1mVx+WIN5jG9hmQO4F4S5
         4OPUFAx3PS1vcygJklxCPhnxZhKApiKyQHY8K94Tn1nScHBUn/WvaZysA+ImtlCKrVrr
         Yl3JfjzWWJbJUbUfB8FfPHFspP1gnG8jLQz5kT7aNgbqG8kn+uUx8WZHiiGpkpozQuv2
         nTnsfDWCVYjZPGwc7wD1PsTv+jiqzFAGt9Oimc1qBKrX6O34a5hkv+BqVL3y3MWD+XAX
         jqtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
X-Gm-Message-State: APjAAAVKrKkscjsj4kze1jaTfWjpFi4gYc8cdV0VI5E8zTCCzEeuWWt0
	FjbTPyVMUnAAXnoP9H/1+N4TY3fats1EXMEZlyPS8bEkiip9YkKkilRQKvomg0pL+OEMbg68vgQ
	sm31icv/nidLNqXtJbxJAfXS/bS2UjxOqK+l+MkYn6H0G+fddnxaZHUCiT0iJyRaQnQ==
X-Received: by 2002:a1c:2dd2:: with SMTP id t201mr8370571wmt.44.1552843014241;
        Sun, 17 Mar 2019 10:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7MqL39mv2VT6Y+XIG08PY1EuoKd6+H4e2buS5J4BrBkUGfmfQzfqmZLtnRecHU0vZJs2D
X-Received: by 2002:a1c:2dd2:: with SMTP id t201mr8370532wmt.44.1552843013209;
        Sun, 17 Mar 2019 10:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552843013; cv=none;
        d=google.com; s=arc-20160816;
        b=I0SYjrHYKBXr7xz+mBDV+fNwr+10MFcEP0N13HmKsRAgMUz63wN5rt6FSU3KsVeUkF
         jBY//Qr0DnJmA/U1XRVv8FvrbDWimSW9gtBHPnPcvKNZRovAluTMbLcSxyIKPqB5/tJZ
         mgAZo5y8dY6Bj+p+PT6PornN2pyfiWnPPP9EfxfJ0x3A9ngpqjf09nFJIiUIZE1h4YKv
         uYhbUqM4CzbCgr0JeEsWdC+qR3HF+TVTsMAwhhbnz/ZqMxbWeEE6oPxKbpLGHtsZLhiq
         sJDz+jpM9gILfuCKiVcAh0AqxvgtYygXr54GjXO90q646GLT/APhWgk1eIwG4Qtu6agp
         7M1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mTubp++F7Yq3tzjD+Ii++Z3hoDP3hp8hbSezQabnf68=;
        b=MTRGq0OkUpVejY2pOhJTr0Glac3u21UjSv5DBLI0iy2/bXppuOcgZ5MY2FVMay1k3E
         B1VRjhb2X9F8x76PvuUijPcgUuMtyxg+Xn6dAFo7A4JCF17SXI1H4Jtwq/C813uTvxsK
         GTMQH8kQGFZWYaSXilUEqSRoViyxSJYwy+2BAr8L8LyrpENKXB/qdnz5ToJMCsMmV2/Z
         wc/V/3RNoecCmcCfw6XVjNIpThKKvAmxVZdCvR3Ra1NbvaBoNOwR9R2Gbd/y3RPZ2zEZ
         hPcpi+Mpc9CLd8udCdcylUzQnVElakP5B6NMqfIfXJPe2EFAw6AO9v/mzsk3hKC7SKyM
         vgmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: from mail.hallyn.com (mail.hallyn.com. [178.63.66.53])
        by mx.google.com with ESMTPS id o3si5089785wrs.357.2019.03.17.10.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 10:16:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) client-ip=178.63.66.53;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id A59087C4; Sun, 17 Mar 2019 12:16:52 -0500 (CDT)
Date: Sun, 17 Mar 2019 12:16:52 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Daniel Colascione <dancol@google.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	Christian Brauner <christian@brauner.io>,
	Joel Fernandes <joel@joelfernandes.org>,
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
	Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190317171652.GA10567@mail.hallyn.com>
References: <20190315182426.sujcqbzhzw4llmsa@brauner.io>
 <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <20190317163505.GA9904@mail.hallyn.com>
 <CAKOZuet+HCZoOgJBAUrcm8nxC-bQ00W7w+=k2SOh+dfXffMU4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuet+HCZoOgJBAUrcm8nxC-bQ00W7w+=k2SOh+dfXffMU4w@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 10:11:10AM -0700, Daniel Colascione wrote:
> On Sun, Mar 17, 2019 at 9:35 AM Serge E. Hallyn <serge@hallyn.com> wrote:
> >
> > On Sun, Mar 17, 2019 at 12:42:40PM +0100, Christian Brauner wrote:
> > > On Sat, Mar 16, 2019 at 09:53:06PM -0400, Joel Fernandes wrote:
> > > > On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> > > > > On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> > > > > >
> > > > > > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > > > > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > > > >
> > > > > > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > > > > >
> > > > > > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > > > > > [..]
> > > > > > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > > > > > needed then, let me know if I missed something?
> > > > > > > > > >
> > > > > > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > > > > > >
> > > > > > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > > > > > reasoning about avoiding a notification about process death through proc
> > > > > > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > > > > > >
> > > > > > > > > May be a dedicated syscall for this would be cleaner after all.
> > > > > > > >
> > > > > > > > Ah, I wish I've seen that discussion before...
> > > > > > > > syscall makes sense and it can be non-blocking and we can use
> > > > > > > > select/poll/epoll if we use eventfd.
> > > > > > >
> > > > > > > Thanks for taking a look.
> > > > > > >
> > > > > > > > I would strongly advocate for
> > > > > > > > non-blocking version or at least to have a non-blocking option.
> > > > > > >
> > > > > > > Waiting for FD readiness is *already* blocking or non-blocking
> > > > > > > according to the caller's desire --- users can pass options they want
> > > > > > > to poll(2) or whatever. There's no need for any kind of special
> > > > > > > configuration knob or non-blocking option. We already *have* a
> > > > > > > non-blocking option that works universally for everything.
> > > > > > >
> > > > > > > As I mentioned in the linked thread, waiting for process exit should
> > > > > > > work just like waiting for bytes to appear on a pipe. Process exit
> > > > > > > status is just another blob of bytes that a process might receive. A
> > > > > > > process exit handle ought to be just another information source. The
> > > > > > > reason the unix process API is so awful is that for whatever reason
> > > > > > > the original designers treated processes as some kind of special kind
> > > > > > > of resource instead of fitting them into the otherwise general-purpose
> > > > > > > unix data-handling API. Let's not repeat that mistake.
> > > > > > >
> > > > > > > > Something like this:
> > > > > > > >
> > > > > > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > > > > > // register eventfd to receive death notification
> > > > > > > > pidfd_wait(pid_to_kill, evfd);
> > > > > > > > // kill the process
> > > > > > > > pidfd_send_signal(pid_to_kill, ...)
> > > > > > > > // tend to other things
> > > > > > >
> > > > > > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > > > > > an eventfd.
> > > > > > >
> > > > >
> > > > > Ok, I probably misunderstood your post linked by Joel. I though your
> > > > > original proposal was based on being able to poll a file under
> > > > > /proc/pid and then you changed your mind to have a separate syscall
> > > > > which I assumed would be a blocking one to wait for process exit.
> > > > > Maybe you can describe the new interface you are thinking about in
> > > > > terms of userspace usage like I did above? Several lines of code would
> > > > > explain more than paragraphs of text.
> > > >
> > > > Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
> > > > from Daniel here is to wait for process death and exit events by just
> > > > referring to a stable fd, independent of whatever is going on in /proc.
> > > >
> > > > What is needed is something like this (in highly pseudo-code form):
> > > >
> > > > pidfd = opendir("/proc/<pid>",..);
> > > > wait_fd = pidfd_wait(pidfd);
> > > > read or poll wait_fd (non-blocking or blocking whichever)
> > > >
> > > > wait_fd will block until the task has either died or reaped. In both these
> > > > cases, it can return a suitable string such as "dead" or "reaped" although an
> > > > integer with some predefined meaning is also Ok.
> > > >
> > > > What that guarantees is, even if the task's PID has been reused, or the task
> > > > has already died or already died + reaped, all of these events cannot race
> > > > with the code above and the information passed to the user is race-free and
> > > > stable / guaranteed.
> > > >
> > > > An eventfd seems to not fit well, because AFAICS passing the raw PID to
> > > > eventfd as in your example would still race since the PID could have been
> > > > reused by another process by the time the eventfd is created.
> > > >
> > > > Also Andy's idea in [1] seems to use poll flags to communicate various tihngs
> > > > which is still not as explicit about the PID's status so that's a poor API
> > > > choice compared to the explicit syscall.
> > > >
> > > > I am planning to work on a prototype patch based on Daniel's idea and post something
> > > > soon (chatted with Daniel about it and will reference him in the posting as
> > > > well), during this posting I will also summarize all the previous discussions
> > > > and come up with some tests as well.  I hope to have something soon.
> > >
> > > Having pidfd_wait() return another fd will make the syscall harder to
> > > swallow for a lot of people I reckon.
> > > What exactly prevents us from making the pidfd itself readable/pollable
> > > for the exit staus? They are "special" fds anyway. I would really like
> > > to avoid polluting the api with multiple different types of fds if possible.
> > >
> > > ret = pidfd_wait(pidfd);
> > > read or poll pidfd
> >
> > I'm not quite clear on what the two steps are doing here.  Is pidfd_wait()
> > doing a waitpid(2), and the read gets exit status info?
> 
> pidfd_wait on an open pidfd returns a "wait handle" FD. The wait

That is what you are proposing.  I'm not sure that's what Christian
was proposing.  'ret' is ambiguous there.  Christian?

> handle works just like a pipe: you can select/epoll/whatever for
> readability. read(2) on the wait handle (which blocks unless you set
> O_NONBLOCK, just like a pipe) completes with a siginfo_t when the
> process to which the wait handle is attached exits. Roughly,
> 
> int kill_and_wait_for_exit(int pidfd) {
>   int wait_handle = pidfd_wait(pidfd);
>   pidfd_send_signal(pidfd, ...);
>   siginfo_t exit_info;
>   read(wait_handle, &exit_info, sizeof(exit_info)); // Blocks because
> we haven't configured non-blocking behavior, just like a pipe.
>   close(wait_handle);
>   return exit_info.si_status;
> }
> 
> >
> > > (Note that I'm traveling so my responses might be delayed quite a bit.)
> > > (Ccing a few people that might have an opinion here.)
> > >
> > > Christian
> >
> > On its own, what you (Christian) show seems nicer.  But think about a main event
> > loop (like in lxc), where we just loop over epoll_wait() on various descriptors.
> > If we want to wait for any of several types of events - maybe a signalfd, socket
> > traffic, or a process death - it would be nice if we can treat them all the same
> > way, without having to setup a separate thread to watch the pidfd and send
> > data over another fd.  Is there a nice way we can provide that with what you've
> > got above?
> 
> Nobody is proposing any kind of mechanism that would require a
> separate thread. What I'm proposing works with poll and read and
> should be trivial to integrate into any existing event loop: from the
> perspective of the event loop, it looks just like a pipe.

(yes, I understood your proposal)

-serge

