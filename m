Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
References: <Pine.LNX.4.10.10005021342380.11153-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Tue, 2 May 2000 13:43:36 -0700 (PDT)"
Date: 02 May 2000 23:31:23 +0200
Message-ID: <ytt4s8g1vx0.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

>> several people have reported Oops in __free_pages_ok, after a
>> BUG() in page_alloc.h.  This happens in 2.3.99-pre[67].  The BUGs are:

linus> I'd like ot know what the back-trace for those reports are? 

I have attached two traces to this mail. I have more if you need them,
basically it always bug in the code: page_alloc.c:__free_page_ok

	if (page->buffers)
/*102*/		BUG();
	if (page->mapping)
/*104*/		BUG();

The BUG in 104 is easy to trigger. The other one is less frequent,
doesn't happen in all the tries.

<self package advertising> 
I can reproduce this BUGs easily with the mmap002 program from the
memtest-0.0.3 suite (http://carpanta.dc.fi.udc.es/~quintela/memtest/).
You need to change the #define RAMSIZE to reflect your memory size in
include file misc_lib.h and you run it in one while(true); do
./mmap002; done and in the 8th, 9th execution it Oops here also.
</self package advertising>

I have more Oops traces, if you want more of them let me know.

linus> I'm not against getting rid of the PageSwapEntry logic (it's complication
linus> for not very much gain), but I'd like to understand this more..

If you want the patch for get rid of PG_swap_entry, I can do it and send it to
you.

Later, Juan.


        kernel BUG at page_alloc.c:102!
        kernel BUG at page_alloc.c:104!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c0125e0d>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000020   ebx: 00004883   ecx: 00000019   edx: 00000000
esi: c1000128   edi: 00000000   ebp: c5464d20   esp: c5fd7ed4
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c5fd7000)
Stack: c01cb662 c01cb950 00000066 00004883 c1000128 c26ef6d8 c5464d20 00066400 
       c10eec40 c0125512 00000001 c10eec40 c0125421 4c1b7000 c26ef6d8 4c0b3000 
       4c400000 00066400 c0125664 c5f95e00 c5464d20 4c1b6000 c26ef6d8 00000004 
Call Trace: [<c01cb662>] [<c01cb950>] [<c0125512>] [<c0125421>] [<c0125664>] [<c
012572d>] [<c01258c5>] 
       [<c012599a>] [<c0125a5d>] [<c0107474>] 
Code: 0f 0b 83 c4 0c 83 7e 08 00 74 18 6a 68 68 50 b9 1c c0 68 62 
>>EIP; c0125e0d <__free_pages_ok+2d/2fc>   <=====
Trace; c01cb662 <tvecs+3462/1ade0>
Trace; c01cb950 <tvecs+3750/1ade0>
Trace; c0125512 <try_to_swap_out+1d2/204>
Trace; c0125421 <try_to_swap_out+e1/204>
Trace; c0125664 <swap_out_vma+120/1b0>
Trace; c012572d <swap_out_mm+39/64>
Trace; c01258c5 <swap_out+16d/1c0>
Trace; c012599a <do_try_to_free_pages+82/9c>
Trace; c0125a5d <kswapd+a9/12c>
Trace; c0107474 <kernel_thread+28/38>
Code;  c0125e0d <__free_pages_ok+2d/2fc>
00000000 <_EIP>:
Code;  c0125e0d <__free_pages_ok+2d/2fc>   <=====
   0:   0f 0b             ud2a      <=====
Code;  c0125e0f <__free_pages_ok+2f/2fc>
   2:   83 c4 0c          addl   $0xc,%esp
Code;  c0125e12 <__free_pages_ok+32/2fc>
   5:   83 7e 08 00       cmpl   $0x0,0x8(%esi)
Code;  c0125e16 <__free_pages_ok+36/2fc>
   9:   74 18             je     23 <_EIP+0x23> c0125e30 <__free_pages_ok+50/2fc
>
Code;  c0125e18 <__free_pages_ok+38/2fc>
   b:   6a 68             pushl  $0x68
