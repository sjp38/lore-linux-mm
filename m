Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FE86C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:43:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E90B4217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:43:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ha7+7dfB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E90B4217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CC756B0272; Tue, 19 Mar 2019 22:43:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77C726B0274; Tue, 19 Mar 2019 22:43:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66BD16B0275; Tue, 19 Mar 2019 22:43:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6816B0272
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:43:07 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id s143so451822vke.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:43:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/GdIaxrDbIreBUUmi7IU7TIF4PHYyYqZ/fe4ms0j5RA=;
        b=Uij9RuLd1ezx6WoS7PSRSPrw53Tt711OoHvs4GqynsM5E9EfEG+ojeaKMZ+b9KTgTa
         LntQN8FVq7rLU5fzIK3IaKX+AkpxAM6FzBnhz9HzKw0JmxnhkPtkPh8pGQ4UzKjOvL/O
         mUsUEsxhG0qEfn0juKdeIJQXkA5gWFHyMw4H83dROehCtpcY1Ntk4VzranG40mPKi0uI
         MoXaO3IfQsRDlPi5oWe+gURy7aLt8s6Chov5xwXxHqreZ6ueY8ryhMA0AonzStP0CgcP
         eukCfxjOy9mgCDcMaKu71JUGzChSet+PLxHDsVrS/r5qU5MmsGIiYq7YCKAbEGEMxAE0
         llsw==
X-Gm-Message-State: APjAAAX6SCsoRp41+GSmwcGrLb+seKOESI6ODgbJuq+Aa61RPMO9+ykH
	LYln9MYJ4jRlegqH76t5HJLTCD95mu4Ldq/Wv5xJkzLvIYMebdyC+yGslHu66oAM5jFGimHmGxD
	8/93S6DSRYeLMBvrBghaihYr8wMQSjlnSUCvVWFLAMGCGsxRBGYJm/OYyPbYxCw7UqA==
X-Received: by 2002:a67:ecc7:: with SMTP id i7mr3554918vsp.182.1553049786784;
        Tue, 19 Mar 2019 19:43:06 -0700 (PDT)
X-Received: by 2002:a67:ecc7:: with SMTP id i7mr3554874vsp.182.1553049785392;
        Tue, 19 Mar 2019 19:43:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553049785; cv=none;
        d=google.com; s=arc-20160816;
        b=bdMs8gaDFnHL5Uaooa0A336ugpJRGT5fIXDgZ+5UbZek1ykX3Ne3ho1ORj1RgnUGeO
         sFUXwz2L4SFQ7xq9bbQ6uyBGcgwekn4K7Qujw38bWMqNAoBIiSqVouLJ957NlWx0xmff
         710LRRooSYJ5agJGAfJb2V/HGnxea51MKRI1j/KZpbz6C/q9qA3ZB6J59NAZ6VJcKdvt
         QXKBT/B6x6jLoNObzBDFD8fhQHv2ZHojkj7JvdEfS91wmrTKm8H20+Zq82UEXrkvMeh3
         Jn6grNnOo5V57VdlWspk6ZLj3Jd7Ec+JrdrKZXq8YPXRqpvOHdDdunOHMH3CEpq3QZvv
         emKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/GdIaxrDbIreBUUmi7IU7TIF4PHYyYqZ/fe4ms0j5RA=;
        b=yOSwlbwAsu7CcoROeJ2nQedn5f9JPy4A0gyjgwOXVZtAu6yuvX/AjXYsBBRdmQXrsE
         b/ZCXNr7iPJhGlM9cbB7PPV3AiLoQiEFMDstbN2LvedVweHO0vW9424qph9ATq/c1SJO
         kMMx/jUdrmuXVD3zLKY2JSedJszZDv9pCXGja7w5YFV+cbqK/07sOsjw29g2J/30LNhP
         SDbtI3/GgklEMEEa4wZmW6fE4ibF3e6VJ310w3t8k3M7h8Yy1LiWZrQ7p/F3PKnxx6fR
         p1TsrTLUYQyweMSky8ASkJR/y+wDIYegeOhyosulrwKd8ITUk9xjIhqPo9RwtHTK93Qz
         +iBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ha7+7dfB;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor569529vsf.36.2019.03.19.19.43.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 19:43:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ha7+7dfB;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/GdIaxrDbIreBUUmi7IU7TIF4PHYyYqZ/fe4ms0j5RA=;
        b=Ha7+7dfBDVj7lKo/5Cr6U2tQeL9pTHppyYpO4eBhiv0OhFCMOtfv54j2zlBiwWmBy+
         HSHtqHGHQ6rXemvE4t5dmV8D8z+4LJmxv6qGt9fNBmyrl7h8zjewQk8fDbngmjhyREM0
         ZMdWeKm4f3vebH/T0+yNHSCWLmqtIyMCtpw9DUqqaMcg6oDsm/4mtrtldS8VDd+JtbsG
         2RaQcgqY5mgQdbk731bme86k6lOr9BPviOng1CR8g6nPo0BuxGX1cdsGVyTrwhexeX5P
         Jjx0ovcpWmtswmV7E+Uzzyq4CCDVugU4gBsP0SGg6dVbQnU5e3q7U0xuDBapiEsEynOo
         Ct2A==
