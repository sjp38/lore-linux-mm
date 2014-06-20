Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB206B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:15:15 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so3512729wgh.18
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 04:15:15 -0700 (PDT)
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
        by mx.google.com with ESMTPS id p8si1713009wij.57.2014.06.20.04.15.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 04:15:14 -0700 (PDT)
Received: by mail-we0-f171.google.com with SMTP id q58so3593182wes.2
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 04:15:13 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:15:10 +0300
From: Gleb Natapov <gleb@minantech.com>
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in kvm.
Message-ID: <20140620111509.GE20764@minantech.com>
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
 <20140618061230.GA10948@minantech.com>
 <53A136C4.5070206@cn.fujitsu.com>
 <20140619092031.GA429@minantech.com>
 <20140619190024.GA3887@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140619190024.GA3887@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>

On Thu, Jun 19, 2014 at 04:00:24PM -0300, Marcelo Tosatti wrote:
> On Thu, Jun 19, 2014 at 12:20:32PM +0300, Gleb Natapov wrote:
> > CCing Marcelo,
> > 
> > On Wed, Jun 18, 2014 at 02:50:44PM +0800, Tang Chen wrote:
> > > Hi Gleb,
> > > 
> > > Thanks for the quick reply. Please see below.
> > > 
> > > On 06/18/2014 02:12 PM, Gleb Natapov wrote:
> > > >On Wed, Jun 18, 2014 at 01:50:00PM +0800, Tang Chen wrote:
> > > >>[Questions]
> > > >>And by the way, would you guys please answer the following questions for me ?
> > > >>
> > > >>1. What's the ept identity pagetable for ?  Only one page is enough ?
> > > >>
> > > >>2. Is the ept identity pagetable only used in realmode ?
> > > >>    Can we free it once the guest is up (vcpu in protect mode)?
> > > >>
> > > >>3. Now, ept identity pagetable is allocated in qemu userspace.
> > > >>    Can we allocate it in kernel space ?
> > > >What would be the benefit?
> > > 
> > > I think the benefit is we can hot-remove the host memory a kvm guest
> > > is using.
> > > 
> > > For now, only memory in ZONE_MOVABLE can be migrated/hot-removed. And the
> > > kernel
> > > will never use ZONE_MOVABLE memory. So if we can allocate these two pages in
> > > kernel space, we can pin them without any trouble. When doing memory
> > > hot-remove,
> > > the kernel will not try to migrate these two pages.
> > But we can do that by other means, no? The patch you've sent for instance.
> > 
> > > 
> > > >
> > > >>
> > > >>4. If I want to migrate these two pages, what do you think is the best way ?
> > > >>
> > > >I answered most of those here: http://www.mail-archive.com/kvm@vger.kernel.org/msg103718.html
> > > 
> > > I'm sorry I must missed this email.
> > > 
> > > Seeing your advice, we can unpin these two pages and repin them in the next
> > > EPT violation.
> > > So about this problem, which solution would you prefer, allocate these two
> > > pages in kernel
> > > space, or migrate them before memory hot-remove ?
> > > 
> > > I think the first solution is simpler. But I'm not quite sure if there is
> > > any other pages
> > > pinned in memory. If we have the same problem with other kvm pages, I think
> > > it is better to
> > > solve it in the second way.
> > > 
> > > What do you think ?
> > Remove pinning is preferable. In fact looks like for identity pagetable
> > it should be trivial, just don't pin. APIC access page is a little bit
> > more complicated since its physical address needs to be tracked to be
> > updated in VMCS.
> 
> Yes, and there are new users of page pinning as well soon (see PEBS
> threads on kvm-devel).
> 
> Was thinking of notifiers scheme. Perhaps:
> 
> ->begin_page_unpin(struct page *page)
> 	- Remove any possible access to page.
> 
> ->end_page_unpin(struct page *page)
> 	- Reinstantiate any possible access to page.
> 
> For KVM:
> 
> ->begin_page_unpin()
> 	- Remove APIC-access page address from VMCS.
> 	  or
> 	- Remove spte translation to pinned page.
> 	
> 	- Put vcpu in state where no VM-entries are allowed.
> 
> ->end_page_unpin()
> 	- Setup APIC-access page, ...
> 	- Allow vcpu to VM-entry.
> 
I believe that to handle identity page and APIC access page we do not
need any of those. We can use mmu notifiers to track when page begins
to be moved and we can find new page location on EPT violation.

> 
> Because allocating APIC access page from distant NUMA node can
> be a performance problem, i believe.
I do not think this is the case. APIC access page is never written to,
and in fact SDM advice to share it between all vcpus.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
