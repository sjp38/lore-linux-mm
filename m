Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 715D0C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:26:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2005C218A3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="YYMUxba7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2005C218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B580F6B0003; Wed, 20 Mar 2019 14:26:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADE516B0006; Wed, 20 Mar 2019 14:26:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 959B46B0007; Wed, 20 Mar 2019 14:26:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DFD6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:26:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z26so3324367pfa.7
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:26:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2g52oUx3+HaxVmfSpxb9ygebPkfjq9P2d+IQ2EIkyuU=;
        b=V9rlR5z0pl3Sl8TRQS43YdWgsq7dijfBacWRCffOuA5Gf8GvZhAVHURJDP0c25z4CG
         XmJJuaoPUnrvz8+zVER+OEFqsJe9S6OVgXrlU/rhxOPZGS8pf/bk0exGcqgRKrSgRZum
         kC33zEKY4YOoqs9geYLwSa2HCvO80f/KkHoAhwjJQIQXm/c3LaMc4ptImd6AyCAA3yan
         Q5klcmtm9k2LOIRs0vzetZ5UJfNIwQf+rnYD7K4IKJZiJGHnLp0QNuq5YDufeM70BJHd
         ptVvwyznhqhgn3vBqHr8c81qM0NY78H9p6Xs7+Gg2o2KCdyZeEbC9l813PJ0/jHlLyYd
         ne9g==
X-Gm-Message-State: APjAAAXdGj8bEdxX3KRF8KtABR793OAJTvl9CrPEwGzDTk7fUizBZjee
	kIGIFuBLIsCYOMK5E/vQzafw07xw6j2wdUAftJRf9ejkVan7EJTcCj8Vi1TCbXHdDA9mVOjY59m
	bhITs7/U/TB40S8yp7t2L2jMBhrjBcoa3t/Nd4uBEx1HGhPoSF/lsTJoPBhaSj/y4pQ==
X-Received: by 2002:a17:902:b684:: with SMTP id c4mr33143606pls.294.1553106415699;
        Wed, 20 Mar 2019 11:26:55 -0700 (PDT)
X-Received: by 2002:a17:902:b684:: with SMTP id c4mr33143486pls.294.1553106414221;
        Wed, 20 Mar 2019 11:26:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553106414; cv=none;
        d=google.com; s=arc-20160816;
        b=ivUFkjj2nJh9weYQCZwn3zDYzGehLkuOT9ijXUrUGCJQ3f2O/jHpmJPVRh5g8BiPkf
         Y0Ysj00ps00iIRLI8x1wPvqxVAwT3KZK/I87TW/zxZPB5KGNI/n1t0h62KeJUAGrEukX
         rnR/fV0MWnYsxlJoMWN0ZVu6UM5JgeON4ue/gvbCBfJ6+fTOKqdR5JQLIvjRLRQHe0y8
         Oc9w/nYpGnB4nL6TJZ7NdOqu9EF/rWeh9/Em/DH2/XwC53DkZ7MPEi+47Yc9yJKeV8eE
         BjOJi8aYJSadM+xmvOcjNaC/PEbV6VPaUCZ+9SkCCPzJQ9ZuuRg/Rdm+c8jD64TaJabL
         sGew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2g52oUx3+HaxVmfSpxb9ygebPkfjq9P2d+IQ2EIkyuU=;
        b=C+eAfXIkmyasRPiNolZRjVy/8+Mb9vRRmWrfxEyWf4FL8HTuwz4akNP98a6BEVPBTv
         L7SNc67BmiPQj3tDwrh6Jha5sgjpPX1vZdUxw7Ih/8/7S5YSjnHAFfJHnHuFMAJFXOsO
         QPLNhXH5Xl9izguvZprHOcZJlEd39Wr9NQuCR2y5LFHjDkCUD7z0tHvbJfd/oZRxEMHs
         3ZvdRg2VIbayXRJG8mj9a4tkiW+ZlrsUD5LTEBR1xfbZLNRWA2H0TV85jB+3bh1sAV1E
         c4KUw0/4bLRCqKL2uJtleS1msOXYAGWstW4kfGeioXvfoYeMm5ib1yvLYdzvi7DLCzAo
         Vx7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=YYMUxba7;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gb2sor4049534plb.38.2019.03.20.11.26.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 11:26:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=YYMUxba7;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2g52oUx3+HaxVmfSpxb9ygebPkfjq9P2d+IQ2EIkyuU=;
        b=YYMUxba7VhK+3hGIQHxE+uionynJB9xmcktnGG+DysX7t/9lWSKNPowLp2wCsc600R
         CRn3WF5jCujdnhEUH8BciQEBO3gGfhgYHyWdOGxid9/L6YoDGDBEfpNbbqN/xpuUdmzG
         68aTye1orT5LNVBGzu0ibiar0Bd10AXjJMnO1mU0vVXABjsa3ZRYgow330jqLfhrQ6Uw
         7BNn+93oY2nzP5CwzhDXOWcPWKLB8ct1CIK15KcrIHhVzwlLlNKC/JWyCWEjHgX+eOjV
         FYndTneZFOkkE5j/iatYntuYVHaatvyW2DD8dSVey8XM9bgdJ1ZspMqpgfoVa/8o4Ou1
         LyXw==
