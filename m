Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 845F66B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 14:24:07 -0400 (EDT)
Date: Thu, 25 Apr 2013 18:24:05 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
In-Reply-To: <20130425060705.GK2672@localhost.localdomain>
Message-ID: <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
References: <alpine.DEB.2.02.1304161315290.30779@chino.kir.corp.google.com> <20130417094750.GB2672@localhost.localdomain> <20130417141909.GA24912@dhcp22.suse.cz> <20130418101541.GC2672@localhost.localdomain> <20130418175513.GA12581@dhcp22.suse.cz>
 <20130423131558.GH8001@dhcp22.suse.cz> <20130424044848.GI2672@localhost.localdomain> <20130424094732.GB31960@dhcp22.suse.cz> <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com> <20130425060705.GK2672@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.02.1304251312502.26930@gentwo.org>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, mhocko@suse.cz, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, 25 Apr 2013, Han Pingtian wrote:

> > A dump of the other fields in /sys/kernel/slab/kmalloc*/* would also be
> > useful.
> >
> I have dumpped all /sys/kernel/slab/kmalloc*/* in kmalloc.tar.xz and
> will attach it to this mail.

Ok that looks like a lot of objects were freed from slab pages but the
slab pages were not freed.

looking at kmalloc-8192 we have

Total capacity of the slab cache is 27k objects but only 508 are in use.

Looks like slab pages are not freed when all objects in them have been
released.

The relevant portion of code that do the freeing are in

mm/slub.c::unfreeze_partials()

		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
                        page->next = discard_page;
                        discard_page = page;
                } else {
                        add_partial(n, page, DEACTIVATE_TO_TAIL);
                        stat(s, FREE_ADD_PARTIAL);
                }


..

       while (discard_page) {
                page = discard_page;
                discard_page = discard_page->next;

                stat(s, DEACTIVATE_EMPTY);
                discard_slab(s, page);
                stat(s, FREE_SLAB);
        }

and mm/slub.c::__slab_free()

     if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
                goto slab_empty;


Could you verify the values of nr_partial and min_partial and verify that
the free paths are actually used?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
