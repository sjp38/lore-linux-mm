Date: Mon, 20 Mar 2006 09:27:02 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced
 mlock-LRU semantic
In-Reply-To: <bc56f2f0603200535s2b801775m@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Mar 2006, Stone Wang wrote:

> 2. More consistent LRU semantics in Memory Management.
>    Mlocked pages is placed on a separate LRU list: Wired List.
>    The pages dont take part in LRU algorithms,for they could never be swapped,
>    until munlocked.

This also implies that dirty bits of the pte for mlocked pages are never 
checked. 

Currently light swapping (which is very common) will scan over all pages 
and move the dirty bits from the pte into struct page. This may take 
awhile but at least at some point we will write out dirtied pages.

The result of not scanning mlocked pages will be that mmapped files will 
not be updated unless either the process terminates or msync() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
