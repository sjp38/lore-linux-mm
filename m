Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D8F5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11E7F21873
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:29:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lBL4jIOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11E7F21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89276B0003; Wed, 20 Mar 2019 15:29:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A11936B0006; Wed, 20 Mar 2019 15:29:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1636B0007; Wed, 20 Mar 2019 15:29:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1666B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:29:44 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id x200so1419479vkd.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:29:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HKDZVJLbci8RoVuRdoZreNJclj5oDrpcOZ3lLcIS9UU=;
        b=BqSpIQrzbG5pUJ6DktSyx6ZUGzs1AvCDK2ybKH5G/dww/ypg0TFhLF0MHJNpPwHwC4
         eUSZNShU4fTt06j0KKP7cX84Vedafr/N7YKKMrmWpn7tsWrvfkKyW9AXr5nyHLjxIFJn
         vrwZntZS3wEPvY+9pUiJUtyRf/JBG4Lxvu3Ebr3OLCkHGsrd6kAyPHEyN3OBZNmmhwkM
         Hp/MNYbG/8M20H/DpraLr1CP2ADVKpCCgawPB80lulD9zZRIq8sNPAbXh7Oe4NxqYT7w
         H4Q49A6i8X6rHYGZFgoXAkWKA/E4vcb1OMl3zMY4YgCAMJVzUJESjBQjyT2Wzgvpj1Hm
         gqTg==
X-Gm-Message-State: APjAAAXSJBePH80hcR3vDc0XUOUx4wPa4p/M3A1v4iot+HkX69/GTZFq
	4J9rIPXOgyBN4t2gTYEMVBTP6bb7gOCriVyfJWbX90iGvJvSLEHlcRfQSxQr7a0JrE9M1rtj4Kf
	VDdRrnIkb+tPiEQEqQozuNjQ7iuGdit7xShT7bUqVWmojpOqpYucaKRWB3wri54EH7g==
X-Received: by 2002:a67:2544:: with SMTP id l65mr6001027vsl.240.1553110184039;
        Wed, 20 Mar 2019 12:29:44 -0700 (PDT)
X-Received: by 2002:a67:2544:: with SMTP id l65mr6000983vsl.240.1553110183063;
        Wed, 20 Mar 2019 12:29:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553110183; cv=none;
        d=google.com; s=arc-20160816;
        b=RwoK93xue9q5x+mWzQZD0w5sqUTzHS+MIdAh1w5wWs1IvGOIpUu2JVpEe2bt2a65WW
         QHWniFQMbPIVv+RANQzN6zKvsCa5OvII5L45V8P7Z7lcONVkTm7mdxxz+SuzQUX//Tb+
         m4NFavgElQIhv+Wt45Q/gacLRzw88H4AwLZmzhIbGtRTkknkQKSCGD08+o4sg6EDW5YB
         yuE+5XHN89RIBumu3FPDFoRsKGDhE/idCjs0IsOF5txfvHN3m61/uyZg7b5/UZKGr2Uc
         kM0wJsez/Kw1dHlunTM2ES6zGE40oXv2c8g0RzPXnJQJcrMKvc+xi3TMKBiXb10F9/Vd
         QNag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HKDZVJLbci8RoVuRdoZreNJclj5oDrpcOZ3lLcIS9UU=;
        b=AWfvWBdtcnnYqOfIaj4YhJPWVV2VKMJ73nqhLqIHNWasUTZVBDpFuovC010RByzONT
         PxpKhAc/RipMKaQlSnOvMHOM7jy054hejfA/T7f4OR3qdQGMT4Z4SABXTIpLd9AYKemN
         aosyCX0T6DjuwT4GaYveen2xchXWU4A8jbXx4GbETNjhddeKH3PrKjNHTmLgX6uToJ5I
         ulgMt4rutLt6zw7iSE4uASob2rJL7qbwg0b+IavvJEpSktMaqGAmUW2pn7ZNS5AEaARN
         7oIPQglIG0f3WCyNYxTuppNlBLeRPbca+AffcL2e5moY6I6dXaGN/JfQGXFx6exS4Sp4
         70AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lBL4jIOk;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor2240555vso.3.2019.03.20.12.29.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:29:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lBL4jIOk;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HKDZVJLbci8RoVuRdoZreNJclj5oDrpcOZ3lLcIS9UU=;
        b=lBL4jIOkrEs3fwB/HbteEV20fxt6zSCyK8Sw2O3+wzERFwf15cqJpGY4Mi+5iej0Zu
         NHg9SskzswgeLim9HXHjEJRCl7ST8eFEaKKWzTAcVLRKg6qhbKjyLUZ6f132xHqmVM7p
         lTn1rzRQSjncaR+5FYB4A/WFEyeNPXjy72yMjkUKu2DpQ7nDsvTKpwzjWUIw2QNsbDMG
         s4BJdLnAon8HFvWqatmSY5sU9fwvUeOfiIYzg607jntJCJdbEHlON/C9M8W+e1sN76uX
         VZSwlf5WP1F1p4ZrbfiSGZ3xcO4E5T52xKHih4mlp6ybIuhV71X5Rc0duGsQF+K236LA
         yszQ==
