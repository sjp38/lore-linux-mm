Message-ID: <3D29F868.1338ACF3@zip.com.au>
Date: Mon, 08 Jul 2002 13:39:04 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D28042E.B93A318C@zip.com.au> <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com> <3D293E19.2AD24982@zip.com.au> <20020708080953.GC1350@dualathlon.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Martin J. Bligh" <fletch@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> ...
> >       generic_file_write()
> >       {
> >               ...
> >               atomic_inc(&current->mm->dont_unmap_pages);
> >
> >               {
> >                       volatile char dummy;
> >                       __get_user(dummy, addr);
> >                       __get_user(dummy, addr+bytes+1);
> >               }
> >               lock_page();
> >               ->prepare_write()
> >               kmap_atomic()
> >               copy_from_user()
> >               kunmap_atomic()
> >               ->commit_write()
> >               atomic_dec(&current->mm->dont_unmap_pages);
> >               unlock_page()
> >       }
> >
> > and over in mm/rmap.c:try_to_unmap_one(), check mm->dont_unmap_pages.
> >
> > Obviously, all this is dependent on CONFIG_HIGHMEM.
> >
> > Workable?
> 
> the above pseudocode still won't work correctly,

Sure.  It's crap.  It can be used to get mlockall() for free.

>  if you don't pin the
> page as Martin proposed and you only rely on its virtual mapping to stay
> there because the page can go away under you despite the
> swap_out/rmap-unmapping work, if there's a parallel thread running
> munmap+re-mmap under you. So at the very least you need the mmap_sem at
> every generic_file_write to avoid other threads to change your virtual
> address under you. And you'll basically need to make the mmap_sem
> recursive, because you have to take it before running __get_user to
> avoid races. You could easily do that using my rwsem, I made two versions
> of them, with one that supports recursion, however this is just for your
> info, I'm not suggesting to make it recursive.

I think I'll just go for pinning the damn page.  It's a spinlock and
maybe three cachelines but the kernel is about to do a 4k memcpy
anyway.  And get_user_pages() doesn't show up much on O_DIRECT
profiles and it'll be a net win and we need to do SOMETHING, dammit.
 
> ...
> The only reason I can imagine rmap useful in todays
> hardware for all kind of vma (what the patch provides compared to what
> we have now) is to more efficiently defragment ram with an algorithm in
> the memory balancing to provide largepages more efficiently from mixed
> zones, if somebody would suggest rmap for this reason (nobody did yet)

It has been discussed.  But no action yet.

> I
> would have to agree completely that it is very useful for that, OTOH it
> seems everybody is reserving (or planning to reserve) a zone for
> largepages anyways so that we don't run into fragmentation in the first
> place. And btw - talking about largepages - we have three concurrent and
> controversial largepage implementations for linux available today, they
> all have different API, one is even shipped in production by a vendor,

What implementation do you favour?

> and while auditing the code I seen it also exports an API visible to
> userspace [ignoring the sysctl] (unlike what I was told):
> 
> +#define MAP_BIGPAGE    0x40            /* bigpage mapping */
> [..]
>                 _trans(flags, MAP_GROWSDOWN, VM_GROWSDOWN) |
>                 _trans(flags, MAP_DENYWRITE, VM_DENYWRITE) |
> +               _trans(flags, MAP_BIGPAGE, VM_BIGMAP) |
>                 _trans(flags, MAP_EXECUTABLE, VM_EXECUTABLE);
>         return prot_bits | flag_bits;
>  #undef _trans
> 
> that's a new unofficial bitflag to mmap that any proprietary userspace
> can pass to mmap today. Other implementations of the largepage feature
> use madvise or other syscalls to tell the kernel to allocate
> largepages. At least the above won't return -EINVAL so the binaryonly
> app will work transparently on a mainline kernel, but it can eventually
> malfunction if we use 0x40 for something else in 2.5. So I think we
> should do something about the largepages too ASAP into 2.5 (like
> async-io).

Yup.  I don't think the -aa kernel has a large page patch, does it?
Is that something which you have time to look into?
 
-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
