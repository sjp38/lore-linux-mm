Date: Tue, 13 Mar 2007 16:14:35 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
Message-ID: <20070313211435.GP10394@waste.org>
References: <20070313200313.GG10459@waste.org> <45F706BC.7060407@goop.org> <20070313202125.GO10394@waste.org> <20070313.140722.72711732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070313.140722.72711732.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeremy@goop.org, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 13, 2007 at 02:07:22PM -0700, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Tue, 13 Mar 2007 15:21:25 -0500
> 
> > Because the fan-out is large, the bulk of the work is bringing the last
> > layer of the tree into cache to find all the pages in the address
> > space. And there's really no way around that.
> 
> That's right.
> 
> And I will note that historically we used to be much worse
> in this area, as we used to walk the page table tree twice
> on address space teardown (once to hit the PTE entries, once
> to free the page tables).
> 
> Happily it is a one-pass algorithm now.
> 
> But, within active VMA ranges, we do have to walk all
> the bits at least one time.

Well you -could- do this:

- reuse a long in struct page as a used map that divides the page up
  into 32 or 64 segments
- every time you set a PTE, set the corresponding bit in the mask
- when we zap, only visit the regions set in the mask

Thus, you avoid visiting most of a PMD page in the sparse case,
assuming PTEs aren't evenly spread across the PMD.

This might not even be too horrible as the appropriate struct page
should be in cache with the appropriate bits of the mm already locked,
etc.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
