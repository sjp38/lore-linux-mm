Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
References: <Pine.LNX.4.21.0005030004330.1677-100000@alpha.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Wed, 3 May 2000 00:08:11 +0200 (CEST)"
Date: 03 May 2000 01:58:30 +0200
Message-ID: <yttvh0wy061.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Hi Andrea

andrea> On 2 May 2000, Juan J. Quintela wrote:
>> swap_entry bit, but not agreement in which is the correct one.

andrea> My latest one is the correct one but I would also use the atomic operation
andrea> in shrink_mmap even if we hold the page lock to be fully safe. I have an
andrea> assert that BUG if a page is freed with such bit set and it never triggers
andrea> since I noticed the few problematic places thanks to Ben.
[...]
andrea> Are you sure it solves the problem? Could you try also the other patch I
andrea> sent you in the email of 1 minute ago? that should be even more effective.

Hi,
        I have just tested 4 changes against 2.3.99-pre7-1:
        (I use also Rik semicolon patch and Al Viro mount-7-1-B
        patch).  The test is:
                 while (true); do time ./mmap002; done

1- I tested without any more patches, it Oops in
   page_alloc.c:__free_pages_ok(): I got a lot of kernel BUG at
   page_alloc.c:104! and one page_alloc.c:102.  This is in the second
   iteration. See the Oops attached.


2- I tested with Andrea patch, make in acquire_swap_entry to always
   allocate a new swap_entry, i.e. Don't use the PG_swap_entry
   information.  No problems after 18 iterations.

3- I tested with my patch (never set the PG_swap_entry bit).  No
   problem after 16 iterations.

4- I added a test in __free_pages_ok, checking for the PG_swap_entry
   bit.

--- testing/mm/page_alloc.c     Mon May  1 18:34:49 2000
+++ pre7-1plus/mm/page_alloc.c  Wed May  3 01:06:26 2000
@@ -110,6 +110,8 @@
                BUG();
        if (PageDecrAfter(page))
                BUG();
+       if (PageSwapEntry(page))
+               BUG();
 
        zone = page->zone;

this kernel BUG() in the first iteration.  And it does in this new
check.  See the attached Oops reports.

If you need any more information, some more test, let me know.

Later, Juan.

PD. There are 4 identicals machines, K6-2 266Mhz, 96MB RAM, headless,
    and  the only proccess running was that one (except system daemons
    and similars).


