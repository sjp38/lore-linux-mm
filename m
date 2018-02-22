Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4353B6B02D3
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:46:06 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f4so2312429plo.11
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:46:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si78913pfc.196.2018.02.22.05.46.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:46:05 -0800 (PST)
Date: Thu, 22 Feb 2018 14:46:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
Message-ID: <20180222134600.5tvizxkroc4oisrd@quack2.suse.cz>
References: <20180221030101.221206-1-shakeelb@google.com>
 <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake>
 <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com>
 <20180221125426.464f894d29a0b6e525b2e3be@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180221125426.464f894d29a0b6e525b2e3be@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 21-02-18 12:54:26, Andrew Morton wrote:
> On Wed, 21 Feb 2018 09:18:35 -0800 Shakeel Butt <shakeelb@google.com> wrote:
> 
> > On Wed, Feb 21, 2018 at 8:09 AM, Christopher Lameter <cl@linux.com> wrote:
> > > Another way to solve this is to switch the user context right?
> > >
> > > Isnt it possible to avoid these patches if do the allocation in another
> > > task context instead?
> > >
> > 
> > Sorry, can you please explain what you mean by 'switch the user
> > context'. Is there any example in kernel which does something similar?
> > 
> > Another way is by adding a field 'remote_memcg_to_charge' in
> > task_struct and set it before the allocation and in memcontrol.c,
> > first check if current->remote_memcg_to_charge is set otherwise use
> > the memcg of current. Also if we provide a wrapper to do that for the
> > user, there will be a lot less plumbing.
> > 
> > Please let me know if you prefer this approach.
> 
> That would be a lot simpler.  Passing function arguments via
> task_struct is a bit dirty but is sometimes sooo effective.  You
> should've seen how much mess task_struct.journal_info avoided!  And
> reclaim_state.

Agreed, although from time to time people try to be too creative e.g. with
journal_info and surprising bugs come out of that :).

> And one always wonders whether we should do a local save/restore before
> modifying the task_struct field, so it nests.
> 
> What do others think?

Sounds nice to me.

> Maybe we can rename task_struct.reclaim_state to `struct task_mm_state
> *task_mm_state", add remote_memcg_to_charge to struct task_mm_state and
> avoid bloating the task_struct?

Yeah, even better, but then we really need to make sure these things stack
properly.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
