Date: Tue, 29 May 2001 11:24:14 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <OF5385EE96.412D8BDB-ON85256A58.005E44E7@pok.ibm.com>
Subject: Re: order of matching alloc_pages/free_pages call pairs. Are they always same?
Message-ID: <f1ZeVC.A.A_H.v08E7@dinero.interactivesi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "Bulent Abali" <abali@us.ibm.com> on Sat, 26 May 2001
13:10:42 -0400


> Is it reasonable to assume that matching
> alloc_pages/free_pages pairs will always have the same order
> as the 2nd argument?
> 
> For example
> pg = alloc_pages( , aorder);   free_pages(pg, forder);
> Is (aorder == forder) always true?
> 
> Or, are there any bizarro drivers etc which will intentionally
> free partial amounts, that is (forder < aorder)?

Yes!!  My driver does exactly that!!  Please DO NOT do anything to break this
functionality.  Here's the code which does that:

void fragment_and_free(void *_region, unsigned current_order, unsigned
new_order)
{
    unsigned long current_size = (1 << current_order) << PAGE_SHIFT;
    unsigned long new_size = (1 << new_order) << PAGE_SHIFT;

    char *region = (char *) _region;
    char *p;

    printk("Subdividing block of order %u into blocks of order %u\n",
current_order, new_order);

    if (new_order <= current_order)
    {
        for (p = region; p < (region + current_size); p += new_size)
            free_pages((u32) p, new_order);
    }
}


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