X-Google-Smtp-Source: APXvYqyukNgTlIk+MH4TLrGu2ooLRvgVazG+HYyPPshNRuOi/AixSDCWvSlksN8IVQtBTgB6fwSpCg==
X-Received: by 2002:a17:902:822:: with SMTP id 31mr32980655plk.290.1553106413603;
        Wed, 20 Mar 2019 11:26:53 -0700 (PDT)
Received: from brauner.io ([12.25.160.29])
        by smtp.gmail.com with ESMTPSA id l28sm8338701pfi.186.2019.03.20.11.26.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 11:26:52 -0700 (PDT)
Date: Wed, 20 Mar 2019 19:26:50 +0100
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
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: pidfd design
Message-ID: <20190320182649.spryp5uaeiaxijum@brauner.io>
References: <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 07:33:51AM -0400, Joel Fernandes wrote:
> 
> 
> On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google.com> wrote:
> >On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner
> ><christian@brauner.io> wrote:
> >>
> >> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> >> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes
> ><joel@joelfernandes.org> wrote:
> >> > >
> >> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner
> >wrote:
> >> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione
> >wrote:
> >> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner
> ><christian@brauner.io> wrote:
> >> > > > > > So I dislike the idea of allocating new inodes from the
> >procfs super
> >> > > > > > block. I would like to avoid pinning the whole pidfd
> >concept exclusively
> >> > > > > > to proc. The idea is that the pidfd API will be useable
> >through procfs
> >> > > > > > via open("/proc/<pid>") because that is what users expect
> >and really
> >> > > > > > wanted to have for a long time. So it makes sense to have
> >this working.
> >> > > > > > But it should really be useable without it. That's why
> >translate_pid()
> >> > > > > > and pidfd_clone() are on the table.  What I'm saying is,
> >once the pidfd
> >> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=N
> >- even
> >> > > > > > though that's crazy - and still be able to use pidfds. This
> >is also a
> >> > > > > > point akpm asked about when I did the pidfd_send_signal
> >work.
> >> > > > >
> >> > > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use
> >pidfds. One
> >> > > > > crazy idea that I was discussing with Joel the other day is
> >to just
> >> > > > > make CONFIG_PROCFS=Y mandatory and provide a new
> >get_procfs_root()
> >> > > > > system call that returned, out of thin air and independent of
> >the
> >> > > > > mount table, a procfs root directory file descriptor for the
> >caller's
> >> > > > > PID namspace and suitable for use with openat(2).
> >> > > >
> >> > > > Even if this works I'm pretty sure that Al and a lot of others
> >will not
> >> > > > be happy about this. A syscall to get an fd to /proc?
> >> >
> >> > Why not? procfs provides access to a lot of core kernel
> >functionality.
> >> > Why should you need a mountpoint to get to it?
> >> >
> >> > > That's not going
> >> > > > to happen and I don't see the need for a separate syscall just
> >for that.
> >> >
> >> > We need a system call for the same reason we need a getrandom(2):
> >you
> >> > have to bootstrap somehow when you're in a minimal environment.
> >> >
> >> > > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> >> >
> >> > I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> >> > proposing that we *hardwire* it as the default and just declare
> >that
> >> > it's not possible to build a Linux kernel that doesn't include
> >procfs.
> >> > Why do we even have that button?
> >> >
> >> > > I think his point here was that he wanted a handle to procfs no
> >matter where
> >> > > it was mounted and then can later use openat on that. Agreed that
> >it may be
> >> > > unnecessary unless there is a usecase for it, and especially if
> >the /proc
> >> > > directory being the defacto mountpoint for procfs is a universal
> >convention.
> >> >
> >> > If it's a universal convention and, in practice, everyone needs
> >proc
> >> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y?
> >If
> >> > we advertise /proc as not merely some kind of optional debug
> >interface
> >> > but *the* way certain kernel features are exposed --- and there's
> >> > nothing wrong with that --- then we should give programs access to
> >> > these core kernel features in a way that doesn't depend on
> >userspace
> >> > kernel configuration, and you do that by either providing a
> >> > procfs-root-getting system call or just hardwiring the "/proc/"
> >prefix
> >> > into VFS.
> >> >
> >> > > > Inode allocation from the procfs mount for the file descriptors
> >Joel
> >> > > > wants is not correct. Their not really procfs file descriptors
> >so this
> >> > > > is a nack. We can't just hook into proc that way.
> >> > >
> >> > > I was not particular about using procfs mount for the FDs but
> >that's the only
> >> > > way I knew how to do it until you pointed out anon_inode (my grep
> >skills
> >> > > missed that), so thank you!
> >> > >
> >> > > > > C'mon: /proc is used by everyone today and almost every
> >program breaks
> >> > > > > if it's not around. The string "/proc" is already de facto
> >kernel ABI.
> >> > > > > Let's just drop the pretense of /proc being optional and bake
> >it into
> >> > > > > the kernel proper, then give programs a way to get to /proc
> >that isn't
> >> > > > > tied to any particular mount configuration. This way, we
> >don't need a
> >> > > > > translate_pid(), since callers can just use procfs to do the
> >same
> >> > > > > thing. (That is, if I understand correctly what translate_pid
> >does.)
> >> > > >
> >> > > > I'm not sure what you think translate_pid() is doing since
> >you're not
> >> > > > saying what you think it does.
> >> > > > Examples from the old patchset:
> >> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> >> >
> >> > Ah, it's a bit different from what I had in mind. It's fair to want
> >to
> >> > translate PIDs between namespaces, but the only way to make the
> >> > translate_pid under discussion robust is to have it accept and
> >produce
> >> > pidfds. (At that point, you might as well call it translate_pidfd.)
> >We
> >> > should not be adding new APIs to the kernel that accept numeric
> >PIDs:
> >>
> >> The traditional pid-based api is not going away. There are users that
> >> have the requirement to translate pids between namespaces and also
> >doing
> >> introspection on these namespaces independent of pidfds. We will not
> >> restrict the usefulness of this syscall by making it only work with
> >> pidfds.
> >>
> >> > it's not possible to use these APIs correctly except under very
> >> > limited circumstances --- mostly, talking about init or a parent
> >>
> >> The pid-based api is one of the most widely used apis of the kernel
> >and
> >> people have been using it quite successfully for a long time. Yes,
> >it's
> >> rac, but it's here to stay.
> >>
> >> > talking about its child.
> >> >
> >> > Really, we need a few related operations, and we shouldn't
> >necessarily
> >> > mingle them.
> >>
> >> Yes, we've established that previously.
> >>
> >> >
> >> > 1) Given a numeric PID, give me a pidfd: that works today: you just
> >> > open /proc/<pid>
> >>
> >> Agreed.
> >>
> >> >
> >> > 2) Given a pidfd, give me a numeric PID: that works today: you just
> >> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> >> > always the numeric PID).
> >>
> >> Agreed.
> >>
> >> >
> >> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal
> >does,
> >> > and it's a good start on the rest of these operations.
> >>
> >> Agreed.
> >>
> >> > 5) Given a pidfd in NS1, get a pidfd in NS2. That's what
> >translate_pid
> >> > is for. My preferred signature for this routine is
> >translate_pid(int
> >> > pidfd, int nsfd) -> pidfd. We don't need two namespace arguments.
> >Why
> >> > not? Because the pidfd *already* names a single process, uniquely!
> >>
> >> Given that people are interested in pids we can't just always return
> >a
> >> pidfd. That would mean a user would need to do get the pidfd read
> >from
> >> <pidfd>/stat and then close the pidfd. If you do that for a 100 pids
> >or
> >> more you end up allocating and closing file descriptors constantly
> >for
> >> no reason. We can't just debate pids away. So it will also need to be
> >> able to yield pids e.g. through a flag argument.
> >
> >Sure, but that's still not a reason that we should care about pidfds
> >working separately from procfs..

