Date: Thu, 12 Jun 2008 22:36:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
In-Reply-To: <1213223825.20045.138.camel@calx>
Message-ID: <Pine.LNX.4.64.0806122216580.14873@blonde.site>
References: <20080611180228.12987026@kernel>  <20080611180230.7459973B@kernel>
  <20080611123724.3a79ea61.akpm@linux-foundation.org>  <1213213980.20045.116.camel@calx>
  <20080611131108.61389481.akpm@linux-foundation.org>  <1213216462.20475.36.camel@nimitz>
  <20080611135207.32a46267.akpm@linux-foundation.org>  <1213219435.20475.44.camel@nimitz>
 <1213223825.20045.138.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, hans.rosenfeld@amd.com, linux-mm@kvack.org, riel@redhat.com, nacc <nacc@linux.vnet.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008, Matt Mackall wrote:
> On Wed, 2008-06-11 at 14:23 -0700, Dave Hansen wrote:
> > On Wed, 2008-06-11 at 13:52 -0700, Andrew Morton wrote:
> > 
> > > Am I missing something, or is pmd_huge() a whopping big grenade for x86
> > > developers to toss at non-x86 architectures?  It seems quite dangerous.
> > 
> > Yeah, it isn't really usable outside of arch code, although it kinda
> > looks like it.
> 
> That begs the question: if we can't use it reliably outside of arch
> code, why do other arches even bother defining it?

Good question.

> And the answer seems to be because of the two uses in mm/memory.c. The
> first seems like it could be avoided with an implementation of
> follow_huge_addr on x86.

No, I don't think we need even that: because get_user_pages avoids
follow_page on huge vmas, and little else uses follow_page, I think
we could delete follow_huge_addr from all architectures.

It's gives a warm glow to know that follow_page could cope with
huge ranges if necessary, but it doesn't feel so good once you've
been misled by pmd_huge.

Incidentally, x86 turns out to have a pmd_large() too!

> The second is either bogus (only works on x86)
> or superfluous (not needed at all), no?

Not needed (checking for things that should never happen
is nice when it's convenient, but not a reason to uglify).

On Dave's patch: yes, I too would have preferred a pmd_huge-style
vma-less approach, but fear that doesn't work out at present.  But
isn't the patch calling find_vma() much more often than necessary?
Is there any architecture which can mix huge and normal pages
within the lowest pagetable?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
