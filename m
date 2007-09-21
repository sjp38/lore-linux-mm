Date: Fri, 21 Sep 2007 13:04:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 5/9] oom: serialize out of memory calls
In-Reply-To: <20070921020147.334857f4.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709211302240.8826@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com> <20070921020147.334857f4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, Andrew Morton wrote:

> > Before invoking the OOM killer, a final allocation attempt with a very
> > high watermark is attempted.  Serialization needs to occur at this point
> > or it may be possible that the allocation could succeed after acquiring
> > the lock.  If the lock is contended, the task is put to sleep and the
> > allocation attempt is retried when rescheduled.
> 
> Am having trouble understanding this description.  How can it ever be a
> problem if an allocation succeeds??
> 
> Want to have another go, please?
> 

Ok, please replace the description in 
oom-serialize-out-of-memory-calls.patch with this:


A final allocation attempt with a very high watermark needs to be 
attempted before invoking out_of_memory().  OOM killer serialization needs 
to occur before this final attempt, otherwise tasks attempting to OOM-lock 
all zones in its zonelist may spin and acquire the lock unnecessarily 
after the OOM condition has already been alleviated.

If the final allocation does succeed, the zonelist is simply OOM-unlocked 
and __alloc_pages() returns the page.  Otherwise, the OOM killer is 
invoked.

If the task cannot acquire OOM-locks on all zones in its zonelist, it is 
put to sleep and the allocation is retried when it gets rescheduled.  One 
of its zones is already marked as being in the OOM killer so it'll 
hopefully be getting some free memory soon, at least enough to satisfy a 
high watermark allocation attempt.  This prevents needlessly killing a 
task when the OOM condition would have already been alleviated if it had 
simply been given enough time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