X-Google-Smtp-Source: APXvYqzyld3p7SL6ZsmbvkXdsMSkQXC12CwuoYbEKaoviwLywlutcW7KVldzJ4mcqT9gc+GBItRcysZ7W5JFnnME5GI=
X-Received: by 2002:a67:fa8c:: with SMTP id f12mr3425725vsq.171.1553049784600;
 Tue, 19 Mar 2019 19:43:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190316185726.jc53aqq5ph65ojpk@brauner.io> <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com> <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io> <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
In-Reply-To: <20190320015249.GC129907@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 19 Mar 2019 19:42:52 -0700
Message-ID: <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
Subject: pidfd design
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Christian Brauner <christian@brauner.io>, Suren Baghdasaryan <surenb@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner wrote:
> > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione wrote:
> > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> > > > So I dislike the idea of allocating new inodes from the procfs super
> > > > block. I would like to avoid pinning the whole pidfd concept exclusively
> > > > to proc. The idea is that the pidfd API will be useable through procfs
> > > > via open("/proc/<pid>") because that is what users expect and really
> > > > wanted to have for a long time. So it makes sense to have this working.
> > > > But it should really be useable without it. That's why translate_pid()
> > > > and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> > > > api is "complete" you should be able to set CONFIG_PROCFS=N - even
> > > > though that's crazy - and still be able to use pidfds. This is also a
> > > > point akpm asked about when I did the pidfd_send_signal work.
> > >
> > > I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
> > > crazy idea that I was discussing with Joel the other day is to just
> > > make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
> > > system call that returned, out of thin air and independent of the
> > > mount table, a procfs root directory file descriptor for the caller's
> > > PID namspace and suitable for use with openat(2).
> >
> > Even if this works I'm pretty sure that Al and a lot of others will not
> > be happy about this. A syscall to get an fd to /proc?

Why not? procfs provides access to a lot of core kernel functionality.
Why should you need a mountpoint to get to it?

> That's not going
> > to happen and I don't see the need for a separate syscall just for that.

We need a system call for the same reason we need a getrandom(2): you
have to bootstrap somehow when you're in a minimal environment.

> > (I do see the point of making CONFIG_PROCFS=y the default btw.)

I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
proposing that we *hardwire* it as the default and just declare that
it's not possible to build a Linux kernel that doesn't include procfs.
Why do we even have that button?

> I think his point here was that he wanted a handle to procfs no matter where
> it was mounted and then can later use openat on that. Agreed that it may be
> unnecessary unless there is a usecase for it, and especially if the /proc
> directory being the defacto mountpoint for procfs is a universal convention.

If it's a universal convention and, in practice, everyone needs proc
mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y? If
we advertise /proc as not merely some kind of optional debug interface
but *the* way certain kernel features are exposed --- and there's
nothing wrong with that --- then we should give programs access to
these core kernel features in a way that doesn't depend on userspace
kernel configuration, and you do that by either providing a
procfs-root-getting system call or just hardwiring the "/proc/" prefix
into VFS.

> > Inode allocation from the procfs mount for the file descriptors Joel
> > wants is not correct. Their not really procfs file descriptors so this
> > is a nack. We can't just hook into proc that way.
>
> I was not particular about using procfs mount for the FDs but that's the only
> way I knew how to do it until you pointed out anon_inode (my grep skills
> missed that), so thank you!
>
> > > C'mon: /proc is used by everyone today and almost every program breaks
> > > if it's not around. The string "/proc" is already de facto kernel ABI.
> > > Let's just drop the pretense of /proc being optional and bake it into
> > > the kernel proper, then give programs a way to get to /proc that isn't
> > > tied to any particular mount configuration. This way, we don't need a
> > > translate_pid(), since callers can just use procfs to do the same
> > > thing. (That is, if I understand correctly what translate_pid does.)
> >
> > I'm not sure what you think translate_pid() is doing since you're not
> > saying what you think it does.
> > Examples from the old patchset:
> > translate_pid(pid, ns, -1)      - get pid in our pid namespace