Code;  c0125e1a <__free_pages_ok+3a/2fc>
   d:   68 50 b9 1c c0    pushl  $0xc01cb950
Code;  c0125e1f <__free_pages_ok+3f/2fc>
  12:   68 62 00 00 00    pushl  $0x62

and the second one:

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0125e29>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000020   ebx: c1000144   ecx: 0000001b   edx: c5f95e00
esi: c1000128   edi: 00000000   ebp: c4be6980   esp: c4cb9d84
ds: 0018   es: 0018   ss: 0018
Process mmap002 (pid: 389, stackpage=c4cb9000)
Stack: c01cb662 c01cb950 00000068 c1000144 c4be6800 c4be6980 c4be6980 c0206ba4 
       c0206ba4 00000286 00000023 c4be6980 c012d317 c1000144 c1000128 c4cb9df8 
       0000007f 00000001 c011e3e7 c1000128 00000020 00000006 00000005 c0204cec 
Call Trace: [<c01cb662>] [<c01cb950>] [<c012d317>] [<c011e3e7>] [<c012594b>] [<c
0125b05>] [<c01263cc>] 
       [<c01264a4>] [<c011e9f0>] [<c011ff27>] [<c011c935>] [<c011caa0>] [<c010f1
f7>] [<c011a78a>] [<c011a891>] 
       [<c0117bd3>] [<c0117b28>] [<c0117a22>] [<c010a555>] [<c010964d>] 
Code: 0f 0b 83 c4 0c 89 f6 89 f1 2b 0d 2c 49 20 c0 8d 14 cd 00 00 


>>EIP; c0125e29 <__free_pages_ok+49/2fc>   <=====
Trace; c01cb662 <tvecs+3462/1ade0>
Trace; c01cb950 <tvecs+3750/1ade0>
Trace; c012d317 <try_to_free_buffers+11b/13c>
Trace; c011e3e7 <shrink_mmap+ff/2a0>
Trace; c012594b <do_try_to_free_pages+33/9c>
Trace; c0125b05 <try_to_free_pages+25/30>
Trace; c01263cc <zone_balance_memory+5c/8c>
Trace; c01264a4 <__alloc_pages+a8/dc>
Trace; c011e9f0 <read_cluster_nonblocking+b8/140>
Trace; c011ff27 <filemap_nopage+1a7/3ac>
Trace; c011c935 <do_no_page+4d/d0>
Trace; c011caa0 <handle_mm_fault+e8/154>
Trace; c010f1f7 <do_page_fault+187/4d0>
Trace; c011a78a <update_process_times+5a/60>
Trace; c011a891 <timer_bh+cd/2b4>
Trace; c0117bd3 <bh_action+1b/5c>
Trace; c0117b28 <tasklet_hi_action+38/60>
Trace; c0117a22 <do_softirq+52/78>
Trace; c010a555 <do_IRQ+a5/b4>
Trace; c010964d <error_code+2d/40>
Code;  c0125e29 <__free_pages_ok+49/2fc>
00000000 <_EIP>:
Code;  c0125e29 <__free_pages_ok+49/2fc>   <=====
   0:   0f 0b             ud2a      <=====
Code;  c0125e2b <__free_pages_ok+4b/2fc>
   2:   83 c4 0c          addl   $0xc,%esp
Code;  c0125e2e <__free_pages_ok+4e/2fc>
   5:   89 f6             movl   %esi,%esi
Code;  c0125e30 <__free_pages_ok+50/2fc>
   7:   89 f1             movl   %esi,%ecx
Code;  c0125e32 <__free_pages_ok+52/2fc>
   9:   2b 0d 2c 49 20    subl   0xc020492c,%ecx
Code;  c0125e37 <__free_pages_ok+57/2fc>
   e:   c0 
Code;  c0125e38 <__free_pages_ok+58/2fc>
   f:   8d 14 cd 00 00    leal   0x0(,%ecx,8),%edx
Code;  c0125e3d <__free_pages_ok+5d/2fc>
  14:   00 00 







-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
