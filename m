Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BD7AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:02:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE1E2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:02:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fyxNliQL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE1E2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674886B0003; Wed, 20 Mar 2019 03:02:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624EE6B0006; Wed, 20 Mar 2019 03:02:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EC8B6B0007; Wed, 20 Mar 2019 03:02:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 243CA6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:02:47 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id g4so127170uak.17
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:02:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vAzgUFOLVUeLsi0TJbcZmkaGpPUw2R62FsElDTLduRg=;
        b=ZSv12dJYXx0xeP7YVvjKzddv/Sx1K9o6RFeHkT0Ixd1xegRspzpGGy0xNhzaK7/Dfe
         l7jlBMWztiTm8X3LcSUcWnMlKdkzOkUfieU7bG23vzFmn22vSWyPKMDj97uwNEpQpBM3
         l3pPMUCenNO7dCjhio5j5ckx4KHs7QBT5pzckBJtxC6HY3lQw/uUgW+h6ohOJyBK1Z3e
         BIxNvygH5OpWWJ+/3YCQIrmm5Hw8wFU172PgobNpkCg0V+a79akl2rMU8lo+lzuZTQfQ
         FBOP0KUEVqgFlM9fDXWGpMiI8Rmf5sJ86wWppOJZJMxzAusMkv/F5K1a7MUfUFf17MF+
         qZSQ==
X-Gm-Message-State: APjAAAWJ+7bIwOCaILB3auE8SPNb0CC5CSQUiJX+txxQ0dqQPa6lIssq
	PbXX36tMqHNFBDYuuwx+M0hXqytKsTYOvl/GZQSdpV3dw/kcetfHA4MMTzI/h2bxCFI4oDKxK2C
	KcjYbgCd+5mab/pZGaUPuHi2bwY75281iZzK8fh6JHKoaYaHSHKWdxyLI6mt68RkT8A==
X-Received: by 2002:ab0:73d3:: with SMTP id m19mr3566247uaq.46.1553065366700;
        Wed, 20 Mar 2019 00:02:46 -0700 (PDT)
X-Received: by 2002:ab0:73d3:: with SMTP id m19mr3566193uaq.46.1553065365297;
        Wed, 20 Mar 2019 00:02:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553065365; cv=none;
        d=google.com; s=arc-20160816;
        b=WcZKIWBeUC2zNFcYIT9p7jx+DtiP7GT/8eaQwnMnypCltpyY+Dz244zlPemQzb70h/
         vErrRLbb2Aj1lTE6gjb+UDnHXHzdXz6suKL6tfJu9M3zQxtS7pBZo3ie6cM+V7LSzKc6
         Wd2GpxP8U9JZ2D7EpB7okHK+0B5h1WvgX7RMbls9YQJn1EkPeATjP4ofLESJtwo+hdoP
         Vp1r2sMS8NwNbrWcoEeU3qMAqgAeXBvhOWcaox6FiKsr1INJthh/sF2hxUW6w0Wt2WmD
         gzwlNtIN7ZewlyjdqqTGqn6xZegwqKp8A7919XENldg8SAO74Q1dauNWtPfq4zwDudLg
         1jZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vAzgUFOLVUeLsi0TJbcZmkaGpPUw2R62FsElDTLduRg=;
        b=pk0a/h13JwWYY3mT6D5Wu+iEEerkgVV1GXgLiitIsh+IoIenAZM+F08eSgQaEztGyg
         8y8ikcL8eKE1GZkBpAM2yyd3m/4PWlppmHXvYIvj9QDOKvk7LQBGLasr9eJ2ura7zE/2
         23x0oz/GprNof4RvMSF9FAT1nklXEcRps8fkURChWnAafsfgh7AdJBM3K4dBzLydDyF/
         oISXZ88nuPVsme9i5onJaBg+d/p3lyf7bGLX5Q+E6I0qcUFRYbi9lZp19Fg8i7Cteusw
         yJMzkjLLLJdcO2MtwsMGwLem4jeVm2v6Q4s6j/g/wWl7VbMUQu+vSGwl5vSWIKv1E7Bw
         /M4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fyxNliQL;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 128sor828624vsr.75.2019.03.20.00.02.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 00:02:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fyxNliQL;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vAzgUFOLVUeLsi0TJbcZmkaGpPUw2R62FsElDTLduRg=;
        b=fyxNliQLxp3Nr34uwJ2T0LBfNXf/FWsZRLtPUpf+gLP4CDIaMf5qf1W36ZYWbO2C33
         2etZxVpe3HnaDRa1e5pv3Me+oaEURa0DpWaIL3ydJucWIfG/26rm7z5vo3vBaAbu2Nj9
         rSNae+6Gngf0K77jG+TV67FSIYgmU4nBDRzDfj7QjIQB1cIRAnp1rri0n6MzrQwajZiO
         Zlw8DfIOkLzg4JI/aJRQ1fp4FKqHjiA3zIT8Rrejt4j39rEFiaBgdgCU0+Oeak9dZf7O
         Ac5aDBa/YQ7zcQ5p5K0xiYfd6QBzXq/GNp3/iskdV2TC5FadutJqkgMCYTOAkXsppc0r
         dXJA==
X-Google-Smtp-Source: APXvYqzIYHl+ptUak8CWPxjPoPTrYJ56qLmPvgdqKaTs+cSZSkAKhJI29hST9o5aSTA58IUca80tbr+Y92AC22AkhTQ=
X-Received: by 2002:a67:e446:: with SMTP id n6mr3837465vsm.183.1553065364333;
 Wed, 20 Mar 2019 00:02:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190317015306.GA167393@google.com> <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io> <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com> <20190320035953.mnhax3vd47ya4zzm@brauner.io>
