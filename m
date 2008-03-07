Date: Fri, 7 Mar 2008 14:40:55 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803071320.58439.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
 <47D06F07.4070404@cs.helsinki.fi> <200803071320.58439.Jens.Osterkamp@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Jens Osterkamp wrote:
> > > Ahh.. That looks like an alignment problem. The other options all add 
> > > data to the object and thus misalign them if no alignment is 
> > > specified.
> > 
> > And causes buffer overrun? So the crazy preempt count 0x00056ef8 could a 
> > the lower part of an instruction pointer tracked by SLAB_STORE_USER? So 
> > does:
> > 
> >    gdb vmlinux
> >    (gdb) l *c000000000056ef8
> > 
> > translate into any meaningful kernel function?
> 
> No, it is in the middle of copy_process. But I will try to identify what
> we are actually looking at instead of prempt_count.

But that's expected. It's the call-site of a kmalloc() or 
kmem_cache_alloc() call that stomps on the memory where the 
->preempt_count of struct thread_info is. Is that anywhere near the 
dup_task_struct() call? I don't quite see how that could happen, however, 
alloc_thread_info() uses the page allocator to allocate memory for struct 
thread_info which is AFAICT 8 KB...

It might we worth it to look at other obviously wrong preempt_counts to 
see if you can figure out a pattern of callers stomping on the memory.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
