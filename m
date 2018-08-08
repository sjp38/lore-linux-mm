Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 934286B0005
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 19:02:43 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id k5-v6so3072541ual.10
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 16:02:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2-v6sor1856069vkq.228.2018.08.08.16.02.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 16:02:42 -0700 (PDT)
MIME-Version: 1.0
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz> <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
 <20180808161330.GA22863@localhost> <f32ab99a-de28-b140-a7d0-027073055728@virtuozzo.com>
 <b4b58edd-b317-6319-1306-7345aa0062b8@virtuozzo.com> <20180808180152.GA2480@localhost>
In-Reply-To: <20180808180152.GA2480@localhost>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 8 Aug 2018 16:02:29 -0700
Message-ID: <CALvZod7C_jcNc=J0wg_wnCa2fkCjHhjoV1G8oKAmivRbvgQWxg@mail.gmail.com>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josh@joshtriplett.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, gregkh@linuxfoundation.org, rafael@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, Hugh Dickins <hughd@google.com>, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>, Huang Ying <ying.huang@intel.com>, jbacik@fb.com, Ingo Molnar <mingo@kernel.org>, mhiramat@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Aug 8, 2018 at 11:02 AM Josh Triplett <josh@joshtriplett.org> wrote:
>
> On Wed, Aug 08, 2018 at 07:30:13PM +0300, Kirill Tkhai wrote:
> > On 08.08.2018 19:23, Kirill Tkhai wrote:
> > > On 08.08.2018 19:13, Josh Triplett wrote:
> > >> On Wed, Aug 08, 2018 at 01:17:44PM +0300, Kirill Tkhai wrote:
> > >>> On 08.08.2018 10:20, Michal Hocko wrote:
> > >>>> On Tue 07-08-18 18:37:36, Kirill Tkhai wrote:
> > >>>>> This patch kills all CONFIG_SRCU defines and
> > >>>>> the code under !CONFIG_SRCU.
> > >>>>
> > >>>> The last time somebody tried to do this there was a pushback due to
> > >>>> kernel tinyfication. So this should really give some numbers about the
> > >>>> code size increase. Also why can't we make this depend on MMU. Is
> > >>>> anybody else than the reclaim asking for unconditional SRCU usage?
> > >>>
> > >>> I don't know one. The size numbers (sparc64) are:
> > >>>
> > >>> $ size image.srcu.disabled
> > >>>    text      data     bss     dec     hex filename
> > >>> 5117546   8030506 1968104 15116156         e6a77c image.srcu.disabled
> > >>> $ size image.srcu.enabled
> > >>>    text      data     bss     dec     hex filename
> > >>> 5126175   8064346 1968104 15158625         e74d61 image.srcu.enabled
> > >>> The difference is: 15158625-15116156 = 42469 ~41Kb
> > >>
> > >> 41k is a *substantial* size increase. However, can you compare
> > >> tinyconfig with and without this patch? That may have a smaller change.
> > >
> > > $ size image.srcu.disabled
> > >    text        data     bss     dec     hex filename
> > > 1105900      195456   63232 1364588  14d26c image.srcu.disabled
> > >
> > > $ size image.srcu.enabled
> > >    text        data     bss     dec     hex filename
> > > 1106960      195528   63232 1365720  14d6d8 image.srcu.enabled
> > >
> > > 1365720-1364588 = 1132 ~ 1Kb
> >
> > 1Kb is not huge size. It looks as not a big price for writing generic code
> > for only case (now some places have CONFIG_SRCU and !CONFIG_SRCU variants,
> > e.g. drivers/base/core.c). What do you think?
>
> That's a little more reasonable than 41k, likely because of
> CONFIG_TINY_SRCU. That's still not ideal, though. And as far as I can
> tell, the *only* two pieces of core code that use SRCU are
> drivers/base/core.c and kernel/notifier.c, and the latter is exclusively
> code to use notifiers with SRCU, not notifiers wanting to use SRCU
> themselves. So, as far as I can tell, this would really just save a
> couple of small #ifdef sections in drivers/base/core.c, and I think
> those #ifdef sections could be simplified even further. That doesn't
> seem worth it at all.

Hi Josh, the motivation behind enabling SRCU is not to simplify the
code in drivers/base/core.c but rather not to introduce similar ifdefs
in mm/vmscan.c for shrinker traversals.

Shakeel
