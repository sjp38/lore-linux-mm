Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33448C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 04:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDBC6204FD
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 04:00:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="TxoOuXhB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDBC6204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683016B026B; Wed, 20 Mar 2019 00:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 659816B026C; Wed, 20 Mar 2019 00:00:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5476B6B026D; Wed, 20 Mar 2019 00:00:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26DD46B026B
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:00:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t13so19850402qkm.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:00:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0k0N07/xnhJHi88frcmOSoHhbMjls/ZerpoxQrxBm4o=;
        b=hCj6+o4t2nZHfhKzNOQZCKMzx4mVFPOH+2bf0UdJ5PeEt6+KOd3NU/HbVusOZiCv8Y
         6hinE65KIBs8SHt8o5IIULoTbGtzKrzx4YeXNQ8Vx/ScpG+uxgLC9SAgrLi6CeJ9LKnT
         L3NjneaooLYkUZUCMX0L8EZWIOB2tUvpv7bcn/obPwSKwDagBwglmWAO6n1KXn6SKDNF
         6fhWd7EjAdAZa4NqX0F4x2GpoXqgZxBBekq7siHaGgcs1nLtKCxqqpdyOeISJ2tJQrS3
         K5/UfFidtofh3/FmevmGkqLXbyxJ4RjwcQ9993gZ4if9CXiQBWAyYJc4J29kptPmPi3t
         bBoQ==
X-Gm-Message-State: APjAAAXT27k9HwxYtGIjyQAmEjDZPM9Vsm4DILfBUQL6LOsQDe5XWNhr
	+BKWdOo3l/BzUBgANMmKkOJeF4rYb1gT5ElIKRMZF13FGvKsx78vuEZkpdFf0YEEpFjrtFDuyoS
	bVtIdJKe/W6fdVYF21jvDn5XaG13bdZF0Va64HaW/DBsz8fwyR8It1IwyaibqZ7epiA==
X-Received: by 2002:a0c:9068:: with SMTP id o95mr4607343qvo.177.1553054399848;
        Tue, 19 Mar 2019 20:59:59 -0700 (PDT)
X-Received: by 2002:a0c:9068:: with SMTP id o95mr4607315qvo.177.1553054398845;
        Tue, 19 Mar 2019 20:59:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553054398; cv=none;
        d=google.com; s=arc-20160816;
        b=Pkht1uZCoMmo7HlkZUUVarmpDYLZnW8s47XCBejwkWz+lD6Po688D1NdoUuXf3xOgY
         O3cEmig/zgcqDoj4ZdT7j9JhtDgQSfNbEDMZjOzECAFPvzvQgsEULQzMlS+bqOMssBZ5
         Xx3b0DMkA8LxTezlqWQs9l9RlUdyiTwf/JlUUwkMQQ4i0hO1FZPj2eSdHNMSbhHPifbM
         ZulD3pqsaV1upRlCIpCDAw/D9Y68ujvhCW2FYUANuP8fg3DzWIXQe4x2Ed31wZcYZIn7
         jC6WFWYpPQeeL2xYHFQOTAQ5mo3f9AdUdYGB/knERo7uj/nKlOlDxdPjklCK0/yoZMxU
         N1zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0k0N07/xnhJHi88frcmOSoHhbMjls/ZerpoxQrxBm4o=;
        b=ZqIsdXPD3llVVJ2AMQfEAQEQITMBp0yOKgAU6xROalQU9Hbs8VPKWeiZFbmshBy89n
         sNORMm8gdoeXVaLaB+D0XcqmU47NieU294EAmdE1VYZ6j9NgBQ9E+PzzauotiJIVqxDL
         R+5gHShlYhb/2RlOGIUrF9CSmR83SH7upGMht8NAXHGaIFuGCspkZujtElmn1vfwBv3g
         XjhkOGwmUeCKXI7PZjAACvGXClcDFXGHVwtO73w6QXwbqe+nRfHXd5th+w3spsODMsYo
         KMh/XSNcPsrRrGa9Ysgd4/Vdg+8HqfKJtAJ3S+G6onZKIomBeWgdv3M4mVi1Duic4aaO
         PJ2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=TxoOuXhB;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19sor895321qve.33.2019.03.19.20.59.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 20:59:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=TxoOuXhB;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0k0N07/xnhJHi88frcmOSoHhbMjls/ZerpoxQrxBm4o=;
        b=TxoOuXhBmzxTHJ27kgV8HMgFJ2eoNVm/M/ymHkgZ4ZjoCucr/H5s2QrDxWN1CG5DD1
         1IBDo+672dAUrvuIVjYkZmeVXnUQCUJh/2+l6h99yGdfxuVy7XxcejEjz0aRIWodrHuF
         exF+FgmNdDEW1gwnGULHxG7Osb5DP+m2J3PTW/nmKvwtgBBU3XrD7VDMn8MCle42Vjt+
         ikzSOC+dXSZFEJMDfe5CeW/b0JtDnjSk+gJoLLg9i2YvqvSI6Ewvj7PxY3xZmjnL8Epa
         PXKKrcPl1Z4iZ5sNCfin5KZ+WKrtCETq0xBdnfWock8EiixxXMuNAYYfbuQW7eVSXH6F
         OzXw==
X-Google-Smtp-Source: APXvYqwaTpxDJza9kXs1yBDpg8F43lpDkr3+IbnSxmkrRpvN0iF8IHEYUr5bpVBjV8VqoV0YzbTTNQ==
X-Received: by 2002:a0c:b92c:: with SMTP id u44mr4707269qvf.222.1553054398368;
        Tue, 19 Mar 2019 20:59:58 -0700 (PDT)
Received: from brauner.io ([50.238.205.70])
        by smtp.gmail.com with ESMTPSA id i68sm491021qkc.63.2019.03.19.20.59.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 20:59:57 -0700 (PDT)
