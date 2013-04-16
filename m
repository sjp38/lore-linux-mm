Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 1C2B46B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 07:43:24 -0400 (EDT)
Date: Tue, 16 Apr 2013 06:43:22 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Message-ID: <20130416114322.GN3658@sgi.com>
References: <516CF235.4060103@linux.vnet.ibm.com>
 <20130416093131.GJ3658@sgi.com>
 <516D275C.8040406@linux.vnet.ibm.com>
 <20130416112553.GM3658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130416112553.GM3658@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Argh.  Taking a step back helped clear my head.

For the -stable releases, I agree we should just go with your
revert-plus-hlist_del_init_rcu patch.  I will give it a test
when I am in the office.

For the v3.10 release, we should work on making this more
correct and completely documented.

Robin

On Tue, Apr 16, 2013 at 06:25:53AM -0500, Robin Holt wrote:
> On Tue, Apr 16, 2013 at 06:26:36PM +0800, Xiao Guangrong wrote:
> > On 04/16/2013 05:31 PM, Robin Holt wrote:
> > > On Tue, Apr 16, 2013 at 02:39:49PM +0800, Xiao Guangrong wrote:
> > >> The commit 751efd8610d3 (mmu_notifier_unregister NULL Pointer deref
> > >> and multiple ->release()) breaks the fix:
> > >>     3ad3d901bbcfb15a5e4690e55350db0899095a68
> > >>     (mm: mmu_notifier: fix freed page still mapped in secondary MMU)
> > > 
> > > Can you describe how the page is still mapped?  I thought I had all
> > > cases covered.  Whichever call hits first, I thought we had one callout
> > > to the registered notifiers.  Are you saying we need multiple callouts?
> > 
> > No.
> > 
> > You patch did this:
> > 
> >                 hlist_del_init_rcu(&mn->hlist);    1 <======
> > +               spin_unlock(&mm->mmu_notifier_mm->lock);
> > +
> > +               /*
> > +                * Clear sptes. (see 'release' description in mmu_notifier.h)
> > +                */
> > +               if (mn->ops->release)
> > +                       mn->ops->release(mn, mm);    2 <======
> > +
> > +               spin_lock(&mm->mmu_notifier_mm->lock);
> > 
> > At point 1, you delete the notify, but the page is still on LRU. Other
> > cpu can reclaim the page but without call ->invalid_page().
> > 
> > At point 2, you call ->release(), the secondary MMU make page Accessed/Dirty
> > but that page has already been on the free-list of page-alloctor.
> 
> That expectation on srcu _REALLY_ needs to be documented better.
> Maybe I missed it in the comments, but there is an expectation beyond
> the synchronize_srcu().  This code has been extremely poorly described
> and I think it is time we fix that up.
> 
> I do see that in comments for mmu_notifier_unregister, there is an
> expectation upon already having all the spte's removed prior to making
> this call.  I think that is also a stale comment as it mentions a lock
> which I am not sure ever really existed.
> 
> > > Also, shouldn't you be asking for a revert commit and then supply a
> > > subsequent commit for the real fix?  I thought that was the process for
> > > doing a revert.
> > 
> > Can not do that pure reversion since your patch moved hlist_for_each_entry_rcu
> > which has been modified now.
> > 
> > Should i do pure-eversion + hlist_for_each_entry_rcu update first?
> 
> Let's not go off without considering this first.
> 
> It looks like what we really need to do is ensure there is a method
> for ensuring that the mmu_notifier remains on the list while callouts
> invalidate_page() callouts are being made and also a means of ensuring
> that only one ->release() callout is made.
> 
> First, is it the case that when kvm calls mmu_notifier_unregister(),
> it has already cleared the spte's?  (what does spte stand for anyway)?
> If so, then we really need to close the hole in __mmu_notifier_release().
> I think we would need to modify code in both _unregister and _release,
> but the issue is really _release.
> 
> 
> I need to get ready and drive into work.  If you want to float something
> out there, that is fine.  Otherwise, I will try to work something up
> when I get to the office.
> 
> Thanks,
> Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
