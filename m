From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 3/3] x86/mm: If INVPCID is available, use it to flush
 global mappings
Date: Fri, 29 Jan 2016 15:26:25 +0100
Message-ID: <20160129142625.GH10187@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org>
 <e3e4f31df42ea5d5e190a6d1e300e01d55e09d79.1453746505.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e3e4f31df42ea5d5e190a6d1e300e01d55e09d79.1453746505.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Mon, Jan 25, 2016 at 10:37:44AM -0800, Andy Lutomirski wrote:
> On my Skylake laptop, INVPCID function 2 (flush absolutely
> everything) takes about 376ns, whereas saving flags, twiddling
> CR4.PGE to flush global mappings, and restoring flags takes about
> 539ns.

FWIW, I ran your microbenchmark on the IVB laptop I have here 3 times
and some of the numbers from each run are pretty unstable. Not that it
means a whole lot - the thing doesn't have INVPCID support.

I'm just questioning the microbenchmark and whether we should be rather
doing those measurements with a real benchmark, whatever that means. My
limited experience says that measuring TLB performance is hard.

 ./context_switch_latency 0 thread same
 use_xstate = 0
 Using threads
1: 100000 iters at 2676.2 ns/switch
2: 100000 iters at 2700.2 ns/switch
3: 100000 iters at 2656.1 ns/switch

 ./context_switch_latency 0 thread different
 use_xstate = 0
 Using threads
1: 100000 iters at 5174.8 ns/switch
2: 100000 iters at 5140.5 ns/switch
3: 100000 iters at 5292.9 ns/switch

 ./context_switch_latency 0 process same
 use_xstate = 0
 Using a subprocess
1: 100000 iters at 2361.2 ns/switch
2: 100000 iters at 2332.2 ns/switch
3: 100000 iters at 3436.9 ns/switch

 ./context_switch_latency 0 process different
 use_xstate = 0
 Using a subprocess
1: 100000 iters at 4713.6 ns/switch
2: 100000 iters at 4957.5 ns/switch
3: 100000 iters at 5012.2 ns/switch

 ./context_switch_latency 1 thread same
 use_xstate = 1
 Using threads
1: 100000 iters at 2505.6 ns/switch
2: 100000 iters at 2483.1 ns/switch
3: 100000 iters at 2479.7 ns/switch

 ./context_switch_latency 1 thread different
 use_xstate = 1
 Using threads
1: 100000 iters at 5245.9 ns/switch
2: 100000 iters at 5241.1 ns/switch
3: 100000 iters at 5220.3 ns/switch

 ./context_switch_latency 1 process same
 use_xstate = 1
 Using a subprocess
1: 100000 iters at 2329.8 ns/switch
2: 100000 iters at 2350.2 ns/switch
3: 100000 iters at 2500.9 ns/switch

 ./context_switch_latency 1 process different
 use_xstate = 1
 Using a subprocess
1: 100000 iters at 4970.7 ns/switch
2: 100000 iters at 5034.0 ns/switch
3: 100000 iters at 4991.6 ns/switch

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
