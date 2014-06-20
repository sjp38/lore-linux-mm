Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id AD1BF6B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:26:39 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so3798561wes.23
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:26:38 -0700 (PDT)
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
        by mx.google.com with ESMTPS id ce8si11309064wjb.125.2014.06.20.07.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 07:26:26 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id u57so3860073wes.5
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:26:26 -0700 (PDT)
Date: Fri, 20 Jun 2014 17:26:22 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in kvm.
Message-ID: <20140620142622.GA28698@minantech.com>
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
 <20140618061230.GA10948@minantech.com>
 <53A136C4.5070206@cn.fujitsu.com>
 <20140619092031.GA429@minantech.com>
 <20140619190024.GA3887@amt.cnet>
 <20140620111509.GE20764@minantech.com>
 <20140620125326.GA22283@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140620125326.GA22283@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>

On Fri, Jun 20, 2014 at 09:53:26AM -0300, Marcelo Tosatti wrote:
> On Fri, Jun 20, 2014 at 02:15:10PM +0300, Gleb Natapov wrote:
> > On Thu, Jun 19, 2014 at 04:00:24PM -0300, Marcelo Tosatti wrote:
> > > On Thu, Jun 19, 2014 at 12:20:32PM +0300, Gleb Natapov wrote:
> > > > CCing Marcelo,
> > > > 
> > > > On Wed, Jun 18, 2014 at 02:50:44PM +0800, Tang Chen wrote:
> > > > > Hi Gleb,
> > > > > 
> > > > > Thanks for the quick reply. Please see below.
> > > > > 
> > > > > On 06/18/2014 02:12 PM, Gleb Natapov wrote:
> > > > > >On Wed, Jun 18, 2014 at 01:50:00PM +0800, Tang Chen wrote:
> > > > > >>[Questions]
> > > > > >>And by the way, would you guys please answer the following questions for me ?
> > > > > >>
> > > > > >>1. What's the ept identity pagetable for ?  Only one page is enough ?
> > > > > >>
> > > > > >>2. Is the ept identity pagetable only used in realmode ?
> > > > > >>    Can we free it once the guest is up (vcpu in protect mode)?
> > > > > >>
> > > > > >>3. Now, ept identity pagetable is allocated in qemu userspace.
> > > > > >>    Can we allocate it in kernel space ?
> > > > > >What would be the benefit?
> > > > > 
> > > > > I think the benefit is we can hot-remove the host memory a kvm guest
> > > > > is using.
> > > > > 
> > > > > For now, only memory in ZONE_MOVABLE can be migrated/hot-removed. And the
> > > > > kernel
> > > > > will never use ZONE_MOVABLE memory. So if we can allocate these two pages in
> > > > > kernel space, we can pin them without any trouble. When doing memory
> > > > > hot-remove,
> > > > > the kernel will not try to migrate these two pages.
> > > > But we can do that by other means, no? The patch you've sent for instance.
> > > > 
> > > > > 
> > > > > >
> > > > > >>
> > > > > >>4. If I want to migrate these two pages, what do you think is the best way ?
> > > > > >>
> > > > > >I answered most of those here: http://www.mail-archive.com/kvm@vger.kernel.org/msg103718.html
> > > > > 
> > > > > I'm sorry I must missed this email.
> > > > > 
> > > > > Seeing your advice, we can unpin these two pages and repin them in the next
> > > > > EPT violation.
> > > > > So about this problem, which solution would you prefer, allocate these two
> > > > > pages in kernel
> > > > > space, or migrate them before memory hot-remove ?
> > > > > 
> > > > > I think the first solution is simpler. But I'm not quite sure if there is
> > > > > any other pages
> > > > > pinned in memory. If we have the same problem with other kvm pages, I think
> > > > > it is better to
> > > > > solve it in the second way.
> > > > > 
> > > > > What do you think ?
> > > > Remove pinning is preferable. In fact looks like for identity pagetable
> > > > it should be trivial, just don't pin. APIC access page is a little bit
> > > > more complicated since its physical address needs to be tracked to be
> > > > updated in VMCS.
> > > 
> > > Yes, and there are new users of page pinning as well soon (see PEBS
> > > threads on kvm-devel).
> > > 
> > > Was thinking of notifiers scheme. Perhaps:
> > > 
> > > ->begin_page_unpin(struct page *page)
> > > 	- Remove any possible access to page.
> > > 
> > > ->end_page_unpin(struct page *page)
> > > 	- Reinstantiate any possible access to page.
> > > 
> > > For KVM:
> > > 
> > > ->begin_page_unpin()
> > > 	- Remove APIC-access page address from VMCS.
> > > 	  or
> > > 	- Remove spte translation to pinned page.
> > > 	
> > > 	- Put vcpu in state where no VM-entries are allowed.
> > > 
> > > ->end_page_unpin()
> > > 	- Setup APIC-access page, ...
> > > 	- Allow vcpu to VM-entry.
> > > 
> > I believe that to handle identity page and APIC access page we do not
> > need any of those. 
> > We can use mmu notifiers to track when page begins
> > to be moved and we can find new page location on EPT violation.
> 
> Does page migration hook via mmu notifiers? I don't think so. 
> 
Both identity page and APIC access page are userspace pages which will
have to be unmap from process address space during migration. At this point
mmu notifiers will be called.

> It won't even attempt page migration because the page count is
> increased (would have to confirm though). Tang?
> 
Of course, we should not pin.
 
> The problem with identity page is this: its location is written into the
> guest CR3. So you cannot allow it (the page which the guest CR3 points
> to) to be reused before you remove the reference.
> 
> Where is the guarantee there will be an EPT violation, allowing a vcpu
> to execute with guest CR3 pointing to page with random data?
> 
A guest's physical address is written into CR3 (0xfffbc000 usually),
not a physical address of an identity page directly. When a guest will
try to use CR3 KVM will get EPT violation and shadow page code will find
a page that backs guest's address 0xfffbc000 and will map it into EPT
table. This is what happens on a first vmentry after vcpu creation.

> Same with the APIC access page.
APIC page is always mapped into guest's APIC base address 0xfee00000.
The way it works is that when vCPU accesses page at 0xfee00000 the access
is translated to APIC access page physical address. CPU sees that access
is for APIC page and generates APIC access exit instead of memory access.
If address 0xfee00000 is not mapped by EPT then EPT violation exit will
be generated instead, EPT mapping will be instantiated, access retired
by a guest and this time will generate APIC access exit.

> 
> > > Because allocating APIC access page from distant NUMA node can
> > > be a performance problem, i believe.
> > I do not think this is the case. APIC access page is never written to,
> > and in fact SDM advice to share it between all vcpus.
> 
> Right. 
> 
> But the point is not so much relevant as this should be handled for
> PEBS pages which would be interesting to force to non-movable zones.
>
IIRC your shadow page pinning patch series support flushing of ptes
by mmu notifier by forcing MMU reload and, as a result, faulting in of
pinned pages during next entry.  Your patch series does not pin pages
by elevating their page count.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
