Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0E98E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:27:38 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 128so19672877itw.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 04:27:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v8sor41374ios.77.2018.12.26.04.27.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 04:27:36 -0800 (PST)
MIME-Version: 1.0
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
In-Reply-To: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 26 Dec 2018 13:27:25 +0100
Message-ID: <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
Subject: Re: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected huge
 vmap mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Duan <fugang.duan@nxp.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>
Cc: "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

On Wed, 26 Dec 2018 at 09:25, Andy Duan <fugang.duan@nxp.com> wrote:
>
> From: Fugang Duan <fugang.duan@nxp.com>
>
> If RPMSG dma memory allocate from per-device mem pool by calling .dma_alloc_coherent(),
> the size is bigger than 2M bytes and alignment with 2M (PMD_SIZE), then kernel dump by
> calling .vmalloc_to_page().
>
> Since per-device dma pool do vmap mappings by __ioremap(), __ioremap() might use
> the hugepage mapping, which in turn will cause the vmalloc_page failed to return
> the correct page due to the PTE not setup.

If there are legal uses for vmalloc_to_page() even if the region is
not mapped down to pages [which appears to be the case here], I'd
prefer to fix vmalloc_to_page() instead of adding this hack. Or
perhaps we need a sg_xxx helper that translates any virtual address
(vmalloc or otherwise) into a scatterlist entry?