Date: Wed, 20 Mar 2019 04:59:54 +0100
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
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
Message-ID: <20190320035953.mnhax3vd47ya4zzm@brauner.io>
References: <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner wrote:
> > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione wrote:
> > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> > > > > So I dislike the idea of allocating new inodes from the procfs super
> > > > > block. I would like to avoid pinning the whole pidfd concept exclusively
> > > > > to proc. The idea is that the pidfd API will be useable through procfs
> > > > > via open("/proc/<pid>") because that is what users expect and really
> > > > > wanted to have for a long time. So it makes sense to have this working.
> > > > > But it should really be useable without it. That's why translate_pid()
> > > > > and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> > > > > api is "complete" you should be able to set CONFIG_PROCFS=N - even
> > > > > though that's crazy - and still be able to use pidfds. This is also a
> > > > > point akpm asked about when I did the pidfd_send_signal work.
> > > >
> > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
> > > > crazy idea that I was discussing with Joel the other day is to just
> > > > make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
> > > > system call that returned, out of thin air and independent of the
> > > > mount table, a procfs root directory file descriptor for the caller's
> > > > PID namspace and suitable for use with openat(2).
> > >
> > > Even if this works I'm pretty sure that Al and a lot of others will not
> > > be happy about this. A syscall to get an fd to /proc?
> 
> Why not? procfs provides access to a lot of core kernel functionality.
> Why should you need a mountpoint to get to it?
> 
> > That's not going
> > > to happen and I don't see the need for a separate syscall just for that.
> 
> We need a system call for the same reason we need a getrandom(2): you
> have to bootstrap somehow when you're in a minimal environment.
> 
> > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> 
> I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> proposing that we *hardwire* it as the default and just declare that
> it's not possible to build a Linux kernel that doesn't include procfs.
> Why do we even have that button?
> 
> > I think his point here was that he wanted a handle to procfs no matter where
> > it was mounted and then can later use openat on that. Agreed that it may be
> > unnecessary unless there is a usecase for it, and especially if the /proc
> > directory being the defacto mountpoint for procfs is a universal convention.
> 
> If it's a universal convention and, in practice, everyone needs proc
> mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y? If
> we advertise /proc as not merely some kind of optional debug interface
> but *the* way certain kernel features are exposed --- and there's
> nothing wrong with that --- then we should give programs access to
> these core kernel features in a way that doesn't depend on userspace
> kernel configuration, and you do that by either providing a
> procfs-root-getting system call or just hardwiring the "/proc/" prefix
> into VFS.
> 
> > > Inode allocation from the procfs mount for the file descriptors Joel
> > > wants is not correct. Their not really procfs file descriptors so this
> > > is a nack. We can't just hook into proc that way.
> >
> > I was not particular about using procfs mount for the FDs but that's the only
> > way I knew how to do it until you pointed out anon_inode (my grep skills
> > missed that), so thank you!
> >
> > > > C'mon: /proc is used by everyone today and almost every program breaks
> > > > if it's not around. The string "/proc" is already de facto kernel ABI.
> > > > Let's just drop the pretense of /proc being optional and bake it into
> > > > the kernel proper, then give programs a way to get to /proc that isn't
> > > > tied to any particular mount configuration. This way, we don't need a
> > > > translate_pid(), since callers can just use procfs to do the same
> > > > thing. (That is, if I understand correctly what translate_pid does.)
> > >
> > > I'm not sure what you think translate_pid() is doing since you're not
> > > saying what you think it does.
> > > Examples from the old patchset:
> > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> 
> Ah, it's a bit different from what I had in mind. It's fair to want to
> translate PIDs between namespaces, but the only way to make the
> translate_pid under discussion robust is to have it accept and produce
> pidfds. (At that point, you might as well call it translate_pidfd.) We
> should not be adding new APIs to the kernel that accept numeric PIDs:

The traditional pid-based api is not going away. There are users that
have the requirement to translate pids between namespaces and also doing
introspection on these namespaces independent of pidfds. We will not
restrict the usefulness of this syscall by making it only work with
pidfds.

> it's not possible to use these APIs correctly except under very
> limited circumstances --- mostly, talking about init or a parent

The pid-based api is one of the most widely used apis of the kernel and
people have been using it quite successfully for a long time. Yes, it's
rac, but it's here to stay.

> talking about its child.
> 
> Really, we need a few related operations, and we shouldn't necessarily
> mingle them.

Yes, we've established that previously.

> 
> 1) Given a numeric PID, give me a pidfd: that works today: you just
> open /proc/<pid>

Agreed.

> 
> 2) Given a pidfd, give me a numeric PID: that works today: you just
> openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> always the numeric PID).

Agreed.

> 
> 3) Given a pidfd, send a signal: that's what pidfd_send_signal does,
> and it's a good start on the rest of these operations.

Agreed.

> 5) Given a pidfd in NS1, get a pidfd in NS2. That's what translate_pid
> is for. My preferred signature for this routine is translate_pid(int
> pidfd, int nsfd) -> pidfd. We don't need two namespace arguments. Why
> not? Because the pidfd *already* names a single process, uniquely!

Given that people are interested in pids we can't just always return a
pidfd. That would mean a user would need to do get the pidfd read from
<pidfd>/stat and then close the pidfd. If you do that for a 100 pids or
more you end up allocating and closing file descriptors constantly for
no reason. We can't just debate pids away. So it will also need to be
able to yield pids e.g. through a flag argument.

> 
> 6) Make a new process and atomically give me a pidfd for it. We need a
> new kind of clone(2) for that. People have been proposing some kind of
> FD-based fork/spawn/etc. thing for ages, and we can finally provide
> it. Yay.

Agreed.

