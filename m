Date: Wed, 30 Jul 2008 00:42:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Process invoked oom-killer
Message-Id: <20080730004229.7009d2a8.akpm@linux-foundation.org>
In-Reply-To: <E1KMiXn-000Fpv-00.che_guevara_3-bk-ru@f202.mail.ru>
References: <E1KMiXn-000Fpv-00.che_guevara_3-bk-ru@f202.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ilya Eremin <che_guevara_3@bk.ru>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jul 2008 16:06:39 +0400 Ilya Eremin <che_guevara_3@bk.ru> wrote:

> Hello,
> I am running a server which has more then 100k+ connected users at a time. At a certain point the process crashes with the following in the dmesg:
> 
> [320561.704783] eserver invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0                                                                         

I'm glad we put the kernel version in that message.

> [320561.704833] Pid: 14417, comm: eserver Not tainted 2.6.25-2-686 #1                                                                                        
> [320561.704880]  [<c015ae08>] oom_kill_process+0x4f/0x195                                                                                                    
> [320561.704917]  [<c015b281>] out_of_memory+0x150/0x183                                                                                                      
> [320561.704947]  [<c015cf02>] __alloc_pages+0x245/0x2cb                                                                                                      
> [320561.704982]  [<c015a609>] filemap_fault+0x289/0x36d                                                                                                      
> [320561.705011]  [<c01632fc>] __do_fault+0x59/0x38e                                                                                                          
> [320561.705043]  [<c024bf07>] sys_recvfrom+0xb4/0x116                                                                                                        
> [320561.705078]  [<c024bf57>] sys_recvfrom+0x104/0x116                                                                                                       
> [320561.705108]  [<c016546f>] handle_mm_fault+0x2c5/0x6bb                                                                                                    
> [320561.705141]  [<c02b54a5>] _spin_lock_bh+0x8/0x1e                                                                                                         
> [320561.705169]  [<c0277d78>] tcp_setsockopt+0x303/0x31b                                                                                                     
> [320561.705198]  [<c024c7fd>] sock_common_setsockopt+0x12/0x16                                                                                               
> [320561.705228]  [<c024adb8>] sys_setsockopt+0x6f/0x8e                                                                                                       
> [320561.705261]  [<c024adcc>] sys_setsockopt+0x83/0x8e                                                                                                       
> [320561.705289]  [<c0118b50>] do_page_fault+0x268/0x584                                                                                                      
> [320561.705324]  [<c01188e8>] do_page_fault+0x0/0x584                                                                                                        
> [320561.705351]  [<c02b571a>] error_code+0x72/0x78                                                                                                           
> [320561.705380]  =======================                                                                                                                     
> [320561.705403] Mem-info:                                                                                                                                    
> [320561.707246] DMA per-cpu:                                                                                                                                 
> [320561.707267] CPU    0: hi:    0, btch:   1 usd:   0                                                                                                       
> [320561.707292] CPU    1: hi:    0, btch:   1 usd:   0                                                                                                       
> [320561.707317] CPU    2: hi:    0, btch:   1 usd:   0                                                                                                       
> [320561.707341] CPU    3: hi:    0, btch:   1 usd:   0                                                                                                       
> [320561.707366] Normal per-cpu:                                                                                                                              
> [320561.707388] CPU    0: hi:  186, btch:  31 usd: 146                                                                                                       
> [320561.707417] CPU    1: hi:  186, btch:  31 usd: 176                                                                                                       
> [320561.707442] CPU    2: hi:  186, btch:  31 usd: 141                                                                                                       
> [320561.707473] CPU    3: hi:  186, btch:  31 usd:  88                                                                                                       
> [320561.707498] HighMem per-cpu:                                                                                                                             
> [320561.707520] CPU    0: hi:  186, btch:  31 usd: 176                                                                                                       
> [320561.707545] CPU    1: hi:  186, btch:  31 usd:  56                                                                                                       
> [320561.707569] CPU    2: hi:  186, btch:  31 usd: 165                                                                                                       
> [320561.707594] CPU    3: hi:  186, btch:  31 usd: 166                                                                                                       
> [320561.707620] Active:291911 inactive:10 dirty:0 writeback:0 unstable:0                                                                                     
> [320561.707621]  free:27658 slab:85314 mapped:166 pagetables:371 bounce:0                                                                                    
> [320561.707676] DMA free:9228kB min:1168kB low:1460kB high:1752kB active:3284kB inactive:0kB present:16256kB pages_scanned:10735 all_unreclaimable? yes      
> [320561.707730] lowmem_reserve[]: 0 873 2015 2015                                                                                                            
> [320561.707764] Normal free:100900kB min:64364kB low:80452kB high:96544kB active:6380kB inactive:40kB present:894080kB pages_scanned:17384 all_unreclaimable? yes                                                                                                                                                         
> [320561.707833] lowmem_reserve[]: 0 0 9142 9142                                                                                                              
> [320561.707866] HighMem free:504kB min:512kB low:21572kB high:42632kB active:1157980kB inactive:0kB present:1170180kB pages_scanned:1914062 all_unreclaimable? yes                                                                                                                                                        
> [320561.707935] lowmem_reserve[]: 0 0 0 0                                                                                                                    
> [320561.707966] DMA: 63*4kB 64*8kB 55*16kB 35*32kB 21*64kB 16*128kB 4*256kB 4*512kB 0*1024kB 0*2048kB 0*4096kB = 9228kB                                      
> [320561.708035] Normal: 1239*4kB 10972*8kB 5*16kB 4*32kB 4*64kB 4*128kB 2*256kB 3*512kB 1*1024kB 0*2048kB 1*4096kB = 100876kB                                
> [320561.708110] HighMem: 112*4kB 7*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 504kB                                       
> [320561.708183] 215 total pagecache pages                                                                                                                    
> [320561.708206] Swap cache: add 586318, delete 586318, find 121541/199699                                                                                    
> [320561.708234] Free swap  = 0kB                                                                                                                             
> [320561.708255] Total swap = 0kB                                                                                                                             
> [320561.708276] Free swap:            0kB                                                                                                                    
> [320561.713405] 524224 pages of RAM                                                                                                                          
> [320561.713427] 294848 pages of HIGHMEM                                                                                                                      
> [320561.713450] 5156 reserved pages                                                                                                                          
> [320561.713471] 11607 pages shared                                                                                                                           
> [320561.713493] 0 pages swap cached                                                                                                                          
> [320561.713515] 0 pages dirty                                                                                                                                
> [320561.713535] 0 pages writeback                                                                                                                            
> [320561.713563] 166 pages mapped                                                                                                                             
> [320561.713584] 85314 pages slab                                                                                                                             
> [320561.713605] 371 pages pagetables                                                                                                                         
> [320561.713633] Out of memory: kill process 5310 (sh) score 1037960 or a child                                                                               
> [320561.713670] Killed process 14404 (eserver)                                                                                                               
> [854010.346518] Out of socket memory                                                                                                                         
> [394065.069129] Out of socket memory                                                                                                                         
> [394065.073127] Out of socket memory                                                                                                                         
> [394065.077145] Out of socket memory                                                                                                                         
> [394065.077179] Out of socket memory                                                                                                                         
> [394065.081139] Out of socket memory                                                                                                                         
> [394065.085150] Out of socket memory                                                                                                                         
> [394065.085185] Out of socket memory                                                                                                                         
> [394065.085211] Out of socket memory   

No swapspace available.

Something is using ~350MB of slabcache, which is pretty damn rude. 
Please monitor /proc/slabinfo, find out what that is for us.  But that
isn't the cause of this failure.

All the signs point at all of your memory having been used for anonymous
memory.  ie: the stuff which applications acquire via malloc().

In other words, it looks like a genuine out-of-memory.  Some
application used all the memory up and we can't swap it out so we have
no choice but to declare OOM.

> The server has 2 GB of RAM and I am quiet sure that there's still free RAM when this happenes. It also happenes when swap is enabled (it's disabled in case of this output). The socket memory errors make me think that it's something to do with the TCP stack? Appreciate any help on this issue

What happens when you put some swapspace online?  If that swap just
fills up and then the same thing happens then this would be consistent
with my above observations - you have a leaky application.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
