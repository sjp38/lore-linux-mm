Subject: Re: [rtf] [patch] 2.3.99-pre6-3 overly swappy
References: <Pine.LNX.4.21.0004202247170.9178-100000@devserv.devel.redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Ben LaHaise's message of "Thu, 20 Apr 2000 22:54:35 -0400 (EDT)"
Date: 21 Apr 2000 19:50:50 +0200
Message-ID: <yttya67uyv9.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

>>>>> "ben" == Ben LaHaise <bcrl@redhat.com> writes:

ben> Ahh, I'd expect this to be the case.  We're both going after the same
ben> problem, by tuning the aggressiveness of the different parts of the vm
ben> code.  Note that the patch I posted earlier is completely broken on
ben> machines that don't have the majority of their memory above 16MB, but it's
ben> atleast giving us a hint about what direction we need to go in.

ben> One of the things that really needs fixing is the allocator's way of
ben> choosing which zone to pressure for memory: most allocators don't care if
ben> it's dma/not memory but the call to try_to_free_pages specifies a zone --
ben> which may be the wrong one. :(

Hi,
        using only Ben patch, I have got the following Oops, the Oops
        happens just after a call to BUG():
                 page_alloc.c::__free_pages_ok(): 110
                        
	if (PageLocked(page))
		BUG();  <- This one

        Following that this Ooops:

        I am using the kernel 2.3.99-pre6-3 plus Ben Patch (I have
        seen only one, I don't know if it is the first or second), the
        headers are:


diff -ur 2.3.99-pre6-3/mm/vmscan.c linux-test/mm/vmscan.c
--- 2.3.99-pre6-3/mm/vmscan.c	Wed Apr 12 14:39:50 2000
+++ linux-test/mm/vmscan.c	Thu Apr 20 15:12:17 2000
@@ -408,7 +408,7 @@


As allways, more information on request, testing offered, ....

Later, Juan.

        
ksymoops 2.3.4 on i686 2.3.99-pre6b.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.3.99-pre6b/ (default)
     -m /boot/System.map-2.3.99-pre6b (default)

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0129bc8>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000020   ebx: c1000320   ecx: 00000020   edx: 00000000
esi: 00000000   edi: c2da2864   ebp: 00000000   esp: c3ebfee8
ds: 0018   es: 0018   ss: 0018
Process test004 (pid: 24141, stackpage=c3ebf000)
Stack: c01dbb2a c01dbdd6 0000006e c1000320 00000000 c2da2864 c715312c 005e9200 
       00000001 c1000320 00000000 c012a417 c012a42d c1000320 c012a4b1 c1000320 
       00400000 000003b5 c011f261 c1000320 cf71c800 8444e000 cdad5e40 03d09000 
Call Trace: [<c01dbb2a>] [<c01dbdd6>] [<c012a417>] [<c012a42d>] [<c012a4b1>] [<c011f261>] [<c0121858>] 
       [<c0114645>] [<c0119f81>] [<c011a21e>] [<c010af4c>] 
Code: 0f 0b 83 c4 0c 8d 76 00 8b 43 18 a8 20 74 19 6a 70 68 d6 bd 

>>EIP; c0129bc8 <__free_pages_ok+b8/2a0>   <=====
Trace; c01dbb2a <tvecs+3442/1c7b8>
Trace; c01dbdd6 <tvecs+36ee/1c7b8>
Trace; c012a417 <delete_from_swap_cache_nolock+67/80>
Trace; c012a42d <delete_from_swap_cache_nolock+7d/80>
Trace; c012a4b1 <free_page_and_swap_cache+51/90>
Trace; c011f261 <zap_page_range+171/1f0>
Trace; c0121858 <exit_mmap+b8/120>
Trace; c0114645 <mmput+15/30>
Trace; c0119f81 <do_exit+c1/350>
Trace; c011a21e <sys_exit+e/10>
Trace; c010af4c <system_call+34/38>
Code;  c0129bc8 <__free_pages_ok+b8/2a0>
00000000 <_EIP>:
Code;  c0129bc8 <__free_pages_ok+b8/2a0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0129bca <__free_pages_ok+ba/2a0>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c0129bcd <__free_pages_ok+bd/2a0>
   5:   8d 76 00                  lea    0x0(%esi),%esi
Code;  c0129bd0 <__free_pages_ok+c0/2a0>
   8:   8b 43 18                  mov    0x18(%ebx),%eax
Code;  c0129bd3 <__free_pages_ok+c3/2a0>
   b:   a8 20                     test   $0x20,%al
Code;  c0129bd5 <__free_pages_ok+c5/2a0>
   d:   74 19                     je     28 <_EIP+0x28> c0129bf0 <__free_pages_ok+e0/2a0>
Code;  c0129bd7 <__free_pages_ok+c7/2a0>
   f:   6a 70                     push   $0x70
Code;  c0129bd9 <__free_pages_ok+c9/2a0>
  11:   68 d6 bd 00 00            push   $0xbdd6


       





-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
