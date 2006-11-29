Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id kATLvmpM006946
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 21:57:48 GMT
Received: from ug-out-1314.google.com (ugck40.prod.google.com [10.66.112.40])
	by spaceape13.eur.corp.google.com with ESMTP id kATLvYEZ029672
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 21:57:38 GMT
Received: by ug-out-1314.google.com with SMTP id k40so1955194ugc
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 13:57:38 -0800 (PST)
Message-ID: <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
Date: Wed, 29 Nov 2006 13:57:37 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456D23A0.9020008@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/28/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> menage@google.com wrote:
> > Currently the page migration APIs allow you to migrate pages from
> > particular processes, but don't provide a clean and efficient way to
> > migrate and/or reclaim memory from individual nodes.
>
> The mechanism for that should probably go in mm/migrate.c, shouldn't
> it?

Quite possibly - I don't have a strong feeling for exactly where the
code should go. There's existing code (sys_migrate_pages) that uses
the migration mechanism that's in mm/mempolicy.c rather than
migrate.c, and this was a pretty simple function to write.

>
> Also, why don't you scan the lru lists of the zones in the node, which
> will a) be much more efficient if there are lots of non LRU pages, and
> b) allow you to batch the lru lock.

I'll take a look at that.

> >
> > - a way to trigger try_to_free_pages() for a given node with a given
> >   minimum priority, vy writing an integer to
> >   /sys/device/system/node/node<id>/try_to_free_pages
>
> ... especially not to userspace. Why does this have to be exposed to
> userspace at all?

We don't need to expose the raw "priority" value, but it would be
really nice for user space to be able to specify how hard the kernel
should try to free some memory.

Then each job can specify a "reclaim pressure", i.e. how much
back-pressure should be applied to its allocated memory, so you can
get a good idea of how much memory the job is really using for a given
level of performance. High reclaim pressure results in a smaller
working set but possibly more paging in from disk; low reclaim
pressure uses more memory but gets higher performance.

> Can you not wire it up to your resource isolation
> implementation in the kernel?

This *is* the resource isolation implementation (plus the existing
cpusets and fake-numa code). The intention is to expose just enough
knobs/hooks to userspace that it can be handled there.

>
> ... yeah it would obviously be much nicer to do it in kernel space,
> behind your higher level APIs.

I don't think it would - keeping as much of the code as possible in
userspace makes development and deployment much faster. We don't
really have any higher-level APIs at this point - just userspace
middleware manipulating cpusets.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
