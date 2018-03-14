Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 435846B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:22:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z3-v6so2017317pln.23
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:22:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v2si2488278pgf.530.2018.03.14.15.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 15:22:05 -0700 (PDT)
Date: Wed, 14 Mar 2018 15:22:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
Message-Id: <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
In-Reply-To: <20180314220909.GE2943022@devbig577.frc2.facebook.com>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
	<20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
	<20180314220909.GE2943022@devbig577.frc2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 14 Mar 2018 15:09:09 -0700 Tejun Heo <tj@kernel.org> wrote:

> Hello, Andrew.
> 
> On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
> > It would benefit from a comment explaining why we're doing this (it's
> > for the oom-killer).
> 
> Will add.
> 
> > My memory is weak and our documentation is awful.  What does
> > mutex_lock_killable() actually do and how does it differ from
> > mutex_lock_interruptible()?  Userspace tasks can run pcpu_alloc() and I
> 
> IIRC, killable listens only to SIGKILL.
> 
> > wonder if there's any way in which a userspace-delivered signal can
> > disrupt another userspace task's memory allocation attempt?
> 
> Hmm... maybe.  Just honoring SIGKILL *should* be fine but the alloc
> failure paths might be broken, so there are some risks.  Given that
> the cases where userspace tasks end up allocation percpu memory is
> pretty limited and/or priviledged (like mount, bpf), I don't think the
> risks are high tho.

hm.  spose so.  Maybe.  Are there other ways?  I assume the time is
being spent in pcpu_create_chunk()?  We could drop the mutex while
running that stuff and take the appropriate did-we-race-with-someone
testing after retaking it.  Or similar.
