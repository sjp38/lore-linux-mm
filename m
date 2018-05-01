Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD7D6B0003
	for <linux-mm@kvack.org>; Tue,  1 May 2018 13:41:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so6815897wmm.1
        for <linux-mm@kvack.org>; Tue, 01 May 2018 10:41:17 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id 41-v6si2154203wrz.0.2018.05.01.10.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 10:41:14 -0700 (PDT)
Date: Tue, 1 May 2018 19:41:13 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <CAGXu5j+tYhQOfVMkZdPzW5CX103LHpm8SYSN51VFLufn0Z0y6Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1805011938460.2494@hadrien>
References: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com> <alpine.DEB.2.20.1803072212160.2814@hadrien> <20180308025812.GA9082@bombadil.infradead.org> <alpine.DEB.2.20.1803080722300.3754@hadrien> <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien> <20180313183220.GA21538@bombadil.infradead.org> <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com> <20180429203023.GA11891@bombadil.infradead.org> <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
 <20180430201607.GA7041@bombadil.infradead.org> <4ad99a55-9c93-5ea1-5954-3cb6e5ba7df9@rasmusvillemoes.dk> <CAGXu5j+tYhQOfVMkZdPzW5CX103LHpm8SYSN51VFLufn0Z0y6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Daniel Vetter <daniel.vetter@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>



On Tue, 1 May 2018, Kees Cook wrote:

> On Mon, Apr 30, 2018 at 2:29 PM, Rasmus Villemoes
> <linux@rasmusvillemoes.dk> wrote:
> > On 2018-04-30 22:16, Matthew Wilcox wrote:
> >> On Mon, Apr 30, 2018 at 12:02:14PM -0700, Kees Cook wrote:
> >>>
> >>> Getting the constant ordering right could be part of the macro
> >>> definition, maybe? i.e.:
> >>>
> >>> static inline void *kmalloc_ab(size_t a, size_t b, gfp_t flags)
> >>> {
> >>>     if (__builtin_constant_p(a) && a != 0 && \
> >>>         b > SIZE_MAX / a)
> >>>             return NULL;
> >>>     else if (__builtin_constant_p(b) && b != 0 && \
> >>>                a > SIZE_MAX / b)
> >>>             return NULL;
> >>>
> >>>     return kmalloc(a * b, flags);
> >>> }
> >>
> >> Ooh, if neither a nor b is constant, it just didn't do a check ;-(  This
> >> stuff is hard.
> >>
> >>> (I just wish C had a sensible way to catch overflow...)
> >>
> >> Every CPU I ever worked with had an "overflow" bit ... do we have a
> >> friend on the C standards ctte who might figure out a way to let us
> >> write code that checks it?
> >
> > gcc 5.1+ (I think) have the __builtin_OP_overflow checks that should
> > generate reasonable code. Too bad there's no completely generic
> > check_all_ops_in_this_expression(a+b*c+d/e, or_jump_here). Though it's
> > hard to define what they should be checked against - probably would
> > require all subexpressions (including the variables themselves) to have
> > the same type.
> >
> > plug: https://lkml.org/lkml/2015/7/19/358
>
> That's a very nice series. Why did it never get taken? It seems to do
> the right things quite correctly.
>
> Daniel, while this isn't a perfect solution, is this something you'd
> use in graphics-land?

Opportunities for this, found with the following are shown below:

@@
expression a,b;
@@

*if (a + b < a)
 { ... return ...; }

- at the beginning of a line indicates an opportunity, not a suggestion
for removal.

I haven't checked the results carefully, but most look relevant.

julia



diff -u -p /var/linuxes/linux-next/lib/zstd/decompress.c /tmp/nothing/lib/zstd/decompress.c
--- /var/linuxes/linux-next/lib/zstd/decompress.c
+++ /tmp/nothing/lib/zstd/decompress.c
@@ -343,7 +343,6 @@ unsigned long long ZSTD_findDecompressed
 					return ret;

 				/* check for overflow */
-				if (totalDstSize + ret < totalDstSize)
 					return ZSTD_CONTENTSIZE_ERROR;
 				totalDstSize += ret;
 			}
