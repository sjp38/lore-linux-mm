Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MM patches against 2.5.31
Date: Mon, 26 Aug 2002 19:56:52 +0200
References: <3D644C70.6D100EA5@zip.com.au> <E17jKlX-0001i0-00@starship> <20020826152950.9929.qmail@thales.mathematik.uni-ulm.de>
In-Reply-To: <20020826152950.9929.qmail@thales.mathematik.uni-ulm.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17jO6g-0002XU-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>
Cc: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 26 August 2002 17:29, Christian Ehrhardt wrote:
> On Mon, Aug 26, 2002 at 04:22:50PM +0200, Daniel Phillips wrote:
> > On Monday 26 August 2002 11:10, Christian Ehrhardt wrote:
> > > + * A special Problem is the lru lists. Presence on one of these lists
> > > + * does not increase the page count.
> > 
> > Please remind me... why should it not?
> 
> Pages that are only on the lru but not reference by anyone are of no
> use and we want to free them immediatly. If we leave them on the lru
> list with a page count of 1, someone else will have to walk the lru
> list and remove pages that are only on the lru.

I don't understand this argument.  Suppose lru list membership is worth a 
page count of one.  Then anyone who finds a page by way of the lru list can 
safely put_page_testzero and remove the page from the lru list.  Anyone who 
finds a page by way of a page table can likewise put_page_testzero and clear 
the pte, or remove the mapping and pass the page to Andrew's pagevec 
machinery, which will eventually do the put_page_testzero.  Anyone who 
removes a page from a radix tree will also do a put_page_testzero.  Exactly 
one of those paths will result in the page count reaching zero, which tells 
us nobody else holds a reference and it's time for __free_pages_ok.  The page 
is thus freed immediately as soon as there are no more references to it, and 
does not hang around on the lru list.

Nobody has to lock against the page count.  Each put_page_testzero caller 
only locks the data structure from which it's removing the reference.

This seems so simple, what is the flaw?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
