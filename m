Date: Fri, 22 Sep 2000 18:51:59 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
In-Reply-To: <Pine.LNX.4.21.0009220544590.27435-100000@duckman.distro.conectiva>
Message-ID: <Pine.Linu.4.10.10009221838370.1910-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Sep 2000, Rik van Riel wrote:

> On Fri, 22 Sep 2000, Mike Galbraith wrote:
> 
> > Much more interesting (i hope) is that refill_inactive() _is_
> > present 2923 times, we're oom as heck, and neither shm_swap()
> > nor swap_out() is ever reached in 1048533 lines of trace.  The
> > only way I can see that this can happen is if
> > refill_inactive_scan() eats all count.
> 
> > :-) I'm currently wo^Handering what count is and if I shouldn't try
> > checking nr_inactive_clean_pages() before exiting the loop.
> 
> This means that refill_inactive_scan() has moved
> so many pages to the inactive_dirty/clean list we
> have satisfied both the inactive_target and the
> free_target ...
> 
> Maybe, however, these pages are not freeable and
> page_launder() moves them back to the active list
> and we end up moving pages from one list to another ????

I do have page_launder() failing permanently.  I also (sysrq-m) do
see ;-) list ping-pong being played.  I tried 2.4.0-t9p2-vmpatch and
had locks with no scheduling happening, always looping in swptst task.
Then, I saw the thinko correction and tried that.  I still get lockups,
though now scheduling happens again.  The magnatude of list ping-pong
active->inactive_dirty->active has changed from few pages to thousands
of pages, but inactive_clean stays 0, free stays constant at 350.. box
is as oom as they come.

