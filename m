Subject: Re: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <1029794688.14756.353.camel@spc9.esa.lanl.gov>
References: <1029790457.14756.342.camel@spc9.esa.lanl.gov>
	<3D61615C.451C2B44@zip.com.au>
	<1029794688.14756.353.camel@spc9.esa.lanl.gov>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 20 Aug 2002 07:39:43 -0600
Message-Id: <1029850784.2045.363.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Mon, 2002-08-19 at 16:04, Steven Cole wrote:
> On Mon, 2002-08-19 at 15:21, Andrew Morton wrote:
> > Steven Cole wrote:
> > > 
> > > Here's a new one.
> > > 
> > > With this patch applied to 2.5.31,
> > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz
> > > 
[earlier problem snipped]
> 
> [patch snipped]
> 
> Patch applied, running dbench 1..128.  Up to 52 clients so far, and no
> blam yet.  I'll run this test several times overnight and let you know
> if anything else falls out.

Something else fell out.  I got kernel BUG at page_alloc.c:98! three
times.  I ran the output of dmesg through ksymoops, and here is the
result. The traceback for the third occurance was identical to that of
the first, so that was snipped.

Steven

ksymoops 2.4.4 on i686 2.5.31.  Options used
     -v linux-2.5.31-akpm/vmlinux (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m linux-2.5.31-akpm/System.map (specified)

kernel BUG at page_alloc.c:98!
invalid operand: 0000
CPU:    1
EIP:    0010:[<c0132733>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: f78b4fe0   ebx: c19bf730   ecx: 00000000   edx: 00000000
esi: d9f03e70   edi: 00000005   ebp: 00000010   esp: d9f03e14
ds: 0018   es: 0018   ss: 0018
Stack: 00007ff0 c100001c c1a79c88 c19a001c c02a710c 00000203 fffffffe 000013cc 
       00000000 00000001 d9f03e70 00000005 00000010 c013315a c1926414 00000002 
       c0131059 d9f03e6c f7944c2b f7944ce0 f72a6ac0 00000000 00000002 c19d69ec 
Call Trace: [<c013315a>] [<c0131059>] [<c0134190>] [<c0134355>] [<c0129ff1>] 
   [<c0115cd0>] [<c0117ab8>] [<c011adbf>] [<c0115c75>] [<c0108ce3>] 
Code: 0f 0b 62 00 a5 f7 26 c0 8b 03 ba 04 00 00 00 83 e0 10 74 1d 

>>EIP; c0132733 <__free_pages_ok+93/310>   <=====
Trace; c013315a <__pagevec_free+1a/20>
Trace; c0131059 <__pagevec_release+f9/110>
Trace; c0134190 <swap_free+20/40>
Trace; c0134355 <remove_exclusive_swap_page+d5/110>
Trace; c0129ff1 <exit_mmap+1a1/280>
Trace; c0115cd0 <default_wake_function+0/40>
Trace; c0117ab8 <mmput+48/70>
Trace; c011adbf <do_exit+df/2c0>
Trace; c0115c75 <schedule+325/380>
Trace; c0108ce3 <syscall_call+7/b>
Code;  c0132733 <__free_pages_ok+93/310>
00000000 <_EIP>:
Code;  c0132733 <__free_pages_ok+93/310>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0132735 <__free_pages_ok+95/310>
   2:   62 00                     bound  %eax,(%eax)
Code;  c0132737 <__free_pages_ok+97/310>
   4:   a5                        movsl  %ds:(%esi),%es:(%edi)
Code;  c0132738 <__free_pages_ok+98/310>
   5:   f7 26                     mull   (%esi)
Code;  c013273a <__free_pages_ok+9a/310>
   7:   c0 8b 03 ba 04 00 00      rorb   $0x0,0x4ba03(%ebx)
Code;  c0132741 <__free_pages_ok+a1/310>
   e:   00 83 e0 10 74 1d         add    %al,0x1d7410e0(%ebx)

 kernel BUG at page_alloc.c:98!
invalid operand: 0000
CPU:    1
EIP:    0010:[<c0132733>]    Not tainted
EFLAGS: 00010286
eax: f7933860   ebx: c1a308dc   ecx: 00000000   edx: 00000000
esi: e841fde0   edi: 00000005   ebp: 00000010   esp: e841fd84
ds: 0018   es: 0018   ss: 0018
Stack: c74cf1a0 c0308e40 c1b1e120 c19a001c c02a7100 00000202 ffffffff 0000289e 
       00000000 00000000 e841fde0 00000005 00000010 c013315a c1a812c8 00000010 
       c0131059 e841fddc dd0e2904 c0173df6 c013e3db de4ce960 00000010 c1a308dc 
Call Trace: [<c013315a>] [<c0131059>] [<c0173df6>] [<c013e3db>] [<c012a32f>] 
   [<c012a783>] [<c016c6a9>] [<c016c701>] [<c012a90d>] [<c015242d>] [<c015268d>] 
   [<c0150f46>] [<c014719d>] [<c0149723>] [<c01482e2>] [<c01497c9>] [<c013c89d>] 
   [<c0108ce3>] 
Code: 0f 0b 62 00 a5 f7 26 c0 8b 03 ba 04 00 00 00 83 e0 10 74 1d 

>>EIP; c0132733 <__free_pages_ok+93/310>   <=====
Trace; c013315a <__pagevec_free+1a/20>
Trace; c0131059 <__pagevec_release+f9/110>
Trace; c0173df6 <journal_unmap_buffer+106/190>
Trace; c013e3db <wake_up_buffer+b/30>
Trace; c012a32f <remove_from_page_cache+2f/40>
Trace; c012a783 <truncate_list_pages+2b3/350>
Trace; c016c6a9 <ext3_do_update_inode+2c9/350>
Trace; c016c701 <ext3_do_update_inode+321/350>
Trace; c012a90d <truncate_inode_pages+8d/d0>
Trace; c015242d <generic_delete_inode+5d/140>
Trace; c015268d <iput+5d/60>
Trace; c0150f46 <d_delete+66/c0>
Trace; c014719d <permission+3d/50>
Trace; c0149723 <vfs_unlink+1b3/1d0>
Trace; c01482e2 <lookup_hash+42/90>
Trace; c01497c9 <sys_unlink+89/f0>
Trace; c013c89d <sys_close+5d/70>
Trace; c0108ce3 <syscall_call+7/b>
Code;  c0132733 <__free_pages_ok+93/310>
00000000 <_EIP>:
Code;  c0132733 <__free_pages_ok+93/310>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0132735 <__free_pages_ok+95/310>
   2:   62 00                     bound  %eax,(%eax)
Code;  c0132737 <__free_pages_ok+97/310>
   4:   a5                        movsl  %ds:(%esi),%es:(%edi)
Code;  c0132738 <__free_pages_ok+98/310>
   5:   f7 26                     mull   (%esi)
Code;  c013273a <__free_pages_ok+9a/310>
   7:   c0 8b 03 ba 04 00 00      rorb   $0x0,0x4ba03(%ebx)
Code;  c0132741 <__free_pages_ok+a1/310>
   e:   00 83 e0 10 74 1d         add    %al,0x1d7410e0(%ebx)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
