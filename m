Date: Thu, 12 Jun 2003 14:44:18 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-Id: <20030612144418.49f75066.akpm@digeo.com>
In-Reply-To: <150040000.1055452098@baldur.austin.ibm.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
	<20030612134946.450e0f77.akpm@digeo.com>
	<20030612140014.32b7244d.akpm@digeo.com>
	<150040000.1055452098@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> --On Thursday, June 12, 2003 14:00:14 -0700 Andrew Morton <akpm@digeo.com>
> wrote:
> 
> > And this does require that ->nopage be entered with page_table_lock held,
> > and that it drop it.
> 
> I think that's a worse layer violation than referencing inode in
> do_no_page.  We shouldn't require that the filesystem layer mess with the
> page_table_lock.

Well it is not "worse".  Futzing with i_sem in do_no_page() is pretty gross.
You could add vm_ops->prevalidate() or something if it worries you.

btw, it should be synchronising with
file->f_dentry->d_inode->i_mapping->host->i_sem, not
file->f_dentry->d_inode->i_sem.  do_truncate() also seems to be taking the
(potentially) wrong semaphore.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
