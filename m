Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B91D6B41C6
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 14:05:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c8-v6so12244890pfn.2
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 11:05:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t66-v6si14401820pgt.181.2018.08.27.11.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 11:05:50 -0700 (PDT)
Date: Mon, 27 Aug 2018 11:05:45 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] x86: Convert vdso to use vm_fault_t
Message-ID: <20180827180544.GA24544@bombadil.infradead.org>
References: <20180703123910.2180-1-willy@infradead.org>
 <20180703123910.2180-2-willy@infradead.org>
 <alpine.DEB.2.21.1807161116590.2644@nanos.tec.linutronix.de>
 <CAFqt6zbgoTgw1HNp+anOYY8CiU1BPoNeeddsnGGXWY_hVOd5iQ@mail.gmail.com>
 <alpine.DEB.2.21.1808031503370.1745@nanos.tec.linutronix.de>
 <CAFqt6zbJq9kca8dHDVAs-MOWNZgo2C=id3Cp4M0C76MQDXevJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbJq9kca8dHDVAs-MOWNZgo2C=id3Cp4M0C76MQDXevJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Brajeswar Ghosh <brajeswar.linux@gmail.com>, Sabyasachi Gupta <sabyasachi.linux@gmail.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Aug 27, 2018 at 09:01:48PM +0530, Souptick Joarder wrote:
> On Fri, Aug 3, 2018 at 6:44 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > On Fri, 3 Aug 2018, Souptick Joarder wrote:
> > > On Mon, Jul 16, 2018 at 2:47 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > > On Tue, 3 Jul 2018, Matthew Wilcox wrote:
> > > >
> > > >> Return vm_fault_t codes directly from the appropriate mm routines instead
> > > >> of converting from errnos ourselves.  Fixes a minor bug where we'd return
> > > >> SIGBUS instead of the correct OOM code if we ran out of memory allocating
> > > >> page tables.
> > > >>
> > > >> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > >
> > > > Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> > > >
> > >
> > > Thomas, are these 3 patches part of this series will be queued
> > > for 4.19 ?
> >
> > I don't know. I expected that these go through the mm tree, but if nobody
> > feels responsible, I could pick up the whole lot. But I'd like to see acks
> > from the mm folks for [1/3] and [3/3]
> >
> >   https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
> >
> > Thanks,
> >
> >         tglx
> >
> 
> Any comment from mm reviewers for patch [1/3] and [3/3] ??
> 
> https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org

I think at this point, it would probably be best to ask Andrew to pick
up all three of these patches.

In addition to these three, I see the following places that need to be changed:

Documentation/gpu/drm-mm.rst:300:               int (*fault)(struct vm_fault *vmf);

drivers/gpu/drm/virtio/virtgpu_ttm.c:117:static int virtio_gpu_ttm_fault(struct vm_fault *vmf)
 - #if 0 code.  convert anyway.

drivers/gpu/drm/vkms/vkms_drv.h:68:int vkms_gem_fault(struct vm_fault *vmf);
drivers/gpu/drm/vkms/vkms_gem.c:46:int vkms_gem_fault(struct vm_fault *vmf)

fs/ext4/ext4.h:2472:extern int ext4_page_mkwrite(struct vm_fault *vmf);
fs/ext4/ext4.h:2473:extern int ext4_filemap_fault(struct vm_fault *vmf);
fs/ext4/inode.c:6154:int ext4_page_mkwrite(struct vm_fault *vmf)
fs/ext4/inode.c:6251:int ext4_filemap_fault(struct vm_fault *vmf)

fs/iomap.c:1059:int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
include/linux/iomap.h:144:int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops);
 - I saw you just resent this patch.

mm/filemap.c:2751:int filemap_page_mkwrite(struct vm_fault *vmf)
 - This is the NOMMU case, so I suspect your testing didn't catch it.