>
> For exp, when reserve 8M bytes per-device dma mem pool, __ioremap() will use hugepage
> mapping:
>  __ioremap
>         ioremap_page_range
>                 ioremap_pud_range
>                         ioremap_pmd_range
>                                 pmd_set_huge(pmd, phys_addr + addr, prot)
>
> Commit:029c54b09599 ("mm/vmalloc.c: huge-vmap: fail gracefully on unexpected huge
> vmap mapping") ensure that vmalloc_to_page() does not go off into the weeds trying
> to dereference huge PUDs or PMDs as table entries:
> rpmsg_sg_init ->
>         vmalloc_to_page->
>                 WARN_ON_ONCE(pmd_bad(*pmd));
>
> In generally, .dma_alloc_coherent() allocate memory from CMA pool/DMA pool/atomic_pool,
> or swiotlb slabs pool, the virt address mapping to physical address should be lineal,
> so for the rpmsg scatterlist initialization can use pfn to find the page to avoid to
> call .vmalloc_to_page().
>
> Kernel dump:
> [    0.881722] WARNING: CPU: 0 PID: 1 at mm/vmalloc.c:301 vmalloc_to_page+0xbc/0xc8
> [    0.889094] Modules linked in:
> [    0.892139] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.14.78-05581-gc61a572 #206
> [    0.899604] Hardware name: Freescale i.MX8QM MEK (DT)
> [    0.904643] task: ffff8008f6c98000 task.stack: ffff000008068000
> [    0.910549] PC is at vmalloc_to_page+0xbc/0xc8
> [    0.914987] LR is at rpmsg_sg_init+0x70/0xcc
> [    0.919238] pc : [<ffff0000081c80d4>] lr : [<ffff000008ac471c>] pstate: 40000045
> [    0.926619] sp : ffff00000806b8b0
> [    0.929923] x29: ffff00000806b8b0 x28: ffff00000961cdf0
> [    0.935220] x27: ffff00000961cdf0 x26: 0000000000000000
> [    0.940519] x25: 0000000000040000 x24: ffff00000961ce40
> [    0.945819] x23: ffff00000f000000 x22: ffff00000961ce30
> [    0.951118] x21: 0000000000000000 x20: ffff00000806b950
> [    0.956417] x19: 0000000000000000 x18: 000000000000000e
> [    0.961717] x17: 0000000000000001 x16: 0000000000000019
> [    0.967016] x15: 0000000000000033 x14: 616d64202c303030
> [    0.972316] x13: 3030306630303030 x12: 3066666666206176
> [    0.977615] x11: 203a737265666675 x10: 62203334394c203a
> [    0.982914] x9 : 000000000000009f x8 : ffff00000806b970
> [    0.988214] x7 : 0000000000000000 x6 : ffff000009690712
> [    0.993513] x5 : 0000000000000000 x4 : 0000000080000000
> [    0.998812] x3 : 00e8000090800f0d x2 : ffff8008ffffd3c0
> [    1.004112] x1 : 0000000000000000 x0 : ffff00000f000000
> [    1.009416] Call trace:
> [    1.011849] Exception stack(0xffff00000806b770 to 0xffff00000806b8b0)
> [    1.018279] b760:                                   ffff00000f000000 0000000000000000
> [    1.026094] b780: ffff8008ffffd3c0 00e8000090800f0d 0000000080000000 0000000000000000
> [    1.033915] b7a0: ffff000009690712 0000000000000000 ffff00000806b970 000000000000009f
> [    1.041731] b7c0: 62203334394c203a 203a737265666675 3066666666206176 3030306630303030
> [    1.049550] b7e0: 616d64202c303030 0000000000000033 0000000000000019 0000000000000001
> [    1.057368] b800: 000000000000000e 0000000000000000 ffff00000806b950 0000000000000000
> [    1.065188] b820: ffff00000961ce30 ffff00000f000000 ffff00000961ce40 0000000000040000
> [    1.073008] b840: 0000000000000000 ffff00000961cdf0 ffff00000961cdf0 ffff00000806b8b0
> [    1.080825] b860: ffff000008ac471c ffff00000806b8b0 ffff0000081c80d4 0000000040000045
> [    1.088646] b880: ffff0000092c8528 ffff00000806b890 ffffffffffffffff ffff000008ac4710
> [    1.096461] b8a0: ffff00000806b8b0 ffff0000081c80d4
> [    1.101327] [<ffff0000081c80d4>] vmalloc_to_page+0xbc/0xc8
> [    1.106800] [<ffff000008ac4968>] rpmsg_probe+0x1f0/0x49c
> [    1.112107] [<ffff00000859a9a0>] virtio_dev_probe+0x198/0x210
> [    1.117839] [<ffff0000086a1c70>] driver_probe_device+0x220/0x2d4
> [    1.123829] [<ffff0000086a1e90>] __device_attach_driver+0x98/0xc8
> [    1.129913] [<ffff00000869fe7c>] bus_for_each_drv+0x54/0x94
> [    1.135470] [<ffff0000086a1944>] __device_attach+0xc4/0x12c
> [    1.141029] [<ffff0000086a1ed0>] device_initial_probe+0x10/0x18
> [    1.146937] [<ffff0000086a0e48>] bus_probe_device+0x90/0x98
> [    1.152501] [<ffff00000869ef88>] device_add+0x3f4/0x570
> [    1.157709] [<ffff00000869f120>] device_register+0x1c/0x28
> [    1.163182] [<ffff00000859a4f8>] register_virtio_device+0xb8/0x114
> [    1.169353] [<ffff000008ac5e94>] imx_rpmsg_probe+0x3a0/0x5d0
> [    1.175003] [<ffff0000086a3768>] platform_drv_probe+0x50/0xbc
> [    1.180730] [<ffff0000086a1c70>] driver_probe_device+0x220/0x2d4
> [    1.186725] [<ffff0000086a1dc8>] __driver_attach+0xa4/0xa8
> [    1.192199] [<ffff00000869fdc4>] bus_for_each_dev+0x58/0x98
> [    1.197759] [<ffff0000086a1598>] driver_attach+0x20/0x28
> [    1.203058] [<ffff0000086a1114>] bus_add_driver+0x1c0/0x224
> [    1.208619] [<ffff0000086a26ec>] driver_register+0x68/0x108
> [    1.214178] [<ffff0000086a36ac>] __platform_driver_register+0x4c/0x54
> [    1.220614] [<ffff0000093d14fc>] imx_rpmsg_init+0x1c/0x50
> [    1.225999] [<ffff000008084144>] do_one_initcall+0x38/0x124
> [    1.231560] [<ffff000009370d28>] kernel_init_freeable+0x18c/0x228
> [    1.237640] [<ffff000008d51b60>] kernel_init+0x10/0x100
> [    1.242849] [<ffff000008085348>] ret_from_fork+0x10/0x18
> [    1.248154] ---[ end trace bcc95d4e07033434 ]---
>
> v2:
>  - use pfn_to_page(PHYS_PFN(x)) instead of phys_to_page(x) since
>    .phys_to_page() interface has arch platform limitation.
>
> Reviewed-by: Richard Zhu <hongxing.zhu@nxp.com>
> Suggested-and-reviewed-by: Jason Liu <jason.hui.liu@nxp.com>
> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
> ---
>  drivers/rpmsg/virtio_rpmsg_bus.c | 25 +++++++++++++------------
>  1 file changed, 13 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/rpmsg/virtio_rpmsg_bus.c b/drivers/rpmsg/virtio_rpmsg_bus.c
> index 664f957..d548bd0 100644
> --- a/drivers/rpmsg/virtio_rpmsg_bus.c
> +++ b/drivers/rpmsg/virtio_rpmsg_bus.c
> @@ -196,16 +196,17 @@ static int virtio_rpmsg_trysend_offchannel(struct rpmsg_endpoint *ept, u32 src,
>   * location (in vmalloc or in kernel).
>   */
>  static void
> -rpmsg_sg_init(struct scatterlist *sg, void *cpu_addr, unsigned int len)
> +rpmsg_sg_init(struct virtproc_info *vrp, struct scatterlist *sg,
> +             void *cpu_addr, unsigned int len)
>  {
> -       if (is_vmalloc_addr(cpu_addr)) {
> -               sg_init_table(sg, 1);
> -               sg_set_page(sg, vmalloc_to_page(cpu_addr), len,
> -                           offset_in_page(cpu_addr));
> -       } else {
> -               WARN_ON(!virt_addr_valid(cpu_addr));
> -               sg_init_one(sg, cpu_addr, len);
> -       }
> +       unsigned int offset;
> +       dma_addr_t dev_add = vrp->bufs_dma + (cpu_addr - vrp->rbufs);
> +       struct page *page = pfn_to_page(PHYS_PFN(dma_to_phys(vrp->bufs_dev,
> +                                       dev_add)));
> +
> +       offset = offset_in_page(cpu_addr);
> +       sg_init_table(sg, 1);
> +       sg_set_page(sg, page, len, offset);
>  }
>
>  /**
> @@ -626,7 +627,7 @@ static int rpmsg_send_offchannel_raw(struct rpmsg_device *rpdev,
>                          msg, sizeof(*msg) + msg->len, true);
>  #endif
>
> -       rpmsg_sg_init(&sg, msg, sizeof(*msg) + len);
> +       rpmsg_sg_init(vrp, &sg, msg, sizeof(*msg) + len);
>
>         mutex_lock(&vrp->tx_lock);
>
> @@ -750,7 +751,7 @@ static int rpmsg_recv_single(struct virtproc_info *vrp, struct device *dev,
>                 dev_warn(dev, "msg received with no recipient\n");
>
>         /* publish the real size of the buffer */
> -       rpmsg_sg_init(&sg, msg, vrp->buf_size);
> +       rpmsg_sg_init(vrp, &sg, msg, vrp->buf_size);
>
>         /* add the buffer back to the remote processor's virtqueue */
>         err = virtqueue_add_inbuf(vrp->rvq, &sg, 1, msg, GFP_KERNEL);
> @@ -934,7 +935,7 @@ static int rpmsg_probe(struct virtio_device *vdev)
>                 struct scatterlist sg;
>                 void *cpu_addr = vrp->rbufs + i * vrp->buf_size;
>
> -               rpmsg_sg_init(&sg, cpu_addr, vrp->buf_size);
> +               rpmsg_sg_init(vrp, &sg, cpu_addr, vrp->buf_size);
>
>                 err = virtqueue_add_inbuf(vrp->rvq, &sg, 1, cpu_addr,
>                                           GFP_KERNEL);
> --
> 1.9.1
>
