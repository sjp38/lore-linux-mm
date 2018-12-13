Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F63E8E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:18:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k90so2789880qte.0
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:18:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s63si317798qkd.0.2018.12.13.11.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 11:18:19 -0800 (PST)
Date: Thu, 13 Dec 2018 14:18:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213191813.GE3186@redhat.com>
References: <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
 <20181213032043.GA3204@ziepe.ca>
 <20181213124325.GA3186@redhat.com>
 <81a731bb-6a8a-a554-cf99-5d0588b0a21f@talpey.com>
 <20181213141838.GB3186@redhat.com>
 <0b75a9a6-3907-ea88-6352-256bc2954f4a@talpey.com>
 <20181213151839.GC3186@redhat.com>
 <a6c25182-9691-d9f9-b3b5-a42b2b5d6f7f@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a6c25182-9691-d9f9-b3b5-a42b2b5d6f7f@talpey.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Talpey <tom@talpey.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Thu, Dec 13, 2018 at 01:12:06PM -0500, Tom Talpey wrote:
> On 12/13/2018 10:18 AM, Jerome Glisse wrote:
> > On Thu, Dec 13, 2018 at 09:51:18AM -0500, Tom Talpey wrote:
> > > On 12/13/2018 9:18 AM, Jerome Glisse wrote:
> > > > On Thu, Dec 13, 2018 at 08:40:49AM -0500, Tom Talpey wrote:
> > > > > On 12/13/2018 7:43 AM, Jerome Glisse wrote:
> > > > > > On Wed, Dec 12, 2018 at 08:20:43PM -0700, Jason Gunthorpe wrote:
> > > > > > > On Wed, Dec 12, 2018 at 07:01:09PM -0500, Jerome Glisse wrote:
> > > > > > > > On Wed, Dec 12, 2018 at 04:37:03PM -0700, Jason Gunthorpe wrote:
> > > > > > > > > On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > > > > > > > > > > Almost, we need some safety around assuming that DMA is complete the
> > > > > > > > > > > page, so the notification would need to go all to way to userspace
> > > > > > > > > > > with something like a file lease notification. It would also need to
> > > > > > > > > > > be backstopped by an IOMMU in the case where the hardware does not /
> > > > > > > > > > > can not stop in-flight DMA.
> > > > > > > > > > 
> > > > > > > > > > You can always reprogram the hardware right away it will redirect
> > > > > > > > > > any dma to the crappy page.
> > > > > > > > > 
> > > > > > > > > That causes silent data corruption for RDMA users - we can't do that.
> > > > > > > > > 
> > > > > > > > > The only way out for current hardware is to forcibly terminate the
> > > > > > > > > RDMA activity somehow (and I'm not even sure this is possible, at
> > > > > > > > > least it would be driver specific)
> > > > > > > > > 
> > > > > > > > > Even the IOMMU idea probably doesn't work, I doubt all current
> > > > > > > > > hardware can handle a PCI-E error TLP properly.
> > > > > > > > 
> > > > > > > > What i saying is reprogram hardware to crappy page ie valid page
> > > > > > > > dma map but that just has random content as a last resort to allow
> > > > > > > > filesystem to reuse block. So their should be no PCIE error unless
> > > > > > > > hardware freak out to see its page table reprogram randomly.
> > > > > > > 
> > > > > > > No, that isn't an option. You can't silently provide corrupted data
> > > > > > > for RDMA to transfer out onto the network, or silently discard data
> > > > > > > coming in!!
> > > > > > > 
> > > > > > > Think of the consequences of that - I have a fileserver process and
> > > > > > > someone does ftruncate and now my clients receive corrupted data??
> > > > > > 
> > > > > > This is what happens _today_ ie today someone do GUP on page file
> > > > > > and then someone else do truncate the first GUP is effectively
> > > > > > streaming _random_ data to network as the page does not correspond
> > > > > > to anything anymore and once the RDMA MR goes aways and release
> > > > > > the page the page content will be lost. So i am not changing anything
> > > > > > here, what i proposed was to make it explicit to device driver at
> > > > > > least that they were streaming random data. Right now this is all
> > > > > > silent but this is what is happening wether you like it or not :)
> > > > > > 
> > > > > > Note that  i am saying do that only for truncate to allow to be
> > > > > > nice to fs. But again i am fine with whatever solution but you can
> > > > > > not please everyone here. Either block truncate and fs folks will
> > > > > > hate you or make it clear to device driver that you are streaming
> > > > > > random things and RDMA people hates you.
> > > > > > 
> > > > > > 
> > > > > > > The only option is to prevent the RDMA transfer from ever happening,
> > > > > > > and we just don't have hardware support (beyond destroy everything) to
> > > > > > > do that.
> > > > > > > 
> > > > > > > > The question is who do you want to punish ? RDMA user that pin stuff
> > > > > > > > and expect thing to work forever without worrying for other fs
> > > > > > > > activities ? Or filesystem to pin block forever :)
> > > > > > > 
> > > > > > > I don't want to punish everyone, I want both sides to have complete
> > > > > > > data integrity as the USER has deliberately decided to combine DAX and
> > > > > > > RDMA. So either stop it at the front end (ie get_user_pages_longterm)
> > > > > > > or make it work in a way that guarantees integrity for both.
> > > > > > > 
> > > > > > > >        S2: notify userspace program through device/sub-system
> > > > > > > >            specific API and delay ftruncate. After a while if there
> > > > > > > >            is no answer just be mean and force hardware to use
> > > > > > > >            crappy page as anyway this is what happens today
> > > > > > > 
> > > > > > > I don't think this happens today (outside of DAX).. Does it?
> > > > > > 
> > > > > > It does it is just silent, i don't remember anything in the code
> > > > > > that would stop a truncate to happen because of elevated refcount.
> > > > > > This does not happen with ODP mlx5 as it does abide by _all_ mmu
> > > > > > notifier. This is for anything that does ODP without support for
> > > > > > mmu notifier.
> > > > > 
> > > > > Wait - is it expected that the MMU notifier upcall is handled
> > > > > synchronously? That is, the page DMA mapping must be torn down
> > > > > immediately, and before returning?
> > > > 
> > > > Yes you must torn down mapping before returning from mmu notifier
> > > > call back. Any time after is too late. You obviously need hardware
> > > > that can support that. In the infiniband sub-system AFAIK only the
> > > > mlx5 hardware can do that. In the GPU sub-system everyone is fine.
> > > 
> > > I'm skeptical that MLX5 can actually make this guarantee. But we
> > > can take that offline in linux-rdma.
> > 
> > It does unless the code lies about what the hardware do :) See umem_odp.c
> > in core and odp.c in mlx5 directories.
> 
> Ok, I did look and there are numerous error returns from these calls.
> Some are related to resource shortages (including the rather ominous-
> sounding "emergency_pages" in odp.c), others related to the generic
> RDMA behaviors such as posting work requests and reaping their
> completion status.
> 
> So I'd ask - what is the backup plan from the mmu notifier if the
> unmap fails? Which it certainly will, in many real-world situations.

No backup, it must succeed, invalidation is:
    invalidate_range_start_trampoline
        mlx5_ib_invalidate_range
            mlx5_ib_update_xlt

Beside sanity check on data structure fields the only failure path
i see there is are for allocating a page to send commands to device
and failing to map that page. What mellanox should be doing there
is pre-allocate and pre-map couple pages for that to avoid any failure
because of that.


There is no way we will accept mmu notifier to fail, it would block
tons of syscall like munmap, truncate, mremap, madvise, mprotect,...
So it is a non starter to try to ask for mmu notifier to fail.

Cheers,
J�r�me
