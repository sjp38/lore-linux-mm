Date: Tue, 13 May 2003 18:10:18 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030513181018.4cbff906.akpm@digeo.com>
In-Reply-To: <199610000.1052864784@baldur.austin.ibm.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
	<3EC15C6D.1040403@kolumbus.fi>
	<199610000.1052864784@baldur.austin.ibm.com>
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
> After some though it occurred to me there is a simple alternative scenario
>  that's not protected.  If a task is *already* in a page fault mapping the
>  page in, then vmtruncate() could call zap_page_range() before the page
>  fault completes.  When the page fault does complete the page will be mapped
>  into the area previously cleared by vmtruncate().

That's the one.  Process is sleeping on I/O in filemap_nopage(), wakes up
after the truncate has done its thing and the page gets instantiated in
pagetables.

But it's an anon page now.  So the application (which was racy anyway) gets
itself an anonymous page.

Which can still have buffers attached, which the swapout code needs to be
careful about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
