Subject: Memory problems with 2.3.99-pre6-7
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 27 Apr 2000 19:45:46 +0200
Message-ID: <ytt3do7h1yt.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,
        I continue having problems with the memory subsystem in this
        kernel.  My system is a uniprocessor Athlon with 256MB of RAM.
        I will try to reproduce it in pre6(final), but each time is
        more difficult for me to reproduce the BUGS().  Each time they
        are less easily reproducible.

        I have get the following Oops:

kernel BUG at swap_state.c:56!
	if (page->mapping)
		BUG();
And the actual Oops is:

invalid operand: 0000
CPU:    0
EIP:    0010:[<c012a417>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 0000001f   ebx: c1000290   ecx: 0000000e   edx: 00000000
esi: c1000290   edi: c98d97fc   ebp: c2560200   esp: c15a1f08
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c15a1000)
Stack: c01dbbc3 c01dbe2f 00000038 00b59b00 c0129418 c1000290 00b59b00 00b59b00 
       77600000 77800000 c98d97fc 77800000 00b59b00 c012959f c2560200 775ff000 
       c98d97fc 00000004 c2560200 775ff000 ca985d80 00000004 779ff000 779ff000 
Call Trace: [<c01dbbc3>] [<c01dbe2f>] [<c0129418>] [<c012959f>] [<c012964b>] [<c012973e>] [<c012980a>] 
       [<c0129895>] [<c0108df8>] 
Code: 0f 0b 83 c4 0c 8d 74 26 00 8b 44 24 0c 50 68 10 83 21 c0 53 

>>EIP; c012a417 <add_to_swap_cache+47/70>   <=====
Trace; c01dbbc3 <tvecs+3663/1ba80>
Trace; c01dbe2f <tvecs+38cf/1ba80>
Trace; c0129418 <try_to_swap_out+178/1e0>
Trace; c012959f <swap_out_vma+11f/190>
Trace; c012964b <swap_out_mm+3b/70>
Trace; c012973e <swap_out+be/110>
Trace; c012980a <do_try_to_free_pages+7a/90>
Trace; c0129895 <kswapd+75/f0>
Trace; c0108df8 <kernel_thread+28/40>
Code;  c012a417 <add_to_swap_cache+47/70>
00000000 <_EIP>:
Code;  c012a417 <add_to_swap_cache+47/70>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c012a419 <add_to_swap_cache+49/70>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c012a41c <add_to_swap_cache+4c/70>
   5:   8d 74 26 00               lea    0x0(%esi,1),%esi
Code;  c012a420 <add_to_swap_cache+50/70>
   9:   8b 44 24 0c               mov    0xc(%esp,1),%eax
Code;  c012a424 <add_to_swap_cache+54/70>
   d:   50                        push   %eax
Code;  c012a425 <add_to_swap_cache+55/70>
   e:   68 10 83 21 c0            push   $0xc0218310
Code;  c012a42a <add_to_swap_cache+5a/70>
  13:   53                        push   %ebx

The second one is the one that I have reported several times to this
list.  It happens just after the first.  It is:

Bad swap file entry 0000bd60
Bad swap file entry 0000bd60
kernel BUG at page_alloc.c:104!
that is: 
	if (page->mapping)
		BUG();
The actual Oops is:

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0129c69>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000020   ebx: c1000290   ecx: c0216a7c   edx: c0216a7c
esi: ffffffff   edi: c59644c0   ebp: 00000000   esp: c3c2df04
ds: 0018   es: 0018   ss: 0018
Process test004 (pid: 4914, stackpage=c3c2d000)
Stack: c01db783 c01dba0f 00000068 c1000290 ffffffff c59644c0 c08d2ae0 c10002b8 
       c10002b8 00000286 00000023 c08d2ae0 c012a5f3 00400000 00000148 c011f381 
       c1000290 c2560980 30000000 40157000 ca985d80 c59644c0 4c000000 000000ec 
Call Trace: [<c01db783>] [<c01dba0f>] [<c012a5f3>] [<c011f381>] [<c012160b>] [<c01216da>] [<c010af4c>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 6c 80 21 c0 69 c0 39 8e e3 

>>EIP; c0129c69 <__free_pages_ok+49/2a0>   <=====
Trace; c01db783 <tvecs+3223/1ba80>
Trace; c01dba0f <tvecs+34af/1ba80>
Trace; c012a5f3 <free_page_and_swap_cache+83/90>
Trace; c011f381 <zap_page_range+171/1f0>
Trace; c012160b <do_munmap+1bb/230>
Trace; c01216da <sys_munmap+5a/b0>
Trace; c010af4c <system_call+34/38>
Code;  c0129c69 <__free_pages_ok+49/2a0>
00000000 <_EIP>:
Code;  c0129c69 <__free_pages_ok+49/2a0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0129c6b <__free_pages_ok+4b/2a0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0129c6e <__free_pages_ok+4e/2a0>
   5:   89 f6                     mov    %esi,%esi
Code;  c0129c70 <__free_pages_ok+50/2a0>
   7:   89 d8                     mov    %ebx,%eax
Code;  c0129c72 <__free_pages_ok+52/2a0>
   9:   2b 05 6c 80 21 c0         sub    0xc021806c,%eax
Code;  c0129c78 <__free_pages_ok+58/2a0>
   f:   69 c0 39 8e e3 00         imul   $0xe38e39,%eax,%eax


If you need more information, let me know.  

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
