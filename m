Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4E50E6B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 08:45:16 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id b13so108701wgh.33
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 05:45:15 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id z7si11091552wje.27.2014.06.05.05.45.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 05:45:14 -0700 (PDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so3364622wib.1
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 05:45:13 -0700 (PDT)
Date: Thu, 5 Jun 2014 14:45:09 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140605124509.GA1975@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
 <20140522090502.GB30094@gmail.com>
 <20140522195056.445f2dcb@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140522195056.445f2dcb@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* NeilBrown <neilb@suse.de> wrote:

> On Thu, 22 May 2014 11:05:02 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> 
> > 
> > * NeilBrown <neilb@suse.de> wrote:
> > 
> > > [[ get_maintainer.pl suggested 61 email address for this patch.
> > >    I've trimmed that list somewhat.  Hope I didn't miss anyone
> > >    important...
> > >    I'm hoping it will go in through the scheduler tree, but would
> > >    particularly like an Acked-by for the fscache parts.  Other acks
> > >    welcome.
> > > ]]
> > > 
> > > The current "wait_on_bit" interface requires an 'action' function
> > > to be provided which does the actual waiting.
> > > There are over 20 such functions, many of them identical.
> > > Most cases can be satisfied by one of just two functions, one
> > > which uses io_schedule() and one which just uses schedule().
> > > 
> > > So:
> > >  Rename wait_on_bit and        wait_on_bit_lock to
> > >         wait_on_bit_action and wait_on_bit_lock_action
> > >  to make it explicit that they need an action function.
> > > 
> > >  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
> > >  which are *not* given an action function but implicitly use
> > >  a standard one.
> > >  The decision to error-out if a signal is pending is now made
> > >  based on the 'mode' argument rather than being encoded in the action
> > >  function.
> > 
> > this patch fails to build on x86-32 allyesconfigs.
> 
> Could you share the build errors?

Sure, find it attached below.

> > 
> > Could we keep the old names for a while, and remove them in the next 
> > cycle or so?
> 
> I don't see how changing the names later rather than now will reduce the
> chance of errors... maybe I'm missing something.

Well, it would reduce build errors?

Thanks,

	Ingo

====================>
fs/cifs/file.c: In function a??cifs_oplock_breaka??:
fs/cifs/file.c:3652:4: warning: passing argument 3 of a??wait_on_bita?? makes integer from pointer without a cast [enabled by default]
    cifs_pending_writers_wait, TASK_UNINTERRUPTIBLE);
    ^
In file included from include/linux/fs.h:6:0,
                 from fs/cifs/file.c:24:
include/linux/wait.h:878:1: note: expected a??unsigned inta?? but argument is of type a??int (*)(void *)a??
 wait_on_bit(void *word, int bit, unsigned mode)
 ^
fs/cifs/file.c:3652:4: error: too many arguments to function a??wait_on_bita??
    cifs_pending_writers_wait, TASK_UNINTERRUPTIBLE);
    ^
In file included from include/linux/fs.h:6:0,
                 from fs/cifs/file.c:24:
include/linux/wait.h:878:1: note: declared here
 wait_on_bit(void *word, int bit, unsigned mode)
 ^
  CC      kernel/smp.o
  CC      kernel/trace/trace_event_perf.o
make[2]: *** [fs/cifs/file.o] Error 1
make[2]: *** Waiting for unfinished jobs....
  CC      drivers/bcma/sprom.o
  CC      fs/btrfs/locking.o
  LD      sound/isa/ad1848/snd-ad1848.o
  LD      sound/isa/ad1848/built-in.o
  CC      sound/isa/cs423x/cs4231.o
  CC      lib/fonts/fonts.o
  CC      lib/fonts/font_sun8x16.o
  CC      drivers/bcma/driver_chipcommon.o
  CC      lib/fonts/font_sun12x22.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
