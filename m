Date: Tue, 22 Feb 2005 19:01:22 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview II
Message-ID: <20050222180122.GO23433@wotan.suse.de>
References: <20050217235437.GA31591@wotan.suse.de> <4215A992.80400@sgi.com> <20050218130232.GB13953@wotan.suse.de> <42168FF0.30700@sgi.com> <20050220214922.GA14486@wotan.suse.de> <20050220143023.3d64252b.pj@sgi.com> <20050220223510.GB14486@wotan.suse.de> <42199EE8.9090101@sgi.com> <20050221121010.GC17667@wotan.suse.de> <421AD3E6.8060307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421AD3E6.8060307@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> OK, so what is the alternative?  Well, if we had a va_start and
> va_end (or a va_start and length) we could move the shared object
> once using a call of the form
> 
>    migrate_pages(pid, va_start, va_end, count, old_node_list,
> 	new_node_list);
> 
> with old_node_list = 0 1 2 ... 31
>      new_node_list = 2 3 4 ... 33
> 
> for one of the pid's in the job.

I still don't like it. It would be bad to make migrate_pages another
ptrace() [and ptrace at least really enforces a stopped process]

But I can see your point that migration DEFAULT pages with first touch
aware applications pretty much needs the old_node, new_node lists.
I just don't think an external process should mess with other processes
VA. But I can see that it makes sense to do this on SHM that 
is mapped into a management process.

How about you add the va_start, va_end but only accept them 
when pid is 0 (= current process). Otherwise enforce with EINVAL
that they are both 0. This way you could map the
shared object into the batch manager, migrate it there, then
mark it somehow to not be migrated further, and then
migrate the anonymous pages using migrate_pages(pid, ...) 

BTW it might be better to make va_end a size, just to be more
symmetric with mlock,madvise,mmap et.al.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
