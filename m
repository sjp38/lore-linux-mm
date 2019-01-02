Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4F50C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 15:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FA7E2171F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 15:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="umkUwBVI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FA7E2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A85BD8E0026; Wed,  2 Jan 2019 10:48:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35B68E0002; Wed,  2 Jan 2019 10:48:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D65D8E0026; Wed,  2 Jan 2019 10:48:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7B98E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 10:48:47 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id f5-v6so8850925ljj.17
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 07:48:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IJHL/z8fAJRE9Iyf8aCknufDky6L83+nNxnmSNmWUL0=;
        b=uQptKgoYEJKJOnvrDqWC/nyWmOV16AkMNTQMi1/OSi1U7PQjL9zRouYpYvo6/UIgES
         1qPshaRy+d4LN7AVbEGG4edlquy7jA08Ocx240B1AGfJojfDq3Aerz5ektWKK2XGeTrV
         zVukaBIr5DDe3NPXrGOXDEVRmmDaNTUnhOdAnEnVrhYWJ4jUa5JyXnfces4y5SWnP4BY
         gFYkSwMXDQWTtWx3UCWQMNkTzA7JqCH/IAX0eO99F0ala1V9wibLbIZ15LA3GY3SCNVJ
         jRJdZbq0MB7xeKN5Vjprbakx7iiTm1k49GkW10G1NsbZYVEN8292oX5DCND2lW2Zmgg9
         PJdg==
X-Gm-Message-State: AJcUukdHMXaWD88bDj2u4rBY94DS75hoavcGiji60uG/E4e51M0yIiRD
	B/cnlHx4BXS22yNy7CTw2Sp0KFLQE4opNHD7oN6DDOttmDYuyglMa8egHY7jc0MR3S42mC7dkWN
	L+lVf1fUFPSCCuyBQwUPf7qngI2Y7VuYpEIt3Avkyp6O3e2nTPnZE4VfxlvWy9uPcjR5fkPrwzX
	jVF6dgkOtN20ECgHWOh6MiFZHS3zWO/dZeY2T80DJmTgvSiJhqXc0mhCEanyKmpxaegCKQOdpqk
	//s2F0tbDGzEFa7MUt4LPVmGD3N3TuywMQXbWbC0tnz8zt8U6XI29KdEWqJn3nyfOSD7wz06WUN
	ius+VSBtEHBy30IR8xMbsOFuFu5yqXa5CWUHxtHIJI07mRqhqOUDDunD4pWob3433/rUSfc0UaH
	M
X-Received: by 2002:a2e:3308:: with SMTP id d8-v6mr20703713ljc.38.1546444126154;
        Wed, 02 Jan 2019 07:48:46 -0800 (PST)
X-Received: by 2002:a2e:3308:: with SMTP id d8-v6mr20703691ljc.38.1546444124943;
        Wed, 02 Jan 2019 07:48:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546444124; cv=none;
        d=google.com; s=arc-20160816;
        b=C3ZBQHz+K4rKSi0pHHoITwPQOhw93MdU6d9nvGsIgrBhIL7IN5OMg8Pu0/XYDcpc3P
         ODUe8wPSTqJDrWSQW4C3EaipzG8zsQtgTWHja7CyJVOXu8A0+2pWdzP1OWL1wn90J8bf
         Fp/xmHwi96cpu6+KfaV8C3r5IcMbgrrMghUMVHhi1xg4G5V+bz83E7M7AUwkg0yTS49+
         yZftDkbqEmtKPe1p9vQcpItd+chxRXyYY1JaDOmU9Y7AzEzcxkgcUNZ+YD5I3CUU2zOB
         IAuVgotUcRk/a+N/qqO0CbLCSCUZKXyM9ASHesTNR37TGcGJ26quUS3AgR7mBtkaBwb1
         wpjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IJHL/z8fAJRE9Iyf8aCknufDky6L83+nNxnmSNmWUL0=;
        b=WTOqIy8iMvHi5s+BB5iRQgKMPDKH/RhwWCPaEYPr3f+GagShJIB2aVaOzBcdnUizek
         RhYun+XHCnjNrLI42yiAb0YFGliIfQjs21/oi3dgb/Xce+OUqGkB7nKNp/p6B9YWA0/B
         lPId81nfdxP/M2IbbPOxPXgPNF4hBKVAPu55O1vwgp38nL7yClqJOOokQlamle71GGIV
         lwtyhkeU0+Ubjl9/uWLU4FC4eXbHHkvzm1g0dIEq0wUvitNT+FGhalVFUQSCQ1MIM+gQ
         vYcnOab2aQVPNVnelTp4jO7wSufHOA+A2PwMiv4JaGCG/kbp57Za9ByNcKXw/eV0m1EI
         894A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=umkUwBVI;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22-v6sor31090951ljb.22.2019.01.02.07.48.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 07:48:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=umkUwBVI;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IJHL/z8fAJRE9Iyf8aCknufDky6L83+nNxnmSNmWUL0=;
        b=umkUwBVIN/yYk5VwfS+MFZuorx2FzrD4Ze8CM4JeoYDHkxfZVPYebJlrJjnTp31bzJ
         AHyYuoq0NXSLLnJ4Re5PjaIZin8goaV7udqBZlTV1dFLZjHnDPcocwxp89M9MBSmKiU4
         4EFxApWVdmqBEDoxVHxbdHxO+6zwE6Az5P4Rq6Tl+48rQPsUn/xFZVOSSCbcbbbO1XNi
         RZ69pUN3T8cFQelu1sY+YuZokaNt/BIufx9VkrqbfrDKtJ3fjqWHOY8NJORHNkjryw/4
         swnyr/5PaEMVABHNSCWzKb+7OQJq0uN7GaBYc9b41jzAsNZ2exlajrGZheN08nXSq0SX
         M3xQ==
