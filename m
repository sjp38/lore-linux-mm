Date: Wed, 19 Sep 2007 13:30:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/8] oom: serialize out of memory calls
In-Reply-To: <Pine.LNX.4.64.0709191159100.2241@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709191325160.26978@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com> <Pine.LNX.4.64.0709191159100.2241@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Christoph Lameter wrote:

> > Before invoking the OOM killer, a final allocation attempt with a very
> > high watermark is attempted.  Serialization needs to occur at this point
> > or it may be possible that the allocation could succeed after acquiring
> > the lock.  If the lock is contended, the task is put to sleep and the
> > allocation attempt is retried when rescheduled.
> 
> The problem with a succeeding allocation is that it takes memory 
> away from the OOM killer?
> 

If the succeeding allocation works with ALLOC_WMARK_HIGH, and 
get_page_from_freelist() returns non-NULL, then clear_zonelist_oom() is 
called and the OOM killer is never invoked.  The same happens if the 
allocation order exceeds PAGE_ALLOC_COSTLY_ORDER.

So, as the comment still says in __alloc_pages(), the succeeding 
allocation attempt is only to catch parallel OOM killings.  Not 
necessarily that we can serialize based on that alone, but it catches 
tasks that were already OOM killed, marked TIF_MEMDIE so they can quickly 
exit, and gone through exit_mm().  This only happens when the earlier 
allocation attempts couldn't catch it because they were ~ALLOC_WMARK_HIGH.

We can't serialize after this final allocation attempt with the new 
try_set_zone_oom() because it is entirely possible that we could enter the 
OOM killer, wait for the read-lock on tasklist_lock, the OOM condition 
could be alleviated, and then we still kill a task unnecessarily.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
