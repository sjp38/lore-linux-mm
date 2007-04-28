Date: Sat, 28 Apr 2007 14:10:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
Message-Id: <20070428141024.887342bd.akpm@linux-foundation.org>
In-Reply-To: <46338AEB.2070109@imap.cc>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>
	<46338AEB.2070109@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Apr 2007 19:56:59 +0200 Tilman Schmidt <tilman@imap.cc> wrote:

> With kernel 2.6.21-rc7-mm2, my Dell Optiplex GX110 (P3/933) regularly
> crashes during the SuSE 10.1 startup sequence. When booting to RL5,
> it panicblinks shortly after the graphical login screen appears.
> Booting to RL3, it hangs after the startup message:
> 
> Starting Firewall Initialization (phase 2 of 2)
> 
> (the last message before "runlevel 3 has been reached") logging this:
> 
> [   57.138955] Eeek! page_mapcount(page) went negative! (-1)
> [   57.139040]   page pfn = 0
> [   57.139053]   page->flags = 400
> [   57.139066]   page->count = 1
> [   57.139079]   page->mapping = 00000000
> [   57.139111]   vma->vm_ops = generic_file_vm_ops+0x0/0x18
> [   57.139147]   vma->vm_ops->nopage = 0x0
> [   57.139181]   vma->vm_file->f_op->mmap = reiserfs_file_mmap+0x0/0x47
> [   57.139220] ------------[ cut here ]------------
> [   57.139236] kernel BUG at mm/rmap.c:648!
> [   57.139251] invalid opcode: 0000 [#1]
> [   57.139264] PREEMPT
> [   57.139278] Modules linked in: usbserial snd_rtctimer snd_seq_dummy snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device thermal processor fan button battery ac af_packet usb_gigaset ser_gigaset bas_gigaset gigaset isdn slhc crc_ccitt ip6t_REJECT xt_tcpudp ipt_REJECT xt_state iptable_mangle iptable_nat nf_nat iptable_filter ip6table_mangle nf_conntrack_ipv4 nf_conntrack nfnetlink ip_tables ip6table_filter ip6_tables x_tables ehci_hcd snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd soundcore snd_page_alloc i2c_i801 uhci_hcd parport_pc lp parport ipv6 nls_iso8859_1 nls_cp437 vfat fat nls_utf8 ntfs dm_mod
> [   57.139447] CPU:    0
> [   57.139450] EIP:    0060:[<c015dfc0>]    Not tainted VLI
> [   57.139453] EFLAGS: 00010282   (2.6.21-rc7-mm2-noinitrd #1)
> [   57.139506] EIP is at page_remove_rmap+0xd7/0x106
> [   57.139522] eax: 0000004b   ebx: c1000000   ecx: 00000001   edx: 00000002
> [   57.139541] esi: c309fde0   edi: b7f24000   ebp: c373ec90   esp: c373ec78
> [   57.139559] ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
> [   57.139577] Process getcfg-interfac (pid: 4343, ti=c373e000 task=c18734d0 task.ti=c373e000)
> [   57.139586] Stack: c042abb5 00000000 c373ec90 c13f91c0 c1000000 c373dc90 c373ecf0 c0158df4
> [   57.139618]        c04f2ac4 00000001 00000000 c309fde0 c373ed10 00005ff1 00000000 00000001
> [   57.139647]        b7f62000 c374cb7c c374cb7c c374cb7c c373b344 fffffffe 00000000 c0569c2c
> [   57.139677] Call Trace:
> [   57.139721]  [<c0158df4>] unmap_vmas+0x2d7/0x4c9
> [   57.139748]  [<c015b7dd>] exit_mmap+0x68/0xeb
> [   57.139772]  [<c01191b0>] mmput+0x52/0xcb
> [   57.139805]  [<c011c368>] exit_mm+0xbb/0xc3
> [   57.139832]  [<c011d188>] do_exit+0x1ea/0x73e
> [   57.139857]  [<c011d74d>] sys_exit_group+0x0/0x13
> [   57.139880]  [<c012524e>] get_signal_to_deliver+0x6cd/0x6f8
> [   57.139917]  [<c01036cf>] do_notify_resume+0x91/0x692
> [   57.139944]  [<c0103f15>] work_notifysig+0x13/0x1a
> [   57.139970]  [<b7f6b7a8>] 0xb7f6b7a8
> [   57.139988]  =======================
> [   57.140002] INFO: lockdep is turned off.
> [   57.140015] Code: c0 74 0d 8b 50 0c b8 e5 ab 42 c0 e8 d7 fa fd ff 8b 46 48 85 c0 74 14 8b 40 10 85 c0 74 0d 8b 50 2c b8 04 ac 42 c0 e8 bc fa fd ff <0f> 0b eb fe 8b 53 10 8b 03 83 e2 01 f7 da c1 e8 1e 83 c2 04 69

I don't know which patch might have caused that.  Is it always
getcfg-interface which dies?  Seems to be a suse-only thing, and I
unfortunately don't have any test boxes which have it.

It seems wildly screwed up that we have a PageReserved() page with a pfn of
zero (!) which claims to be in a reiserfs mapping, only it isn't attached to a
reiserfs file.  How the heck did that happen?

Nick, I think that printk needs updating for changed vm_operations methods,
btw (->fault?)

This puts a dark cloud over about 200 patches at present.  It would be
great if you could perform a bisection search as per
http://www.zip.com.au/~akpm/linux/patches/stuff/bisecting-mm-trees.txt. 
I'd start out at fix-slab-corruption-running-ip6sic.patch then try
mm-fix-handling-of-panic_on_oom-when-cpusets-are-in-use.patch.  It should
take six or seven hops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
