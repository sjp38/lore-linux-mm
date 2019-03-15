Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54D8FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3F6B21019
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:18:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gxhQwXAO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3F6B21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17A806B027D; Fri, 15 Mar 2019 13:18:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FFA66B0294; Fri, 15 Mar 2019 13:18:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0ABC6B0295; Fri, 15 Mar 2019 13:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFB1F6B027D
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:18:03 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id x9so672529uac.22
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:18:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rnoznC+t5dzyGLgzfOQVo2l5wURP9NE8DM3DcfltKV4=;
        b=ZluWbyIFatyEhLV4eB5hEmpZzLjbOGKrMCLswv6y3tnsZnlKNjxZet3+9FRKKc6OAj
         AQ19qzEdT9nJfnAvfQ5Xy2fqHzhTIMPG+b9X+AMhBlSRMwFaeTUJRKH9EE/K3f0luEWi
         wUZFDhRfYkdaDiqkkbWRoUbh62z6FqiovItra2LIl1/4rNTIaV93Wh5KShRxvyzl843s
         clZWCoffCQ/LgWdbfvtfQMIBHs+9MSOAs8z33BNGHbqiUOX1WZn9F8oXY0gALkeO0eQD
         ftBXI/cUroMSnkiAAgSJO9ppn+ZMnEZeOLw9y7rDPjycioSa6I5ThlsVyIiojQKJnfWq
         XYZQ==
X-Gm-Message-State: APjAAAWItuDO1C46EacCyrQeP1h6kl1juEStjpM6PTu2qRs0GQRfTWWE
	eI/W3j+mvIxdBfKY1WyU+KsOaxnj/WPYhStnTtlhwcIqyu7RnYjk6X1CtesUFOZAUZzdUotdNEq
	Jqclhcv/ygdCbEhOhIR+/p+1HAvrdtxe1D6fsYlqTHnfEln0y4BpXOZDaXr3+svKUQg==
X-Received: by 2002:ab0:e10:: with SMTP id g16mr296656uak.80.1552670283323;
        Fri, 15 Mar 2019 10:18:03 -0700 (PDT)
X-Received: by 2002:ab0:e10:: with SMTP id g16mr296606uak.80.1552670282141;
        Fri, 15 Mar 2019 10:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552670282; cv=none;
        d=google.com; s=arc-20160816;
        b=BdQ4kcAhi3YtpQqT9xiVZXd1VTWNBSQ/GAcWuUhK1yBzrDJkvv5rpcJp+uq4DdYzXY
         JDoyt3ziqU1kxVOHwV/rGiDT6dLNoqRxb60gaVE5yPi9zlSdf8hZk2qBkLYZxIQm28ws
         qmB8+MMCcykw0pARgRF4qKYheYRPNfRHMyQeb6Dtk4iS1Ys0BRkr8GOM5jqTemDM621P
         4qETcFUiu1DsJ9m9v4uW/ewDMF69YJ0RRyIgIJGzJ39NeNcP8bgDDA1B/K4mjTX9wLgp
         sq1DVKf80sSZPQjahtVAWwQKN/wvRb86d6SM3KMSlZggu+g4N9hRcRdmXcp2dUwg86IX
         OG5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rnoznC+t5dzyGLgzfOQVo2l5wURP9NE8DM3DcfltKV4=;
        b=GY43Knaf898ofPDdXpSdj13NB80mAZKWf+nSavntLk9dOcdzVdjSf8zBWTkrSFoyq4
         o2YxSh76GjSp1em26PUew6Rk6v2eMp4vGg1Kv2Q1+LU8uy02ZvO7Cam9bqBxFRI03XjW
         Pa96cy0JpgpwBXasMjcVxuWyhhRD3jmb1YnHL10mxNDwWn3d6SU6zzp0O4TyJr2N+mWQ
         Tngv4MSGl1ZH8epAJq8Nd7DkuIlNxQE3sj/BKqmxHDlwNbs43K9NpzRMX4WvwNjrNsQO
         j8aK/gvsDW5KrkCXpIRHdwDnU9AZLP9rOOZX4Arnv/UhJ8Y2OoUDGtqzCChX4DdYab9X
         +CfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gxhQwXAO;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor1230080vkr.14.2019.03.15.10.18.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 10:18:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gxhQwXAO;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rnoznC+t5dzyGLgzfOQVo2l5wURP9NE8DM3DcfltKV4=;
        b=gxhQwXAOoftHpXlUgejl7DE+58vlxEnTn2okDInr44WrKPy2T30fSxzRoS0ZLhfu2K
         RZH4Qo2nRyNMfhapCPsjmz9MLiLkAaI63UrapdCTtXtsQXyOs0mVu2eAhFCv/tbh12p/
         kJK1p5d7nqDtXmHIOVNBB148pTsCizZTW2O2pop8/3cJe6ExN1RyG2CGM2UsPQ+caeqV
         CDUqwA/RpdRqNVSd3bR4wMWv4/jbaEWOd1ATWzqUTvWPyULNhbV2f+yHmkjUkl+rYYzo
         HbeOv2CxytoRfrpqFpsjCr/TYWPvjAdAGOLdGwfEQZP6EQRKo0eSFOGF9jf6DeFlm05Q
         lRug==
