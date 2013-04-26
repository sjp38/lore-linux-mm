Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id E658B6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:24:45 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Fri, 26 Apr 2013 02:24:44 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2EFBC6E803F
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:24:38 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3Q6OfDM342570
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:24:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3Q6Oep1025573
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:24:40 -0400
Date: Fri, 26 Apr 2013 14:24:36 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130426062436.GB4441@localhost.localdomain>
References: <20130417094750.GB2672@localhost.localdomain>
 <20130417141909.GA24912@dhcp22.suse.cz>
 <20130418101541.GC2672@localhost.localdomain>
 <20130418175513.GA12581@dhcp22.suse.cz>
 <20130423131558.GH8001@dhcp22.suse.cz>
 <20130424044848.GI2672@localhost.localdomain>
 <20130424094732.GB31960@dhcp22.suse.cz>
 <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com>
 <20130425060705.GK2672@localhost.localdomain>
 <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Christoph Lameter <cl@linux.com>, mhocko@suse.cz, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, Apr 25, 2013 at 06:24:05PM +0000, Christoph Lameter wrote:
> On Thu, 25 Apr 2013, Han Pingtian wrote:
> 
> > > A dump of the other fields in /sys/kernel/slab/kmalloc*/* would also be
> > > useful.
> > >
> > I have dumpped all /sys/kernel/slab/kmalloc*/* in kmalloc.tar.xz and
> > will attach it to this mail.
> 
> Ok that looks like a lot of objects were freed from slab pages but the
> slab pages were not freed.
> 
> looking at kmalloc-8192 we have
> 
> Total capacity of the slab cache is 27k objects but only 508 are in use.
> 
> Looks like slab pages are not freed when all objects in them have been
> released.
> 
> The relevant portion of code that do the freeing are in
> 
> mm/slub.c::unfreeze_partials()
> 
> 		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
>                         page->next = discard_page;
>                         discard_page = page;
>                 } else {
>                         add_partial(n, page, DEACTIVATE_TO_TAIL);
>                         stat(s, FREE_ADD_PARTIAL);
>                 }
> 
> 
> ..
> 
>        while (discard_page) {
>                 page = discard_page;
>                 discard_page = discard_page->next;
> 
>                 stat(s, DEACTIVATE_EMPTY);
>                 discard_slab(s, page);
>                 stat(s, FREE_SLAB);
>         }
> 
> and mm/slub.c::__slab_free()
> 
>      if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
>                 goto slab_empty;
> 
> 
> Could you verify the values of nr_partial and min_partial and verify that
> the free paths are actually used?

Could you give me some hints about how to verify them? Only I can do is
adding two printk() statements to print the vaules in those two
functions:

--------------------------------------------------------------------------------
diff --git a/mm/slub.c b/mm/slub.c
index 4aec537..d08d62d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1915,6 +1915,9 @@ static void unfreeze_partials(struct kmem_cache *s,
                                new.freelist, new.counters,
                                "unfreezing slab"));
 
+               if (strcmp(s->name, "kmalloc-8192") == 0) {
+                       printk(KERN_INFO "In unfreeze_partials(); kmalloc-8192: n->nr_partial=%lu, s->min_partial
+                }
                if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
                        page->next = discard_page;
                        discard_page = page;
@@ -2536,6 +2539,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                 return;
         }
 
+       if (strcmp(s->name, "kmalloc-8192") == 0) {
+               printk(KERN_INFO "In __slab_free(); kmalloc-8192: n->nr_partial=%lu, s->min_partial=%lu\n", n->nr
+       }
+
        if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
                goto slab_empty;

--------------------------------------------------------------------------------

And looks like only printk() in __slab_free() is invoked. I got about 6764 
lines of something like this:

--------------------------------------------------------------------------------
Apr 26 01:04:05 riblp3 kernel: [    6.969775] In __slab_free(); kmalloc-8192: n->nr_partial=2, s->min_partial=6
Apr 26 01:04:05 riblp3 kernel: [    6.970154] In __slab_free(); kmalloc-8192: n->nr_partial=3, s->min_partial=6
Apr 26 01:04:05 riblp3 kernel: [    6.979489] In __slab_free(); kmalloc-8192: n->nr_partial=4, s->min_partial=6
Apr 26 01:04:05 riblp3 kernel: [    6.979823] In __slab_free(); kmalloc-8192: n->nr_partial=5, s->min_partial=6
Apr 26 01:04:05 riblp3 kernel: [    9.500383] In __slab_free(); kmalloc-8192: n->nr_partial=7, s->min_partial=6
Apr 26 01:04:05 riblp3 kernel: [    9.509736] In __slab_free(); kmalloc-8192: n->nr_partial=7, s->min_partial=6
Apr 26 01:04:08 riblp3 kernel: [   42.314395] In __slab_free(); kmalloc-8192: n->nr_partial=100, s->min_partial=6
Apr 26 01:04:08 riblp3 kernel: [   42.410333] In __slab_free(); kmalloc-8192: n->nr_partial=100, s->min_partial=6
Apr 26 01:04:09 riblp3 kernel: [   43.411851] In __slab_free(); kmalloc-8192: n->nr_partial=339, s->min_partial=6
Apr 26 01:04:09 riblp3 kernel: [   43.411980] In __slab_free(); kmalloc-8192: n->nr_partial=338, s->min_partial=6
Apr 26 01:04:09 riblp3 kernel: [   43.412083] In __slab_free(); kmalloc-8192: n->nr_partial=337, s->min_partial=6
--------------------------------------------------------------------------------
The s->min_partial is always "6" and most of n->nr_partial is bigger than 
its partner of the same line.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