In-Reply-To: <20190320035953.mnhax3vd47ya4zzm@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 20 Mar 2019 00:02:32 -0700
Message-ID: <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
Subject: Re: pidfd design
To: Christian Brauner <christian@brauner.io>
Cc: Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
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

On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner <christian@brauner.io> wrote:
>
> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> > >
> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner wrote:
> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione wrote:
> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> > > > > > So I dislike the idea of allocating new inodes from the procfs super
> > > > > > block. I would like to avoid pinning the whole pidfd concept exclusively
> > > > > > to proc. The idea is that the pidfd API will be useable through procfs
> > > > > > via open("/proc/<pid>") because that is what users expect and really
> > > > > > wanted to have for a long time. So it makes sense to have this working.
> > > > > > But it should really be useable without it. That's why translate_pid()
> > > > > > and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=N - even
> > > > > > though that's crazy - and still be able to use pidfds. This is also a
> > > > > > point akpm asked about when I did the pidfd_send_signal work.
> > > > >
> > > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
> > > > > crazy idea that I was discussing with Joel the other day is to just
> > > > > make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
> > > > > system call that returned, out of thin air and independent of the
> > > > > mount table, a procfs root directory file descriptor for the caller's
> > > > > PID namspace and suitable for use with openat(2).
> > > >
> > > > Even if this works I'm pretty sure that Al and a lot of others will not
> > > > be happy about this. A syscall to get an fd to /proc?
> >
> > Why not? procfs provides access to a lot of core kernel functionality.
> > Why should you need a mountpoint to get to it?
> >
> > > That's not going
> > > > to happen and I don't see the need for a separate syscall just for that.
> >
> > We need a system call for the same reason we need a getrandom(2): you
> > have to bootstrap somehow when you're in a minimal environment.
> >
> > > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> >
> > I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> > proposing that we *hardwire* it as the default and just declare that
> > it's not possible to build a Linux kernel that doesn't include procfs.
> > Why do we even have that button?
> >
> > > I think his point here was that he wanted a handle to procfs no matter where
> > > it was mounted and then can later use openat on that. Agreed that it may be
> > > unnecessary unless there is a usecase for it, and especially if the /proc
> > > directory being the defacto mountpoint for procfs is a universal convention.
> >
> > If it's a universal convention and, in practice, everyone needs proc
> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y? If
> > we advertise /proc as not merely some kind of optional debug interface
> > but *the* way certain kernel features are exposed --- and there's
> > nothing wrong with that --- then we should give programs access to
> > these core kernel features in a way that doesn't depend on userspace
> > kernel configuration, and you do that by either providing a
> > procfs-root-getting system call or just hardwiring the "/proc/" prefix
> > into VFS.
> >
> > > > Inode allocation from the procfs mount for the file descriptors Joel
> > > > wants is not correct. Their not really procfs file descriptors so this
> > > > is a nack. We can't just hook into proc that way.
> > >
> > > I was not particular about using procfs mount for the FDs but that's the only
> > > way I knew how to do it until you pointed out anon_inode (my grep skills
> > > missed that), so thank you!
> > >
> > > > > C'mon: /proc is used by everyone today and almost every program breaks
> > > > > if it's not around. The string "/proc" is already de facto kernel ABI.
> > > > > Let's just drop the pretense of /proc being optional and bake it into
> > > > > the kernel proper, then give programs a way to get to /proc that isn't
> > > > > tied to any particular mount configuration. This way, we don't need a
> > > > > translate_pid(), since callers can just use procfs to do the same
> > > > > thing. (That is, if I understand correctly what translate_pid does.)
> > > >
> > > > I'm not sure what you think translate_pid() is doing since you're not
> > > > saying what you think it does.
> > > > Examples from the old patchset:
> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> >
> > Ah, it's a bit different from what I had in mind. It's fair to want to
> > translate PIDs between namespaces, but the only way to make the
> > translate_pid under discussion robust is to have it accept and produce
> > pidfds. (At that point, you might as well call it translate_pidfd.) We
> > should not be adding new APIs to the kernel that accept numeric PIDs:
>
> The traditional pid-based api is not going away. There are users that
> have the requirement to translate pids between namespaces and also doing
> introspection on these namespaces independent of pidfds. We will not
> restrict the usefulness of this syscall by making it only work with
> pidfds.
>
> > it's not possible to use these APIs correctly except under very
> > limited circumstances --- mostly, talking about init or a parent
>
> The pid-based api is one of the most widely used apis of the kernel and
> people have been using it quite successfully for a long time. Yes, it's
> rac, but it's here to stay.
>
> > talking about its child.
> >
> > Really, we need a few related operations, and we shouldn't necessarily
> > mingle them.
>
> Yes, we've established that previously.
>
> >
> > 1) Given a numeric PID, give me a pidfd: that works today: you just
> > open /proc/<pid>
>
> Agreed.
>
> >
> > 2) Given a pidfd, give me a numeric PID: that works today: you just
> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> > always the numeric PID).
>
> Agreed.
>
> >
> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal does,
> > and it's a good start on the rest of these operations.
>
> Agreed.
>
> > 5) Given a pidfd in NS1, get a pidfd in NS2. That's what translate_pid
> > is for. My preferred signature for this routine is translate_pid(int
> > pidfd, int nsfd) -> pidfd. We don't need two namespace arguments. Why
> > not? Because the pidfd *already* names a single process, uniquely!
>
> Given that people are interested in pids we can't just always return a
> pidfd. That would mean a user would need to do get the pidfd read from
> <pidfd>/stat and then close the pidfd. If you do that for a 100 pids or
> more you end up allocating and closing file descriptors constantly for
> no reason. We can't just debate pids away. So it will also need to be
> able to yield pids e.g. through a flag argument.

Sure, but that's still not a reason that we should care about pidfds
working separately from procfs.

