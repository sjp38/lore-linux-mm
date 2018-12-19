Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12C848E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:24:33 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id z17so2215535lfg.10
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 23:24:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b187sor5034969lfd.68.2018.12.18.23.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 23:24:31 -0800 (PST)
MIME-Version: 1.0
References: <20181217202246.GA10500@jordon-HP-15-Notebook-PC> <20181218104513.GM26090@n2100.armlinux.org.uk>
In-Reply-To: <20181218104513.GM26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 19 Dec 2018 12:54:18 +0530
Message-ID: <CAFqt6zZw2jO5qGjG3CdAZR2ZXt19+ykhyw+hhVDP7xTaemusiA@mail.gmail.com>
Subject: Re: [PATCH v4 3/9] drivers/firewire/core-iso.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, stefanr@s5r6.in-berlin.de, Linux-MM <linux-mm@kvack.org>, linux1394-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Dec 18, 2018 at 4:15 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Tue, Dec 18, 2018 at 01:52:46AM +0530, Souptick Joarder wrote:
> > Convert to use vm_insert_range to map range of kernel memory
> > to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >  drivers/firewire/core-iso.c | 15 ++-------------
> >  1 file changed, 2 insertions(+), 13 deletions(-)
> >
> > diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> > index 35e784c..7bf28bb 100644
> > --- a/drivers/firewire/core-iso.c
> > +++ b/drivers/firewire/core-iso.c
> > @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
> >  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
> >                         struct vm_area_struct *vma)
> >  {
> > -     unsigned long uaddr;
> > -     int i, err;
> > -
> > -     uaddr = vma->vm_start;
> > -     for (i = 0; i < buffer->page_count; i++) {
> > -             err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> > -             if (err)
> > -                     return err;
> > -
> > -             uaddr += PAGE_SIZE;
> > -     }
> > -
> > -     return 0;
> > +     return vm_insert_range(vma, vma->vm_start, buffer->pages,
> > +                             buffer->page_count);
>
> This looks functionally equivalent.  Note that if we go with my
> proposal to your patch 4, that would cause an issue for this
> implementation.
>
> Maybe we need two functions, but that then causes problems with
> which function should be used (which makes it easy to get wrong.)

I think, apart from patch [4/9] and [6/9], all others places can be
directly replaced
with vm_insert_range(). [4/9] and [6/9] are the places where
*vma->vm_pgoff* need to be
considered and need to adjust *count* accordingly. In my opinion, bugs
around these
[4/9] & [6/9] can be fixed (raised during review) to accommodate it to
use vm_insert_range().
>
> I'm beginning to wonder if the risks of causing regressions and
> introducing bugs is actually worth the effort of trying to clean
> this up.
>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up
