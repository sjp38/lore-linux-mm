Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6346CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 070722190A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 17:03:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="udceG1FM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 070722190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97A196B0007; Thu, 21 Mar 2019 13:03:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9299D6B0008; Thu, 21 Mar 2019 13:03:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 819DB6B000A; Thu, 21 Mar 2019 13:03:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C69A6B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:03:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 14so5990005pfh.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:03:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8nk9wC7VNLSYGbnKXNFliOMWzjti45R+hfkYeXkHyp8=;
        b=sAPbNl7syFIKRUvs9QaGGMFJvrAdep7D2LTlXzkFfM5PA38GnOzcuLz2h6RsMpzwGs
         yOf6pMfeBKgQyErstPTE053xyHRBgIDNZIfEKzpXGiNFWvxDE4pckE3BUcXXjilw4VIY
         5Gddp59VNJ6vvtdee6icoyJiYSEEpyyyKpufc63E4rrrkeXTsiQnWGeB1l7jT2vTCx7W
         M+7C5J8rOwRx82F2cXO3051UtXFVuGbQ995d+kuwYdzbUmRAlB3+rWrhjyH5NOoxdl4M
         AR8lf4jcJlDutf8LMf0iPV7v62XVK3r38Id4NznOFtjC21ZhB9hd9cNFh40cTdmesJ69
         wpJQ==
X-Gm-Message-State: APjAAAVj99kL9oHkxwxEmsrawEsYhYcSAM1LN/BrtMYJYromfywCFC/3
	D8LCRvTG+2uE44wd/DQsGJfeXhbucSE+O6F1Y82iXHjuPsVtwCzSgl/wny6bj1vu2tLhjIN0NhQ
	oROMmM+QToLuTN49llUsyxiwZximzNNx1MTQWc8azHurEpnqyhK6CzPD7g7l53YpvAQ==
X-Received: by 2002:a63:6883:: with SMTP id d125mr4298617pgc.324.1553187785785;
        Thu, 21 Mar 2019 10:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNcmIRM2stL3THt+Tr5N+4rlOb8QtnqUEZ14CorpVzb6dBTIyCesRCtftoPdb7tRoDLb3Q
X-Received: by 2002:a63:6883:: with SMTP id d125mr4298521pgc.324.1553187784657;
        Thu, 21 Mar 2019 10:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553187784; cv=none;
        d=google.com; s=arc-20160816;
        b=imSE9n1TflYirA0p9s9BiE64L6wr6h1ptGVy1cydn0jXY8M5JihxH2nOZhX8xpWvrT
         m7KzeeJheOS8Bf/6BFm85ZQf8+Azt++MyzMD657w8ozarQXC7tO+5DcK0FMXyzWm7VxY
         I0wApjn4YQlGDatAc8Peu0wq1NznUf+wBH84ffxQSjeQVH7qV6YM3eCVkXnl4TY7qKvb
         Ipr5kPMztYajqZbvtZpBV+6+xzRdccOv1yUjizLQcdosSngmFKbNT4sSfdtSdOrJwqi1
         mOjLkL0eo2VHYdUS6ewVg3iSPm0kD1S+ZQPJ8jpL0cltnINI8cPpZ0KA//3FfLCkdUND
         gPXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8nk9wC7VNLSYGbnKXNFliOMWzjti45R+hfkYeXkHyp8=;
        b=JX4nYFMPcEiXsxf5MtoUTuhgGTJDlUtW++g+wueH0+H0kI9eg9wLEZFY7lb86w2KhQ
         oS7+35jkEGKFUuzHCO12vlnjV7IUYo58+KO2mmkmPeNfHczJs3xvB0W+/cV0Y0XcxCjC
         7poFtY7ErXoclul87ci3RuXUmI0dDrtCfTfW3nmtlCl2eHqKdizhOkUWRt9OTuSsLiPM
         7VYurWY5MhAaEiQCk3aqtsA9EriTT0ICFuBGXr7Tf0R5z3TZH7B0vF/+jdn2AlmozJG3
         fqhDq9YF7yxXVlLqWPynFZlN43+rlyGR9mBsDrZDdjPa42Ayo/O/WjIYHeFJlxI+hDOn
         UZ7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=udceG1FM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h6si4428851pfc.255.2019.03.21.10.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 10:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=udceG1FM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F10202196E
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:03:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553187784;
	bh=y92cZEHdoDTXHyB7361NDOYr7VXAJFgdUc2dCy4T9OM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=udceG1FM5zLjpCWWEV9rh2gRF88G5Ntp4PA8sRxZtRWbnOfQGKv9C95B/V7CNBiQ5
	 qNHLJv/uBjK+7LdQTa4F+TLQ+BW8GPOutSn8axo86hgl1fDMnUQm3a+3oafVf/OrNh
	 HTtNbtKYBTG4NMwaHYZq4k2/w57HfCk4Uo9udiu4=
Received: by mail-wr1-f50.google.com with SMTP id q1so7488308wrp.0
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:03:03 -0700 (PDT)
X-Received: by 2002:a5d:6252:: with SMTP id m18mr3147947wrv.199.1553187782467;
 Thu, 21 Mar 2019 10:03:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io> <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
 <20190320191412.5ykyast3rgotz3nu@brauner.io> <CAKOZuesRwQ4=Svu1KgHWY=HZSS8mF8uFmuzuVOSH0QpJoy7a5w@mail.gmail.com>
