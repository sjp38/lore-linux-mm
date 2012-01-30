Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D67336B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 13:50:03 -0500 (EST)
Received: by pbaa12 with SMTP id a12so5071020pba.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 10:50:03 -0800 (PST)
Date: Mon, 30 Jan 2012 10:49:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <1327912964.12941.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Message-ID: <alpine.LSU.2.00.1201301034100.1884@eggly.anvils>
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201231125200.1677@eggly.anvils> <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com>
 <alpine.LSU.2.00.1201251623340.2141@eggly.anvils> <1327912964.12941.YahooMailNeo@web162006.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1200577600-1327949391=:1884"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1200577600-1327949391=:1884
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 30 Jan 2012, PINTU KUMAR wrote:
> =A0
> >If these are ordinary pages with struct pages, then you could probably
> >use a loop of vm_insert_page()s to insert them at mmap time, or a fault
> >routine to insert them on fault.=A0 But as I said, I don't know if this
> >memory is part of the ordinary page pool or not.
> =A0
> You suggestion about using vm_insert_page() instead of remap_pfn_range wo=
rked for me and I got the Rss/Pss information for my driver.

Oh, I'm glad that happened to work for you.

> But still there is one problem related to page fault.=20
> If I remove remap_pfn_range then I get a page fault in the beginning.=20
> I tried to use the same vm_insert_page() during page_fault_handler for ea=
ch vmf->virtual_address but it did not work.
> So for time being I remove the page fault handler from my vm_operations.
> But with these my menu screen(LCD screen) is not behaving properly (I get=
 colorful lines on my LCD).
> So I need to handle the page fault properly.
> =A0
> But I am not sure what is that I need to do inside page fault handler. Do=
 you have any example or references or suggestions?

Sounds like you're not using vm_insert_page() properly: I would not expect
you to get a page fault there once you've set up the area with a loop of
vm_insert_page()s.

Check the comments above it in mm/memory.c ("Your vma protection will
have to be set up correctly" might be relevant).

Compare how you're using it with other users of vm_insert_page() in
the kernel tree.  Sorry, I don't have time to do your debugging.

> =A0
> >Really, the question has to be, why do you need to see non-0s there?
> I want Rss/Pss value to account for how much video memory is used by the =
driver for the menu-screen,Xorg processes.

So, userspace does an mmap for a large-enough window, but only some part of
that is filled by the driver (whether by remap_pfn_range or vm_insert_pages=
),
and you'd like to communicate back how much via the Rss, instead of adding
some ioctl or sysfs interface to the driver?  Fair enough.

I expect userspace could also work it out by touching pages of the area
until it gets a SIGBUS, but that might be too dirty a way of finding out.

Hmm, SIGBUS: maybe that's related to the faults that are puzzling you:
perhaps you're mapping less than you need to.

Hugh
--8323584-1200577600-1327949391=:1884--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
