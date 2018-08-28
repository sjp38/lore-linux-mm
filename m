Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5A2E6B449F
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:18:26 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id p8-v6so118162ljg.10
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 23:18:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h15-v6sor38138ljg.44.2018.08.27.23.18.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 23:18:24 -0700 (PDT)
MIME-Version: 1.0
References: <20180703123910.2180-1-willy@infradead.org> <20180703123910.2180-2-willy@infradead.org>
 <alpine.DEB.2.21.1807161116590.2644@nanos.tec.linutronix.de>
 <CAFqt6zbgoTgw1HNp+anOYY8CiU1BPoNeeddsnGGXWY_hVOd5iQ@mail.gmail.com>
 <alpine.DEB.2.21.1808031503370.1745@nanos.tec.linutronix.de>
 <CAFqt6zbJq9kca8dHDVAs-MOWNZgo2C=id3Cp4M0C76MQDXevJg@mail.gmail.com> <20180827180544.GA24544@bombadil.infradead.org>
In-Reply-To: <20180827180544.GA24544@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 28 Aug 2018 11:48:12 +0530
Message-ID: <CAFqt6zZ+4aTiOK13a61hCHKY9p=GkaNiagV6zQ4zVZRM1fHq5g@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86: Convert vdso to use vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Brajeswar Ghosh <brajeswar.linux@gmail.com>, Sabyasachi Gupta <sabyasachi.linux@gmail.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Aug 27, 2018 at 11:35 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Aug 27, 2018 at 09:01:48PM +0530, Souptick Joarder wrote:
> > On Fri, Aug 3, 2018 at 6:44 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> > >
> > > On Fri, 3 Aug 2018, Souptick Joarder wrote:
> > > > On Mon, Jul 16, 2018 at 2:47 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > > > On Tue, 3 Jul 2018, Matthew Wilcox wrote:
> > > > >
> > > > >> Return vm_fault_t codes directly from the appropriate mm routines instead
> > > > >> of converting from errnos ourselves.  Fixes a minor bug where we'd return
> > > > >> SIGBUS instead of the correct OOM code if we ran out of memory allocating
> > > > >> page tables.
> > > > >>
> > > > >> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > > > >
> > > > > Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> > > > >
> > > >
> > > > Thomas, are these 3 patches part of this series will be queued
> > > > for 4.19 ?
> > >
> > > I don't know. I expected that these go through the mm tree, but if nobody
> > > feels responsible, I could pick up the whole lot. But I'd like to see acks
> > > from the mm folks for [1/3] and [3/3]
> > >
> > >   https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
> > >
> > > Thanks,
> > >
> > >         tglx
> > >
> >
> > Any comment from mm reviewers for patch [1/3] and [3/3] ??
> >
> > https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
>
> I think at this point, it would probably be best to ask Andrew to pick
> up all three of these patches.

Do we need to repost these three patches or lkml link
https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
is fine to request Andrew ??


> In addition to these three, I see the following places that need to be changed:
>
> Documentation/gpu/drm-mm.rst:300:               int (*fault)(struct vm_fault *vmf);
ok, I will add this.

>
> drivers/gpu/drm/virtio/virtgpu_ttm.c:117:static int virtio_gpu_ttm_fault(struct vm_fault *vmf)
>  - #if 0 code.  convert anyway.

https://lkml.org/lkml/2018/7/2/795
Gerd Hoffmann, agreed to remove this dead code, but queued for 4.20.
I think, this shouldn't be a blocker for us.

>
> drivers/gpu/drm/vkms/vkms_drv.h:68:int vkms_gem_fault(struct vm_fault *vmf);
> drivers/gpu/drm/vkms/vkms_gem.c:46:int vkms_gem_fault(struct vm_fault *vmf)

This was not queued for 4.19. Would you like to see this patch in 4.19-rc-x ?
https://lkml.org/lkml/2018/7/30/767

>
> fs/ext4/ext4.h:2472:extern int ext4_page_mkwrite(struct vm_fault *vmf);
> fs/ext4/ext4.h:2473:extern int ext4_filemap_fault(struct vm_fault *vmf);
> fs/ext4/inode.c:6154:int ext4_page_mkwrite(struct vm_fault *vmf)
> fs/ext4/inode.c:6251:int ext4_filemap_fault(struct vm_fault *vmf)

I have this patch ready in my local tree based on review comment
from Ted. Ted was planning to take it in next merge window.
I will post it on mailing list.

>
> fs/iomap.c:1059:int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
> include/linux/iomap.h:144:int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops);
>  - I saw you just resent this patch.

Now added to mm-tree.

> mm/filemap.c:2751:int filemap_page_mkwrite(struct vm_fault *vmf)
>  - This is the NOMMU case, so I suspect your testing didn't catch it.
Sorry, I missed it.
