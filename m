Date: Tue, 13 May 2003 17:26:24 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <199610000.1052864784@baldur.austin.ibm.com>
In-Reply-To: <3EC15C6D.1040403@kolumbus.fi>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <3EC15C6D.1040403@kolumbus.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, May 13, 2003 23:58:21 +0300 Mika Penttila
<mika.penttila@kolumbus.fi> wrote:

> Isn't that what inode->i_sem is supposed to protect...?

Hmm... Yep, it is.  I did some more investigating.  My initial scenario
required that the task mapping the page extend the file after the truncate,
which must be done via some kind of write().  The write() would trip over
i_sem and therefore hang waiting for vmtruncate() to complete.  So I was
wrong about that one.

Hoever, vmtruncate() does get to truncate_complete_page() with a page
that's mapped...

After some though it occurred to me there is a simple alternative scenario
that's not protected.  If a task is *already* in a page fault mapping the
page in, then vmtruncate() could call zap_page_range() before the page
fault completes.  When the page fault does complete the page will be mapped
into the area previously cleared by vmtruncate().

We could make vmtruncate() take mmap_sem for write, but that seems somewhat
drastic.  Does anyone have any alternative ideas?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
