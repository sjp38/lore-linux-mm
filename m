Date: Tue, 22 Feb 2005 19:49:15 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview II
Message-ID: <20050222184915.GA8981@wotan.suse.de>
References: <20050218130232.GB13953@wotan.suse.de> <42168FF0.30700@sgi.com> <20050220214922.GA14486@wotan.suse.de> <20050220143023.3d64252b.pj@sgi.com> <20050220223510.GB14486@wotan.suse.de> <42199EE8.9090101@sgi.com> <20050221121010.GC17667@wotan.suse.de> <421AD3E6.8060307@sgi.com> <20050222180122.GO23433@wotan.suse.de> <421B7DC1.8070504@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421B7DC1.8070504@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 22, 2005 at 12:45:21PM -0600, Ray Bryant wrote:
> Andi Kleen wrote:
> 
> >
> >How about you add the va_start, va_end but only accept them 
> >when pid is 0 (= current process). Otherwise enforce with EINVAL
> >that they are both 0. This way you could map the
> >shared object into the batch manager, migrate it there, then
> >mark it somehow to not be migrated further, and then
> >migrate the anonymous pages using migrate_pages(pid, ...) 
> >
> 
> We'd have to use up a struct page flag (PG_MIGRATED?) to mark
> the page as migrated to keep the call to migrate_pages() for
> the anonymous pages from migrating the pages again.  Then we'd

I was more thinking of a new mempolicy or a flag for one.
Flag would be probably better.  No need to keep state in struct page.

> How about ignoring the va_start and va_end values unless
> either:
> 
>       pid == current->pid
>   or  current->euid == 0 /* we're root */
> 
> I like the first check a bit better than checking for 0.  Are
> there other system calls that follow that convention (e. g.
> pid = 0 implies current?)
> 
> The second check lets a sufficiently responsible task manipulate
> other tasks.  This task can choose to have the target tasks
> suspended before it starts fussing with them.

I don't like that. The idea behind this restriction is to simplify
things by making sure only processes change their own VM. Letting
root overwrite this doesn't make much sense.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
