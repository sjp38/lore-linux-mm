Message-ID: <4198043D.6070308@yahoo.com.au>
Date: Mon, 15 Nov 2004 12:19:57 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Possible alternate 4 level pagetables?
References: <4196F12D.20005@yahoo.com.au> <20041114082525.GB16795@wotan.suse.de>
In-Reply-To: <20041114082525.GB16795@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Sun, Nov 14, 2004 at 04:46:21PM +1100, Nick Piggin wrote:
> 
>>Just looking at your 4 level page tables patch, I wondered why the extra
>>level isn't inserted between pgd and pmd, as that would appear to be the
>>least intrusive (conceptually, in the generic code). Also it maybe matches
>>more closely the way that the 2->3 level conversion was done.
> 
> 
> I did it the way I did to keep i386 and other archs obviously correct 
> because their logic doesn't change at all for the three lower levels,
> and the highest level just hands a pointer through.
> 

Yeah true. Although a pointer to a pud is essentially just a pointer
to pgd in the case where you've only got three levels instead of four.

So it is really a matter of where you make the "folds" I guess.

> Regarding intrusiveness in common code: you pretty much have to change
> most of of mm/memory.c, no matter what you do. Also there are overall
> only 7 or 8 users that really need the full scale changes, so 
> it's not as bad as it looks. Ok there is ioremap in each architecture,
> but usually you can cheat for these because you know the architecture
> will never support 4levels.
> 

Yeah - technically you can ignore the "pud" type in this system as well
if you're only using three levels, so architectures should be able to just
work. Although really they should just be converted over for cleanliness.

> I'm sorry, but I don't see much advantage of your patches over mine.
> 

Well no there isn't much I guess - if mine were bug free it would nearly
compile into the same object code.

The main thing I see is that in my scheme, you have the business ends
of the page table - pgd and pte which are always there, and you fold away
the middle, "transient" levels when they're not in use. It also allows
you to use the same system for both pmd and pud.

But on the other hand yours is maybe as you say a bit less intrusive
code-wise, if not logically. And maybe has other advantages as well.

Anyway, this was just a suggestion - as I said I won't have much time
for it for the next week, but I might try to flesh it out a bit more
after that.

Thanks
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
