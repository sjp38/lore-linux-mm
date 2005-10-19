From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: [RFC] VGA mapping arbitration
Date: Wed, 19 Oct 2005 14:03:38 -0600
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510191403.38532.bjorn.helgaas@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm working on support for multiple VGA devices.  Sysfs-pci exports
access to the legacy I/O port and MMIO resources required.  And HP
chipsets have programmable routing for those resources (actually just
the VGA-specific 0xA0000-0xBFFFF MMIO and 0x3B0-0x3DF I/O port
ranges).

But since the chipset only routes to one VGA device at a time, we need
some arbitration to coordinate user accesses and the chipset routing.
The attached file is a start, but I'm a complete VM neophyte, so I'd
appreciate any guidance.

There are no struct pages for the VGA MMIO region, so I couldn't use a
nopage() vm_op directly.  I used populate() instead, which seems a bit
hacky.  It sounds like a nopfn() or similar is coming, and I might be
able to use that.

We have to keep track of all existing mappings of the VGA region, so
we can invalidate them when the chipset routing changes.  I used a
simple list, but that means allocating an entry in open(), where
there's no way to handle allocation failure.  Can I use something in
the vma to thread them together instead?

I'd appreciate any comments or suggestions.  Thanks.


/*
 * VGA routing
 *
 * (c) Copyright 2005 Hewlett-Packard Development Company, L.P.
 *	Bjorn Helgaas <bjorn.helgaas@hp.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

/*
 * Some chipsets, including HP zx1, zx2, sx1000, and sx2000, route
 * legacy VGA (MMIO accesses to 0xA0000-0xBFFFF and I/O port accesses
 * to 0x3B0-0x3DF and their 10-bit aliases) to a single PCI root
 * bridge.  This routing is programmable, so we can support several
 * VGA devices in the same system.
 *
 * These legacy resources are exposed to the user via read/write of
 * "legacy_io" (for I/O ports) and mmap of "legacy_mem" (for MMIO)
 * in the /sys directory corresponding to the PCI root bridge.
 *
 * But, of course, only one of the VGA devices is accessible at a time,
 * so this file does the locking and VM chicanery to keep multiple
 * users separated.
 */

#include <linux/types.h>
#include <linux/list.h>
#include <linux/pci.h>
#include <asm/tlbflush.h>
#include "cec.h"


#define VGA_MMIO_BASE		0xA0000UL
#define VGA_MMIO_END		0xC0000UL
#define VGA_IO_ALIAS_MASK	0x3FF
#define VGA_IO_BASE		0x3B0
#define VGA_IO_END		0x3E0

/* FIXME can we avoid dynamic allocations by statically allocating
 * a per-page struct here and using some rmap-style list to thread
 * things together?
 */
struct vga_mapping {
	struct list_head	list;
	struct vm_area_struct	*vma;
	struct pci_bus		*bus;
};

static DEFINE_SPINLOCK(vga_lock);
static LIST_HEAD(vga_mappers);

static struct pci_bus *vga_owner;

static void
change_vga_route(struct pci_bus *bus)
{
	struct hp_lba_data *lba = PCI_CONTROLLER(bus)->platform_data;

	hp_lba_vga_enable(lba);
	hp_sba_vga_enable(lba->sba, lba->rope);
	hp_pin_vga_enable(lba->cell);

	vga_owner = bus;
}

static pte_t *
my_pte_alloc_map(struct mm_struct *mm, unsigned long address)
{
	pgd_t *pgd;
	pud_t *pud;
	pmd_t *pmd;

	/* FIXME doesn't this leak on the failure paths? */

	pgd = pgd_offset(mm, address);
	if (!pgd)
		return NULL;

	pud = pud_alloc(mm, pgd, address);
	if (!pud)
		return NULL;

	pmd = pmd_alloc(mm, pud, address);
	if (!pmd)
		return NULL;

	return pte_alloc_map(mm, pmd, address);
}

static void
pte_protect(struct vm_area_struct *vma, unsigned long addr,
	unsigned long pgoff, pgprot_t prot)
{
	struct mm_struct *mm = vma->vm_mm;
	pte_t *pte, entry;

	pte = my_pte_alloc_map(mm, addr);
	if (!pte) {
		printk("%s: no PTE!\n", __FUNCTION__);
		BUG();	/* FIXME */
		return;
	}

	entry = pfn_pte(pgoff, prot);
	ptep_establish(vma, addr, pte, entry);
	pte_unmap(pte);
}

static inline pte_t *
va_to_pte(struct mm_struct *mm, unsigned long address)
{
	pgd_t *pgd;
	pud_t *pud;
	pmd_t *pmd;

	/* FIXME copied from page_check_address */
	pgd = pgd_offset(mm, address);
	if (likely(pgd_present(*pgd))) {
		pud = pud_offset(pgd, address);
		if (likely(pud_present(*pud))) {
			pmd = pmd_offset(pud, address);
			if (likely(pmd_present(*pmd)))
				return pte_offset_map(pmd, address);
		}
	}
	return 0;
}

