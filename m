Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81F246B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 11:55:10 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c18so3647286ioj.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 08:55:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y207sor363309iof.18.2017.08.28.08.55.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 08:55:09 -0700 (PDT)
Date: Mon, 28 Aug 2017 10:55:06 -0500
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fork: fix incorrect fput of ->exe_file causing
 use-after-free
Message-ID: <20170828155506.GA531@zzz.localdomain>
References: <20170823211408.31198-1-ebiggers3@gmail.com>
 <20170824132041.GA22882@redhat.com>
 <20170824165935.GA21624@gmail.com>
 <20170825144036.GA26620@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825144036.GA26620@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>

On Fri, Aug 25, 2017 at 04:40:36PM +0200, Oleg Nesterov wrote:
> On 08/24, Eric Biggers wrote:
> >
> > On Thu, Aug 24, 2017 at 03:20:41PM +0200, Oleg Nesterov wrote:
> > > On 08/23, Eric Biggers wrote:
> > > >
> > > > From: Eric Biggers <ebiggers@google.com>
> > > >
> > > > Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
> > > > write killable") made it possible to kill a forking task while it is
> > > > waiting to acquire its ->mmap_sem for write, in dup_mmap().  However, it
> > > > was overlooked that this introduced an new error path before a reference
> > > > is taken on the mm_struct's ->exe_file.
> > >
> > > Hmm. Unless I am totally confused, the same problem with mm->exol_area?
> > > I'll recheck....
> >
> > I'm not sure what you mean by ->exol_area.
> 
> I meant mm->uprobes_state.xol_area, sorry
> 

Yep, that's a bug too.  I was able to cause a use-after-free using the same
reproducer program I gave in my commit message, after setting a uprobe
tracepoint on the beginning of the fork_thread() function.  I'll send a patch to
fix it when I have a chance.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
