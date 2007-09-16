From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.22.6: kernel BUG at fs/locks.c:171
Date: Sun, 16 Sep 2007 18:15:39 +1000
References: <1189675222.5352.10.camel@localhost> <1189849627.4270.12.camel@localhost> <1189851735.4270.19.camel@localhost>
In-Reply-To: <1189851735.4270.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709161815.39633.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Soeren Sonnenburg <kernel@nn7.de>, linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Saturday 15 September 2007 20:22, Soeren Sonnenburg wrote:
> On Sat, 2007-09-15 at 09:47 +0000, Soeren Sonnenburg wrote:

> > Memtest did not find anything after 16 passes so I finally stopped it
> > applied your patch and used
> >
> > CONFIG_DEBUG_SLAB=y
> > CONFIG_DEBUG_SLAB_LEAK=y
> >
> > and booted into the new kernel.
> >
> > A few hours later the machine hung (due to nmi watchdog rebooted), so I
> > restarted and disabled the watchdog and while compiling a kernel with a
> > ``more minimal'' config I got this (not sure whether this is related/the
> > cause .../ note that I don't use a swapfile/partition).
> >
> > I would need more guidance on what to try now...
> >
> > Thanks!
> > Soeren
> >
> > swap_dup: Bad swap file entry 28c8af9d

Hmm, this is another telltale symptom of either bad hardware
or a memory scribbling bug.


> > VM: killing process cc1
> > Eeek! page_mapcount(page) went negative! (-1)
> >   page pfn = 36233
> >   page->flags = 40000834
> >   page->count = 2
> >   page->mapping = c1cfed14
> >   vma->vm_ops = run_init_process+0x3feff000/0x14

And these are probably related (it's just gone off and started
performing VM operations on the wrong page...).

Had you been using the dvb card since rebooting when you saw
these messages come up? What happens if you remove the card
from the system?


> > ------------[ cut here ]------------
> > kernel BUG at mm/rmap.c:628!
> > invalid opcode: 0000 [#1]
> > Modules linked in: ipt_iprange ipt_REDIRECT capi kernelcapi capifs
> > ipt_REJECT xt_tcpudp xt_state xt_limit ipt_LOG ipt_MASQUERADE
> > iptable_mangle iptable_nat nf_conntrack_ipv4 iptable_filter ip_tables
> > x_tables b44 ohci1394 ieee1394 nf_nat_ftp nf_nat nf_conntrack_ftp
> > nf_conntrack lcd tda827x saa7134_dvb dvb_pll video_buf_dvb tda1004x tuner
> > ves1820 usb_storage usblp budget_ci budget_core saa7134 compat_ioctl32
> > dvb_ttpci dvb_core saa7146_vv video_buf saa7146 ttpci_eeprom ir_kbd_i2c
> > videodev v4l2_common v4l1_compat ir_common via_agp agpgart CPU:    0
> > EIP:    0060:[<c0144487>]    Not tainted VLI
> > EFLAGS: 00010246   (2.6.22.6 #2)
> > EIP is at page_remove_rmap+0xd4/0x101
> > eax: 00000000   ebx: c16c4660   ecx: 00000000   edx: 00000000
> > esi: d4570b30   edi: d6560a78   ebp: b7400000   esp: d6265eac
> > ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
> > Process cc1 (pid: 26095, ti=d6264000 task=d67af5b0 task.ti=d6264000)
> > Stack: c0422e26 c1cfed14 c16c4660 b729e000 c013f5b8 36233cce 00000000
> > d4570b30 d6265f20 00000000 00000001 f4ffcb70 f483a3b8 c04f44b8 00000000
> > ffffffff f4ffcb70 00303ff4 b7c18000 00000000 d6265f20 f4a8c510 f483a3b8
> > 00000009 Call Trace:
> >  [<c013f5b8>] unmap_vmas+0x23f/0x404
> >  [<c0141c09>] exit_mmap+0x5f/0xc9
> >  [<c011923a>] mmput+0x1b/0x5e
> >  [<c011cf97>] do_exit+0x1a0/0x606
> >  [<c01135f8>] do_page_fault+0x49c/0x518
> >  [<c011e340>] __do_softirq+0x35/0x75
> >  [<c011315c>] do_page_fault+0x0/0x518
> >  [<c039aada>] error_code+0x6a/0x70
> >  =======================
> > Code: c0 74 0d 8b 50 08 b8 56 2e 42 c0 e8 ac f4 fe ff 8b 46 48 85 c0 74
> > 14 8b 40 10 85 c0 74 0d 8b 50 2c b8 75 2e 42 c0 e8 91 f4 fe ff <0f> 0b eb
> > fe 8b 53 10 8b 03 83 e2 01 c1 e8 1e f7 da 83 c2 04 69 EIP: [<c0144487>]
> > page_remove_rmap+0xd4/0x101 SS:ESP 0068:d6265eac Fixing recursive fault
> > but reboot is needed!
>
> Hmmhh, so now I rebooted and again tried to
>
> $ make
>
> the new kernel which again triggered this(?) BUG:
>
> Any ideas?
> Soeren.
>
> Eeek! page_mapcount(page) went negative! (-1)
>   page pfn = 18722
>   page->flags = 40000000
>   page->count = 1
>   page->mapping = 00000000
>   vma->vm_ops = run_init_process+0x3feff000/0x14
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:628!
> invalid opcode: 0000 [#1]
> Modules linked in: ipt_iprange ipt_REDIRECT capi kernelcapi capifs
> ipt_REJECT xt_tcpudp xt_state xt_limit ipt_LOG ipt_MASQUERADE
> iptable_mangle iptable_nat nf_conntrack_ipv4 iptable_filter ip_tables x_t
> CPU:    0
> EIP:    0060:[<c0144487>]    Not tainted VLI
> EFLAGS: 00010246   (2.6.22.6 #2)
> EIP is at page_remove_rmap+0xd4/0x101
> eax: 00000000   ebx: c130e440   ecx: 00000000   edx: 00000000
> esi: f438b510   edi: f3328ac8   ebp: c130e440   esp: f28d5eec
> ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> Process cc1 (pid: 17957, ti=f28d4000 task=f60bb0d0 task.ti=f28d4000)
> Stack: c0422e26 00000000 f3328ac8 00000002 c013f185 b76b2000 f438b510
> f43013b8 c1a7c640 18722229 b76b2000 f3328ac8 f438b510 c014021d f3328ac8
> f4360b74 f43013f8 18722229 00100073 b76b2000 f43013b8 f4360b74 00000100
> f28d5f90 Call Trace:
>  [<c013f185>] do_wp_page+0x28a/0x35c
>  [<c014021d>] __handle_mm_fault+0x626/0x6a4
>  [<c0113368>] do_page_fault+0x20c/0x518
>  [<c011315c>] do_page_fault+0x0/0x518
>  [<c039aada>] error_code+0x6a/0x70
>  =======================
> Code: c0 74 0d 8b 50 08 b8 56 2e 42 c0 e8 ac f4 fe ff 8b 46 48 85 c0 74 14
> 8b 40 10 85 c0 74 0d 8b 50 2c b8 75 2e 42 c0 e8 91 f4 fe ff <0f> 0b eb fe
> 8b 53 10 8b 03 83 e2 01 c1 e8 1e f7 da 83 c2 04 69 EIP: [<c0144487>]
> page_remove_rmap+0xd4/0x101 SS:ESP 0068:f28d5eec Eeek! page_mapcount(page)
> went negative! (-2)
>   page pfn = 18722
>   page->flags = 40000004
>   page->count = 1
>   page->mapping = 00000000
>   vma->vm_ops = run_init_process+0x3feff000/0x14
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:628!
> invalid opcode: 0000 [#2]
> Modules linked in: ipt_iprange ipt_REDIRECT capi kernelcapi capifs
> ipt_REJECT xt_tcpudp xt_state xt_limit ipt_LOG ipt_MASQUERADE
> iptable_mangle iptable_nat nf_conntrack_ipv4 iptable_filter ip_tables x_t
> CPU:    0
> EIP:    0060:[<c0144487>]    Not tainted VLI
> EFLAGS: 00010246   (2.6.22.6 #2)
> EIP is at page_remove_rmap+0xd4/0x101
> eax: 00000000   ebx: c130e440   ecx: 00000000   edx: 00000000
> esi: f438b510   edi: f3328ac8   ebp: b7800000   esp: f28d5d30
> ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
> Process cc1 (pid: 17957, ti=f28d4000 task=f60bb0d0 task.ti=f28d4000)
> Stack: c0422e26 00000000 c130e440 b76b2000 c013f5b8 18722229 00000000
> f438b510 f28d5da4 00000000 00000001 f4360b74 f43013b8 c04f44b8 00000000
> ffffffff f4360b74 00173c7a b7c03000 00000000 f28d5da4 f6754cf0 f43013b8
> 0000000b Call Trace:
>  [<c013f5b8>] unmap_vmas+0x23f/0x404
>  [<c0141c09>] exit_mmap+0x5f/0xc9
>  [<c011923a>] mmput+0x1b/0x5e
>  [<c011cf97>] do_exit+0x1a0/0x606
>  [<c0104db5>] die+0x188/0x190
>  [<c0105123>] do_invalid_op+0x0/0x8a
>  [<c01051a4>] do_invalid_op+0x81/0x8a
>  [<c0144487>] page_remove_rmap+0xd4/0x101
>  [<c011ae03>] wake_up_klogd+0x33/0x35
>  [<c01066e5>] timer_interrupt+0x1d/0x23
>  [<c013445c>] handle_IRQ_event+0x1a/0x3f
>  [<c039aada>] error_code+0x6a/0x70
>  [<c0144487>] page_remove_rmap+0xd4/0x101
>  [<c013f185>] do_wp_page+0x28a/0x35c
>  [<c014021d>] __handle_mm_fault+0x626/0x6a4
>  [<c0113368>] do_page_fault+0x20c/0x518
>  [<c011315c>] do_page_fault+0x0/0x518
>  [<c039aada>] error_code+0x6a/0x70
>  =======================
> Code: c0 74 0d 8b 50 08 b8 56 2e 42 c0 e8 ac f4 fe ff 8b 46 48 85 c0 74 14
> 8b 40 10 85 c0 74 0d 8b 50 2c b8 75 2e 42 c0 e8 91 f4 fe ff <0f> 0b eb fe
> 8b 53 10 8b 03 83 e2 01 c1 e8 1e f7 da 83 c2 04 69 EIP: [<c0144487>]
> page_remove_rmap+0xd4/0x101 SS:ESP 0068:f28d5d30 Fixing recursive fault but
> reboot is needed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