static void
vga_invalidate(struct vga_mapping *mapping)
{
	struct vm_area_struct *vma = mapping->vma;
	struct mm_struct *mm = vma->vm_mm;
	unsigned long pages, pgoff, end, address;
	pte_t *pte, entry;

	pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
	pgoff = max(vma->vm_pgoff, VGA_MMIO_BASE >> PAGE_SHIFT);
	end = min(vma->vm_pgoff + pages, VGA_MMIO_END >> PAGE_SHIFT);
	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);

	/*
	 * We never *add* mappings to a non-current mm, merely
	 * invalidate any that exist.  This avoids races with
	 * exit_mmap().
	 */
	spin_lock(&mm->page_table_lock);
	while (pgoff < end) {
		pte = va_to_pte(mm, address);
		if (pte) {
			entry = pgoff_to_pte(pgoff);
			ptep_establish(vma, address, pte, entry);
			pte_unmap(pte);
		}
		address += PAGE_SIZE;
		pgoff++;
	}
	spin_unlock(&mm->page_table_lock);
}

static void
vga_map(struct vga_mapping *mapping, pgprot_t prot)
{
	struct vm_area_struct *vma = mapping->vma;
	struct mm_struct *mm = vma->vm_mm;
	unsigned long pages, pgoff, end, addr;

	pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
	pgoff = max(vma->vm_pgoff, VGA_MMIO_BASE >> PAGE_SHIFT);
	end = min(vma->vm_pgoff + pages, VGA_MMIO_END >> PAGE_SHIFT);
	addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);

	spin_lock(&mm->page_table_lock);
	while (pgoff < end) {
		pte_protect(vma, addr, pgoff, prot);
		addr += PAGE_SIZE;
		pgoff++;
	}
	spin_unlock(&mm->page_table_lock);
}

static void
vga_open(struct vm_area_struct *vma)
{
	struct pci_bus *bus = vma->vm_private_data;
	struct vga_mapping *mapping;

	mapping = kzalloc(sizeof(*mapping), GFP_KERNEL);
	if (!mapping) {
		BUG();		/* FIXME */
		return;
	}

	mapping->vma = vma;
	mapping->bus = bus;

	spin_lock(&vga_lock);
	vga_invalidate(mapping);
	list_add(&mapping->list, &vga_mappers);
	spin_unlock(&vga_lock);
}

static void
vga_close(struct vm_area_struct *vma)
{
	struct vga_mapping *mapper;

	spin_lock(&vga_lock);
	list_for_each_entry(mapper, &vga_mappers, list) {
		if (mapper->vma == vma) {
			list_del(&mapper->list);
			break;
		}
	}
	spin_unlock(&vga_lock);
	kfree(mapper);
}

static struct vga_mapping *
change_vga_owner(struct pci_bus *bus, struct vm_area_struct *vma)
{
	struct vga_mapping *mapper, *new_owner = NULL;

	list_for_each_entry(mapper, &vga_mappers, list) {
		vga_invalidate(mapper);
		if (mapper->vma == vma)
			new_owner = mapper;
	}
	change_vga_route(bus);

	return new_owner;
}

static struct page *
vga_nopage(struct vm_area_struct *vma, unsigned long address, int *type)
{
	return NOPAGE_SIGBUS;
}

static int
vga_populate(struct vm_area_struct *vma, unsigned long address,
	unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock)
{
	struct pci_bus *bus = vma->vm_private_data;
	struct vga_mapping *mapping;

	spin_lock(&vga_lock);
	mapping = change_vga_owner(bus, vma);
	vga_map(mapping, prot);
	spin_unlock(&vga_lock);
	return 0;
}

static struct vm_operations_struct vga_vm_ops = {
	.open		= vga_open,
	.close		= vga_close,
	.nopage		= vga_nopage,
	.populate	= vga_populate,
};

int
hp_pci_mmap_legacy_page_range(struct pci_bus *bus, struct vm_area_struct *vma)
{
	unsigned long size = vma->vm_end - vma->vm_start;

	if ((vma->vm_pgoff << PAGE_SHIFT) + size > 1024*1024)
		return -EINVAL;

	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO | VM_SHARED);
	vma->vm_ops = &vga_vm_ops;
	vma->vm_private_data = bus;

	vga_open(vma);
	return 0;
}

static inline int
is_vga_port(u16 alias)
{
	u16 port = alias & VGA_IO_ALIAS_MASK;

	if (port >= VGA_IO_BASE && port < VGA_IO_END)
		return 1;
	return 0;
}

int
hp_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
{
	int is_vga = is_vga_port(port);
	int ret = size;

	if (is_vga) {
		spin_lock(&vga_lock);
		if (vga_owner != bus)
			change_vga_owner(bus, NULL);
	}

	switch (size) {
	case 1:
		*val = inb(port);
		break;
	case 2:
		*val = inw(port);
		break;
	case 4:
		*val = inl(port);
		break;
	default:
		ret = -EINVAL;
		break;
	}

	if (is_vga)
		spin_unlock(&vga_lock);

	return ret;
}

int
hp_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
{
	int is_vga = is_vga_port(port);
	int ret = size;

	if (is_vga) {
		spin_lock(&vga_lock);
		if (vga_owner != bus)
			change_vga_owner(bus, NULL);
	}

	switch (size) {
	case 1:
		outb(val, port);
		break;
	case 2:
		outw(val, port);
		break;
	case 4:
		outl(val, port);
		break;
	default:
		ret = -EINVAL;
		break;
	}

	if (is_vga)
		spin_unlock(&vga_lock);

	return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
