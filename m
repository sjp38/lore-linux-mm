Date: Tue, 25 Oct 2005 10:45:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 5494] New: OOM killer kills process on kernel boot up and
 system performance is very low
Message-Id: <20051025104516.4bd3798c.akpm@osdl.org>
In-Reply-To: <200510251218.j9PCIOoo027509@fire-1.osdl.org>
References: <200510251218.j9PCIOoo027509@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sharyathi@in.ibm.com
Cc: linux-mm@kvack.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@kernel-bugs.osdl.org>
List-ID: <linux-mm.kvack.org>

bugme-daemon@kernel-bugs.osdl.org wrote:
>
>  http://bugzilla.kernel.org/show_bug.cgi?id=5494
> 
>             Summary: OOM killer kills process on kernel boot up and system
>                      performance is very low
>      Kernel Version: 2.6.14-rc4

You have an enormous memory leak.


Active:1452 inactive:929 dirty:3 writeback:717 unstable:0 free:7065 slab:2779 mapped:1356 pagetables:464
DMA free:6160kB min:68kB low:84kB high:100kB active:0kB inactive:2348kB present:16384kB pages_scanned:1o
lowmem_reserve[]: 0 880 1519
Normal free:21604kB min:3756kB low:4692kB high:5632kB active:276kB inactive:188kB present:901120kB pages
lowmem_reserve[]: 0 0 5119
HighMem free:496kB min:512kB low:640kB high:768kB active:5532kB inactive:1052kB present:655296kB pages_s
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 3*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 1*4096kB = 6160kB
Normal: 1*4kB 20*8kB 36*16kB 10*32kB 3*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 4*4096kB = 21604kB
HighMem: 0*4kB 0*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 496kB
Swap cache: add 51244, delete 50404, find 25442/32337, race 0+13

And it's leaking highmem too, so it has to be user memory: pagecache or
anoymous RAM.

I'm not too sure what to do really - something odd is happening because if
this was happening generally then everyone in the world would be reporting
it.

I'd suggest you try switching compiler versions, try disabling unneeded
features in .config, see if you can identify any one which causes the leak.
Ideally, use `git bisect' to identify when the problem started occurring. 

All very strange.

btw, what is this:

Starting readahead:  [  OK  ]

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
