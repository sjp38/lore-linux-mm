Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id AAAB36B00B0
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 12:28:39 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id s18so12102286lam.14
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 09:28:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oy5si2382311lbb.15.2014.09.11.09.28.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 09:28:32 -0700 (PDT)
Date: Thu, 11 Sep 2014 17:28:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140911162827.GZ17501@suse.de>
References: <54082B25.9090600@oracle.com>
 <20140908171853.GN17501@suse.de>
 <540DEDE7.4020300@oracle.com>
 <20140909213309.GQ17501@suse.de>
 <540F7D42.1020402@oracle.com>
 <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
 <20140910124732.GT17501@suse.de>
 <alpine.LSU.2.11.1409101210520.1744@eggly.anvils>
 <54110C62.4030702@oracle.com>
 <alpine.LSU.2.11.1409110356280.2116@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409110356280.2116@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Thu, Sep 11, 2014 at 04:39:39AM -0700, Hugh Dickins wrote:
> On Wed, 10 Sep 2014, Sasha Levin wrote:
> > On 09/10/2014 03:36 PM, Hugh Dickins wrote:
> > > Right, and Sasha  reports that that can fire, but he sees the bug
> > > with this patch in and without that firing.
> > 
> > I've changed that WARN_ON_ONCE() to a VM_BUG_ON_VMA() to get some useful
> > VMA information out, and got the following:
> 
> Well, thanks, but Mel and I have both failed to perceive any actual
> problem arising from that peculiarity.  And Mel's warning, and the 900s
> in yesterday's dumps, have shown that it is not correlated with the
> pte_mknuma() bug we are chasing.  So there isn't anything that I want to
> look up in these vmas.  Or did you notice something interesting in them?
> 
> > And on a maybe related note, I've started seeing the following today. It may
> > be because we fixed mbind() in trinity but it could also be related to
> 
> The fixed trinity may be counter-productive for now, since we think
> there is an understandable pte_mknuma() bug coming from that direction,
> but have not posted a patch for it yet.
> 
> > this issue (free_pgtables() is in the call chain). If you don't think it has
> > anything to do with it let me know and I'll start a new thread:
> > 
> > [ 1195.996803] BUG: unable to handle kernel NULL pointer dereference at           (null)
> > [ 1196.001744] IP: __rb_erase_color (include/linux/rbtree_augmented.h:107 lib/rbtree.c:229 lib/rbtree.c:367)
> > [ 1196.001744] Call Trace:
> > [ 1196.001744] vma_interval_tree_remove (mm/interval_tree.c:24)
> > [ 1196.001744] __remove_shared_vm_struct (mm/mmap.c:232)
> > [ 1196.001744] unlink_file_vma (mm/mmap.c:246)
> > [ 1196.001744] free_pgtables (mm/memory.c:547)
> > [ 1196.001744] exit_mmap (mm/mmap.c:2826)
> > [ 1196.001744] mmput (kernel/fork.c:654)
> > [ 1196.001744] do_exit (./arch/x86/include/asm/thread_info.h:168 kernel/exit.c:461 kernel/exit.c:746)
> 
> I didn't study in any detail, but this one seems much more like the
> zeroing and vma corruption that you've been seeing in other dumps.
> 

I didn't look through the dumps closely today because I spent the time
putting together a KVM setup similar to Sasha's (many cpus, fake NUMA,
etc) so I could run trinity in it in another attempt to reproduce this.
I did not encounter the same VM_BUG_ON unfortunately. However, trinity
itself crashed after 2.5 hours complaining

[watchdog] pid 32188 has disappeared. Reaping.
[watchdog] pid 32024 has disappeared. Reaping.
[watchdog] pid 32300 has disappeared. Reaping.
[watchdog] Sanity check failed! Found pid 0 at pidslot 35!

This did not happen when running on bare metal. This error makes me wonder
if it is evidence that there is zeroing corruption occuring when running
inside KVM. Another possibility is that it's somehow related to fake NUMA
although it's hard to see how. It's still possible the bug is with the
page table handling and KVM affects timing enough to cause problems so
I'm not ruling that out.

> Though a single pte_mknuma() crash could presumably be caused by vma
> corruption (but I think not mere zeroing), the recurrent way in which
> you hit that pte_mknuma() bug in particular makes it unlikely to be
> caused by random corruption.
> 
> You are generating new crashes faster than we can keep up with them.
> Would this be a suitable point for you to switch over to testing
> 3.17-rc, to see if that is as unstable for you as -next is?
> 
> That VM_BUG_ON(!(val & _PAGE_PRESENT)) is not in the 3.17-rc tree,
> but I think you can "safely" add it to 3.17-rc.  Quotes around
> "safely" meaning that we know that there's a bug to hit, at least
> in -next, but I don't think it's going to be hit for stupid obvious
> reasons.
> 

Agreed. If 3.17-rc4 looks stable with the VM_BUG_ON then it would be
really nice if you could bisect 3.17-rc4 to linux-next carrying the
VM_BUG_ON(!(val & _PAGE_PRESENT)) check at each bisection point. I'm not
100% sure if I'm seeing the same corruption as you or some other issue and
do not want to conflate numerous different problems into one. I know this
is a pain in the ass but if 3.17-rc4 looks stable then a bisection might
be faster overall than my constant head scratching :(

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
