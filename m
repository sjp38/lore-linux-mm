Date: Wed, 21 Jun 2000 10:19:18 +0200 (CEST)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: BUG in filemap.c:69/page_alloc.c:85
Message-ID: <Pine.LNX.4.21.0006211016030.4537-100000@fs1.dekanat.physik.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel List <linux-kernel@vger.rutgers.edu>
Cc: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

I didnt see this mentioned already, so here's the oopses
I got last night (still running 2.4.0test1-ac20, unpatched
though - this is a P100 with 32MB ram):

Jun 20 23:57:10 mickey kernel: kernel BUG at page_alloc.c:85!
Jun 20 23:57:10 mickey kernel: invalid operand: 0000
Jun 20 23:57:10 mickey kernel: CPU:    0
Jun 20 23:57:10 mickey kernel: EIP:    0010:[__free_pages_ok+45/788]
Jun 20 23:57:10 mickey kernel: EFLAGS: 00013282
Jun 20 23:57:10 mickey kernel: eax: 0000001f   ebx: c101398c   ecx: 0000000f   edx: c0e4a160
Jun 20 23:57:10 mickey kernel: esi: 00000057   edi: c0c82408   ebp: 00000000   esp: c0c29efc
Jun 20 23:57:10 mickey kernel: ds: 0018   es: 0018   ss: 0018
Jun 20 23:57:10 mickey kernel: Process XF86_Mach64 (pid: 296, stackpage=c0c29000)
Jun 20 23:57:10 mickey kernel: Stack: c01d6716 c01d69e5 00000055 c101398c 00000057 c0c82408 c0028ea4 c100000c 
Jun 20 23:57:10 mickey kernel:        c021663c 00003213 ffffffff 00000210 c012a2d6 0073b000 00000057 c011e52d 
Jun 20 23:57:10 mickey kernel:        c101398c c0827d20 4093b000 4073b000 00200000 c0c82408 40b3b000 0000006d 
Jun 20 23:57:10 mickey kernel: Call Trace: [tvecs+13154/78636] [tvecs+13873/78636] [free_page_and_swap_cache+130/136] [zap_page_range+361/484] [do_munmap+484/632] [sys_munmap+103/188] [system_call+52/64] 
Jun 20 23:57:10 mickey kernel: Code: 0f 0b 83 c4 0c 83 7b 08 00 74 18 6a 57 68 e5 69 1d c0 68 16 
(this one happened multiple times some days ago, so it seems non-fatal)

Jun 20 23:57:32 mickey kernel: kernel BUG at filemap.c:69!
Jun 20 23:57:32 mickey kernel: invalid operand: 0000
Jun 20 23:57:32 mickey kernel: CPU:    0
Jun 20 23:57:32 mickey kernel: EIP:    0010:[__add_page_to_hash_queue+60/68]
Jun 20 23:57:32 mickey kernel: EFLAGS: 00010282
Jun 20 23:57:32 mickey kernel: eax: 0000001c   ebx: c100effc   ecx: 0000001d   edx: c0e4a7a0
Jun 20 23:57:32 mickey kernel: esi: c11c1a24   edi: 000000c7   ebp: c10b2620   esp: c1b8de38
Jun 20 23:57:32 mickey kernel: ds: 0018   es: 0018   ss: 0018
Jun 20 23:57:32 mickey kernel: Process mpg123 (pid: 719, stackpage=c1b8d000)
Jun 20 23:57:32 mickey kernel: Stack: c01d41b6 c01d4439 00000045 c100efec c0121b39 c100efec c10b2620 c100efec 
Jun 20 23:57:32 mickey kernel:        000000c7 c11c1a24 c10b2620 c0121c99 c100efec c11c1a24 000000c7 c10b2620 
Jun 20 23:57:32 mickey kernel:        00000000 c0e4a7a0 00000000 000000c0 00000008 c01232e7 c0f12960 000000c0 
Jun 20 23:57:32 mickey kernel: Call Trace: [tvecs+3586/78636] [tvecs+4229/78636] [add_to_page_cache_unique+205/340] [read_cluster_nonblocking+217/328] [filemap_nopage+423/932] [do_no_page+77/184] [handle_mm_fault+240/348] 
Jun 20 23:57:32 mickey kernel:        [do_page_fault+394/1360] [pipe_write+660/928] [sys_write+192/224] [error_code+45/64] 
Jun 20 23:57:32 mickey kernel: Code: 0f 0b 83 c4 0c 5b c3 90 53 8b 5c 24 08 8b 43 18 a9 01 00 00 
(of course this one killed X - sysrq still did work, though)


Richard.

--
Richard Guenther <richard.guenther@student.uni-tuebingen.de>
WWW: http://www.anatom.uni-tuebingen.de/~richi/
The GLAME Project: http://www.glame.de/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
