Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 533178E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 09:18:46 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j5so1890540qtk.11
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:18:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a24si1142669qvd.18.2018.12.13.06.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 06:18:44 -0800 (PST)
Date: Thu, 13 Dec 2018 09:18:39 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213141838.GB3186@redhat.com>
References: <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
 <20181213032043.GA3204@ziepe.ca>
 <20181213124325.GA3186@redhat.com>
 <81a731bb-6a8a-a554-cf99-5d0588b0a21f@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <81a731bb-6a8a-a554-cf99-5d0588b0a21f@talpey.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Talpey <tom@talpey.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Thu, Dec 13, 2018 at 08:40:49AM -0500, Tom Talpey wrote:
> On 12/13/2018 7:43 AM, Jerome Glisse wrote:
> > On Wed, Dec 12, 2018 at 08:20:43PM -0700, Jason Gunthorpe wrote:
> > > On Wed, Dec 12, 2018 at 07:01:09PM -0500, Jerome Glisse wrote:
> > > > On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
> > > > > On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > > > > > > Almost, we need some safety around assuming that DMA is complete the
> > > > > > > page, so the notification would need to go all to way to userspace
> > > > > > > with something like a file lease notification. It would also need to
> > > > > > > be backstopped by an IOMMU in the case where the hardware does not /
> > > > > > > can not stop in-flight DMA.
> > > > > > 
> > > > > > You can always reprogram the hardware right away it will redirect
> > > > > > any dma to the crappy page.
> > > > > 
> > > > > That causes silent data corruption for RDMA users - we can't do that.
> > > > > 
> > > > > The only way out for current hardware is to forcibly terminate the
> > > > > RDMA activity somehow (and I'm not even sure this is possible, at
> > > > > least it would be driver specific)
> > > > > 
> > > > > Even the IOMMU idea probably doesn't work, I doubt all current
> > > > > hardware can handle a PCI-E error TLP properly.
> > > > 
> > > > What i saying is reprogram hardware to crappy page ie valid page
> > > > dma map but that just has random content as a last resort to allow
> > > > filesystem to reuse block. So their should be no PCIE error unless
> > > > hardware freak out to see its page table reprogram randomly.
> > > 
> > > No, that isn't an option. You can't silently provide corrupted data
> > > for RDMA to transfer out onto the network, or silently discard data
> > > coming in!!
> > > 
> > > Think of the consequences of that - I have a fileserver process and
> > > someone does ftruncate and now my clients receive corrupted data??
> > 
> > This is what happens _today_ ie today someone do GUP on page file
> > and then someone else do truncate the first GUP is effectively
> > streaming _random_ data to network as the page does not correspond
> > to anything anymore and once the RDMA MR goes aways and release
> > the page the page content will be lost. So i am not changing anything
> > here, what i proposed was to make it explicit to device driver at
> > least that they were streaming random data. Right now this is all
> > silent but this is what is happening wether you like it or not :)
> > 
> > Note that  i am saying do that only for truncate to allow to be
> > nice to fs. But again i am fine with whatever solution but you can
> > not please everyone here. Either block truncate and fs folks will
> > hate you or make it clear to device driver that you are streaming
> > random things and RDMA people hates you.
> > 
> > 
> > > The only option is to prevent the RDMA transfer from ever happening,
> > > and we just don't have hardware support (beyond destroy everything) to
> > > do that.
> > > 
> > > > The question is who do you want to punish ? RDMA user that pin stuff
> > > > and expect thing to work forever without worrying for other fs
> > > > activities ? Or filesystem to pin block forever :)
> > > 
> > > I don't want to punish everyone, I want both sides to have complete
> > > data integrity as the USER has deliberately decided to combine DAX and
> > > RDMA. So either stop it at the front end (ie get_user_pages_longterm)
> > > or make it work in a way that guarantees integrity for both.
> > > 
> > > >      S2: notify userspace program through device/sub-system
> > > >          specific API and delay ftruncate. After a while if there
> > > >          is no answer just be mean and force hardware to use
> > > >          crappy page as anyway this is what happens today
> > > 
> > > I don't think this happens today (outside of DAX).. Does it?
> > 
> > It does it is just silent, i don't remember anything in the code
> > that would stop a truncate to happen because of elevated refcount.
> > This does not happen with ODP mlx5 as it does abide by _all_ mmu
> > notifier. This is for anything that does ODP without support for
> > mmu notifier.
> 
> Wait - is it expected that the MMU notifier upcall is handled
> synchronously? That is, the page DMA mapping must be torn down
> immediately, and before returning?

