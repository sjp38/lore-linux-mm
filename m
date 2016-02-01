Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 88D486B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 21:55:13 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id d63so125750110ioj.2
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 18:55:13 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id fs3si12341009igb.25.2016.01.31.18.55.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 31 Jan 2016 18:55:13 -0800 (PST)
Date: Mon, 1 Feb 2016 11:55:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-ID: <20160201025530.GD32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
 <20160128074051.GA15426@js1304-P5Q-DELUXE>
 <CAG_fn=Uxk-Y2gVfrdLxPRFf2SQ+1VnoWNUorcDw4E18D0+NBWQ@mail.gmail.com>
 <CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VetOrSwqseiRwCFVr-nTTemczMixbbafgEJdqDRB4p7Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, rostedt@goodmis.org

On Thu, Jan 28, 2016 at 02:27:44PM +0100, Alexander Potapenko wrote:
> On Thu, Jan 28, 2016 at 1:51 PM, Alexander Potapenko <glider@google.com> wrote:
> >
> > On Jan 28, 2016 8:40 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
> >>
> >> Hello,
> >>
> >> On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
> >> > Stack depot will allow KASAN store allocation/deallocation stack traces
> >> > for memory chunks. The stack traces are stored in a hash table and
> >> > referenced by handles which reside in the kasan_alloc_meta and
> >> > kasan_free_meta structures in the allocated memory chunks.
> >>
> >> Looks really nice!
> >>
> >> Could it be more generalized to be used by other feature that need to
> >> store stack trace such as tracepoint or page owner?
> > Certainly yes, but see below.
> >
> >> If it could be, there is one more requirement.
> >> I understand the fact that entry is never removed from depot makes things
> >> very simpler, but, for general usecases, it's better to use reference
> >> count
> >> and allow to remove. Is it possible?
> > For our use case reference counting is not really necessary, and it would
> > introduce unwanted contention.

Okay.

> > There are two possible options, each having its advantages and drawbacks: we
> > can let the clients store the refcounters directly in their stacks (more
> > universal, but harder to use for the clients), or keep the counters in the
> > depot but add an API that does not change them (easier for the clients, but
> > potentially error-prone).
> > I'd say it's better to actually find at least one more user for the stack
> > depot in order to understand the requirements, and refactor the code after
> > that.

I re-think the page owner case and it also may not need refcount.
For now, just moving this stuff to /lib would be helpful for other future user.

BTW, is there any performance number? I guess that it could affect
the performance.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
