Date: Fri, 23 Mar 2007 21:14:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-Id: <20070323211410.35e6ba4f.akpm@linux-foundation.org>
In-Reply-To: <4603BC6C.4010902@yahoo.com.au>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
	<20070322223927.bb4caf43.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
	<20070322234848.100abb3d.akpm@linux-foundation.org>
	<4603BC6C.4010902@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007 22:39:24 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Andrew Morton wrote:
> 
> > but it crashes early in the page allocator (i386) and I don't see why.  It
> > makes me wonder if we have a use-after-free which is hidden by the presence
> > of the quicklist buffering or something.
> 
> Does CONFIG_DEBUG_PAGEALLOC catch it?

It'll be a while before I can get onto doing anything with this.
I do have an oops trace:


kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 296k freed
Write protecting the kernel read-only data: 921k
BUG: unable to handle kernel paging request at virtual address 00100104
 printing eip:
c015b676
*pde = 00000000
Oops: 0002 [#1]
SMP 
Modules linked in:
CPU:    1
EIP:    0060:[<c015b676>]    Not tainted VLI
EFLAGS: 00010002   (2.6.21-rc4 #6)
EIP is at get_page_from_freelist+0x166/0x3d0
eax: c1b110bc   ebx: 00000001   ecx: 00100100   edx: 00200200
esi: c1b11090   edi: c04cc500   ebp: f67d3b88   esp: f67d3b34
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Process default.hotplug (pid: 872, ti=f67d2000 task=f6748030 task.ti=f67d2000)
Stack: 00000001 00000044 c067eae8 00000001 00000001 00000000 c04cc6c0 c04cc4a0 
       00000001 00000000 000284d0 c04ccb78 00000286 00000001 00000000 f67b6000 
       00000000 00000001 c04cc4a0 f6748030 000084d0 f67d3bcc c015b92e 00000044 
Call Trace:
 [<c0103e6a>] show_trace_log_lvl+0x1a/0x30
 [<c0103f29>] show_stack_log_lvl+0xa9/0xd0
 [<c0104139>] show_registers+0x1e9/0x2f0
 [<c0104355>] die+0x115/0x250
 [<c011561e>] do_page_fault+0x27e/0x630
 [<c03d5f64>] error_code+0x7c/0x84
 [<c015b92e>] __alloc_pages+0x4e/0x2f0
 [<c0114c84>] pte_alloc_one+0x14/0x20
 [<c0163d1b>] __pte_alloc+0x1b/0xa0
 [<c016459d>] __handle_mm_fault+0x7fd/0x940
 [<c01154b9>] do_page_fault+0x119/0x630
 [<c03d5f64>] error_code+0x7c/0x84
 [<c01a5e8f>] padzero+0x1f/0x30
 [<c01a744e>] load_elf_binary+0x76e/0x1a80
 [<c017c2c7>] search_binary_handler+0x97/0x220
 [<c01a5886>] load_script+0x1d6/0x220
 [<c017c2c7>] search_binary_handler+0x97/0x220
 [<c017dd0f>] do_execve+0x14f/0x200
 [<c010140e>] sys_execve+0x2e/0x80
 [<c0102dcc>] sysenter_past_esp+0x5d/0x99
 =======================
Code: 06 8b 4d c0 8b 7d c8 8d 04 81 8d 44 82 20 01 c7 9c 8f 45 dc fa e8 4b f4 fd ff 8b 07 85 c0 74 7b 8b 47 0c 8b 08 8d 70 d4 8b 50 04 <89> 51 04 89 0a c7 40 04 00 02 20 00 c7 00 00 01 10 00 ff 0f 8b 
EIP: [<c015b676>] get_page_from_freelist+0x166/0x3d0 SS:ESP 0068:f67d3b34

Not pretty.  That was bare mainline+christoph's patches+that patch which I sent.
Using http://userweb.kernel.org/~akpm/config-vmm.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
