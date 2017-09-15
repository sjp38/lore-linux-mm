Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 389A26B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:05:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g50so3115427wra.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 11:05:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 13si1377586wmo.260.2017.09.15.11.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 11:05:22 -0700 (PDT)
Date: Fri, 15 Sep 2017 11:05:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + include-linux-sched-mmh-uninline-mmdrop_async-etc.patch added
 to -mm tree
Message-Id: <20170915110520.69c2b26b32f03f0c34e2d2a1@linux-foundation.org>
In-Reply-To: <20170915071228.bw5f2atahrfhj7zp@dhcp22.suse.cz>
References: <59bae45a.Fmr8uSXzjRP94/2V%akpm@linux-foundation.org>
	<20170915070731.y5ddmgtzvjz5aot3@dhcp22.suse.cz>
	<20170915071228.bw5f2atahrfhj7zp@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org, oleg@redhat.com, peterz@infradead.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Sep 2017 09:12:28 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 15-09-17 09:07:31, Michal Hocko wrote:
> > On Thu 14-09-17 13:19:38, Andrew Morton wrote:
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Subject: include/linux/sched/mm.h: uninline mmdrop_async(), etc
> > > 
> > > mmdrop_async() is only used in fork.c.  Move that and its support
> > > functions into fork.c, uninline it all.
> > 
> > Is this really an improvement? Why do we want to discourage more code
> > paths to use mmdrop_async? It sounds like a useful api and it has been
> > removed only because it lost its own user in oom code. Now that we have
> > a user I would just keep it where it was before.
> 
> Dohh, I have mixed mmput_async with mmdrop_async. Anyway I still think
> that this is universal enough to have it in a header rather than hiding
> it in fork.c

Async free is a hack.  It consumes more resources (runtime and memory)
than a synchronous free.  It introduces a risk of memory exhaustion
when an unbounded number of async frees are pending, not yet serviced. 
It introduces a risk of unbounded latency when an unbounded number of
async frees are serviced by the kernel thread.

Synchronous frees are simply better, so we shouldn't encourage the use
of async frees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
