Message-ID: <3D293E19.2AD24982@zip.com.au>
Date: Mon, 08 Jul 2002 00:24:09 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Sun, 7 Jul 2002, Andrew Morton wrote:
> >
> > Probably the biggest offenders are generic_file_read/write.  In
> > generic_file_write() we're already faulting in the user page(s)
> > beforehand (somewhat racily, btw).  We could formalise that into
> > a pin_user_page_range() or whatever and use an atomic kmap
> > in there.
> 
> I'd really prefer not to. We're talking of a difference between one
> single-cycle instruction (the address should be in the TLB 99% of all
> times), and a long slow TLB walk with various locks etc.
> 
> Anyway, it couldn't be an atomic kmap in file_send_actor anyway, since the
> write itself may need to block for other reasons (ie socket buffer full
> etc). THAT is the one that can get misused - the others are not a big
> deal, I think.
> 
> So kmap_atomic definitely doesn't work there.
> 

OK, I've been through everything and all the filesystems and
written four patches which I'll throw away.  I think I know
how to do all this now.

- Convert buffer.c to atomic kmaps.

- prepare_write/commit_write no longer do any implicit kmapping
  at all.

- file_read_actor and generic_file_write do their own atomic_kmap
  (more on this below).

- file_send_actor still does kmap.

- If a filesystem wants its page kmapped between prepare and commit,
  it does it itself.  So

  foo_prepare_write()
  {
	int ret;

	ret = block_prepare_write();
	if (ret == 0)
		kmap(page);
	return ret;
  }

  foo_commit_write()
  {
 	kunmap(page);
	return generic_commit_write();
  }

  So in the case of ext2, we can split the directory and S_ISREG a_ops.
  The directory a_ops will kmap the page.  The S_ISREG a_ops will not.


Basically: no implicit kmaps.  You do it yourself if you want it, and
if you cannot do atomic kmaps.


Now, file_read_actor and generic_file_write still have the problem
of the target userspace page getting evited while they're holding an
atomic kmap.

But the rmap page eviction code has the mm_struct.  So can we not do this:

	generic_file_write()
	{
		...
		atomic_inc(&current->mm->dont_unmap_pages);

		{
			volatile char dummy;
			__get_user(dummy, addr);
			__get_user(dummy, addr+bytes+1);
		}
		lock_page();
		->prepare_write()
		kmap_atomic()
		copy_from_user()
		kunmap_atomic()
		->commit_write()
		atomic_dec(&current->mm->dont_unmap_pages);
		unlock_page()
	}

and over in mm/rmap.c:try_to_unmap_one(), check mm->dont_unmap_pages.

Obviously, all this is dependent on CONFIG_HIGHMEM.

Workable?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
