Date: Tue, 13 May 2003 15:49:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030513224929.GX8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <3EC15C6D.1040403@kolumbus.fi> <199610000.1052864784@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <199610000.1052864784@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Mika Penttil? <mika.penttila@kolumbus.fi>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 05:26:24PM -0500, Dave McCracken wrote:
> Hmm... Yep, it is.  I did some more investigating.  My initial scenario
> required that the task mapping the page extend the file after the truncate,
> which must be done via some kind of write().  The write() would trip over
> i_sem and therefore hang waiting for vmtruncate() to complete.  So I was
> wrong about that one.
> Hoever, vmtruncate() does get to truncate_complete_page() with a page
> that's mapped...
> After some though it occurred to me there is a simple alternative scenario
> that's not protected.  If a task is *already* in a page fault mapping the
> page in, then vmtruncate() could call zap_page_range() before the page
> fault completes.  When the page fault does complete the page will be mapped
> into the area previously cleared by vmtruncate().
> We could make vmtruncate() take mmap_sem for write, but that seems somewhat
> drastic.  Does anyone have any alternative ideas?

That doesn't sound like it's going to help, there isn't a unique
mmap_sem to be taken and so we just get caught between acquisitions
with the same problem.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
