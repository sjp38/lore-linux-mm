Date: Wed, 11 Dec 2002 09:01:02 +0100
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: Question on set_page_dirty()
Message-ID: <20021211080102.GG20525@vagabond>
References: <3DF5BB06.A6F6AFFD@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DF5BB06.A6F6AFFD@scs.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 10, 2002 at 10:59:34AM +0100, Martin Maletinsky wrote:
> Hello,
> 
> Looking at the function set_page_dirty() (in linux 2.4.18-3 - see
> below) I noticed, that it not only sets the pages PG_dirty bit (as the
> SetPageDirty() macro does), but additionnally may link the page onto
> a queue (more precisely the dirty queue of it's 'mapping').

That's the most important bit of it all. All dirty pages must at some
point be cleaned. The list keeps track of which pages need to be
cleaned, so kernel can do it quickly either when it needs to free the
mapping (close the file, terminate process, exec) or when it's just time
to flush some pages (in kflushd).

> What is the meaning of this dirty queue, what is the effect of linking
> a page onto that queue, and when should the set_page_dirty() function
> be used rather than the
> SetPageDirty() macro?

If you use the SetPageDirty macro, then the page is marked dirty, but
kernel can't find it when it should clean it. Thus it eventualy won't
flush the data (it won't call writepage on it).

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
