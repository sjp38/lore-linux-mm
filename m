Date: Sun, 4 Apr 2004 01:27:17 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040403232717.GO2307@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040402104334.A871@infradead.org> <20040402164634.GF21341@dualathlon.random> <20040403174043.GK2307@dualathlon.random> <20040403120227.398268aa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040403120227.398268aa.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hch@infradead.org, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 03, 2004 at 12:02:27PM -0800, Andrew Morton wrote:
> It might be better to switch over to address masking in get_user_pages()
> and just dump all the compound page logic.  I don't immediately see how the

I'm all for it, this is how the 2.4 get_user_pages deals with bigpages
too, I've never enjoyed the compound thing.

> get_user_pages() caller can subsequently do put_page() against the correct
> pageframe, but I assume you worked that out?

see this patch:

	http://www.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.23aa2/9910_shm-largepage-18.gz

it's a two liner fix in follow_page:

@@ -439,6 +457,8 @@ static struct page * follow_page(struct
        pmd = pmd_offset(pgd, address);
        if (pmd_none(*pmd))
                goto out;
+       if (pmd_bigpage(*pmd))
+               return __pmd_page(*pmd) + (address & BIGPAGE_MASK) / PAGE_SIZE;


the BIGPAGE_MASK will never expose anything but the page->private to the
get_user_pages code, and handle_mm_fault takes care of doing the page
faults properly using larepages and pmds if the vma is marked
VM_BIGPAGE.

rawio on largepages has been a must-have feature (especially on >=32G)
for more than one year, definitely no need of compound slowdown for that.

Still I would like to understand what's wrong in Christoph's ppc machine
before dumping the whole compound thing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
