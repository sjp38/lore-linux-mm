Date: Sun, 15 Sep 2002 17:02:01 -0400
Subject: Re: Obtaining the kernel's PTEs
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
In-Reply-To: <20020913221032.GM2179@holomorphy.com>
Message-Id: <614E162E-C8EE-11D6-97BB-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Thanks for the responses...Here we go...

On Friday, September 13, 2002, at 05:19 PM, Martin J. Bligh wrote:

> On an ia32 machine, I believe there is no PTE - they're large pages for 
> ZONE_NORMAL.
> I don't know of any function to walk one, but you could look at 
> pagetable_init for something close to what you're doing?

A-ha.  Not surprising, and it does look like it wouldn't be hard to force 
the kernel to map its space using small pages.  Of course, that begs the 
question, ``How much overhead will be introduced by using small pages?''  
Increased space use for page table consumption and increased TLB misses 
_could_ be significant, but it depends on the reference patterns of the 
applications and the kernel itself.

On Friday, September 13, 2002, at 06:10 PM, William Lee Irwin III wrote:

> (1) Pagetables are only meaningful to a couple of machines, most notably
> 	i386 and m68k. The rest is pretty much software TLB or inverted.
> 	So there's zero accounting of the direct-mapping within the kernel
> 	for some machines, not sure which since I've not gone about the
> 	task of hunting for the answer to "What does everyone do when
> 	they've taken a TLB miss on kernelspace?" My suspicion is TLB
> 	entries are generated on the fly for what is not bolted.

First, the essentials (for me):  I just want to implement some 
kernel-level changes for experimental purposes.  It needs to run only on 
one platform.  So, if it just works on i386, that's fine for me.

Second, my curiosity:  I confess that I don't understand how a software 
TLB or inverted page table obviates the need for a virtual->physical 
mapping for the kernel.  Those are simply different mechanisms for 
supporting the mapping task.  While the mapping information may be stored 
and handled differently for other architectures, the kernel must have its 
address space mapped onto the physical address space.  Or am I completely 
misunderstanding you?

> (2) The kernel is often mapped out using various tidbits of TLB magic not
> 	handled by user PTE manipulation routines. e.g. the G and PS bits
> 	on i386. i386 is even worse, as the PAT bit in a PTE has the same
> 	position as the PS bit in a PMD so a priori knowledge of mapping
> 	size is required.

What is the ``PAT bit''?  Wait, doesn't the PS bit on the PGD entry tell 
you whether it points to a 4 MB page or whether the levels of indirection 
to 4 KB pages continues?  Again, this issue seems to be more one of 
curiosity for me, and not something essential to what I'm trying to do -- 
but I would like to know to what you're referring, because I'm having 
trouble understanding it.

> 	Also, since the kernel translations at least on i386 use the G
> 	bit which is basically "invalidate the TLB entry only when a
> 	specific page is targeted." This is also not a particularly
> 	friendly feature...

I don't think this feature is a problem for what I want to do.  I'm aiming 
to change the protection on individual pages, so changing the PTE and then 
invalidating that specific mapping in the TLB is exactly what I want.

Thanks to those who responded, as the information is quite helpful!
Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9hPVM8eFdWQtoOmgRAu4HAJ42Pg40Ld+tXWizw2oHpzAyF0h5+ACglehx
1Yt4BCjdN5WC6qPKSjMj0Ys=
=OiP7
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
