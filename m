Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 141086B0032
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 07:24:29 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Sat, 27 Apr 2013 05:24:24 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9236919D8036
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 05:24:15 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3RBOLpf127558
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 05:24:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3RBOKP0005023
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 05:24:20 -0600
Date: Sat, 27 Apr 2013 19:24:18 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130427112418.GC4441@localhost.localdomain>
References: <20130418101541.GC2672@localhost.localdomain>
 <20130418175513.GA12581@dhcp22.suse.cz>
 <20130423131558.GH8001@dhcp22.suse.cz>
 <20130424044848.GI2672@localhost.localdomain>
 <20130424094732.GB31960@dhcp22.suse.cz>
 <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com>
 <20130425060705.GK2672@localhost.localdomain>
 <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
 <20130426062436.GB4441@localhost.localdomain>
 <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, mhocko@suse.cz, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Fri, Apr 26, 2013 at 02:42:32PM +0000, Christoph Lameter wrote:
> On Fri, 26 Apr 2013, Han Pingtian wrote:
> 
> > Could you give me some hints about how to verify them? Only I can do is
> > adding two printk() statements to print the vaules in those two
> > functions:
> 
> Ok thats good. nr->partial needs to be bigger than min_partial in order
> for frees to occur. So they do occur.
> 
> > And looks like only printk() in __slab_free() is invoked. I got about 6764
> > lines of something like this:
> >
> > --------------------------------------------------------------------------------
> > Apr 26 01:04:05 riblp3 kernel: [    6.969775] In __slab_free(); kmalloc-8192: n->nr_partial=2, s->min_partial=6
> > Apr 26 01:04:05 riblp3 kernel: [    6.970154] In __slab_free(); kmalloc-8192: n->nr_partial=3, s->min_partial=6
> > Apr 26 01:04:05 riblp3 kernel: [    6.979489] In __slab_free(); kmalloc-8192: n->nr_partial=4, s->min_partial=6
> > Apr 26 01:04:05 riblp3 kernel: [    6.979823] In __slab_free(); kmalloc-8192: n->nr_partial=5, s->min_partial=6
> > Apr 26 01:04:05 riblp3 kernel: [    9.500383] In __slab_free(); kmalloc-8192: n->nr_partial=7, s->min_partial=6
> > Apr 26 01:04:05 riblp3 kernel: [    9.509736] In __slab_free(); kmalloc-8192: n->nr_partial=7, s->min_partial=6
> > Apr 26 01:04:08 riblp3 kernel: [   42.314395] In __slab_free(); kmalloc-8192: n->nr_partial=100, s->min_partial=6
> > Apr 26 01:04:08 riblp3 kernel: [   42.410333] In __slab_free(); kmalloc-8192: n->nr_partial=100, s->min_partial=6
> > Apr 26 01:04:09 riblp3 kernel: [   43.411851] In __slab_free(); kmalloc-8192: n->nr_partial=339, s->min_partial=6
> > Apr 26 01:04:09 riblp3 kernel: [   43.411980] In __slab_free(); kmalloc-8192: n->nr_partial=338, s->min_partial=6
> > Apr 26 01:04:09 riblp3 kernel: [   43.412083] In __slab_free(); kmalloc-8192: n->nr_partial=337, s->min_partial=6
> > --------------------------------------------------------------------------------
> > The s->min_partial is always "6" and most of n->nr_partial is bigger than
> > its partner of the same line.
> 
> Thats the way it should be. But the mystery is still there. Why do the
> pages not get freed? Can you add a printk in __free_slab to verify that it
> actually gets called? Print s->name to see which slab is affected by the
> free.
> 
I added a printk() like this:

@@ -1388,6 +1388,8 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
        int order = compound_order(page);
        int pages = 1 << order;
 
+       printk(KERN_INFO "__free_slab(): %s\n", s->name);
+
        if (kmem_cache_debug(s)) {
                void *p;

and it is called so many times that the boot cannot be finished. So
maybe the memory isn't freed even though __free_slab() get called?


> Is there any way I can run a powerpc kernel that shows the issue on x86
> with an emulator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