Yes you must torn down mapping before returning from mmu notifier
call back. Any time after is too late. You obviously need hardware
that can support that. In the infiniband sub-system AFAIK only the
mlx5 hardware can do that. In the GPU sub-system everyone is fine.

Dunno about other sub-systems.


> That's simply not possible, since the hardware needs to get control
> to do this. Even if there were an IOMMU that could intercept the
> DMA, reprogramming it will require a flush, which cannot be guaranteed
> to occur "inline".

If hardware can not do that then hardware should not use GUP, at
least not on file back page. I advocated in favor of forbiding GUP
for device that can not do that as right now this silently breaks
in few cases (truncate, mremap, splice, reflink, ...). So the device
in those cases can end up with GUPed pages that do not correspond
to anything anymore ie they do not correspond to the memory backing
the virtual address they were GUP against, nor they correspond to
the file content at the given offset anymore. It is just random
data as far as the kernel or filesystem is concern.

Of course for this to happen you need an application that do stupid
thing like create an MR in one thread on the mmap of a file and
truncate that same file in another thread (or from the same thread).

So this is unlikely to happen in sane program. It does not mean it
will not happen.


The second set of issue at to deals with set_page_dirty happening
long time after page_release did happens and thus the fs dirty
page callback will see page in bad state and will BUG() and you
will have an oops and loose any data your device might have written
to the page. This is highly filesystem dependend and also timing
dependend and link to thing like memory pressure so it might not
happen that often but again it can happen.


> > > .. and the remedy here is to kill the process, not provide corrupt
> > > data. Kill the process is likely to not go over well with any real
> > > users that want this combination.
> > > 
> > > Think Samba serving files over RDMA - you can't have random unpriv
> > > users calling ftruncate and causing smbd to be killed or serve corrupt
> > > data.
> > 
> > So what i am saying is there is a choice and it would be better to
> > decide something than let the existing status quo where we just keep
> > streaming random data after truncate to a GUPed page.
> 
> Let's also remember that any torn-down DMA mapping can't be recycled
> until all uses of the old DMA addresses are destroyed. The whole
> thing screams for reference counting all the way down, to me.

I am not saying reuse the DMA address in the emergency_mean_callback
the idea was:

    gup_page_emergency_revoke(device, page)
    {
        crapy_page = alloc_page();
        dma_addr = dma_map(crappy_page, device, ...);
        mydevice_page_table_update(device, crappy_page, dma_addr);
        mydevice_tlb_flush(device);
        mydevice_wait_pending_dma(device)

        // at this point the original GUPed page is not access by hw

        dma_unmap(page);
        put_user_page(page);
    }

I know that it is something we can do with GPU devices. So i assumed
that other devices can do that to. But i understand this is highly
device dependent. Not that if you have a command queue it is more like:

    gup_page_emergency_revoke(device, page)
    {
        crapy_page = alloc_page();
        dma_addr = dma_map(crappy_page, device, ...);

        // below function update kernel side data structure that stores
        // the pointer to the GUPed page and that are use to build cmds
        // send to the hardware. It does not update the hardware, just
        // the device driver internal data structure.
        mydevice_replace_page_in_object(device, page, crappy_page, dma_addr);

        mydevice_queue_wait_pending_job(device);

        // at this point the original GUPed page is not access by hw and
        // any new command will be using the crappy page not the GUPed
        // page

        dma_unmap(page);
        put_user_page(page);
    }

Again if device can not do any of the above then it should really not
be using GUP because they are corner case that are simply not solvable.
We can avoid kernel OOPS but we can not pin the page as GUP user believe
ie the virtual address the GUP happened against can point to a different
page (true for both anonymous memory and file back memory).


The put_user_page() patchset is about solving the OOPS and BUG() and
also fixing the tiny race that exist for direct I/O. Fixing other user
of GUP should happen sub-system by sub-system and each sub-system or
device driver maintainer must choose their poison. This is what i am
advocating for. If the emergency_revoke above is something that would
work for device is something i can't say for certain, only for devices
i know (which are GPU mostly).

Cheers,
J�r�me
