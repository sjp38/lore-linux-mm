Message-Id: <4.3.2.7.0.20000825113602.00a9b520@192.168.1.9>
Date: Fri, 25 Aug 2000 11:38:21 +0530
From: Santosh Eraniose <santosh@sony.co.in>
Subject: linux SH3 MMU queries
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I have a few questions on the h/w interface part of memory mgmt in Linux.
The example I have chosen is SH3. Its is similar to x86 in the sense, it is 
a 32 bit
address space and has the 3 level pg table folded into two.
If any of u can can shed some light on the questions below(prefixed with 
a >>>>Q)
it will be most helpful.
If any one can give an example as to how the address transaltion is done it 
will be most helpful.
Thanks a lot

Memory Map of Linux on SH3
[ P0/U0 (virtual) ]                     0x00000000<------ User space
[ P1 (fixed)   cached ]               0x80000000<------ Kernel space
[ P2 (fixed)  non-cachable]       0xA0000000<------ Physical access
[ P3 (virtual) cached]                0xC0000000<------ not used
[ P4 control   ]                           0xE0000000

SH3 provides 2MB for User space and 2 MB for kernel space
Hence PAGE_OFFSET =0x80000000
TASK_SIZE should be equal to PAGE_OFFSET but SH3 says we can't use
0x7c000000--0x7fffffff ==>pg 209 SH h/w manual
Hence TASK_SIZE= 0x7c000000UL
 >>>>>Q: Is this correct??

#define PAGE_SHIFT     12
#define PAGE_SIZE        (1UL << PAGE_SHIFT) ==>4096
Page size =4K
On a 32 bit machine, the Linux kernel usually resides at virtual address 
0xc0000000 and virtual addresses from 0xc0000000 to 0xffffffff are reserved 
for kernel text/data and I/O space.
CONFIG_MEMORY_START 0x0c000000
#define __MEMORY_START          CONFIG_MEMORY_START
 >>>>>Q:In the map above this address range is shown as unused??

As IX bit in MMUCR is 1, TLB index is computed by ex oring ASID bits 0-4 in 
PTEH and VPN bits 16-12.
VPN is upper 20 bits of virtual address for a 4K page
TTB->base address of current page table
bits 16-12 of VPN is exored with ASID and forms index into TLB. Hence these 
are not stored in the TLB.
This can be obtained by exoring with the ASID present in the PTEH register.
 >>>>Q:Where is this exoring done in Linux? I don?t see any mask to get the 
VPN16-12 for indexing?
 >>>>Q:How is TLB "way" selection done in Linux?
 >>>>Q:Can a page overlap two sections eg P1 & P2?

#define PAGE_OFFSET             (0x80000000)
#define __pa(x)                 ((unsigned long)(x)-PAGE_OFFSET)
#define __va(x)                 ((void *)((unsigned long)(x)+PAGE_OFFSET))
#define MAP_NR(addr)            ((__pa(addr)-__MEMORY_START) >> PAGE_SHIFT)

pa/va =gives the physical address/virtual address.
 >>>>Q:Whats the math behind the -/+ PAGE_OFFSET.
 >>>>Does this mean that the address in Kernel space are the same as 
physical address.
 >>>>What about the address in P2 and P3 area?
 >>>>Q:Does MAP_NR give the total number of pages?

PTRS_PER_PMD    1
PTRS_PER_PGD    1024
PTRS_PER_PTE    1024


Virtual address
31 ?22 21 ?12 11?0
DIR       TABLE  OFFSET
1024 entries1024 entries


Physical address is then computed as:
CR3 + DIR  points to the table_base
table_base + TABLE  points to the page_base
physical_address  page_base + OFFSET

DIR=swapper_pg_dir[1024]; This is the kernel pg table.
There is only one kernel page table.
Each user program have their own page tables.

The register CR3 contains the physical base address of the page directory 
and is stored as part of the TSS in the task_struct and is therefore loaded 
on each task switch.
 >>>>Q:what is it on SH3?

#define MMU_PAGE_ASSOC_BIT      0x80
#define MMU_CONTEXT_VERSION_MASK        0xffffff00
#define MMU_CONTEXT_FIRST_VERSION       0x00000100
 >>>>Q:What is the purpose of MMU_PAGE_ASSOC_BIT
 >>>>Q:What is this version referred to?

--
Santosh Eraniose
-----------------------------------------------
Member Technical
Sony Software Architecture Lab
Bangalore
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
