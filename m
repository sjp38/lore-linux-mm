Message-ID: <20000906132503.8101.qmail@web6405.mail.yahoo.com>
Date: Wed, 6 Sep 2000 06:25:03 -0700 (PDT)
From: Zeshan Ahmad <zeshan_uet@yahoo.com>
Subject: Re: stack overflow
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1804289383-968246703=:8051"
Sender: owner-linux-mm@kvack.org
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hemment <markhe@veritas.com>
Cc: tigran@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mark!

Thanx for ur reply in considering my problem. I am
using Kernel version 2.2.14

I have attached the portion of mm/slab.c containing
the function kmem_cache_sizes_init from the kernel
code i am using with this mail. Plz have a look at it
and recommend me any changes.

Also plz suggest any good readings about "slab
allocator" on the net.

Thanx for ur support. Help is badly needed.
Anxiously waiting for ur reply.

Regards
ZESHAN
--- Mark Hemment <markhe@veritas.com> wrote:
> Hi Zeshan,
> 
>   What version of 2.2.x are you using, and have you
> applied any patches it
> to?
>   I'm not subscribed to linux-mm at the moment, so I
> missed your original
> posting.
> 
> Mark
> 
> 
> On Tue, 5 Sep 2000, Zeshan Ahmad wrote:
> 
> > Hi
> > 
> > I have figured out why the patch is'nt working. 
> > 
> > Mark wrote:
> > >In my original, the code assumes that all general
> > >purpose slabs below
> > >"bufctl_limit" where suitable for bufctl
> allocation 
> > >(look at a 2.2.x
> > >version, in kmem_cache_sizes_init() I have a
> state
> > >variable called
> > >"found").
> >   
> > Since I am already using 2.2.x, so the patch is
> not
> > working. This means i am already using the
> variable
> > "found".
> > So this will not work i presume.
> > 
> > Any other solution available?
> > 
> > Regards
> > Zeshan
> > 
> > __________________________________________________
> > Do You Yahoo!?
> > Yahoo! Mail - Free email you can access from
> anywhere!
> > http://mail.yahoo.com/
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux.eu.org/Linux-MM/


__________________________________________________
Do You Yahoo!?
Yahoo! Mail - Free email you can access from anywhere!
http://mail.yahoo.com/
--0-1804289383-968246703=:8051
Content-Type: text/plain; name="kmem_cache_sizes_init.txt"
Content-Description: kmem_cache_sizes_init.txt
Content-Disposition: inline; filename="kmem_cache_sizes_init.txt"

void __init kmem_cache_sizes_init(void)
{
	unsigned int	found = 0;

	cache_slabp = kmem_cache_create("slab_cache", sizeof(kmem_slab_t),
					0, SLAB_HWCACHE_ALIGN, NULL, NULL);

        if (cache_slabp) {
		char **names = cache_sizes_name;
		cache_sizes_t *sizes = cache_sizes;
		do {
			/* For performance, all the general caches are L1 aligned.
			 * This should be particularly beneficial on SMP boxes, as it
			 * eliminates "false sharing".
			 * Note for systems short on memory removing the alignment will
			 * allow tighter packing of the smaller caches. */
			if (!(sizes->cs_cachep =
			      kmem_cache_create(*names++, sizes->cs_size,
						0, SLAB_HWCACHE_ALIGN, NULL, NULL)))
				goto panic_time;
			if (!found) {
				/* Inc off-slab bufctl limit until the ceiling is hit. */
				if (SLAB_BUFCTL(sizes->cs_cachep->c_flags))
					found++;
				else
					bufctl_limit =
						(sizes->cs_size/sizeof(kmem_bufctl_t));
			}
			sizes->cs_cachep->c_flags |= SLAB_CFLGS_GENERAL;
			sizes++;
		} while (sizes->cs_size);
#if	SLAB_SELFTEST
		kmem_self_test();
#endif	/* SLAB_SELFTEST */
		return;
	}
panic_time:
	panic("kmem_cache_sizes_init: Error creating caches");
	/* NOTREACHED */
}

--0-1804289383-968246703=:8051--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
