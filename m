Date: Sun, 3 Sep 2000 18:21:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Oopses as discussed on irc
In-Reply-To: <m3vgwdb3tm.fsf@kalahari.s2.org>
Message-ID: <Pine.LNX.4.21.0009031815260.1112-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jarno Paananen <jpaana@s2.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3 Sep 2000, Jarno Paananen wrote:

> I'll now attach both the syslogd output and ksymoops output of
> the oopses, hope it helps.
> Syslogd:
> 
> Sep  3 19:26:07 siinai kernel: kernel BUG at filemap.c:67!
> Sep  3 19:26:07 siinai kernel: invalid operand: 0000
> Sep  3 19:26:07 siinai kernel: CPU:    0
> Sep  3 19:26:07 siinai kernel: EIP:    0010:[__add_page_to_hash_queue+60/80]
> Sep  3 19:26:07 siinai kernel: EFLAGS: 00010282
> Sep  3 19:26:07 siinai kernel: eax: 0000001c   ebx: 00000000   ecx: c020fb8c   edx: 00000001
> Sep  3 19:26:07 siinai kernel: esi: c134b7f0   edi: cc7dd89c   ebp: 0000002e   esp: cca07e3c
> Sep  3 19:26:07 siinai kernel: ds: 0018   es: 0018   ss: 0018
> Sep  3 19:26:07 siinai kernel: Process WindowMaker (pid: 452, stackpage=cca07000)
> Sep  3 19:26:07 siinai kernel: Stack: c01df8a9 c01dfa68 00000043 00000000 c01226ed c134b7f0 c14aa5d0 00000000 
> Sep  3 19:26:07 siinai kernel:        c134b7f0 0000002e cc7dd89c c01227f3 c134b7f0 cc7dd89c 0000002e c14aa5d0 
> Sep  3 19:26:07 siinai kernel:        c01238b0 00000000 00000028 ccf864c0 c14aa5d0 00000001 c01239ec ccf864c0 
> Sep  3 19:26:07 siinai kernel: Call Trace: [tvecs+2621/50420] [tvecs+3068/50420] [add_to_page_cache_unique+269/288] [read_cluster_nonblocking+243/336] [filemap_nopage+0/800] [filemap_nopage+316/800] [filemap_nopage+0/800] 
> Sep  3 19:26:07 siinai kernel:        [do_no_page+79/192] [handle_mm_fault+240/352] [do_page_fault+303/960] [unmap_fixup+98/288] [do_munmap+612/640] [sys_munmap+41/64] [error_code+44/52] 
> Sep  3 19:26:07 siinai kernel: Code: 0f 0b 83 c4 0c 5b c3 8d b6 00 00 00 00 8d bc 27 00 00 00 00 

This is consistent with the observed bug. /Somebody/ is using a
page, freeing the page and then using it again ...

Also, the window between freeing and using it again is big enough
that the page can be put on the freelist and allocated to somebody
else in the same time...

> Sep  3 21:59:30 siinai kernel: kernel BUG at page_alloc.c:91!
> Sep  3 21:59:30 siinai kernel: invalid operand: 0000
> Sep  3 21:59:30 siinai kernel: CPU:    0
> Sep  3 21:59:30 siinai kernel: EIP:    0010:[__free_pages_ok+73/832]
> Sep  3 21:59:30 siinai kernel: EFLAGS: 00013286
> Sep  3 21:59:30 siinai kernel: eax: 0000001f   ebx: c134b6e0   ecx: c020fb8c   edx: 00000001
> Sep  3 21:59:30 siinai kernel: esi: 000001c6   edi: cd1fb084   ebp: 00000000   esp: cc989f00
> Sep  3 21:59:30 siinai kernel: ds: 0018   es: 0018   ss: 0018
> Sep  3 21:59:30 siinai kernel: Process X (pid: 512, stackpage=cc989000)
> Sep  3 21:59:30 siinai kernel: Stack: c01e0e89 c01e1057 0000005b c134b6e0 000001c6 cd1fb084 cd1f88e8 c1044010 
> Sep  3 21:59:30 siinai kernel:        c0210c00 00003217 ffffffff 00005b3a c012a113 c012a540 005d8000 000001c6 
> Sep  3 21:59:30 siinai kernel:        c011f8fa c134b6e0 cc6d5a40 081d8000 ce85ef00 0030b000 cd1fb084 085d8000 
> Sep  3 21:59:30 siinai kernel: Call Trace: [tvecs+8221/50420] [tvecs+8683/50420] [__free_pages+19/32] [free_page_and_swap_cache+112/128] [zap_page_range+378/512] [exit_mmap+184/272] [mmput+21/48] 
> Sep  3 21:59:30 siinai kernel:        [do_exit+162/560] [sys_exit+14/16] [system_call+51/56] 
> Sep  3 21:59:30 siinai kernel: Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 20 08 21 c0 69 c0 f1 f0 f0 

This one is interesting. It looks like zap_page_range() can unmap
pages without holding them locked. This is a legal move and should
not cause any problems ... unless somebody else is doing something
with them at the same time?!  (but what?)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
