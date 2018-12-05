Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E01FB6B75E2
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 14:14:09 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id z17so8778652wmk.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 11:14:09 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x15si14931284wru.294.2018.12.05.11.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 05 Dec 2018 11:14:08 -0800 (PST)
Date: Wed, 5 Dec 2018 20:14:01 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181205191400.qrhim3m3ak5hcsuh@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <40a63aa5-edb6-4673-b4cc-1bc10e7b3953@windriver.com>
 <20181130181956.eewrlaabtceekzyu@linutronix.de>
 <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <e7795912-7d93-8f4e-b997-67c4ac1f3549@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Zhe <zhe.he@windriver.com>
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On 2018-12-05 21:53:37 [+0800], He Zhe wrote:
> For call trace 1:
=E2=80=A6
> Since kmemleak would most likely be used to debug in environments where
> we would not expect as great performance as without it, and kfree() has r=
aw locks
> in its main path and other debug function paths, I suppose it wouldn't hu=
rt that
> we change to raw locks.
okay.

> >> >From what I reached above, this is RT-only and happens on v4.18 and v=
4.19.
> >>
> >> The call trace above is caused by grabbing kmemleak_lock and then gett=
ing
> >> scheduled and then re-grabbing kmemleak_lock. Using raw lock can also =
solve
> >> this problem.
> > But this is a reader / writer lock. And if I understand the other part
> > of the thread then it needs multiple readers.
>=20
> For call trace 2:
>=20
> I don't get what "it needs multiple readers" exactly means here.
>=20
> In this call trace, the kmemleak_lock is grabbed as write lock, and then =
scheduled
> away, and then grabbed again as write lock from another path. It's a
> write->write locking, compared to the discussion in the other part of the=
 thread.
>=20
> This is essentially because kmemleak hooks on the very low level memory
> allocation and free operations. After scheduled away, it can easily re-en=
ter itself.
> We need raw locks to prevent this from happening.

With raw locks you wouldn't have multiple readers at the same time.
Maybe you wouldn't have recursion but since you can't have multiple
readers you would add lock contention where was none (because you could
have two readers at the same time).

> > Couldn't we just get rid of that kfree() or move it somewhere else?
> > I mean if the free() memory on CPU-down and allocate it again CPU-up
> > then we could skip that, rigth? Just allocate it and don't free it
> > because the CPU will likely get up again.
>=20
> For call trace 1:
>=20
> I went through the CPU hotplug code and found that the allocation of the
> problematic data, cpuc->shared_regs, is done in intel_pmu_cpu_prepare. And
> the free is done in intel_pmu_cpu_dying. They are handlers triggered by t=
wo
> different perf events.
>=20
> It seems we can hardly form a convincing method that holds the data while
> CPUs are off and then uses it again. raw locks would be easy and good eno=
ugh.

Why not allocate the memory in intel_pmu_cpu_prepare() if it is not
already there (otherwise skip the allocation) and in
intel_pmu_cpu_dying() not free it. It looks easy.

> Thanks,
> Zhe

Sebastian