In-Reply-To: <CAKOZuesRwQ4=Svu1KgHWY=HZSS8mF8uFmuzuVOSH0QpJoy7a5w@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 21 Mar 2019 10:02:50 -0700
X-Gmail-Original-Message-ID: <CALCETrUFrFKC2YTLH7ViM_7XPYk3LNmNiaz6s8wtWo1pmJQXzg@mail.gmail.com>
Message-ID: <CALCETrUFrFKC2YTLH7ViM_7XPYk3LNmNiaz6s8wtWo1pmJQXzg@mail.gmail.com>
Subject: Re: pidfd design
To: Daniel Colascione <dancol@google.com>
Cc: Christian Brauner <christian@brauner.io>, Andy Lutomirski <luto@kernel.org>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 12:40 PM Daniel Colascione <dancol@google.com> wrote:
>
> On Wed, Mar 20, 2019 at 12:14 PM Christian Brauner <christian@brauner.io> wrote:
> >
> > On Wed, Mar 20, 2019 at 11:58:57AM -0700, Andy Lutomirski wrote:
> > > On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > >
> > > > You're misunderstanding. Again, I said in my previous mails it should
> > > > accept pidfds optionally as arguments, yes. But I don't want it to
> > > > return the status fds that you previously wanted pidfd_wait() to return.
> > > > I really want to see Joel's pidfd_wait() patchset and have more people
> > > > review the actual code.
> > >
> > > Just to make sure that no one is forgetting a material security consideration:
> >
> > Andy, thanks for commenting!
> >
> > >
> > > $ ls /proc/self
> > > attr             exe        mountinfo      projid_map    status
> > > autogroup        fd         mounts         root          syscall
> > > auxv             fdinfo     mountstats     sched         task
> > > cgroup           gid_map    net            schedstat     timers
> > > clear_refs       io         ns             sessionid     timerslack_ns
> > > cmdline          latency    numa_maps      setgroups     uid_map
> > > comm             limits     oom_adj        smaps         wchan
> > > coredump_filter  loginuid   oom_score      smaps_rollup
> > > cpuset           map_files  oom_score_adj  stack
> > > cwd              maps       pagemap        stat
> > > environ          mem        personality    statm
> > >
> > > A bunch of this stuff makes sense to make accessible through a syscall
> > > interface that we expect to be used even in sandboxes.  But a bunch of
> > > it does not.  For example, *_map, mounts, mountstats, and net are all
> > > namespace-wide things that certain policies expect to be unavailable.
> > > stack, for example, is a potential attack surface.  Etc.
>
> If you can access these files sources via open(2) on /proc/<pid>, you
> should be able to access them via a pidfd. If you can't, you
> shouldn't. Which /proc? The one you'd get by mounting procfs. I don't
> see how pidfd makes any material changes to anyone's security. As far
> as I'm concerned, if a sandbox can't mount /proc at all, it's just a
> broken and unsupported configuration.

It's not "broken and unsupported".  I know of an actual working,
deployed container-ish sandbox that does exactly this.  I would also
guess that quite a few not-at-all-container-like sandboxes work like
this.  (The obvious seccomp + unshare + pivot_root
deny-myself-access-to-lots-of-things trick results in no /proc, which
is by dsign.)

>
> An actual threat model and real thought paid to access capabilities
> would help. Almost everything around the interaction of Linux kernel
> namespaces and security feels like a jumble of ad-hoc patches added as
> afterthoughts in response to random objections.

I fully agree.  But if you start thinking for real about access
capabilities, there's no way that you're going to conclude that a
capability to access some process implies a capability to access the
settings of its network namespace.

>
> >> All these new APIs either need to
> > > return something more restrictive than a proc dirfd or they need to
> > > follow the same rules.
>

...

> What's special about libraries? How is a library any worse-off using
> openat(2) on a pidfd than it would be just opening the file called
> "/proc/$apid"?

Because most libraries actually work, right now, without /proc.  Even
libraries that spawn subprocesses.  If we make the new API have the
property that it doesn't work if you're in a non-root user namespace
and /proc isn't mounted, the result will be an utter mess.

>
> > > Yes, this is unfortunate, but it is indeed the current situation.  I
> > > suppose that we could return magic restricted dirfds, or we could
> > > return things that aren't dirfds and all and have some API that gives
> > > you the dirfd associated with a procfd but only if you can see
> > > /proc/PID.
> >
> > What would be your opinion to having a
> > /proc/<pid>/handle
> > file instead of having a dirfd. Essentially, what I initially proposed
> > at LPC. The change on what we currently have in master would be:
> > https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df
>
> And how do you propose, given one of these handle objects, getting a
> process's current priority, or its current oom score, or its list of
> memory maps? As I mentioned in my original email, and which nobody has
> addressed, if you don't use a dirfd as your process handle or you
> don't provide an easy way to get one of these proc directory FDs, you
> need to duplicate a lot of metadata access interfaces.

An API that takes a process handle object and an fd pointing at /proc
(the root of the proc fs) and gives you back a proc dirfd would do the
trick.  You could do this with no new kernel features at all if you're
willing to read the pid, call openat(2), and handle the races in user
code.

