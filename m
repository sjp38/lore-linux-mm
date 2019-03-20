Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDF01C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F4032183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="dK4LQal2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F4032183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED3A86B0003; Tue, 19 Mar 2019 21:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E59D96B0006; Tue, 19 Mar 2019 21:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD3C66B0007; Tue, 19 Mar 2019 21:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A981E6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:52:53 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 75so14361434qki.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:52:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=URYsqXzm4tpouWLG3Ria7i5qb4uisz6pczg3Jg8fHXg=;
        b=EfgfLrD/BjVMAaCsmzkvwAgoT8GZEhcLJW2GaQDDPbPaHf6ntwI0RMCvKcumDde0oS
         VzjXNCy6/7lF5GmYTbJ6WuvZPRj9xCVraoVvyawOELp2FpG3LCxYy3eVYQcFNjIHy3Uh
         R7GHJAeQCergY5dEYjqPXNk68NskKV4XJMAqt6S5LDe4hbJBKGydq4nGw7Bf3juR2SU7
         Rji0KwXWtE8ATNJW9QaSSSmfgHQlBWLJt7mSnB9egmy2zKPQpm7UrSyAtHCmcx7xAa9/
         AoOydXNcgRWweG8DaHipcW4yG25C0XW9ru/1cuAs+DcmaxosowWvqd2aA36UUkhY1j3f
         3bEg==
X-Gm-Message-State: APjAAAV6YogjW+2hbfoD6rIveoQtcX75xiTeQ8IP/n6ArP6cKCwWD1rr
	mppC7gTtuSYEpTrIKubF7AA4Om0nhRywlv/QBzm7GCVZM0MhmF1eOnzUQCDPcE/DECzCdIbXZ+g
	PovRXNDLKMBWccwVve85FBLyexOcVLX88CclepBLEn9oU/Q5Y65Xg8ISlOZ/92zGURw==
X-Received: by 2002:a0c:d0f3:: with SMTP id b48mr4443354qvh.139.1553046773340;
        Tue, 19 Mar 2019 18:52:53 -0700 (PDT)
X-Received: by 2002:a0c:d0f3:: with SMTP id b48mr4443317qvh.139.1553046772189;
        Tue, 19 Mar 2019 18:52:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553046772; cv=none;
        d=google.com; s=arc-20160816;
        b=yesPDYoWlQt5oIgJG23QIjMW3SIVY43pytz1CqYOGBpGnpsCLgOa1lyzhqX9XZnOjF
         0rgNJK3W9qzl18dXdAjRSk911CKGNINzFexVexO1e/h42vy0LTif1GxmS1SKtykvOv67
         5pFYQ775jC1PmgPFemkEpkCgkAuKte2Gfi6EPoEWaL4VY7qygo6MciCKPxX3/mpJ3CAt
         B2FmoLa7nfGWXUlSy7ves1I4PlpCKAxvF2Qkdu8Kjvf5r0uXAAcAj1WYCzUOfZvh9Ya4
         jRBDZnJkgVg7a1ihmK/L2dNJY95uSGruMYMXztwCB+SnuaGN9e3tQdLWWye5usrw5eT/
         Dxnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=URYsqXzm4tpouWLG3Ria7i5qb4uisz6pczg3Jg8fHXg=;
        b=DpzPs96eFAtfrCzwJh9h5FT+XAZBX60jKinTwE05gTbF2ob1LgnPJSZR6FqNJXZp49
         8q6ZORpBWlCcsh1WDnkwjaDRj1pa9cCTJxUKCbcY3iB289obh/W8X24Lll0MmA8Za/hR
         mAlVjx2POecyNpmA4t+EaoExb9cRqUEpTzLVjPgXVbiaks0uOZDvQo33bEBT+6dEyEQn
         57JYmnX+YXLAuyml/006I3MRAzNFOIoA/yRVgUI4zs2iGhyuYFHSWj9Hq+wPNZCxT3hV
         TvvipQP7jhybnd1CAjp27P0DEnkXM5kSDILyM/IMdmHrimavYYlRKDxdaQjNO4D2QX9n
         qNUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=dK4LQal2;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor1177698qtj.62.2019.03.19.18.52.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 18:52:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=dK4LQal2;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=URYsqXzm4tpouWLG3Ria7i5qb4uisz6pczg3Jg8fHXg=;
        b=dK4LQal2tGrvNa1nScgf/3oiN6mSuxN8xz/BwabXf8ZuCHrRh46yKA5uAtsZ5TrC9W
         rKmwOcQdsboFYsplDCMiuBD3eES7eNcSjP664ETourBZuFhgRal0ClFZQ8ngCB6gwYPE
         xTlF7aoAGjTcd7R3j2eQySf6kP/FuKOGS3dmA=
X-Google-Smtp-Source: APXvYqx+foeYw1DyavKsbljAbp9XQfjAgI+VcP6eQPgdScgF62bYg9Q0IuXwzRlzeQxwUQx3Dl+qvA==
X-Received: by 2002:aed:20e4:: with SMTP id 91mr4530293qtb.362.1553046771741;
        Tue, 19 Mar 2019 18:52:51 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id z140sm409609qka.81.2019.03.19.18.52.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 18:52:50 -0700 (PDT)
