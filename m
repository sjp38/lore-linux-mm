Message-ID: <39CA9A5B.F7F51118@norran.net>
Date: Fri, 22 Sep 2000 01:31:39 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Problem remains - page_launder? (Was: Re: [patch *] VM deadlock fix)
References: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva> <39CA6F84.813057D6@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again,

Further hints.

More testing (printks in refill_inactive and page_launder)
reveals that refill_inactive works ok (16 pages) but 
page_launder never succeeds in my lockup state... (WHY)
alloc fails since there is no inactive_clean and free is
less than MIN. And then when page_launder fails...

/RogerL


Roger Larsson wrote:
> 
> Hi,
> 
> Tried your patch on 2.2.4-test9-pre4
> with the included debug patch applied.
> 
> Rebooted, started mmap002
> 
> After a while it starts outputting (magic did not work
> this time - usually does):
> 
> - - -
> "VM: try_to_free_pages (result: 1) try_again # 12345"
> "VM: try_to_free_pages (result: 1) try_again # 12346"
> - - -
> 
> My interpretation:
> 1) try_to_free_pages succeeds (or returns ok when it did not work)
> 2) __alloc_pages still can't alloc
> 
> Maybe it is different limits,
>   try_to_free_pages requires less to succeed than
>   __alloc_pages_limit requires.
> or a bug in
>   __alloc_pages_limit(zonelist, order, PAGES_MIN, direct_reclaim)
> 
> Note:
>   12345  is an example, it loops to over 30000...
> 
> /RogerL
> 
> Rik van Riel wrote:
> >
> > Hi,
> >
> > I've found and fixed the deadlocks in the new VM. They turned out
> > to be single-cpu only bugs, which explains why they didn't crash my
> > SMP tesnt box ;)
> >
> > They have to do with the fact that processes schedule away while
> > holding IO locks after waking up kswapd. At that point kswapd
> > spends its time spinning on the IO locks and single-cpu systems
> > will die...
> >
> > Due to bad connectivity I'm not attaching this patch but have only
> > put it online on my home page:
> >
> > http://www.surriel.com/patches/2.4.0-t9p2-vmpatch
> >
> > (yes, I'm at a conference now ... the worst beating this patch
> > has had is a full night in 'make bzImage' with mem=8m)
> >
> > regards,
> >
> > Rik
> > --
> > "What you're running that piece of shit Gnome?!?!"
> >        -- Miguel de Icaza, UKUUG 2000
> >
> > http://www.conectiva.com/               http://www.surriel.com/
> >
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > Please read the FAQ at http://www.tux.org/lkml/
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> 
>   ------------------------------------------------------------------------
>                     Name: vmdebug.patch
>    vmdebug.patch    Type: Plain Text (text/plain)
>                 Encoding: 7bit

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
