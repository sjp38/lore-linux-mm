Date: Sat, 3 Mar 2001 01:52:19 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] count for buffer IO in page_launder()
In-Reply-To: <20010302171020.W28854@redhat.com>
Message-ID: <Pine.LNX.4.21.0103030133440.1033-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 2 Mar 2001, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, Feb 27, 2001 at 04:09:09AM -0300, Marcelo Tosatti wrote:
> > 
> > page_launder() is not counting direct ll_rw_block() IO correctly in the
> > flushed pages counter. 
> 
> Having not seen any follow to this, it's worth asking: what is the
> expected consequence of _not_ including this?  

The page launder loop avoids flushing too many pages if it already
flushed/cleaned enough pages to remove the system from low memory
condition (mm/vmscan.c::page_launder()):

                /*
                 * Disk IO is really expensive, so we make sure we
                 * don't do more work than needed.
                 * Note that clean pages from zones with enough free
                 * pages still get recycled and dirty pages from these
                 * zones can get flushed due to IO clustering.
                 */
                if (freed_pages + flushed_pages > target && !free_shortage())
                        break;


Dirty buffer pages and dirty pagecache pages with page->buffers mapping
which were being flushed (with try_to_free_buffers()) were not being
counted in the "flushed_pages" counter correctly.

So what could happen is that tasks trying to launder pages could
flush/swapout more than needed. 

> Have you done an performance testing on it?

No. The code makes sense now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