1st test. Normal kernel.
invalid operand: 0000
CPU:    0
EIP:    0010:[<c0127029>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000020   ebx: c1000128   ecx: 00000017   edx: 00000000
esi: c1000128   edi: c12f8538   ebp: 00000000   esp: c5fd7ed4
ds: 0018   es: 0018   ss: 0018
Process kswapd (pid: 2, stackpage=c5fd7000)
Stack: c01d02a4 c01d05b2 00000068 c5f96c20 c1000128 c12f8538 c545e240 40c00000 
       41000000 00000004 00000018 00000018 c0126645 4c14f000 c12f8538 4c0b3000 
       4c400000 00043e00 c0126894 c5f96c20 c545e240 4c14e000 c12f8538 00000004 
Call Trace: [<c01d02a4>] [<c01d05b2>] [<c0126645>] [<c0126894>] [<c012695c>] [<c
0126af5>] [<c0126bca>] 
       [<c0126c7a>] [<c0108cc4>] 
Code: 0f 0b 83 c4 0c 89 f6 89 d8 2b 05 6c b9 20 c0 69 c0 39 8e e3 

>>EIP; c0127029 <__free_pages_ok+49/298>   <=====
Trace; c01d02a4 <tvecs+3600/1b87c>
Trace; c01d05b2 <tvecs+390e/1b87c>
Trace; c0126645 <try_to_swap_out+c5/1f4>
Trace; c0126894 <swap_out_vma+120/1ac>
Trace; c012695c <swap_out_mm+3c/68>
Trace; c0126af5 <swap_out+16d/1c0>
Trace; c0126bca <do_try_to_free_pages+82/98>
Trace; c0126c7a <kswapd+9a/11c>
Trace; c0108cc4 <kernel_thread+28/38>
Code;  c0127029 <__free_pages_ok+49/298>
00000000 <_EIP>:
Code;  c0127029 <__free_pages_ok+49/298>   <=====
   0:   0f 0b             ud2a      <=====
Code;  c012702b <__free_pages_ok+4b/298>
   2:   83 c4 0c          addl   $0xc,%esp
Code;  c012702e <__free_pages_ok+4e/298>
   5:   89 f6             movl   %esi,%esi
Code;  c0127030 <__free_pages_ok+50/298>
   7:   89 d8             movl   %ebx,%eax
Code;  c0127032 <__free_pages_ok+52/298>
   9:   2b 05 6c b9 20    subl   0xc020b96c,%eax
Code;  c0127037 <__free_pages_ok+57/298>
   e:   c0 
Code;  c0127038 <__free_pages_ok+58/298>
   f:   69 c0 39 8e e3    imull  $0xe38e39,%eax,%eax
Code;  c012703d <__free_pages_ok+5d/298>
  14:   00 

For the next Oops I put only the traces, if you need more information,
let me know.

>>EIP; c0127029 <__free_pages_ok+49/298>   <=====
Trace; c01d02a4 <tvecs+3600/1b87c>
Trace; c01d05b2 <tvecs+390e/1b87c>
Trace; c011f7ec <shrink_mmap+1b8/2a4>
Trace; c0126b7b <do_try_to_free_pages+33/98>
Trace; c0126d20 <try_to_free_pages+24/34>
Trace; c01274f0 <zone_balance_memory+60/94>
Trace; c01275d1 <__alloc_pages+ad/e0>
Trace; c011dbec <do_anonymous_page+64/e0>
Trace; c011dc98 <do_no_page+30/b0>
Trace; c011de00 <handle_mm_fault+e8/154>
Trace; c01108b7 <do_page_fault+187/4c0>
Trace; c01185e4 <it_real_fn+0/44>
Trace; c011bc27 <update_process_times+5f/68>
Trace; c011bd02 <timer_bh+a2/288>
Trace; c0119133 <bh_action+1b/5c>
Trace; c0119087 <tasklet_hi_action+37/60>
Trace; c0118f82 <do_softirq+52/78>
Trace; c010bd2a <do_IRQ+a2/b8>
Trace; c010ae4d <error_code+2d/40>

Other:
>>EIP; c0127029 <__free_pages_ok+49/298>   <=====
Trace; c01d02a4 <tvecs+3600/1b87c>
Trace; c01d05b2 <tvecs+390e/1b87c>
Trace; c01265de <try_to_swap_out+5e/1f4>
Trace; c0126645 <try_to_swap_out+c5/1f4>
Trace; c0126894 <swap_out_vma+120/1ac>
Trace; c012695c <swap_out_mm+3c/68>
Trace; c0126af5 <swap_out+16d/1c0>
Trace; c0126bca <do_try_to_free_pages+82/98>
Trace; c0126d20 <try_to_free_pages+24/34>
Trace; c01274f0 <zone_balance_memory+60/94>
Trace; c01275d1 <__alloc_pages+ad/e0>
Trace; c0125334 <kmem_cache_grow+10c/404>
Trace; c012580d <kmem_cache_alloc+169/1c4>
Trace; c012c7dd <get_unused_buffer_head+39/b8>
Trace; c012c8dc <create_buffers+20/310>
Trace; c012cda7 <create_empty_buffers+17/70>
Trace; c012d26f <block_read_full_page+63/220>
Trace; c011fc1b <add_to_page_cache_unique+cf/13c>
Trace; c0143c9e <ext2_readpage+e/14>
Trace; c0143600 <ext2_get_block+0/490>
Trace; c011fd70 <read_cluster_nonblocking+e8/140>
Trace; c0121247 <filemap_nopage+1a7/390>
Trace; c011dcb5 <do_no_page+4d/b0>
Trace; c011de00 <handle_mm_fault+e8/154>
Trace; c01108b7 <do_page_fault+187/4c0>
Trace; c011bc27 <update_process_times+5f/68>
Trace; c011bd02 <timer_bh+a2/288>
Trace; c0119133 <bh_action+1b/5c>
Trace; c0119087 <tasklet_hi_action+37/60>
Trace; c011296a <schedule+266/3d8>
Trace; c010ae4d <error_code+2d/40>


Now the Oops for the 4th test:

kernel BUG at page_alloc.c:114!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c01270d9>]
EFLAGS: 00010286
invalid operand: 0000
CPU:    0
EIP:    0010:[<c01270d9>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000020   ebx: c1137c48   ecx: 0000003b   edx: c5f96c20
esi: c1137c48   edi: c541dd74   ebp: 00000000   esp: c541dd1c
ds: 0018   es: 0018   ss: 0018
Process mmap002 (pid: 264, stackpage=c541d000)
Stack: c01d02c4 c01d05d2 00000072 c1137c64 c1137c48 c541dd74 00000570 c1137c70 
       c1137c70 00000286 00000023 00000570 c011f859 0000001e 00000002 00000003 
       c020bd4c c541dd7c c541dd74 00000000 c541dd6c c541dd6c c11a9c04 c11ae8cc 
Call Trace: [<c01d02c4>] [<c01d05d2>] [<c011f859>] [<c0126b7b>] [<c0126d20>] [<c
0127510>] [<c01275f1>] 
       [<c0125334>] [<c012c403>] [<c012580d>] [<c012c7fd>] [<c012c8fc>] [<c012cd
c7>] [<c012cea1>] [<c012d795>] 
       [<c0143620>] [<c0143caa>] [<c0143620>] [<c0121458>] [<c0121710>] [<c01218
7a>] [<c012199f>] [<c010ad14>] 
Code: 0f 0b 83 c4 0c 89 f6 8b 73 44 8b 15 8c b9 20 c0 c7 44 24 1c 

>>EIP; c01270d9 <__free_pages_ok+f9/2b8>   <=====
Trace; c01d02c4 <tvecs+3600/1b87c>
Trace; c01d05d2 <tvecs+390e/1b87c>
Trace; c011f859 <shrink_mmap+225/2a4>
Trace; c0126b7b <do_try_to_free_pages+33/98>
Trace; c0126d20 <try_to_free_pages+24/34>
Trace; c0127510 <zone_balance_memory+60/94>
Trace; c01275f1 <__alloc_pages+ad/e0>
Trace; c0125334 <kmem_cache_grow+10c/404>
Trace; c012c403 <getblk+1b/90>
Trace; c012580d <kmem_cache_alloc+169/1c4>
Trace; c012c7fd <get_unused_buffer_head+39/b8>
Trace; c012c8fc <create_buffers+20/310>
Trace; c012cdc7 <create_empty_buffers+17/70>
Trace; c012cea1 <__block_write_full_page+4d/110>
Trace; c012d795 <block_write_full_page+3d/100>
Trace; c0143620 <ext2_get_block+0/490>
Trace; c0143caa <ext2_writepage+e/14>
Trace; c0143620 <ext2_get_block+0/490>
Trace; c0121458 <filemap_write_page+28/48>
Trace; c0121710 <filemap_sync+274/318>
Trace; c012187a <msync_interval+2e/6c>
Trace; c012199f <sys_msync+e7/16c>
Trace; c010ad14 <system_call+34/40>
Code;  c01270d9 <__free_pages_ok+f9/2b8>
00000000 <_EIP>:
Code;  c01270d9 <__free_pages_ok+f9/2b8>   <=====
   0:   0f 0b             ud2a      <=====
Code;  c01270db <__free_pages_ok+fb/2b8>
   2:   83 c4 0c          addl   $0xc,%esp
Code;  c01270de <__free_pages_ok+fe/2b8>
   5:   89 f6             movl   %esi,%esi
Code;  c01270e0 <__free_pages_ok+100/2b8>
   7:   8b 73 44          movl   0x44(%ebx),%esi
Code;  c01270e3 <__free_pages_ok+103/2b8>
   a:   8b 15 8c b9 20    movl   0xc020b98c,%edx
Code;  c01270e8 <__free_pages_ok+108/2b8>
   f:   c0 
Code;  c01270e9 <__free_pages_ok+109/2b8>
  10:   c7 44 24 1c 00    movl   $0x0,0x1c(%esp,1)
Code;  c01270ee <__free_pages_ok+10e/2b8>
  15:   00 00 00 

For the nexts Oops, only the traces also:
>>EIP; c01270d9 <__free_pages_ok+f9/2b8>   <=====
Trace; c01d02c4 <tvecs+3600/1b87c>
Trace; c01d05d2 <tvecs+390e/1b87c>
Trace; c011f859 <shrink_mmap+225/2a4>
Trace; c0126b7b <do_try_to_free_pages+33/98>
Trace; c0126d20 <try_to_free_pages+24/34>
Trace; c0127510 <zone_balance_memory+60/94>
Trace; c01275f1 <__alloc_pages+ad/e0>
Trace; c013924c <alloc_wait+3c/15c>
Trace; c01396a1 <do_select+4d/25c>
Trace; c0139c22 <sys_select+372/488>
Trace; c010ad14 <system_call+34/40>

and another one:

>>EIP; c01270d9 <__free_pages_ok+f9/2b8>   <=====
Trace; c01d02c4 <tvecs+3600/1b87c>
Trace; c01d05d2 <tvecs+390e/1b87c>
Trace; c011f859 <shrink_mmap+225/2a4>
Trace; c0126b7b <do_try_to_free_pages+33/98>
Trace; c0126c7a <kswapd+9a/11c>
Trace; c0108cc4 <kernel_thread+28/38>


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
