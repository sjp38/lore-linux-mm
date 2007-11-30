Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id lAUIWcVA009139
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 18:32:38 GMT
Received: from nf-out-0910.google.com (nfdk4.prod.google.com [10.48.137.4])
	by zps78.corp.google.com with ESMTP id lAUIWaQW021583
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:32:37 -0800
Received: by nf-out-0910.google.com with SMTP id k4so2580434nfd
        for <linux-mm@kvack.org>; Fri, 30 Nov 2007 10:32:35 -0800 (PST)
Message-ID: <d43160c70711301032q7cf245c0w1521711b597c77f5@mail.gmail.com>
Date: Fri, 30 Nov 2007 13:32:35 -0500
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable Part 2 Page Table Migration Code
In-Reply-To: <1196445857.18851.140.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70711300836g52c10a88qc46288cf380192ca@mail.gmail.com>
	 <1196445857.18851.140.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Nov 30, 2007 1:04 PM, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Fri, 2007-11-30 at 11:36 -0500, Ross Biro wrote:
> > lmbench shows the overhead of rewalking the page tables is less than
> > that of spinlock debugging.
>
> Spinlock debugging can be pretty heavy, so I wouldn't use it as a
> benchmark.  Thanks for posting them early, though.

It was unintentional.  I was really excited because I saw no
performance hit from my changes.  It wasn't until the next time I hit
an uninitialized spinlock that I realized my benchmark was all but
useless.


>
> > Here's the actual page table migration code.  I'm not sure I plugged
> > it into the correct spot, but it works well enough to test.
>
> Could you remind us exactly what you're trying to do here?  A bit of the
> theory of what you're trying would be good.  Also, this is a wee bit
> hard to review because it's a bit messy, still has lots of debugging
> printks, and needs some CodingStyle love.  Don't forget to add -p do
> your diffs while you're at it.

Sorry about that.  I rushed these out so they wouldn't sit around for
a couple of weeks before I could get them out.

The goal is to make page tables relocatable.  Right now, I'm only
trying to relocate the page tables when moving a process from one node
to another in a numa system. However, the same code should work just
as well to move page tables around in a node to free up larger blocks
of memory.


> Where did PageDying() come from?  Where ever it came from, please wrap
> it up in its header in a nice #ifdef so you don't have to do this a
> number of times:

It's left over cruft from an optimization that I realized would only
be an optimization if the cache was really slow.  I thought I had
eliminated it.  Just ignore it for now.  I'll delete it everywhere.

> There's a nice shiny comment next to 'lru'.  Hint, hint. ;)

Like I said, rushed for preview.

>
> > +int migrate_top_level_page_table(struct mm_struct *mm, struct page *dest)
> > +{
> > +       return 1;
> > +#if 0
> > +       unsigned long flags;
> > +       void *dest_ptr;
> > +
> > +       /* We can't do this until we get a heavy duty tlb flush, or
> > +          we can force this mm to be switched on all cpus. */
>
> Can you elaborate on this?  You need each cpu to do a task switch _away_
> from this mm?

Switching away is sufficient, but you can do a little better by just
reloading the appropriate registers from the mm.  For example on
X86_64, an mm flush is accomplished by the equivalent of mov cr3, cr3
(I think it's cr3).  We need a reload of cr3 from the mm struct.
Currently the only code that does that is the task switch code.

>
> > +int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
> > +               struct page *dest)
> > +{
> ...
> > +       pte = pte_offset_map(pmd, addr);
> > +
> > +       dest_ptr = kmap_atomic(dest, KM_IRQ0);
>
> Why KM_IRQ0 here?

Laziness.  I needed a mapping and irq0 is safe.  Something better
should be chosen before the code is ready to go in.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