X-Google-Smtp-Source: ALg8bN6ZMhgMMSVTgm4KwPh+JHX95y+LJ/UlD3B0Q2we2PeXB5w2/dx1ar5vX/RQEzZ8FO+3P2kJNezF7K/5a/X45JI=
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr20634319ljj.149.1546444124257;
 Wed, 02 Jan 2019 07:48:44 -0800 (PST)
MIME-Version: 1.0
References: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
 <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com> <20190102111553.GG26090@n2100.armlinux.org.uk>
In-Reply-To: <20190102111553.GG26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 2 Jan 2019 21:22:34 +0530
Message-ID:
 <CAFqt6zadJ-4xh256BqzALnGY31nDAU=5XwUaSaz5OcJuOc7Bfg@mail.gmail.com>
Subject: Re: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, pawel@osciak.com, 
	Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	robin.murphy@arm.com, linux-media@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102155234.tFOr1Pa4nr113DVy-rVOsL37oMRTys6whiEq73isDCQ@z>

On Wed, Jan 2, 2019 at 4:46 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Wed, Jan 02, 2019 at 04:23:15PM +0530, Souptick Joarder wrote:
> > On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > >
> > > Convert to use vm_insert_range to map range of kernel memory
> > > to user vma.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > > Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> > > ---
> > >  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
> > >  1 file changed, 7 insertions(+), 16 deletions(-)
> > >
> > > diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > index 015e737..898adef 100644
> > > --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
> > >  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
> > >  {
> > >         struct vb2_dma_sg_buf *buf = buf_priv;
> > > -       unsigned long uaddr = vma->vm_start;
> > > -       unsigned long usize = vma->vm_end - vma->vm_start;
> > > -       int i = 0;
> > > +       unsigned long page_count = vma_pages(vma);
> > > +       int err;
> > >
> > >         if (!buf) {
> > >                 printk(KERN_ERR "No memory to map\n");
> > >                 return -EINVAL;
> > >         }
> > >
> > > -       do {
> > > -               int ret;
> > > -
> > > -               ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> > > -               if (ret) {
> > > -                       printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> > > -                       return ret;
> > > -               }
> > > -
> > > -               uaddr += PAGE_SIZE;
> > > -               usize -= PAGE_SIZE;
> > > -       } while (usize > 0);
> > > -
> > > +       err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> > > +       if (err) {
> > > +               printk(KERN_ERR "Remapping memory, error: %d\n", err);
> > > +               return err;
> > > +       }
> > >
> >
> > Looking into the original code -
> > drivers/media/common/videobuf2/videobuf2-dma-sg.c
> >
> > Inside vb2_dma_sg_alloc(),
> >            ...
> >            buf->num_pages = size >> PAGE_SHIFT;
> >            buf->dma_sgt = &buf->sg_table;
> >
> >            buf->pages = kvmalloc_array(buf->num_pages, sizeof(struct page *),
> >                                                        GFP_KERNEL | __GFP_ZERO);
> >            ...
> >
> > buf->pages has index upto  *buf->num_pages*.
> >
> > now inside vb2_dma_sg_mmap(),
> >
> >            unsigned long usize = vma->vm_end - vma->vm_start;
> >            int i = 0;
> >            ...
> >            do {
> >                  int ret;
> >
> >                  ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> >                  if (ret) {
> >                            printk(KERN_ERR "Remapping memory, error:
> > %d\n", ret);
> >                            return ret;
> >                  }
> >
> >                 uaddr += PAGE_SIZE;
> >                 usize -= PAGE_SIZE;
> >            } while (usize > 0);
> >            ...
> > is it possible for any value of  *i  > (buf->num_pages)*,
> > buf->pages[i] is going to overrun the page boundary ?
>
> Yes it is, and you've found an array-overrun condition that is
> triggerable from userspace - potentially non-root userspace too.
> Depending on what it can cause to be mapped without oopsing the
> kernel, it could be very serious.  At best, it'll oops the kernel.
> At worst, it could expose pages of memory that userspace should
> not have access to.
>
> This is why I've been saying that we need a helper that takes the
> _object_ and the user request, and does all the checking internally,
> so these kinds of checks do not get overlooked.

ok, while replacing this code with the suggested vm_insert_range_buggy(),
we could fixed this issue.


>
> A good API is one that helpers authors avoid bugs.
>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up

