Date: Wed, 14 May 2003 10:57:06 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030514105706.628fba15.akpm@digeo.com>
In-Reply-To: <82240000.1052934152@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
	<20030513181018.4cbff906.akpm@digeo.com>
	<18240000.1052924530@baldur.austin.ibm.com>
	<20030514103421.197f177a.akpm@digeo.com>
	<82240000.1052934152@baldur.austin.ibm.com>
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
> task 1 waits for IO in the page fault.
> 
>  task 2 calls truncate, which does zap_page_range() on the range that page
>  is in.
> 
>  task 1 wakes up and maps the page.
> 
>  task 2 calls truncate_inode_pages which removes the newly mapped page from
>  the page cache.
> 
>  Now the state is that the page has been disconnected from the file, but
>  it's still mapped in task 1's address space.  That task thinks it has valid
>  data from the file in that page, and may continue to read/write there, and
>  assume any changes will get written back..

yes.  It's a very complex way of allocating anonymous memory.

I am told that Stephen, Linus and others discussed this at length at KS a
couple of years ago and the upshot was that the application is racy anyway
and there's nothing wrong with it.

Hugh calls these "Morton pages" but it wasn't me and nobody saw me do it.

It would be nice to make them go away - they cause problems.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