X-Google-Smtp-Source: APXvYqwDKhgiky+EFFXeweQWiRnEf661Q5jhY8blZ4geRrTDkZbB8mTHxm8poc7SFzPii5oxSTnH8NYgPBTTX5IIPQo=
X-Received: by 2002:a1f:2dc7:: with SMTP id t190mr2543104vkt.55.1552670281373;
 Fri, 15 Mar 2019 10:18:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com> <20190315124348.528ecd87@gandalf.local.home>
In-Reply-To: <20190315124348.528ecd87@gandalf.local.home>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 15 Mar 2019 10:17:49 -0700
Message-ID: <CAKOZuevt5aLc70Tmk6j8Ej5BKpP3hKtZ1y233kz5t5qVTw6zig@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Suren Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Christian Brauner <christian@brauner.io>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 9:43 AM Steven Rostedt <rostedt@goodmis.org> wrote:
>
> On Thu, 14 Mar 2019 21:36:43 -0700
> Daniel Colascione <dancol@google.com> wrote:
>
> > On Thu, Mar 14, 2019 at 8:16 PM Steven Rostedt <rostedt@goodmis.org> wrote:
> > >
> > > On Thu, 14 Mar 2019 13:49:11 -0700
> > > Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> > >
> > > > Perhaps I'm missing something, but if you want to know when a process has died
> > > > after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> > > > block until the process has died completely? It'd be rather trivial to just
> > > > store a pointer to an onstack completion inside the victim process' task_struct,
> > > > and then complete it in free_task().
> > >
> > > How would you implement such a method in userspace? kill() doesn't take
> > > any parameters but the pid of the process you want to send a signal to,
> > > and the signal to send. This would require a new system call, and be
> > > quite a bit of work.
> >
> > That's what the pidfd work is for. Please read the original threads
> > about the motivation and design of that facility.
>
> I wasn't Cc'd on the original work, so I haven't read them.
>
> >
> > > If you can solve this with an ebpf program, I
> > > strongly suggest you do that instead.
> >
>
>
>
> > We do want killed processes to die promptly. That's why I support
> > boosting a process's priority somehow when lmkd is about to kill it.
> > The precise way in which we do that --- involving not only actual
> > priority, but scheduler knobs, cgroup assignment, core affinity, and
> > so on --- is a complex topic best left to userspace. lmkd already has
> > all the knobs it needs to implement whatever priority boosting policy
> > it wants.
> >
> > Hell, once we add a pidfd_wait --- which I plan to work on, assuming
> > nobody beats me to it, after pidfd_send_signal lands --- you can
> > imagine a general-purpose priority inheritance mechanism expediting
> > process death when a high-priority process waits on a pidfd_wait
> > handle for a condemned process. You know you're on the right track
> > design-wise when you start seeing this kind of elegant constructive
> > interference between seemingly-unrelated features. What we don't need
> > is some kind of blocking SIGKILL alternative or backdoor event
> > delivery system.
> >
> > We definitely don't want to have to wait for a process's parent to
> > reap it. Instead, we want to wait for it to become a zombie. That's
> > why I designed my original exithand patch to fire death notification
> > upon transition to the zombie state, not upon process table removal,
> > and I expect pidfd_wait (or whatever we call it) to act the same way.
> >
> > In any case, there's a clear path forward here --- general-purpose,
> > cheap, and elegant --- and we should just focus on doing that instead
> > of more complex proposals with few advantages.
>
> If you add new pidfd systemcalls then making a new way to send a signal
> and block till it does die or whatever is

Right. And we shouldn't couple the killing and the waiting: while we
now have a good race-free way to kill processes using
pidfd_send_signal, but we still have no good facility for waiting for
the death of a process that isn't a child of the waiter. Any kind of
unified "kill and wait for death" primitive precludes the killing
thread waiting for things other than death at the same time! Instead,
if we allow waiting for an arbitrary process's death using
general-purpose wait primitives like select/poll/epoll/io_submit/etc.,
then synchronous killing becomes just another sleep that composes in
useful and predictable ways.

> more acceptable than adding a
> new signal that changes the semantics of sending signals, which is what
> I was against.

Agreed. Even if it were possible to easily add signals without
breaking everyone, a special kind of signal with delivery semantics
different from those of existing signals is a bad idea, and not really
a signal at all, but just a new system call in disguise.

> I do agree with Joel about bloating task_struct too. If anything, have
> a wait queue you add, where you can allocate a descriptor with the task
> dieing and task killing, and just search this queue on dying. We could
> add a TIF flag to the task as well to let the exiting of this task know
> it should do such an operation.

That's my basic plan. I think we need one link from struct signal or
something so we don't end up doing some kind of *global* search on
process death, but let's see how it goes.

