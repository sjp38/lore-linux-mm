Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA15719
	for <linux-mm@kvack.org>; Fri, 27 Dec 2002 22:58:12 -0800 (PST)
Message-ID: <3E0D4B83.FEE220B8@digeo.com>
Date: Fri, 27 Dec 2002 22:58:11 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shared pagetable benchmarking
References: <3E0D0D99.5EB318E5@digeo.com> <Pine.LNX.4.44.0212271846100.2759-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Fri, 27 Dec 2002, Andrew Morton wrote:
> >
> > I think we can do a few things still in the 2.6 context.  The fact that
> > my "apply seventy patches with patch-scripts" test takes 350,000 pagefaults
> > in 13 seconds makes one go "hmm".
> 
> Hmm.. Whatever happened to the MAP_POPULATE tests?
> 
> The current "filemap_populate()" function is extremely stupid (it takes
> advantage neither of the locality of the page tables _nor_ of the radix
> tree layout), but even so it would probably be a win to pre-populate at
> mmap time.

Yup.  Ingo said at the time:

  It would be faster to iterate the pagecache mapping's radix tree
  and the pagetables at once, but it's also *much* more complex. I have
  tried to implement it and had to unroll the change - mixing radix tree
  walking and pagetable walking and getting all the VM details right is
  really complex - especially considering all the re-lookup race checks
  that have to occur upon IO.

But find_get_pages() is well-suited to this, and was not in place when
he did this work.

> But having a better "populate()" function that actually does multiple
> pages at once by just accessing the radix trees and page table trees
> directly should really be very low-overhead for the normal case, and be a
> _big_ win in avoiding page faults.
> 
> Even with the existing stupid populate function, it might be interesting
> seeing what would happen just from doing something silly like
> 
> ===== arch/i386/kernel/sys_i386.c 1.10 vs edited =====
> --- 1.10/arch/i386/kernel/sys_i386.c    Sat Dec 21 08:24:45 2002
> +++ edited/arch/i386/kernel/sys_i386.c  Fri Dec 27 19:08:30 2002
> @@ -54,6 +54,8 @@
>                 file = fget(fd);
>                 if (!file)
>                         goto out;
> +               if (prot & PROT_EXEC)
> +                       flags |= MAP_POPULATE | MAP_NONBLOCK;

Yes, this could be used to prototype it, I think.

It doesn't work as-is, because remap_file_pages() requires a shared
mapping.  Disabling that check results in a scrogged ld.so and a
non-booting system.  remap_file_pages() plays games with the vma
protection in ways which I do not understand.

So hum.  I'll finish off some other stuff, take a more detailed look
at this soon.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
