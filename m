Date: Tue, 3 Jun 2008 04:04:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/5] x86: implement pte_special
Message-ID: <20080603020439.GA5527@wotan.suse.de>
References: <20080529122050.823438000@nick.local0.net> <20080529122602.062780000@nick.local0.net> <20080602165847.dd19ddb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080602165847.dd19ddb1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 02, 2008 at 04:58:47PM -0700, Andrew Morton wrote:
> On Thu, 29 May 2008 22:20:51 +1000
> npiggin@suse.de wrote:
> 
> > Implement the pte_special bit for x86. This is required to support lockless
> > get_user_pages, because we need to know whether or not we can refcount a
> > particular page given only its pte (and no vma).
> 
> Spits this reject:
> 
> ***************
> *** 39,44 ****
>   #define _PAGE_UNUSED3	(_AC(1, L)<<_PAGE_BIT_UNUSED3)
>   #define _PAGE_PAT	(_AC(1, L)<<_PAGE_BIT_PAT)
>   #define _PAGE_PAT_LARGE (_AC(1, L)<<_PAGE_BIT_PAT_LARGE)
>   
>   #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
>   #define _PAGE_NX	(_AC(1, ULL) << _PAGE_BIT_NX)
> --- 40,47 ----
>   #define _PAGE_UNUSED3	(_AC(1, L)<<_PAGE_BIT_UNUSED3)
>   #define _PAGE_PAT	(_AC(1, L)<<_PAGE_BIT_PAT)
>   #define _PAGE_PAT_LARGE (_AC(1, L)<<_PAGE_BIT_PAT_LARGE)
> + #define _PAGE_SPECIAL	(_AC(1, L)<<_PAGE_BIT_SPECIAL)
> + #define __HAVE_ARCH_PTE_SPECIAL
>   
>   #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
>   #define _PAGE_NX	(_AC(1, ULL) << _PAGE_BIT_NX)
> 
> Which I fixed thusly:
> 
> #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
> #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
> #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
> #define __HAVE_ARCH_PTE_SPECIAL
> 
> 
> OK?

I think so, thanks.


> (Also please check the bunch of checkpatch fixes, a warning fix and a
> compile fix).

Ah, I forgot to rerun checkpatch after renaming it from fast_gup.
Missed the compile bug though... perhaps I was getting the definition
pulled in some other way... hmm, will investigate, but it looks
good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
