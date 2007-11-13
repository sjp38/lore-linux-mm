Date: Tue, 13 Nov 2007 03:55:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Vmstat: Small revisions to refresh_cpu_vm_stats()
Message-Id: <20071113035509.5d221318.akpm@linux-foundation.org>
In-Reply-To: <20071113.034737.199780122.davem@davemloft.net>
References: <Pine.LNX.4.64.0711091837390.18567@schroedinger.engr.sgi.com>
	<20071113033755.c2e64c09.akpm@linux-foundation.org>
	<20071113.034737.199780122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007 03:47:37 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 13 Nov 2007 03:37:55 -0800
> 
> > : undefined reference to `__xchg_called_with_bad_pointer'
> > 
> > This is sparc64's way of telling you that you can'd do xchg on an s8.
> > 
> > Dave, is that fixable?
> > 
> > I assume not, in which case we either go for some open-coded implementation
> > for 8- and 16-bits or we should ban (at compile time) 8- and 16-bit xchg on
> > all architectures.
> 
> Right, let's write some generic code for this because other platforms
> are going to need this too.

ok.  I guess if x86 can do it in hardware then it's worthwhile.

> Basically, do a normal "ll/sc" or "load/cas" sequence on a u32 with
> some shifting and masking as needed.
> 
> 	int shift = (((unsigned long) addr) % 4) * 8;
> 	unsigned long mask = 0xff << shift;
> 	unsigned long val = newval << shift;
> 	u32 *ptr = (u32 *) ((unsigned long)addr & ~0x3UL);
> 
> 	while (1) {
> 		u32 orig, tmp = *ptr;
> 
> 		orig = tmp;
> 		tmp &= ~mask;
> 		tmp |= val;
> 		cmpxchg_u32(ptr, orig, tmp);
> 		if (orig == tmp)
> 			break;
> 	}
> 
> Repeat for u16, etc.
> 
> However, for platforms like sparc32 that can do a xchg() atomically
> but can't do cmpxchg, this idea won't work :-/

xchg() is nonatomic wrt other CPUs, so I think we can get by with
local_irq_save()/swap()/local_irq_restore().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
