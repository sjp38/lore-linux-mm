Date: Wed, 23 Jun 2004 20:59:06 +0900 (JST)
Message-Id: <20040623.205906.71913783.taka@valinux.co.jp>
Subject: Re: Atomic operation for physically moving a page (for memory
 defragmentation)
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <1087619137.4921.93.camel@nighthawk>
References: <20040619031536.61508.qmail@web10902.mail.yahoo.com>
	<1087619137.4921.93.camel@nighthawk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com
Cc: ashwin_s_rao@yahoo.com, Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > > However, if we're on an unlikely error path or
> > > similar and other options aren't suitable...
> > 
> > Maintaining atomicity in uniprocessor systems is easy
> > by preempt_enable and preempt_disable during the
> > operation. This implementation cannot be used for SMP
> > systems. 
> > Now during the time a page is copied/updatede if a
> > page is accessed the copied contents become invalid,
> > as updation is not done. Also during updation a
> > similar situation might arise.
> > The problem we are facing is to maintain the atomicity
> > of this operation on SMP boxes.
> 
> I think what you really want to do is keep anybody else from making a
> new pte to the page, once you've invalidated all of the existing ones,
> right?
> 
> Holding a lock_page() should do the trick.  Anybody that goes any pulls
> the page out of the page cache has to do a lock_page() and check
> page->mapping before they can establish a pte to it, so you can stop
> that.  Since you're invalidating page->mapping before you move the page
> (you *are* doing this, right?), it will end up working itself out.  

We should know that many part of kernel code will access the page
without holding a lock_page(). The lock_page() can't block them.

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
