Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 446316B005D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:08:53 -0400 (EDT)
Date: Thu, 6 Aug 2009 12:08:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806100824.GO23385@random.random>
References: <20090805024058.GA8886@localhost>
 <20090805155805.GC23385@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805155805.GC23385@random.random>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 05:58:05PM +0200, Andrea Arcangeli wrote:
> On Wed, Aug 05, 2009 at 10:40:58AM +0800, Wu Fengguang wrote:
> >  			 */
> > -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> > +			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
> >  				list_add(&page->lru, &l_active);
> >  				continue;
> >  			}
> > 
> 
> Please nuke the whole check and do an unconditional list_add;
> continue; there.

After some conversation it seems reactivating on large systems
generates troubles to the VM as young bit have excessive time to be
reactivated, giving troubles to shrink active list. I see that, so
then the check should be still nuked, but the unconditional
deactivation should happen instead. Otherwise it's trivial to put the
VM to its knees and DoS it with a simple mmap of a file with MAP_EXEC
as parameter of mmap. My whole point is that deciding if activating or
deactivating pages can't be in function  of VM_EXEC, and clearly it
helps on desktops but then it probably is a signal that the VM isn't
good enough by itself to identify the important working set using
young bits and stuff on desktop systems, and if there's a good reason
to not activate, we shouldn't activate the VM_EXEC either as anything
and anybody can generate a file mapping with VM_EXEC set...

Likely we need a cut-off point, if we detect it takes more than X
seconds to scan the whole active list, we start ignoring young bits,
as young bits don't provide any meaningful information then and they
just hang the VM in preventing it to shrink active list and looping
over it endlessy with million pages inside that list. But on small
systems if inactive list is short it may be too quick to just clear
the young bit and only giving it time to be re-enabled in inactive
list. That may be the source of the problem. Actually I'm speculating
here, because I barely understood that this is swapin... not sure
exactly what this regression is about but testing the patch posted is
good idea and it will tell us if we just need to dynamically
differentiating the algorithm between large and small systems and start
ignoring young bits only at some point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