> With the latest change to get all pages properly
> deactivated when needed, maybe this is possible to
> happen. It /seems/ possible now that I think about
> it, very very unlikely, but possible ;(
> 
> Btw, was there any swap free when you got into
> this situation ?

Yes, the locks always happened (and still do) with swap_used being
some random number always far above zero.

(question:  __get_free_pages below is GFP_USER, is that ok there?)

	-Mike

-----------------------------datapoint---------------------------
dmesg log retrieved after breakout:
...
SysRq: Suspending trace
(that freezes 1000000+ line 334590.00 usec ktrace buffer during lock..
seperated profiles of kswapd and all_others below)
kdb> bt
    EBP       EIP         Function(args)
0xc3053d0c 0xc01355f0 sync_page_buffers+0x3c (0xc6f113e0, 0x2)
0xc3053d30 0xc013571b try_to_free_buffers+0x107 (0xc11d61c4, 0x2)
0xc3053d60 0xc012cde0 page_launder+0x294 (0x5, 0x1)
0xc3053d7c 0xc012d60f do_try_to_free_pages+0x47 (0x5, 0x1)
0xc3053d8c 0xc012d88e try_to_free_pages+0x22 (0x5)
0xc3053dac 0xc012e51a __alloc_pages_wrap+0x1fe (0xc02fe8ac, 0x0, 0xc02fe55c)
0xc3053dc0 0xc012e5d3 __get_free_pages_wrap+0x2f (0x5, 0x0, 0xc02fe55c)
0xc3053de0 0xc012ec1b read_swap_cache_async+0x3f (0x10e000, 0x0)
0xc3053e08 0xc0123f68 swapin_readahead+0x90 (0x10e900)
0xc3053e20 0xc0123fcf do_swap_page+0x2b (0xc712e620, 0xc6e4b9e0, 0x804de40, 0xc3050134, 0x10e900)
0xc3053e58 0xc01243b7 handle_mm_fault+0x19b (0xc712e620, 0xc6e4b9e0, 0x804de40, 0x1)
more> 
0xc3053f0c 0xc0113d21 do_page_fault+0x151 (0xc3053f1c, 0x2, 0x804de40, 0xc02fcc3c, 0x1249)
           0xc010abac error_code+0x2c
Interrupt registers:
eax = 0x00000000 ebx = 0x0804de40 ecx = 0xc02fcc3c edx = 0x00001249 
esi = 0xc0354b40 edi = 0x00000000 esp = 0xc3053f50 eip = 0xc011a2b4 
ebp = 0xc3053f84  ss = 0x00000018  cs = 0x00000010 eflags = 0x00010246 
 ds = 0x00000018  es = 0x00000018 origeax = 0xffffffff &regs = 0xc3053f1c
           0xc011a2b4 do_syslog+0x140 (0x2, 0x804de40, 0x1000)
0xc3053f98 0xc014c0cc kmsg_read+0x1c (0xc30a4740, 0x804de40, 0x1000, 0xc30a4760)
0xc3053fbc 0xc0131e2f sys_read+0x9b (0x0, 0x804de40, 0x1000, 0x400, 0x804ee40)
           0xc010aa84 system_call+0x3c
kdb> bp page_launder+0x700
Instruction(i) BP #0 at 0xc012d24c (page_launder+0x700)
    is enabled globally adjust 1
kdb> go
Instruction(i) breakpoint #0 at 0xc012d24c (adjusted)
0xc012d24c page_launder+0x700:   ret    

Entering kdb (0xc3052000) due to Breakpoint @ 0xc012d24c
kdb> bt
    EBP       EIP         Function(args)
0xc3053d7c 0xc012d24c page_launder+0x700 (0x5, 0x1)
           0xc012d60f do_try_to_free_pages+0x47 (0x5, 0x1)
0xc3053d8c 0xc012d88e try_to_free_pages+0x22 (0x5)
0xc3053dac 0xc012e51a __alloc_pages_wrap+0x1fe (0xc02fe8ac, 0x0, 0xc02fe55c)
0xc3053dc0 0xc012e5d3 __get_free_pages_wrap+0x2f (0x5, 0x0, 0xc02fe55c)
0xc3053de0 0xc012ec1b read_swap_cache_async+0x3f (0x10e000, 0x0)
0xc3053e08 0xc0123f68 swapin_readahead+0x90 (0x10e900)
0xc3053e20 0xc0123fcf do_swap_page+0x2b (0xc712e620, 0xc6e4b9e0, 0x804de40, 0xc3050134, 0x10e900)
0xc3053e58 0xc01243b7 handle_mm_fault+0x19b (0xc712e620, 0xc6e4b9e0, 0x804de40, 0x1)
0xc3053f0c 0xc0113d21 do_page_fault+0x151 (0xc3053f1c, 0x2, 0x804de40, 0xc02fcc3c, 0x1249)
           0xc010abac error_code+0x2c
more> 
Interrupt registers:
eax = 0x00000000 ebx = 0x0804de40 ecx = 0xc02fcc3c edx = 0x00001249 
esi = 0xc0354b40 edi = 0x00000000 esp = 0xc3053f50 eip = 0xc011a2b4 
ebp = 0xc3053f84  ss = 0x00000018  cs = 0x00000010 eflags = 0x00010246 
 ds = 0x00000018  es = 0x00000018 origeax = 0xffffffff &regs = 0xc3053f1c
           0xc011a2b4 do_syslog+0x140 (0x2, 0x804de40, 0x1000)
0xc3053f98 0xc014c0cc kmsg_read+0x1c (0xc30a4740, 0x804de40, 0x1000, 0xc30a4760)
0xc3053fbc 0xc0131e2f sys_read+0x9b (0x0, 0x804de40, 0x1000, 0x400, 0x804ee40)
           0xc010aa84 system_call+0x3c
kdb> rd
eax = 0x00000000 ebx = 0x00000000 ecx = 0x00000001 edx = 0xc11d558c 
esi = 0x00000000 edi = 0x00000005 esp = 0xc3053d64 eip = 0xc012d24c 
ebp = 0xc3053d7c  ss = 0x00000018  cs = 0x00000010 eflags = 0x00000202 
 ds = 0x00000018  es = 0x00000018 origeax = 0xffffffff &regs = 0xc3053d30
kdb> go
Instruction(i) breakpoint #0 at 0xc012d24c (adjusted)
0xc012d24c page_launder+0x700:   ret    

Entering kdb (0xc2d5e000) due to Breakpoint @ 0xc012d24c
kdb> bt
    EBP       EIP         Function(args)
0xc2d5fdb0 0xc012d24c page_launder+0x700 (0x5, 0x1)
           0xc012d60f do_try_to_free_pages+0x47 (0x5, 0x1)
0xc2d5fdc0 0xc012d88e try_to_free_pages+0x22 (0x5)
0xc2d5fde0 0xc012e51a __alloc_pages_wrap+0x1fe (0xc02fe8ac, 0x0, 0xc02fe55c)
0xc2d5fdf4 0xc012e5d3 __get_free_pages_wrap+0x2f (0x5, 0x0, 0xc02fe55c)
0xc2d5fe14 0xc012ec1b read_swap_cache_async+0x3f (0x453100, 0x0)
0xc2d5fe3c 0xc0123f68 swapin_readahead+0x90 (0x453400)
0xc2d5fe54 0xc0123fcf do_swap_page+0x2b (0xc712e6c0, 0xc2f4dee0, 0xbfffe1a8, 0xc2d5aff8, 0x453400)
0xc2d5fe8c 0xc01243b7 handle_mm_fault+0x19b (0xc712e6c0, 0xc2f4dee0, 0xbfffe1a8, 0x1)
0xc2d5ff40 0xc0113d21 do_page_fault+0x151 (0xc2d5ff50, 0x2, 0xc2d5e000, 0xbfffe1a8, 0x0)
           0xc010abac error_code+0x2c
more> 
Interrupt registers:
eax = 0xbfffe1ac ebx = 0xc2d5e000 ecx = 0xbfffe1a8 edx = 0x00000000 
esi = 0x00000000 edi = 0x00000000 esp = 0xc2d5ff84 eip = 0xc0140799 
ebp = 0xc2d5ffbc  ss = 0x00000018  cs = 0x00000010 eflags = 0x00010246 
 ds = 0x00000018  es = 0x00000018 origeax = 0xffffffff &regs = 0xc2d5ff50
           0xc0140799 sys_select+0x395 (0x5, 0xbfffe22c, 0x0, 0x0, 0xbfffe1a8)
           0xc010aa84 system_call+0x3c
kdb> rd
eax = 0x00000000 ebx = 0x00000000 ecx = 0x00000001 edx = 0xc11d558c 
esi = 0x00000000 edi = 0x00000005 esp = 0xc2d5fd98 eip = 0xc012d24c 
ebp = 0xc2d5fdb0  ss = 0x00000018  cs = 0x00000010 eflags = 0x00000202 
 ds = 0x00000018  es = 0x00000018 origeax = 0xffffffff &regs = 0xc2d5fd64
kdb> set LOGGING 0
SysRq: Terminate All Tasks

trimmed profile of kswapd portion of trace:
%TOTAL-TIME  TOTAL-USECS    AVG/CALL    CALLS ADDR     FUNC
  0.0706%          51.40        0.99       52 c01092c3 __switch_to
  0.2707%         197.09        3.79       52 c012b58b kmem_cache_reap
  0.0211%          15.38        0.19       79 c012d3fe inactive_shortage
  0.0216%          15.76        0.12      131 c012d357 free_shortage
  0.0659%          48.01        0.23      210 c012e6fa nr_inactive_clean_pages
  0.1056%          76.88        0.23      341 c012e6b2 nr_free_pages
  0.2061%         150.08        0.32      468 c01355c7 sync_page_buffers
  0.3044%         221.68        0.24      936 c0135627 try_to_free_buffers
  0.3390%         246.86        0.26      936 c012e63d __free_pages
  0.3239%         235.86        0.24      963 c0117fb3 __wake_up
 21.7178%       15813.72        0.20    80467 c012d263 refill_inactive_scan
 24.2149%       17631.96        0.22    81400 c012b95d age_page_down_nolock
 51.7663%       37693.43        0.46    81400 c012b9eb deactivate_page_nolock
Total entries: 248146  Total usecs:     72814.65

trimmed profile of all_others:
%TOTAL-TIME  TOTAL-USECS    AVG/CALL    CALLS ADDR     FUNC
  0.1098%         287.37        7.77       37 c010f2e2 timer_interrupt
  0.0035%           9.26        0.20       46 c010c351 do_IRQ
  0.0104%          27.32        0.59       46 c010e5b1 end_8259A_irq
  0.0111%          29.00        0.63       46 c011dd14 do_softirq
  0.0125%          32.62        0.71       46 c010e631 enable_8259A_irq
  0.0108%          28.20        0.60       47 c010c168 handle_IRQ_event
  0.0163%          42.65        0.91       47 c010c2b7 do_IRQ
  0.0406%         106.41        2.26       47 c010e6e8 mask_and_ack_8259A
  0.1509%         395.04        0.12     3288 c012d453 refill_inactive
  0.1760%         460.79        0.14     3288 c012d3fe inactive_shortage
  0.1849%         483.96        0.15     3288 c01443ef prune_icache
  0.1993%         521.67        0.16     3288 c013577a wakeup_bdflush
  0.2058%         538.68        0.16     3288 c0142ef0 prune_dcache
  0.2582%         675.87        0.21     3288 c01444d9 shrink_icache_memory
  0.2679%         701.22        0.21     3288 c014328d shrink_dcache_memory
  0.2843%         744.17        0.23     3288 c0118bc6 wake_up_process
  0.3264%         854.55        0.26     3288 c014427f dispose_list
  1.0448%        2734.97        0.83     3288 c0143f74 sync_all_inodes
  0.1619%         423.73        0.13     3289 c012d879 try_to_free_pages
  0.1885%         493.39        0.15     3289 c012d5d8 do_try_to_free_pages
  0.2297%         601.39        0.18     3289 c012d7b2 wakeup_kswapd
  0.4406%        1153.40        0.35     3289 c012cb5f page_launder
  0.2189%         572.93        0.17     3314 c013581f flush_dirty_buffers
  0.5468%        1431.39        0.43     3315 c0117a07 reschedule_idle
  0.3532%         924.58        0.14     6576 c012adca kmem_cache_shrink
  0.7292%        1908.83        0.29     6576 c012ad72 __kmem_cache_shrink
  1.5872%        4154.79        0.63     6576 c012ad12 is_chained_kmem_cache
  6.2938%       16475.60        2.51     6577 c012b58b kmem_cache_reap
  1.2516%        3276.47        0.50     6603 c01092c3 __switch_to
  2.4868%        6509.88        0.98     6655 c0117ba3 schedule
  0.9808%        2567.60        0.26     9867 c012e26c __alloc_pages_limit_wrap
  0.6042%        1581.76        0.12    13153 c012d357 free_shortage
  1.3030%        3410.99        0.17    19755 c012e6fa nr_inactive_clean_pages
  2.3829%        6237.93        0.19    32908 c012e6b2 nr_free_pages
  4.3462%       11377.38        0.22    52624 c012d263 refill_inactive_scan
  4.6854%       12265.25        0.23    52767 c012b95d age_page_down_nolock
 10.7973%       28264.67        0.54    52767 c012b9eb deactivate_page_nolock
 13.1619%       34454.59        0.31   111792 c01355c7 sync_page_buffers
 11.2581%       29470.95        0.25   118370 c0135627 try_to_free_buffers
 20.5987%       53922.25        0.46   118370 c012e63d __free_pages
 11.7535%       30767.65        0.25   124974 c0117fb3 __wake_up
Total entries: 800409  Total usecs:    261775.35

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