That's unrelated to the point made in the above paragraph.
Please note, I said that the pidfd api should work when proc is not
available not that they can't be dirfds.

> 
> Agreed. I can't imagine pidfd being anything but a proc pid directory handle. So I am confused what Christian meant. Pidfd *is* a procfs directory fid  always. That's what I gathered from his pidfd_send_signal patch but let me know if I'm way off in the woods.

(K9 Mail still hasn't learned to wrap lines at 80 it seems. :))

Again, I never said that pidfds should be a directory handle.
(Though I would like to point out that one of the original ideas I
discussed at LPC was to have something like this to get regular file
descriptors instead of dirfds:
https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df)

> 
> For my next revision, I am thinking of adding the flag argument Christian mentioned to make translate_pid return an anon_inode FD which can be used for death status, given a <pid>. Since it is thought that translate_pid can be made to return a pid FD, I think it is ok to have it return a pid status FD for the purposes of the death status as well.

translate_pid() should just return you a pidfd. Having it return a pidfd
and a status fd feels like stuffing too much functionality in there. If
you're fine with it I'll finish prototyping what I had in mind. As I
said in previous mails I'm already working on this.

Would you be ok with prototyping the pidfd_wait() syscall you had in
mind? Especially the wait_fd part that you want to have I would like to
see how that is supposed to work, e.g. who is allowed to wait on the
process and how notifications will work for non-parent processes and so
on. I feel we won't get anywhere by talking in the abstrace and other
people are far more likely to review/comment once there's actual code.

Christian

