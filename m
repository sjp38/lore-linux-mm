Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA14332
	for <linux-mm@kvack.org>; Fri, 8 Nov 2002 14:44:09 -0800 (PST)
Message-ID: <3DCC3E38.29B0ABEF@digeo.com>
Date: Fri, 08 Nov 2002 14:44:08 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: get_user_pages rewrite (completed, updated for 2.4.46)
References: <20021107110840.P659@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> Hi Andrew,
> 
> now I have implemented the big get_user_pages rewrite.


/* &custom_page_walker - A custom page walk handler for walk_user_pages().
 * vma:         The vma we walk pages of.
 * page:        The page we found or an %ERR_PTR() value
 * virt_addr:   The virtual address we are at while walking.
 * customdata:  Anything you would like to pass additionally.
 *
 * Returns:
 *      Negative values -> ERRNO values.
 *      0               -> continue page walking.
 *      1               -> abort page walking.
 *
 * If this functions gets a page, for which %IS_ERR(@page) is true, than it
 * should do it's cleanup of customdata and return -PTR_ERR(@page).
 *
 * This function is called with @vma->vm_mm->page_table_lock held,
 * if IS_ERR(@vma) is not true.
 *
 * But if IS_ERR(@vma) is true, IS_ERR(@page) is also true, since if we have no
 * vma, then we also have no user space page.
 *
 * If it returns a negative value, then the page_table_lock must be dropped
 * by this function, if it is held.
 */

This locking is rather awkward.  Why is it necessary, and can it
be simplified??

wrt the removal of the vmas arg to get_user_pages(): I assume this
was because none of the multipage callers were using it?

The patches would be easier to follow if things were sequenced a
little differently: lose the intermediate steps.  Or just roll
the whole thing into a single patch, really.  I don't think there
are any intermediate steps in this one?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