Ah, it's a bit different from what I had in mind. It's fair to want to
translate PIDs between namespaces, but the only way to make the
translate_pid under discussion robust is to have it accept and produce
pidfds. (At that point, you might as well call it translate_pidfd.) We
should not be adding new APIs to the kernel that accept numeric PIDs:
it's not possible to use these APIs correctly except under very
limited circumstances --- mostly, talking about init or a parent
talking about its child.

Really, we need a few related operations, and we shouldn't necessarily
mingle them.

1) Given a numeric PID, give me a pidfd: that works today: you just
open /proc/<pid>

2) Given a pidfd, give me a numeric PID: that works today: you just
openat(pidfd, "stat", O_RDONLY) and read the first token (which is
always the numeric PID).

3) Given a pidfd, send a signal: that's what pidfd_send_signal does,
and it's a good start on the rest of these operations.

4) Given a pidfd, wait for the named process to exit: that's what my
original exithand thing did, and that's what Joel's helpfully agreed
to start hacking on.

5) Given a pidfd in NS1, get a pidfd in NS2. That's what translate_pid
is for. My preferred signature for this routine is translate_pid(int
pidfd, int nsfd) -> pidfd. We don't need two namespace arguments. Why
not? Because the pidfd *already* names a single process, uniquely!

6) Make a new process and atomically give me a pidfd for it. We need a
new kind of clone(2) for that. People have been proposing some kind of
FD-based fork/spawn/etc. thing for ages, and we can finally provide
it. Yay.

7) Retrieve miscellaneous information about a process identified by a
pidfd: openat(2) handles this case today.

This is a decent framework for a good general-purpose process API that
builds on the one the kernel already provides. With this API, people
should never have to touch the old unix process API except to talk to
humans and other legacy systems. It's a big project, but worthwhile,
and we can do it piecemeal.

Christian, what worries me is that you want to make this project 10x
harder, both in technical and lkml-political terms, by making it work
without CONFIG_PROCFS=y. Without procfs, all the operations above that
involve the word "openat" or "/proc" break, which means that our
general-purpose process API needs to provide its own equivalents to
these operations, and on top of these, its own non-procfs pidfd FD
type --- let's call it pidfd_2. (Let's call a directory FD on
/proc/<pid> a pidfd_1.) Under this scheme, we have to have all
operations that accept a pidfd_1 (like pidfd_send_signal) and have
them accept pidfd_2 file descriptors as well in general fashion. (The
difference between pidfd_1 and pidfd_2 is visible to users who can
call fstat and look at st_dev.) We'd also need an API to translate a
pidfd_2 to a pidfd_1 so you could call openat on it to look at
/proc/<pid> data files, to support operation #7 above.  The
alternative to provide #7 is some kind of new general-purpose
process-information-retrieval interface that mirrors the functionality
/proc/<pid> already provides --- e.g., getting the smaps list for a
process.

To sum it up, we can

A) declare that pidfds don't work without CONFIG_PROCFS=y,
B) hardwire CONFIG_PROCFS=y in all configurations, or
C) support both procfs-based pidfd_1 FDs and non-procfs pidfd_2 FDs.

Option C seems like pointless complexity to me, as I described above.
Option C means that we have to duplicate a lot of existing and
perfectly good functionality.

Option A is fine by me, since I think CONFIG_PROCFS=n is just a
bonkers and broken configuration that's barely even Linux.

From a design perspective, I prefer option B: it turns a de-facto
guaranteed /proc ABI into a de-jure guaranteed ABI, and that's just
more straightforward for everyone --- especially since it reduces the
complexity of the Linux core by deleting all the !CONFIG_PROCFS code
paths. My point about the procfs system call is that *if* we go with
option B and make procfs mandatory, we're essentially stating that
certain kernel functionality is always available, and because (as a
general rule) kernel functionality that's always available should be
available to every process, we should provide a way to *use* this
always-present kernel functionality that doesn't depend on the mount
table --- thus my proposed get_procfs_root(2).

We don't have to decide between A and B right now. We can continue
develop pidfd development under the assumption we're going with option
A, and when option B seems like a good idea, we can just switch with
minimal hassle. On the other hand, if we did implement option C and,
later, it became apparently that option B was right after all, all the
work needed for option C would have been a waste.

