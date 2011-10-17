Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 172756B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 09:34:56 -0400 (EDT)
Subject: Re: [PATCH 6/X] uprobes: reimplement xol_add_vma() via
 install_special_mapping()
From: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <20111017105054.GC11831@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20111015190007.GA30243@redhat.com> <20111016161359.GA24893@redhat.com>
	 <20111017105054.GC11831@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 Oct 2011 09:34:15 -0400
Message-ID: <1318858455.7251.12.camel@moss-pluto>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Eric Paris <eparis@parisplace.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-10-17 at 16:20 +0530, Srikar Dronamraju wrote:
> > I apologize in advance if this was already discussed, but I just can't
> > understand why xol_add_vma() does not use install_special_mapping().
> > Unless I missed something this should work and this has the following
> > advantages:
> 
> 
> The override_creds was based on what Stephen Smalley suggested 
> https://lkml.org/lkml/2011/4/20/224    
> 
> At that time Peter had suggested install_special_mapping(). However the
> consensus was to go with Stephen's suggestion of override_creds.
> 
> > 
> > 	- we can avoid override_creds() hacks, install_special_mapping()
> > 	  fools security_file_mmap() passing prot/flags = 0
> > 
> > 	- no need to play with vma after do_mmap_pgoff()
> > 
> > 	- no need for get_user_pages(FOLL_WRITE/FOLL_FORCE) hack
> > 
> > 	- no need for do_munmap() if get_user_pages() fails
> > 
> > 	- this protects us from mprotect(READ/WRITE)
> > 
> > 	- this protects from MADV_DONTNEED, the page will be correctly
> > 	  re-instantiated from area->page
> > 
> > 	- this makes xol_vma more "cheap", swapper can't see this page
> > 	  and we avoid the meaningless add_to_swap/pageout.
> > 
> > 	  Note that, before this patch, area->page can't be removed
> > 	  from the swap cache anyway (we have the reference). And it
> > 	  must not, uprobes modifies this page directly.
> 
> Stephan, Eric, 
> 
> Would you agree with Oleg's observation that we would be better off
> using install_special_mapping rather than using override_creds.
> 
> To give you some more information about the problem.
> 
> Uprobes will be a in-kernel debugging facility that provides
> singlestepping out of line. To achieve this, it will create a per-mm vma
> which is not mapped to any file. However this vma has to be executable.
> 
> Slots are made in this executable vma, and one slot can be used to
> single step a original instruction.
> 
> This executable vma that we are creating is not for any particular
> binary but would have to be created dynamically as and when an
> application is debugged. For example, if we were to debug malloc call in
> libc, we would end up adding xol vma to all the live processes in the
> system.
> 
> Since selinux wasnt happy to have an anonymous vma attached, we would
> create a pseudo file using shmem_file_setup. However after comments from
> Peter and Stephan's suggestions we started using override_creds. Peter and
> Oleg suggest that we use install_special_mapping. 
> 
> Are you okay with using install_special_mapping instead of
> override_creds()?

That's fine with me.  But I'm still not clear on how you are controlling
the use of this facility from userspace, which is my primary concern.
Who gets to enable/disable this facility, and what check is applied
between the process that enables it and the target process(es) that are
affected by it?  Is it subject to the same checks as ptrace?

-- 
Stephen Smalley
National Security Agency

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
