Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 36CF690010B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 21:04:40 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1334848pwi.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 18:04:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>
References: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>
Date: Thu, 19 May 2011 03:04:38 +0200
Message-ID: <BANLkTinZJUWMc39TLP28M5=cRvqev+0QWg@mail.gmail.com>
Subject: Re: mmap() implementation for pci_alloc_consistent() memory?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Thu, May 19, 2011 at 12:14 AM, Leon Woestenberg
<leon.woestenberg@gmail.com> wrote:
>
> int ringbuffer_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf=
)
> {
> =A0 =A0 =A0 =A0/* the buffer allocated with pci_alloc_consistent() */
> =A0 =A0 =A0 =A0void *vaddr =3D ringbuffer_virt;
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0/* find the struct page that describes vaddr, the buffer
> =A0 =A0 =A0 =A0 * allocated with pci_alloc_consistent() */
> =A0 =A0 =A0 =A0struct page *page =3D virt_to_page(lro_char->engine->ringb=
uffer_virt);
> =A0 =A0 =A0 =A0vmf->page =3D page;
>
> =A0 =A0 =A0 =A0/*** I have verified that vaddr, page, and the pfn corresp=
ond
> with vaddr =3D pci_alloc_consistent() ***/
> =A0 =A0 =A0 =A0ret =3D vm_insert_pfn(vma, address, page_to_pfn(page));
> =A0 =A0 =A0 =A0return ret;
> }
>

Some further debugging insights:

I found that pfn_valid is 0 on page_to_pfn(page). Isn't
pci_alloc_consistent() memory backed by a real struct page?

I found that when I use the allocation/mapping below instead of
pci_alloc_consistent(), the fault handler does the mapping correctly.

	vaddr =3D __get_free_pages(GFP_KERNEL, 4);
	busaddr =3D dma_map_single(lro->pci_dev, vaddr,
		psize, dir_to_dev? DMA_TO_DEVICE: DMA_FROM_DEVICE);

Still no clue why the mmap fails on pci_alloc_consistent() memory.

Regards,
--=20
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
