Date: Mon, 8 Jul 2002 10:09:53 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708080953.GC1350@dualathlon.random>
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D293E19.2AD24982@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 12:24:09AM -0700, Andrew Morton wrote:
> Linus Torvalds wrote:
> > 
> > On Sun, 7 Jul 2002, Andrew Morton wrote:
> > >
> > > Probably the biggest offenders are generic_file_read/write.  In
> > > generic_file_write() we're already faulting in the user page(s)
> > > beforehand (somewhat racily, btw).  We could formalise that into
> > > a pin_user_page_range() or whatever and use an atomic kmap
> > > in there.
> > 
> > I'd really prefer not to. We're talking of a difference between one
> > single-cycle instruction (the address should be in the TLB 99% of all
> > times), and a long slow TLB walk with various locks etc.
> > 
> > Anyway, it couldn't be an atomic kmap in file_send_actor anyway, since the
> > write itself may need to block for other reasons (ie socket buffer full
> > etc). THAT is the one that can get misused - the others are not a big
> > deal, I think.
> > 
> > So kmap_atomic definitely doesn't work there.
> > 
> 
> OK, I've been through everything and all the filesystems and
> written four patches which I'll throw away.  I think I know
> how to do all this now.
> 
> - Convert buffer.c to atomic kmaps.
> 
> - prepare_write/commit_write no longer do any implicit kmapping
>   at all.
> 
> - file_read_actor and generic_file_write do their own atomic_kmap
>   (more on this below).
> 
> - file_send_actor still does kmap.
> 
> - If a filesystem wants its page kmapped between prepare and commit,
>   it does it itself.  So
> 
>   foo_prepare_write()
>   {
> 	int ret;
> 
> 	ret = block_prepare_write();
> 	if (ret == 0)
> 		kmap(page);
> 	return ret;
>   }
> 
>   foo_commit_write()
>   {
>  	kunmap(page);
> 	return generic_commit_write();
>   }
> 
>   So in the case of ext2, we can split the directory and S_ISREG a_ops.
>   The directory a_ops will kmap the page.  The S_ISREG a_ops will not.
> 
> 
> Basically: no implicit kmaps.  You do it yourself if you want it, and
> if you cannot do atomic kmaps.
> 
> 
> Now, file_read_actor and generic_file_write still have the problem
> of the target userspace page getting evited while they're holding an
> atomic kmap.
> 
> But the rmap page eviction code has the mm_struct.  So can we not do this:
> 
> 	generic_file_write()
> 	{
> 		...
> 		atomic_inc(&current->mm->dont_unmap_pages);
> 
> 		{
> 			volatile char dummy;
> 			__get_user(dummy, addr);
> 			__get_user(dummy, addr+bytes+1);
> 		}
> 		lock_page();
> 		->prepare_write()
> 		kmap_atomic()
> 		copy_from_user()
> 		kunmap_atomic()
> 		->commit_write()
> 		atomic_dec(&current->mm->dont_unmap_pages);
> 		unlock_page()
> 	}
> 
> and over in mm/rmap.c:try_to_unmap_one(), check mm->dont_unmap_pages.
> 
> Obviously, all this is dependent on CONFIG_HIGHMEM.
> 
> Workable?

the above pseudocode still won't work correctly, if you don't pin the
page as Martin proposed and you only rely on its virtual mapping to stay
there because the page can go away under you despite the
swap_out/rmap-unmapping work, if there's a parallel thread running
munmap+re-mmap under you. So at the very least you need the mmap_sem at
every generic_file_write to avoid other threads to change your virtual
address under you. And you'll basically need to make the mmap_sem
recursive, because you have to take it before running __get_user to
avoid races. You could easily do that using my rwsem, I made two versions
of them, with one that supports recursion, however this is just for your
info, I'm not suggesting to make it recursive.

furthmore rmap provides no advantages at all here, swap_out as well will
have to learn about the mm_struct before it has a chance to try to unmap
a mm_struct.

side note: I heard a "I need rmap for this" from a number of people so
far, and they were all wrong so far, none of them would get any
advantage from rmap, one of them (the closer one to really need rmap)
wasn't aware that we just have rmap for all shared mappings, and he
needed the rmap information for the shared mappings for the same reason
we need the rmap information to keep the shared mappings synchronized
with truncate. The only reason I can imagine rmap useful in todays
hardware for all kind of vma (what the patch provides compared to what
we have now) is to more efficiently defragment ram with an algorithm in
the memory balancing to provide largepages more efficiently from mixed
zones, if somebody would suggest rmap for this reason (nobody did yet) I
would have to agree completely that it is very useful for that, OTOH it
seems everybody is reserving (or planning to reserve) a zone for
largepages anyways so that we don't run into fragmentation in the first
place. And btw - talking about largepages - we have three concurrent and
controversial largepage implementations for linux available today, they
all have different API, one is even shipped in production by a vendor,
and while auditing the code I seen it also exports an API visible to
userspace [ignoring the sysctl] (unlike what I was told):

+#define MAP_BIGPAGE	0x40		/* bigpage mapping */
[..]
 		_trans(flags, MAP_GROWSDOWN, VM_GROWSDOWN) |
 		_trans(flags, MAP_DENYWRITE, VM_DENYWRITE) |
+		_trans(flags, MAP_BIGPAGE, VM_BIGMAP) |
 		_trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE);
 	return prot_bits | flag_bits;
 #undef _trans

that's a new unofficial bitflag to mmap that any proprietary userspace
can pass to mmap today. Other implementations of the largepage feature
use madvise or other syscalls to tell the kernel to allocate
largepages. At least the above won't return -EINVAL so the binaryonly
app will work transparently on a mainline kernel, but it can eventually
malfunction if we use 0x40 for something else in 2.5. So I think we
should do something about the largepages too ASAP into 2.5 (like
async-io).

Returning to the above kmap hack (assuming you take the mmap_sem and you
fix your instability), your hack will destabilize the vm by design and
it will run the machine oom despite of lots of swap available, think all
tasks taking the page fault in __get_user due a swapin at the same time,
and not being able to swapout some memory to resolve the __get_user
swapin because you pinned all the address spaces, they'll run oom
despite there's still lots of swap free (of course with the oom killer
and the infinite loop in the allocator such condition will deadlock the
kernel instead, it's one of the cases where nobody is going to teach the
oom killer to detect such condition as a case where it has to oom kill
because there's still lots of vm available at that time; so to be
accurate I meant with my vm updates applied the kernel will run oom,
while a mainline kernel will silenty deadlock). So I I'm not really
happy with this mm-pinning-during-page-fault design solution (regardless
if you prefer to deadlock or to run oom, you know I prefer the latter :).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