diff -u -p /var/linuxes/linux-next/lib/scatterlist.c /tmp/nothing/lib/scatterlist.c
--- /var/linuxes/linux-next/lib/scatterlist.c
+++ /tmp/nothing/lib/scatterlist.c
@@ -503,7 +503,6 @@ struct scatterlist *sgl_alloc_order(unsi
 	nalloc = nent;
 	if (chainable) {
 		/* Check for integer overflow */
-		if (nalloc + 1 < nalloc)
 			return NULL;
 		nalloc++;
 	}
diff -u -p /var/linuxes/linux-next/drivers/dma-buf/dma-buf.c /tmp/nothing/drivers/dma-buf/dma-buf.c
--- /var/linuxes/linux-next/drivers/dma-buf/dma-buf.c
+++ /tmp/nothing/drivers/dma-buf/dma-buf.c
@@ -954,7 +954,6 @@ int dma_buf_mmap(struct dma_buf *dmabuf,
 		return -EINVAL;

 	/* check for offset overflow */
-	if (pgoff + vma_pages(vma) < pgoff)
 		return -EOVERFLOW;

 	/* check for overflowing the buffer's size */
diff -u -p /var/linuxes/linux-next/drivers/md/dm-verity-target.c /tmp/nothing/drivers/md/dm-verity-target.c
--- /var/linuxes/linux-next/drivers/md/dm-verity-target.c
+++ /tmp/nothing/drivers/md/dm-verity-target.c
@@ -1043,7 +1043,6 @@ static int verity_ctr(struct dm_target *
 		v->hash_level_block[i] = hash_position;
 		s = (v->data_blocks + ((sector_t)1 << ((i + 1) * v->hash_per_block_bits)) - 1)
 					>> ((i + 1) * v->hash_per_block_bits);
-		if (hash_position + s < hash_position) {
 			ti->error = "Hash device offset overflow";
 			r = -E2BIG;
 			goto bad;
diff -u -p /var/linuxes/linux-next/drivers/md/dm-flakey.c /tmp/nothing/drivers/md/dm-flakey.c
--- /var/linuxes/linux-next/drivers/md/dm-flakey.c
+++ /tmp/nothing/drivers/md/dm-flakey.c
@@ -233,7 +233,6 @@ static int flakey_ctr(struct dm_target *
 		goto bad;
 	}

-	if (fc->up_interval + fc->down_interval < fc->up_interval) {
 		ti->error = "Interval overflow";
 		r = -EINVAL;
 		goto bad;
diff -u -p /var/linuxes/linux-next/drivers/gpu/drm/vc4/vc4_validate.c /tmp/nothing/drivers/gpu/drm/vc4/vc4_validate.c
--- /var/linuxes/linux-next/drivers/gpu/drm/vc4/vc4_validate.c
+++ /tmp/nothing/drivers/gpu/drm/vc4/vc4_validate.c
@@ -306,7 +306,6 @@ validate_gl_array_primitive(VALIDATE_ARG
 	}
 	shader_state = &exec->shader_state[exec->shader_state_count - 1];

-	if (length + base_index < length) {
 		DRM_DEBUG("primitive vertex count overflow\n");
 		return -EINVAL;
 	}
diff -u -p /var/linuxes/linux-next/drivers/vme/vme.c /tmp/nothing/drivers/vme/vme.c
--- /var/linuxes/linux-next/drivers/vme/vme.c
+++ /tmp/nothing/drivers/vme/vme.c
@@ -208,7 +208,6 @@ int vme_check_window(u32 aspace, unsigne
 {
 	int retval = 0;

-	if (vme_base + size < size)
 		return -EINVAL;

 	switch (aspace) {
diff -u -p /var/linuxes/linux-next/drivers/virtio/virtio_pci_modern.c /tmp/nothing/drivers/virtio/virtio_pci_modern.c
--- /var/linuxes/linux-next/drivers/virtio/virtio_pci_modern.c
+++ /tmp/nothing/drivers/virtio/virtio_pci_modern.c
@@ -99,7 +99,6 @@ static void __iomem *map_capability(stru

 	length -= start;

-	if (start + offset < offset) {
 		dev_err(&dev->dev,
 			"virtio_pci: map wrap-around %u+%u\n",
 			start, offset);
diff -u -p /var/linuxes/linux-next/drivers/net/wireless/marvell/mwifiex/pcie.c /tmp/nothing/drivers/net/wireless/marvell/mwifiex/pcie.c
--- /var/linuxes/linux-next/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ /tmp/nothing/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -2015,7 +2015,6 @@ static int mwifiex_extract_wifi_fw(struc

 		switch (dnld_cmd) {
 		case MWIFIEX_FW_DNLD_CMD_1:
-			if (offset + data_len < data_len) {
 				mwifiex_dbg(adapter, ERROR, "bad FW parse\n");
 				ret = -1;
 				goto done;
@@ -2039,7 +2038,6 @@ static int mwifiex_extract_wifi_fw(struc
 		case MWIFIEX_FW_DNLD_CMD_5:
 			first_cmd = true;
 			/* Check for integer overflow */
-			if (offset + data_len < data_len) {
 				mwifiex_dbg(adapter, ERROR, "bad FW parse\n");
 				ret = -1;
 				goto done;
@@ -2049,7 +2047,6 @@ static int mwifiex_extract_wifi_fw(struc
 		case MWIFIEX_FW_DNLD_CMD_6:
 			first_cmd = true;
 			/* Check for integer overflow */
-			if (offset + data_len < data_len) {
 				mwifiex_dbg(adapter, ERROR, "bad FW parse\n");
 				ret = -1;
 				goto done;
diff -u -p /var/linuxes/linux-next/drivers/net/ethernet/sun/niu.c /tmp/nothing/drivers/net/ethernet/sun/niu.c
--- /var/linuxes/linux-next/drivers/net/ethernet/sun/niu.c
+++ /tmp/nothing/drivers/net/ethernet/sun/niu.c
@@ -6884,7 +6884,6 @@ static int niu_get_eeprom(struct net_dev
 	offset = eeprom->offset;
 	len = eeprom->len;

-	if (offset + len < offset)
 		return -EINVAL;
 	if (offset >= np->eeprom_len)
 		return -EINVAL;
diff -u -p /var/linuxes/linux-next/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c /tmp/nothing/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
--- /var/linuxes/linux-next/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ /tmp/nothing/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -389,7 +389,6 @@ ixgb_get_eeprom(struct net_device *netde

 	max_len = ixgb_get_eeprom_len(netdev);

-	if (eeprom->offset > eeprom->offset + eeprom->len) {
 		ret_val = -EINVAL;
 		goto geeprom_error;
 	}
@@ -435,7 +434,6 @@ ixgb_set_eeprom(struct net_device *netde

 	max_len = ixgb_get_eeprom_len(netdev);

-	if (eeprom->offset > eeprom->offset + eeprom->len)
 		return -EINVAL;

 	if ((eeprom->offset + eeprom->len) > max_len)
diff -u -p /var/linuxes/linux-next/drivers/crypto/axis/artpec6_crypto.c /tmp/nothing/drivers/crypto/axis/artpec6_crypto.c
--- /var/linuxes/linux-next/drivers/crypto/axis/artpec6_crypto.c
+++ /tmp/nothing/drivers/crypto/axis/artpec6_crypto.c
@@ -1193,7 +1193,6 @@ artpec6_crypto_ctr_crypt(struct skcipher
 	 * the whole IV is a counter.  So fallback if the counter is going to
 	 * overlow.
 	 */
-	if (counter + nblks < counter) {
 		int ret;

 		pr_debug("counter %x will overflow (nblks %u), falling back\n",
diff -u -p /var/linuxes/linux-next/drivers/vhost/vringh.c /tmp/nothing/drivers/vhost/vringh.c
--- /var/linuxes/linux-next/drivers/vhost/vringh.c
+++ /tmp/nothing/drivers/vhost/vringh.c
@@ -123,7 +123,6 @@ static inline bool range_check(struct vr
 	}

 	/* Otherwise, don't wrap. */
-	if (addr + *len < addr) {
 		vringh_bad("Wrapping descriptor %zu@0x%llx",
 			   *len, (unsigned long long)addr);
 		return false;
diff -u -p /var/linuxes/linux-next/drivers/infiniband/hw/cxgb3/iwch_qp.c /tmp/nothing/drivers/infiniband/hw/cxgb3/iwch_qp.c
--- /var/linuxes/linux-next/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ /tmp/nothing/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -224,8 +224,6 @@ static int iwch_sgl2pbl_map(struct iwch_
 			pr_debug("%s %d\n", __func__, __LINE__);
 			return -EINVAL;
 		}
-		if (sg_list[i].addr + ((u64) sg_list[i].length) <
-		    sg_list[i].addr) {
 			pr_debug("%s %d\n", __func__, __LINE__);
 			return -EINVAL;
 		}
diff -u -p /var/linuxes/linux-next/drivers/infiniband/hw/hfi1/eprom.c /tmp/nothing/drivers/infiniband/hw/hfi1/eprom.c
--- /var/linuxes/linux-next/drivers/infiniband/hw/hfi1/eprom.c
+++ /tmp/nothing/drivers/infiniband/hw/hfi1/eprom.c
@@ -362,7 +362,6 @@ static int read_segment_platform_config(
 	}

 	/* check for bogus offset and size that wrap when added together */
-	if (entry->offset + entry->size < entry->offset) {
 		dd_dev_err(dd,
 			   "Bad configuration file start + size 0x%x+0x%x\n",
 			   entry->offset, entry->size);
diff -u -p /var/linuxes/linux-next/drivers/fsi/fsi-core.c /tmp/nothing/drivers/fsi/fsi-core.c
--- /var/linuxes/linux-next/drivers/fsi/fsi-core.c
+++ /tmp/nothing/drivers/fsi/fsi-core.c
@@ -317,7 +317,6 @@ EXPORT_SYMBOL_GPL(fsi_slave_write);
 extern int fsi_slave_claim_range(struct fsi_slave *slave,
 		uint32_t addr, uint32_t size)
 {
-	if (addr + size < addr)
 		return -EINVAL;

 	if (addr + size > slave->size)
diff -u -p /var/linuxes/linux-next/virt/kvm/arm/vgic/vgic-v2.c /tmp/nothing/virt/kvm/arm/vgic/vgic-v2.c
--- /var/linuxes/linux-next/virt/kvm/arm/vgic/vgic-v2.c
+++ /tmp/nothing/virt/kvm/arm/vgic/vgic-v2.c
@@ -274,9 +274,7 @@ void vgic_v2_enable(struct kvm_vcpu *vcp
 /* check for overlapping regions and for regions crossing the end of memory */
 static bool vgic_v2_check_base(gpa_t dist_base, gpa_t cpu_base)
 {
-	if (dist_base + KVM_VGIC_V2_DIST_SIZE < dist_base)
 		return false;
-	if (cpu_base + KVM_VGIC_V2_CPU_SIZE < cpu_base)
 		return false;

 	if (dist_base + KVM_VGIC_V2_DIST_SIZE <= cpu_base)
diff -u -p /var/linuxes/linux-next/virt/kvm/kvm_main.c /tmp/nothing/virt/kvm/kvm_main.c
--- /var/linuxes/linux-next/virt/kvm/kvm_main.c
+++ /tmp/nothing/virt/kvm/kvm_main.c
@@ -921,7 +921,6 @@ int __kvm_set_memory_region(struct kvm *
 		goto out;
 	if (as_id >= KVM_ADDRESS_SPACE_NUM || id >= KVM_MEM_SLOTS_NUM)
 		goto out;
-	if (mem->guest_phys_addr + mem->memory_size < mem->guest_phys_addr)
 		goto out;

 	slot = id_to_memslot(__kvm_memslots(kvm, as_id), id);
diff -u -p /var/linuxes/linux-next/virt/kvm/eventfd.c /tmp/nothing/virt/kvm/eventfd.c
--- /var/linuxes/linux-next/virt/kvm/eventfd.c
+++ /tmp/nothing/virt/kvm/eventfd.c
@@ -917,7 +917,6 @@ kvm_assign_ioeventfd(struct kvm *kvm, st
 	}

 	/* check for range overflow */
-	if (args->addr + args->len < args->addr)
 		return -EINVAL;

 	/* check for extra flags that we don't understand */
diff -u -p /var/linuxes/linux-next/virt/kvm/coalesced_mmio.c /tmp/nothing/virt/kvm/coalesced_mmio.c
--- /var/linuxes/linux-next/virt/kvm/coalesced_mmio.c
+++ /tmp/nothing/virt/kvm/coalesced_mmio.c
@@ -31,7 +31,6 @@ static int coalesced_mmio_in_range(struc
 	 */
 	if (len < 0)
 		return 0;
-	if (addr + len < addr)
 		return 0;
 	if (addr < dev->zone.addr)
 		return 0;
diff -u -p /var/linuxes/linux-next/arch/x86/kernel/e820.c /tmp/nothing/arch/x86/kernel/e820.c
--- /var/linuxes/linux-next/arch/x86/kernel/e820.c
+++ /tmp/nothing/arch/x86/kernel/e820.c
@@ -306,7 +306,6 @@ int __init e820__update_table(struct e82

 	/* Bail out if we find any unreasonable addresses in the map: */
 	for (i = 0; i < table->nr_entries; i++) {
-		if (entries[i].addr + entries[i].size < entries[i].addr)
 			return -1;
 	}

diff -u -p /var/linuxes/linux-next/arch/powerpc/platforms/powernv/opal-prd.c /tmp/nothing/arch/powerpc/platforms/powernv/opal-prd.c
--- /var/linuxes/linux-next/arch/powerpc/platforms/powernv/opal-prd.c
+++ /tmp/nothing/arch/powerpc/platforms/powernv/opal-prd.c
@@ -52,7 +52,6 @@ static bool opal_prd_range_is_valid(uint
 	struct device_node *parent, *node;
 	bool found;

-	if (addr + size < addr)
 		return false;

 	parent = of_find_node_by_path("/reserved-memory");
diff -u -p /var/linuxes/linux-next/arch/powerpc/kernel/kexec_elf_64.c /tmp/nothing/arch/powerpc/kernel/kexec_elf_64.c
--- /var/linuxes/linux-next/arch/powerpc/kernel/kexec_elf_64.c
+++ /tmp/nothing/arch/powerpc/kernel/kexec_elf_64.c
@@ -206,7 +206,6 @@ static bool elf_is_phdr_sane(const struc
 	} else if (phdr->p_offset + phdr->p_filesz > buf_len) {
 		pr_debug("ELF segment not in file.\n");
 		return false;
-	} else if (phdr->p_paddr + phdr->p_memsz < phdr->p_paddr) {
 		pr_debug("ELF segment address wraps around.\n");
 		return false;
 	}
@@ -322,7 +321,6 @@ static bool elf_is_shdr_sane(const struc
 	if (!size_ok) {
 		pr_debug("ELF section with wrong entry size.\n");
 		return false;
-	} else if (shdr->sh_addr + shdr->sh_size < shdr->sh_addr) {
 		pr_debug("ELF section address wraps around.\n");
 		return false;
 	}
diff -u -p /var/linuxes/linux-next/arch/mips/kernel/setup.c /tmp/nothing/arch/mips/kernel/setup.c
--- /var/linuxes/linux-next/arch/mips/kernel/setup.c
+++ /tmp/nothing/arch/mips/kernel/setup.c
@@ -97,7 +97,6 @@ void __init add_memory_region(phys_addr_
 		--size;

 	/* Sanity check */
-	if (start + size < start) {
 		pr_warn("Trying to add an invalid memory region, skipped\n");
 		return;
 	}
diff -u -p /var/linuxes/linux-next/arch/blackfin/kernel/setup.c /tmp/nothing/arch/blackfin/kernel/setup.c
--- /var/linuxes/linux-next/arch/blackfin/kernel/setup.c
+++ /tmp/nothing/arch/blackfin/kernel/setup.c
@@ -351,7 +351,6 @@ static int __init sanitize_memmap(struct

 	/* bail out if we find any unreasonable addresses in memmap */
 	for (i = 0; i < old_nr; i++)
-		if (map[i].addr + map[i].size < map[i].addr)
 			return -1;

 	/* create pointers for initial change-point information (for sorting) */
diff -u -p /var/linuxes/linux-next/arch/blackfin/kernel/ptrace.c /tmp/nothing/arch/blackfin/kernel/ptrace.c
--- /var/linuxes/linux-next/arch/blackfin/kernel/ptrace.c
+++ /tmp/nothing/arch/blackfin/kernel/ptrace.c
@@ -123,7 +123,6 @@ is_user_addr_valid(struct task_struct *c
 	struct sram_list_struct *sraml;

 	/* overflow */
-	if (start + len < start)
 		return -EIO;

 	down_read(&child->mm->mmap_sem);
diff -u -p /var/linuxes/linux-next/arch/nios2/kernel/sys_nios2.c /tmp/nothing/arch/nios2/kernel/sys_nios2.c
--- /var/linuxes/linux-next/arch/nios2/kernel/sys_nios2.c
+++ /tmp/nothing/arch/nios2/kernel/sys_nios2.c
@@ -31,7 +31,6 @@ asmlinkage int sys_cacheflush(unsigned l
 		return -EINVAL;

 	/* Check for overflow */
-	if (addr + len < addr)
 		return -EFAULT;

 	/*
diff -u -p /var/linuxes/linux-next/arch/m68k/kernel/sys_m68k.c /tmp/nothing/arch/m68k/kernel/sys_m68k.c
--- /var/linuxes/linux-next/arch/m68k/kernel/sys_m68k.c
+++ /tmp/nothing/arch/m68k/kernel/sys_m68k.c
@@ -392,7 +392,6 @@ sys_cacheflush (unsigned long addr, int
 		struct vm_area_struct *vma;

 		/* Check for overflow.  */
-		if (addr + len < addr)
 			goto out;

 		/*
diff -u -p /var/linuxes/linux-next/arch/sh/kernel/sys_sh.c /tmp/nothing/arch/sh/kernel/sys_sh.c
--- /var/linuxes/linux-next/arch/sh/kernel/sys_sh.c
+++ /tmp/nothing/arch/sh/kernel/sys_sh.c
@@ -66,7 +66,6 @@ asmlinkage int sys_cacheflush(unsigned l
 	 * Verify that the specified address region actually belongs
 	 * to this process.
 	 */
-	if (addr + len < addr)
 		return -EFAULT;

 	down_read(&current->mm->mmap_sem);
diff -u -p /var/linuxes/linux-next/mm/vmalloc.c /tmp/nothing/mm/vmalloc.c
--- /var/linuxes/linux-next/mm/vmalloc.c
+++ /tmp/nothing/mm/vmalloc.c
@@ -456,12 +456,10 @@ nocache:
 		addr = ALIGN(first->va_end, align);
 		if (addr < vstart)
 			goto nocache;
-		if (addr + size < addr)
 			goto overflow;

 	} else {
 		addr = ALIGN(vstart, align);
-		if (addr + size < addr)
 			goto overflow;

 		n = vmap_area_root.rb_node;
@@ -488,7 +486,6 @@ nocache:
 		if (addr + cached_hole_size < first->va_start)
 			cached_hole_size = first->va_start - addr;
 		addr = ALIGN(first->va_end, align);
-		if (addr + size < addr)
 			goto overflow;

 		if (list_is_last(&first->list, &vmap_area_list))
diff -u -p /var/linuxes/linux-next/mm/memory.c /tmp/nothing/mm/memory.c
--- /var/linuxes/linux-next/mm/memory.c
+++ /tmp/nothing/mm/memory.c
@@ -2136,7 +2136,6 @@ int vm_iomap_memory(struct vm_area_struc
 	unsigned long vm_len, pfn, pages;

 	/* Check that the physical memory area passed in looks valid */
-	if (start + len < start)
 		return -EINVAL;
 	/*
 	 * You *really* shouldn't map things that aren't page-aligned,
@@ -2146,7 +2145,6 @@ int vm_iomap_memory(struct vm_area_struc
 	len += start & ~PAGE_MASK;
 	pfn = start >> PAGE_SHIFT;
 	pages = (len + ~PAGE_MASK) >> PAGE_SHIFT;
-	if (pfn + pages < pfn)
 		return -EINVAL;

 	/* We start the mapping 'vm_pgoff' pages into the area */
diff -u -p /var/linuxes/linux-next/mm/mmap.c /tmp/nothing/mm/mmap.c
--- /var/linuxes/linux-next/mm/mmap.c
+++ /tmp/nothing/mm/mmap.c
@@ -2792,7 +2792,6 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 		return ret;

 	/* Does pgoff wrap? */
-	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;

 	if (down_write_killable(&mm->mmap_sem))
diff -u -p /var/linuxes/linux-next/mm/nommu.c /tmp/nothing/mm/nommu.c
--- /var/linuxes/linux-next/mm/nommu.c
+++ /tmp/nothing/mm/nommu.c
@@ -1860,7 +1860,6 @@ int access_process_vm(struct task_struct
 {
 	struct mm_struct *mm;

-	if (addr + len < addr)
 		return 0;

 	mm = get_task_mm(tsk);
diff -u -p /var/linuxes/linux-next/mm/mremap.c /tmp/nothing/mm/mremap.c
--- /var/linuxes/linux-next/mm/mremap.c
+++ /tmp/nothing/mm/mremap.c
@@ -411,7 +411,6 @@ static struct vm_area_struct *vma_to_res
 	/* Need to be careful about a growing mapping */
 	pgoff = (addr - vma->vm_start) >> PAGE_SHIFT;
 	pgoff += vma->vm_pgoff;
-	if (pgoff + (new_len >> PAGE_SHIFT) < pgoff)
 		return ERR_PTR(-EINVAL);

 	if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
diff -u -p /var/linuxes/linux-next/tools/perf/util/unwind-libunwind-local.c /tmp/nothing/tools/perf/util/unwind-libunwind-local.c
--- /var/linuxes/linux-next/tools/perf/util/unwind-libunwind-local.c
+++ /tmp/nothing/tools/perf/util/unwind-libunwind-local.c
@@ -517,7 +517,6 @@ static int access_mem(unw_addr_space_t _
 	end = start + stack->size;

 	/* Check overflow. */
-	if (addr + sizeof(unw_word_t) < addr)
 		return -EINVAL;

 	if (addr < start || addr + sizeof(unw_word_t) >= end) {
diff -u -p /var/linuxes/linux-next/tools/perf/util/dso.c /tmp/nothing/tools/perf/util/dso.c
--- /var/linuxes/linux-next/tools/perf/util/dso.c
+++ /tmp/nothing/tools/perf/util/dso.c
@@ -964,7 +964,6 @@ static ssize_t data_read_offset(struct d
 	if (offset > dso->data.file_size)
 		return -1;

-	if (offset + size < offset)
 		return -1;

 	return cached_read(dso, machine, offset, data, size);
diff -u -p /var/linuxes/linux-next/tools/perf/util/unwind-libdw.c /tmp/nothing/tools/perf/util/unwind-libdw.c
--- /var/linuxes/linux-next/tools/perf/util/unwind-libdw.c
+++ /tmp/nothing/tools/perf/util/unwind-libdw.c
@@ -145,7 +145,6 @@ static bool memory_read(Dwfl *dwfl __may
 	end = start + stack->size;

 	/* Check overflow. */
-	if (addr + sizeof(Dwarf_Word) < addr)
 		return false;

 	if (addr < start || addr + sizeof(Dwarf_Word) > end) {
diff -u -p /var/linuxes/linux-next/net/netfilter/xt_u32.c /tmp/nothing/net/netfilter/xt_u32.c
--- /var/linuxes/linux-next/net/netfilter/xt_u32.c
+++ /tmp/nothing/net/netfilter/xt_u32.c
@@ -57,7 +57,6 @@ static bool u32_match_it(const struct xt
 				val >>= number;
 				break;
 			case XT_U32_AT:
-				if (at + val < at)
 					return false;
 				at += val;
 				pos = number;
diff -u -p /var/linuxes/linux-next/net/netfilter/nft_limit.c /tmp/nothing/net/netfilter/nft_limit.c
--- /var/linuxes/linux-next/net/netfilter/nft_limit.c
+++ /tmp/nothing/net/netfilter/nft_limit.c
@@ -71,7 +71,6 @@ static int nft_limit_init(struct nft_lim
 	else
 		limit->burst = 0;

-	if (limit->rate + limit->burst < limit->rate)
 		return -EOVERFLOW;

 	/* The token bucket size limits the number of tokens can be
diff -u -p /var/linuxes/linux-next/fs/btrfs/extent_map.c /tmp/nothing/fs/btrfs/extent_map.c
--- /var/linuxes/linux-next/fs/btrfs/extent_map.c
+++ /tmp/nothing/fs/btrfs/extent_map.c
@@ -84,7 +84,6 @@ void free_extent_map(struct extent_map *
 /* simple helper to do math around the end of an extent, handling wrap */
 static u64 range_end(u64 start, u64 len)
 {
-	if (start + len < start)
 		return (u64)-1;
 	return start + len;
 }
diff -u -p /var/linuxes/linux-next/fs/btrfs/ordered-data.c /tmp/nothing/fs/btrfs/ordered-data.c
--- /var/linuxes/linux-next/fs/btrfs/ordered-data.c
+++ /tmp/nothing/fs/btrfs/ordered-data.c
@@ -31,7 +31,6 @@ static struct kmem_cache *btrfs_ordered_

 static u64 entry_end(struct btrfs_ordered_extent *entry)
 {
-	if (entry->file_offset + entry->len < entry->file_offset)
 		return (u64)-1;
 	return entry->file_offset + entry->len;
 }
diff -u -p /var/linuxes/linux-next/fs/ext4/resize.c /tmp/nothing/fs/ext4/resize.c
--- /var/linuxes/linux-next/fs/ext4/resize.c
+++ /tmp/nothing/fs/ext4/resize.c
@@ -1615,14 +1615,10 @@ int ext4_group_add(struct super_block *s
 		return -EPERM;
 	}

-	if (ext4_blocks_count(es) + input->blocks_count <
-	    ext4_blocks_count(es)) {
 		ext4_warning(sb, "blocks_count overflow");
 		return -EINVAL;
 	}

-	if (le32_to_cpu(es->s_inodes_count) + EXT4_INODES_PER_GROUP(sb) <
-	    le32_to_cpu(es->s_inodes_count)) {
 		ext4_warning(sb, "inodes_count overflow");
 		return -EINVAL;
 	}
@@ -1770,7 +1766,6 @@ int ext4_group_extend(struct super_block

 	add = EXT4_BLOCKS_PER_GROUP(sb) - last;

-	if (o_blocks_count + add < o_blocks_count) {
 		ext4_warning(sb, "blocks_count overflow");
 		return -EINVAL;
 	}
diff -u -p /var/linuxes/linux-next/sound/core/info.c /tmp/nothing/sound/core/info.c
--- /var/linuxes/linux-next/sound/core/info.c
+++ /tmp/nothing/sound/core/info.c
@@ -109,7 +109,6 @@ static bool valid_pos(loff_t pos, size_t
 {
 	if (pos < 0 || (long) pos != pos || (ssize_t) count < 0)
 		return false;
-	if ((unsigned long) pos + (unsigned long) count < (unsigned long) pos)
 		return false;
 	return true;
 }
diff -u -p /var/linuxes/linux-next/ipc/mqueue.c /tmp/nothing/ipc/mqueue.c
--- /var/linuxes/linux-next/ipc/mqueue.c
+++ /tmp/nothing/ipc/mqueue.c
@@ -291,7 +291,6 @@ static struct inode *mqueue_get_inode(st
 			min_t(unsigned int, info->attr.mq_maxmsg, MQ_PRIO_MAX) *
 			sizeof(struct posix_msg_tree_node);
 		mq_bytes = info->attr.mq_maxmsg * info->attr.mq_msgsize;
-		if (mq_bytes + mq_treesize < mq_bytes)
 			goto out_inode;
 		mq_bytes += mq_treesize;
 		spin_lock(&mq_lock);
diff -u -p /var/linuxes/linux-next/ipc/shm.c /tmp/nothing/ipc/shm.c
--- /var/linuxes/linux-next/ipc/shm.c
+++ /tmp/nothing/ipc/shm.c
@@ -1417,7 +1417,6 @@ long do_shmat(int shmid, char __user *sh

 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
-		if (addr + size < addr)
 			goto invalid;

 		if (find_vma_intersection(current->mm, addr, addr + size))
