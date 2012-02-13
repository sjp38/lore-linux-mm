Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8355B6B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 03:08:49 -0500 (EST)
Message-ID: <4F38C502.40306@gmx.de>
Date: Mon, 13 Feb 2012 08:08:34 +0000
From: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
MIME-Version: 1.0
Subject: BUG: scheduling while atomic
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

Hi all,

since I upgraded to 3.3-rc3 I received this bug. Probably a regression although
I also recently updated git, so I can't say for sure. It looks like it happens
quite often here when doing git push in kernel trees.

[19313.126490] BUG: scheduling while atomic: git/3379/0x00000002
[19313.131251] Modules linked in: rtl8187 eeprom_93cx6 snd_hda_codec_realtek
fbcon font bitblit softcursor snd_hda_intel snd_hda_codec snd_hwdep snd_pcm
snd_timer snd soundcore snd_page_alloc i2c_viapro ehci_hcd uhci_hcd video
viafb(O) fb fbdev i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect
[19313.131479] Pid: 3379, comm: git Tainted: G           O 3.3.0-rc3+ #2
[19313.131506] Call Trace:
[19313.131558]  [<c1044837>] __schedule_bug+0x67/0x70
[19313.131607]  [<c1396077>] __schedule+0x537/0x570
[19313.131660]  [<c116e154>] ? __blk_run_queue+0x14/0x20
[19313.131697]  [<c1170281>] ? queue_unplugged+0x51/0x70
[19313.131743]  [<c1396532>] schedule+0x32/0x50
[19313.131780]  [<c1396582>] io_schedule+0x32/0x50
[19313.131824]  [<c1075b58>] sleep_on_page_killable+0x8/0x30
[19313.131863]  [<c1394ec7>] __wait_on_bit+0x47/0x70
[19313.131900]  [<c1075b50>] ? sleep_on_page+0x10/0x10
[19313.131941]  [<c1075d48>] wait_on_page_bit_killable+0x98/0xb0
[19313.131988]  [<c103cbb0>] ? autoremove_wake_function+0x50/0x50
[19313.132053]  [<c1075ee4>] __lock_page_or_retry+0x84/0xa0
[19313.132094]  [<c1076577>] filemap_fault+0x267/0x3a0
[19313.132137]  [<c108be86>] __do_fault+0x66/0x4a0
[19313.132182]  [<c1076310>] ? read_cache_page+0x20/0x20
[19313.132219]  [<c108cdfb>] handle_pte_fault+0x8b/0x830
[19313.132271]  [<c118a489>] ? prio_tree_insert+0x209/0x280
[19313.132321]  [<c101ef6e>] ? pte_alloc_one+0x1e/0x40
[19313.132356]  [<c108d95d>] ? __pte_alloc+0x6d/0xc0
[19313.132393]  [<c108da7f>] handle_mm_fault+0xcf/0x120
[19313.132436]  [<c101b090>] do_page_fault+0x150/0x3d0
[19313.132524]  [<c1091de4>] ? vma_link+0xc4/0xd0
[19313.132560]  [<c10930c5>] ? do_brk+0x2a5/0x350
[19313.132596]  [<c1093066>] ? do_brk+0x246/0x350
[19313.132635]  [<c101af40>] ? mm_fault_error+0x1e0/0x1e0
[19313.132671]  [<c139709c>] error_code+0x58/0x60
[19313.132712]  [<c101af40>] ? mm_fault_error+0x1e0/0x1e0
[19313.132752]  [<c1192542>] ? clear_user+0x32/0x50
[19313.132796]  [<c10e8705>] load_elf_binary+0x905/0x1a10
[19313.132845]  [<c107faf5>] ? lru_cache_add_lru+0x25/0x40
[19313.132897]  [<c101ef6e>] ? pte_alloc_one+0x1e/0x40
[19313.132934]  [<c118eade>] ? strrchr+0xe/0x30
[19313.132972]  [<c10e58fe>] ? load_misc_binary+0x16e/0x3e0
[19313.133013]  [<c108dc53>] ? __get_user_pages+0xe3/0x410
[19313.133077]  [<c108e027>] ? get_user_pages+0x57/0x70
[19313.133124]  [<c10aa04a>] search_binary_handler+0xfa/0x310
[19313.133167]  [<c10e7e00>] ? elf_map+0x130/0x130
[19313.133204]  [<c10ab695>] do_execve+0x2b5/0x360
[19313.133249]  [<c1008aba>] sys_execve+0x4a/0x70
[19313.133286]  [<c1397372>] ptregs_execve+0x12/0x18
[19313.133321]  [<c1397310>] ? sysenter_do_call+0x12/0x26
[19313.133521] note: git[3379] exited with preempt_count 1

Any suggestions/ideas/fixes?


Best regards,

Florian Tobias Schandinat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
