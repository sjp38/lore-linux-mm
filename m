Message-ID: <419953C6.7000702@yahoo.com.au>
Date: Tue, 16 Nov 2004 12:11:34 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Possible alternate 4 level pagetables?
References: <Pine.LNX.4.44.0411152121340.4171-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0411152121340.4171-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Sun, 14 Nov 2004, Nick Piggin wrote:
> 
>>Just looking at your 4 level page tables patch, I wondered why the extra
>>level isn't inserted between pgd and pmd, as that would appear to be the
>>least intrusive (conceptually, in the generic code). Also it maybe matches
>>more closely the way that the 2->3 level conversion was done.
> 
> 
> I thought the same, when I finally took a look a week or so ago.
> 
> I've scarcely looked at your patches, but notice they change i386.
> 

Yep. The problem is that I was making an asm-generic/ header file
to handle pmd folding before even doing anything with 4 levels. Then
this meant that pud folding could be just done with a straight copy
of the pgtable-nopmd.h file.

Technically, I think, arch code would still run without changing a
single line if you didn't want to include those new "folding" headers.
(Maybe aside from a few type warnings / errors).

Andi's is much the same *except* that yes, being the top level means
names have to be changed.

> For me, the attraction of putting the new level in between pgd and pmd
> was that it seemed that only common code and x86_64 (and whatever else
> comes to use all four levels in future) would need changing (beyond,
> perhaps, #including some asm-generic headers).  Some casting to combine
> the two levels into pmd in unchanged arch code, or rename pmd to pld in
> the changed common code.  Andi's arch patches seemed (all?) to spring
> from replacing mm->pgd by mm->pml4.
> 

My first attempt was to insert a pld below pmd actually :) It is the
most appropriately named!

The problem is that some architectures are actually using this level,
it is used in hugepages code, etc. So I decided a 'pud' was the least
intrusive.

> But I could well be mistaken, I wasn't so industrious as to actually
> try it.
> 
> 
>>I've been toying with it a little bit. It is mainly just starting with
>>your code and doing straight conversions, although I also attempted to
>>implement a better compatibility layer that does the pagetable "folding"
>>for you if you don't need to use the full range of them.
>>
>>Caveats are that there is still something slightly broken with it on i386,
>>and so I haven't looked at x86-64 yet. I don't see why this wouldn't work
>>though.
>>
>>I've called the new level 'pud'. u for upper or something.
> 
> 
> Well, yes, your base appetites have led you to the name "pud",
> where my refined intellect led me to "phd", with h for higher ;)
> 

Oh now I think that is going to cause you all sorts of problems ;)

> 
>>Sorry the patch isn't in very good shape at the moment - I won't have time
>>to work on it for a week, so I thought this would be a good point just to
>>solicit initial comments.
> 
> 
> I doubt it's worthwhile now, particularly if you do have to patch arches.
> 

When I get time I'll do another cut with minimal possible architecture
changes first, and put 'improvements' on top of that.

I think I'll hopefully have time to get something more productive to add
to the debate before 2.6.10 comes out. I'm not completely adverse to Andi's
system, but this is going to be around for the next n-years, so I figure
an alternate perspective can't hurt.

Thanks
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