Date: Tue, 19 Mar 2019 21:52:49 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
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
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190320015249.GC129907@google.com>
References: <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319231020.tdcttojlbmx57gke@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner wrote:
> On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione wrote:
> > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> > > So I dislike the idea of allocating new inodes from the procfs super
> > > block. I would like to avoid pinning the whole pidfd concept exclusively
> > > to proc. The idea is that the pidfd API will be useable through procfs
> > > via open("/proc/<pid>") because that is what users expect and really
> > > wanted to have for a long time. So it makes sense to have this working.
> > > But it should really be useable without it. That's why translate_pid()
> > > and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> > > api is "complete" you should be able to set CONFIG_PROCFS=N - even
> > > though that's crazy - and still be able to use pidfds. This is also a
> > > point akpm asked about when I did the pidfd_send_signal work.
> > 
> > I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
> > crazy idea that I was discussing with Joel the other day is to just
> > make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
> > system call that returned, out of thin air and independent of the
> > mount table, a procfs root directory file descriptor for the caller's
> > PID namspace and suitable for use with openat(2).
> 
> Even if this works I'm pretty sure that Al and a lot of others will not
> be happy about this. A syscall to get an fd to /proc? That's not going
> to happen and I don't see the need for a separate syscall just for that.
> (I do see the point of making CONFIG_PROCFS=y the default btw.)

I think his point here was that he wanted a handle to procfs no matter where
it was mounted and then can later use openat on that. Agreed that it may be
unnecessary unless there is a usecase for it, and especially if the /proc
directory being the defacto mountpoint for procfs is a universal convention.

> Inode allocation from the procfs mount for the file descriptors Joel
> wants is not correct. Their not really procfs file descriptors so this
> is a nack. We can't just hook into proc that way.

I was not particular about using procfs mount for the FDs but that's the only
way I knew how to do it until you pointed out anon_inode (my grep skills
missed that), so thank you!

> > C'mon: /proc is used by everyone today and almost every program breaks
> > if it's not around. The string "/proc" is already de facto kernel ABI.
> > Let's just drop the pretense of /proc being optional and bake it into
> > the kernel proper, then give programs a way to get to /proc that isn't
> > tied to any particular mount configuration. This way, we don't need a
> > translate_pid(), since callers can just use procfs to do the same
> > thing. (That is, if I understand correctly what translate_pid does.)
> 
> I'm not sure what you think translate_pid() is doing since you're not
> saying what you think it does.
> Examples from the old patchset:
> translate_pid(pid, ns, -1)      - get pid in our pid namespace
> translate_pid(pid, -1, ns)      - get pid in other pid namespace
> translate_pid(1, ns, -1)        - get pid of init task for namespace
> translate_pid(pid, -1, ns) > 0  - is pid is reachable from ns?
> translate_pid(1, ns1, ns2) > 0  - is ns1 inside ns2?
> translate_pid(1, ns1, ns2) == 0 - is ns1 outside ns2?
> translate_pid(1, ns1, ns2) == 1 - is ns1 equal ns2?
> 
> Allowing this syscall to yield pidfds as proper regular file fds and
> also taking pidfds as argument is an excellent way to kill a few
> problems at once:
> - cheap pid namespace introspection
> - creates a bridge between the "old" pid-based api and the "new" pidfd api

This second point would solve the problem of getting a new pidfd given a pid
indeed, without depending on /proc/<pid> at all. So kudos for that and I am
glad you are making it return pidfds (but correct me if I misunderstood what
you're planning to do with translate_fd). It also obviates any need for
dealing with procfs mount points.

> - allows us to get proper non-directory file descriptors for any pids we
>   like

Here I got a bit lost. AIUI pidfd is a directory fd. Why would we want it to
not be a directory fd? That would be ambigiuous with what pidfd_send_signal
expects.

Also would it be a bad idea to extend translate_pid to also do what we want
for the pidfd_wait syscall?  So translate_fd in this case would return an fd
that is just used for the pid's death status.

All of these extensions seem to mean translate_pid should probably take a
fourth parameter that tells it the target translation type?

They way I am hypothesizing, translate_pid, it should probably be
- translation to a pid in some ns
- translation of a pid to a pidfd
- translation of a pid to a "wait" fd which returns the death/reap process status.

If that makes sense, that would also avoid the need for a new syscall we are adding.

> The additional advantage is that people are already happy to add this
> syscall so simply extending it and routing it through the pidfd tree or
> Eric's tree is reasonable. (It should probably grow a flag argument. I
> need to start prototyping this.)

Great!

> > 
> > We still need a pidfd_clone() for atomicity reasons, but that's a
> > separate story. My goal is to be able to write a library that
> 
> Yes, on my todo list and I have a ported patch based on prior working
> rotting somehwere on my git server.

Is that different from using dup2 on a pidfd?  Sorry I don't follow what is
pidfd_clone / why it is needed.

thanks,

 - Joel

