Message-ID: <3EC15C6D.1040403@kolumbus.fi>
Date: Tue, 13 May 2003 23:58:21 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: Race between vmtruncate and mapped areas?
References: <154080000.1052858685@baldur.austin.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Isn't that what inode->i_sem is supposed to protect...?

--Mika


Dave McCracken wrote:

>As part of chasing the BUG() we've been seeing in objrmap I took a good
>look at vmtruncate().  I believe I've identified a race condition that no
>only  triggers that BUG(), but also could cause some strange behavior
>without the objrmap patch.
>
>Basically vmtruncate() does the following steps:  first, it unmaps the
>truncated pages from all page tables using zap_page_range().  Then it
>removes those pages from the page cache using truncate_inode_pages().
>These steps are done without any lock that I can find, so it's possible for
>another task to get in between the unmap and the remove, and remap one or
>more pages back into its page tables.
>
>The result of this is a page that has been disconnected from the file but
>is mapped in a task's address space as if it were still part of that file.
>Any further modifications to this page will be lost.
>
>I can easily detect this condition by adding a bugcheck for page_mapped()
>in truncate_complete_page(), then running Andrew's bash-shared-mapping test
>case.
>
>Please feel free to poke holes in my analysis.  I'm not at all sure I
>haven't missed some subtlety here.
>
>Dave McCracken
>
>======================================================================
>Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
>dmccr@us.ibm.com                                        T/L   678-3059
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
