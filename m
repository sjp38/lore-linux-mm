Date: Thu, 24 Aug 2000 13:04:35 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: ioremap_nocache() doesn't work
Message-Id: <20000824181451Z131170-249+6@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I've written the following function which is supposed to make a physical page
uncacheable.  It doesn't appear to be working, however.

void *uncache_pages(unsigned long phys, unsigned long num_pages)
{
    mem_map_t *mm = phys_to_mem_map(phys & PAGE_MASK);
    unsigned i;
    unsigned long flags[num_pages];
    void *v;
    u32 reg_flags;

    save_flags(reg_flags);
    cli();

    for (i=0; i<num_pages; i++)
    {
        flags[i] = mm[i].flags;
	SetPageReserved(mm+i);
    }

    restore_flags(reg_flags);

    v = ioremap_nocache(phys, num_pages * PAGE_SIZE);
    if (!v)
        printk("uncache_pages() failed!\n");

    save_flags(reg_flags);
    cli();

    for (i=0; i<num_pages; i++)
        mm[i].flags = flags[i];

    restore_flags(reg_flags);

    return v;
}

The problem is, I'm no expert on the page tables, so I don't know how pages are
supposed to be marked uncacheable in the first place.

>From what I can tell, this function marks a bunch of pages as uncacheable and
then remaps them to virtual space.  But it doesn't appear to work.  When I
perform a write, it is not immediately sent over the bus.  This is on an x86
platform, using kernel 2.4.0-test2.

So I have a few questions:

1) As I understand it, only physical pages, not virtual pages, can be cacheable
or uncacheable.  That is, if two virtual addresses point to the same physical
address, then it's impossible for one virtual address to be "cacheable" and the
other to be "uncacheable".  Correct?

2) Once I map/mark a page, how do I unmap it?  I don't see an iounmap_nocache()
function anywhere.

3) I know my routine is a bad way of doing this, but all my previous attempts
to get the question, "How do I mark a page as uncacheable" have gone UNANSWERED.
This IS a linux kernel [memory manager] mailing list, isn't it?  Someone MUST
know the answer to the question.  How is anyone supposed to learn anything if
knowledgeable people refuse to answer questions they know?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
