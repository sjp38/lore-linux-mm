Date: Wed, 14 May 2003 11:53:19 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030514115319.51a54174.akpm@digeo.com>
In-Reply-To: <108250000.1052936665@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
	<20030513181018.4cbff906.akpm@digeo.com>
	<18240000.1052924530@baldur.austin.ibm.com>
	<20030514103421.197f177a.akpm@digeo.com>
	<82240000.1052934152@baldur.austin.ibm.com>
	<20030514105706.628fba15.akpm@digeo.com>
	<99000000.1052935556@baldur.austin.ibm.com>
	<20030514111748.57670088.akpm@digeo.com>
	<108250000.1052936665@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> --On Wednesday, May 14, 2003 11:17:48 -0700 Andrew Morton <akpm@digeo.com>
> wrote:
> 
> > I think it might be sufficient to re-check the page against i_size
> > after IO completion in filemap_nopage().
> 
> It would definitely make the window a lot smaller, though it won't quite
> close it.  To be entirely safe we'd need to recheck after we've retaken
> page_table_lock.

hmm.

One possible timing diagram is



	truncate:				pagefault:


						check i_size

						grab page
	drop i_size

	shoot down pagetables

						install in pagetables

	truncate file


converting i_sem to an rwsem and taking it in the pagefault would certainly
stitch it up.  Unpopular, very messy.

Could "truncate file" return some code to say pages were left behind, so
truncate re-runs zap_page_range()?  Sounds unpleasant.


Yes, re-checking the page against i_size from do_no_page() would fix it up.
 But damn, that's another indirect call, 64-bit math, etc on _every_
file-backed pagefault.


Remind me again what problem this whole thing is currently causing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