X-Google-Smtp-Source: APXvYqzZmYth0geZRwK8/cPaxo7MhfE1YtjjEraAL/oYZgwuyW0xlor+n6xIT1zPkSRABVAjWBYF3uVB+AKjBg5wf5k=
X-Received: by 2002:a67:cc2:: with SMTP id 185mr6019174vsm.77.1553110182296;
 Wed, 20 Mar 2019 12:29:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com> <20190320185156.7bq775vvtsxqlzfn@brauner.io>
In-Reply-To: <20190320185156.7bq775vvtsxqlzfn@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 20 Mar 2019 12:29:31 -0700
Message-ID: <CAKOZuetKkPaAZvRZyG3V6RMAgOJx08dH4K4ABqLnAf53WRUHTg@mail.gmail.com>
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

On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
>
> On Wed, Mar 20, 2019 at 11:38:35AM -0700, Daniel Colascione wrote:
> > On Wed, Mar 20, 2019 at 11:26 AM Christian Brauner <christian@brauner.io> wrote:
> > > On Wed, Mar 20, 2019 at 07:33:51AM -0400, Joel Fernandes wrote:
> > > >
> > > >
> > > > On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google.com> wrote:
> > > > >On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner
> > > > ><christian@brauner.io> wrote:
> > > > >>
> > > > >> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> > > > >> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes
> > > > ><joel@joelfernandes.org> wrote:
> > > > >> > >
> > > > >> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner
> > > > >wrote:
> > > > >> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione
> > > > >wrote:
> > > > >> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner
> > > > ><christian@brauner.io> wrote:
> > > > >> > > > > > So I dislike the idea of allocating new inodes from the
> > > > >procfs super
> > > > >> > > > > > block. I would like to avoid pinning the whole pidfd
> > > > >concept exclusively
> > > > >> > > > > > to proc. The idea is that the pidfd API will be useable
> > > > >through procfs
> > > > >> > > > > > via open("/proc/<pid>") because that is what users expect
> > > > >and really
> > > > >> > > > > > wanted to have for a long time. So it makes sense to have
> > > > >this working.
> > > > >> > > > > > But it should really be useable without it. That's why
> > > > >translate_pid()
> > > > >> > > > > > and pidfd_clone() are on the table.  What I'm saying is,
> > > > >once the pidfd
> > > > >> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=N
> > > > >- even
> > > > >> > > > > > though that's crazy - and still be able to use pidfds. This
> > > > >is also a
> > > > >> > > > > > point akpm asked about when I did the pidfd_send_signal
> > > > >work.
> > > > >> > > > >
> > > > >> > > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use
> > > > >pidfds. One
> > > > >> > > > > crazy idea that I was discussing with Joel the other day is
> > > > >to just
> > > > >> > > > > make CONFIG_PROCFS=Y mandatory and provide a new
> > > > >get_procfs_root()
> > > > >> > > > > system call that returned, out of thin air and independent of
> > > > >the
> > > > >> > > > > mount table, a procfs root directory file descriptor for the
> > > > >caller's
> > > > >> > > > > PID namspace and suitable for use with openat(2).
> > > > >> > > >
> > > > >> > > > Even if this works I'm pretty sure that Al and a lot of others
> > > > >will not
> > > > >> > > > be happy about this. A syscall to get an fd to /proc?
> > > > >> >
> > > > >> > Why not? procfs provides access to a lot of core kernel
> > > > >functionality.
> > > > >> > Why should you need a mountpoint to get to it?
> > > > >> >
> > > > >> > > That's not going
> > > > >> > > > to happen and I don't see the need for a separate syscall just
> > > > >for that.
> > > > >> >
> > > > >> > We need a system call for the same reason we need a getrandom(2):
> > > > >you
> > > > >> > have to bootstrap somehow when you're in a minimal environment.
> > > > >> >
> > > > >> > > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> > > > >> >
> > > > >> > I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> > > > >> > proposing that we *hardwire* it as the default and just declare
> > > > >that
> > > > >> > it's not possible to build a Linux kernel that doesn't include
> > > > >procfs.
> > > > >> > Why do we even have that button?
> > > > >> >
> > > > >> > > I think his point here was that he wanted a handle to procfs no
> > > > >matter where
> > > > >> > > it was mounted and then can later use openat on that. Agreed that
> > > > >it may be
> > > > >> > > unnecessary unless there is a usecase for it, and especially if
> > > > >the /proc
> > > > >> > > directory being the defacto mountpoint for procfs is a universal
> > > > >convention.
> > > > >> >
> > > > >> > If it's a universal convention and, in practice, everyone needs
> > > > >proc
> > > > >> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y?
> > > > >If
> > > > >> > we advertise /proc as not merely some kind of optional debug
> > > > >interface
> > > > >> > but *the* way certain kernel features are exposed --- and there's
> > > > >> > nothing wrong with that --- then we should give programs access to
> > > > >> > these core kernel features in a way that doesn't depend on
> > > > >userspace
> > > > >> > kernel configuration, and you do that by either providing a
> > > > >> > procfs-root-getting system call or just hardwiring the "/proc/"
> > > > >prefix
> > > > >> > into VFS.
> > > > >> >
> > > > >> > > > Inode allocation from the procfs mount for the file descriptors
> > > > >Joel
> > > > >> > > > wants is not correct. Their not really procfs file descriptors
> > > > >so this
> > > > >> > > > is a nack. We can't just hook into proc that way.
> > > > >> > >
> > > > >> > > I was not particular about using procfs mount for the FDs but
> > > > >that's the only
> > > > >> > > way I knew how to do it until you pointed out anon_inode (my grep
> > > > >skills
> > > > >> > > missed that), so thank you!
> > > > >> > >
> > > > >> > > > > C'mon: /proc is used by everyone today and almost every
> > > > >program breaks
> > > > >> > > > > if it's not around. The string "/proc" is already de facto
> > > > >kernel ABI.
> > > > >> > > > > Let's just drop the pretense of /proc being optional and bake
> > > > >it into
> > > > >> > > > > the kernel proper, then give programs a way to get to /proc
> > > > >that isn't
> > > > >> > > > > tied to any particular mount configuration. This way, we
> > > > >don't need a
> > > > >> > > > > translate_pid(), since callers can just use procfs to do the
> > > > >same
> > > > >> > > > > thing. (That is, if I understand correctly what translate_pid
> > > > >does.)
> > > > >> > > >
> > > > >> > > > I'm not sure what you think translate_pid() is doing since
> > > > >you're not
> > > > >> > > > saying what you think it does.
> > > > >> > > > Examples from the old patchset:
> > > > >> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> > > > >> >
> > > > >> > Ah, it's a bit different from what I had in mind. It's fair to want
> > > > >to
> > > > >> > translate PIDs between namespaces, but the only way to make the
> > > > >> > translate_pid under discussion robust is to have it accept and
> > > > >produce
> > > > >> > pidfds. (At that point, you might as well call it translate_pidfd.)
> > > > >We
> > > > >> > should not be adding new APIs to the kernel that accept numeric
> > > > >PIDs:
> > > > >>
> > > > >> The traditional pid-based api is not going away. There are users that
> > > > >> have the requirement to translate pids between namespaces and also
> > > > >doing
> > > > >> introspection on these namespaces independent of pidfds. We will not
> > > > >> restrict the usefulness of this syscall by making it only work with
> > > > >> pidfds.
> > > > >>
> > > > >> > it's not possible to use these APIs correctly except under very
> > > > >> > limited circumstances --- mostly, talking about init or a parent
> > > > >>
> > > > >> The pid-based api is one of the most widely used apis of the kernel
> > > > >and
> > > > >> people have been using it quite successfully for a long time. Yes,
> > > > >it's
> > > > >> rac, but it's here to stay.
> > > > >>
> > > > >> > talking about its child.
> > > > >> >
> > > > >> > Really, we need a few related operations, and we shouldn't
> > > > >necessarily
> > > > >> > mingle them.
> > > > >>
> > > > >> Yes, we've established that previously.
> > > > >>
> > > > >> >
> > > > >> > 1) Given a numeric PID, give me a pidfd: that works today: you just
> > > > >> > open /proc/<pid>
> > > > >>
> > > > >> Agreed.
> > > > >>
> > > > >> >
> > > > >> > 2) Given a pidfd, give me a numeric PID: that works today: you just
> > > > >> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> > > > >> > always the numeric PID).
> > > > >>
> > > > >> Agreed.
> > > > >>
> > > > >> >
> > > > >> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal
> > > > >does,
> > > > >> > and it's a good start on the rest of these operations.
> > > > >>
> > > > >> Agreed.
> > > > >>
> > > > >> > 5) Given a pidfd in NS1, get a pidfd in NS2. That's what
> > > > >translate_pid
> > > > >> > is for. My preferred signature for this routine is
> > > > >translate_pid(int
> > > > >> > pidfd, int nsfd) -> pidfd. We don't need two namespace arguments.
> > > > >Why
> > > > >> > not? Because the pidfd *already* names a single process, uniquely!
> > > > >>
> > > > >> Given that people are interested in pids we can't just always return
> > > > >a
> > > > >> pidfd. That would mean a user would need to do get the pidfd read
> > > > >from
> > > > >> <pidfd>/stat and then close the pidfd. If you do that for a 100 pids
> > > > >or
> > > > >> more you end up allocating and closing file descriptors constantly
> > > > >for
> > > > >> no reason. We can't just debate pids away. So it will also need to be
> > > > >> able to yield pids e.g. through a flag argument.
> > > > >
> > > > >Sure, but that's still not a reason that we should care about pidfds
> > > > >working separately from procfs..
> > >
> > > That's unrelated to the point made in the above paragraph.
> > > Please note, I said that the pidfd api should work when proc is not
> > > available not that they can't be dirfds.
> >
> > What do you mean by "not available"? CONFIG_PROCFS=n? If pidfds
>
> I'm talking about the ability to clone processes and get fd handles on
> them via pidfd_clone() or CLONE_NEWFD.

I wouldn't call that situation "proc [not being] available". We need
pidfd_clone to return a pidfd for atomicity reasons, not /proc
availability reasons. Again, it doesn't make any sense to support this
stuff when CONFIG_PROCFS=n, and CONFIG_PROCFS=n shouldn't even be a
supported configuration.

> > > translate_pid() should just return you a pidfd. Having it return a pidfd
> > > and a status fd feels like stuffing too much functionality in there. If
> > > you're fine with it I'll finish prototyping what I had in mind. As I
> > > said in previous mails I'm already working on this.
> >
> > translate_pid also needs to *accept* pidfds, at least optionally.
> > Unless you have a function from pidfd to pidfd, you race.
>
> You're misunderstanding. Again, I said in my previous mails it should
> accept pidfds optionally as arguments, yes. But I don't want it to
> return the status fds that you previously wanted pidfd_wait() to return.

Agreed. There should be a different way to get these wait handle FDs.

> I really want to see Joel's pidfd_wait() patchset and have more people
> review the actual code.

Sure. But it's also unpleasant to have people write code and then have
to throw it away due to guessing incorrectly about unclear
requirements.

