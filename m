Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 441CF6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:10:09 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L1A5bi011622
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 Jan 2010 10:10:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67B5D45DE51
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:10:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 468AB45DE52
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:10:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A953E08003
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:10:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3B551DB803C
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:10:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: cache alias in mmap + write
In-Reply-To: <20100120095242.GA5672@desktop>
References: <20100120174630.4071.A69D9226@jp.fujitsu.com> <20100120095242.GA5672@desktop>
Message-Id: <20100121094733.3778.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 Jan 2010 10:10:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, jamie@shareable.org
List-ID: <linux-mm.kvack.org>

> On Wed, Jan 20, 2010 at 06:10:11PM +0900, KOSAKI Motohiro wrote:
> > Hello,
> > 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index 96ac6b0..07056fb 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -2196,6 +2196,9 @@ again:
> > >  		if (unlikely(status))
> > >  			break;
> > >  
> > > +		if (mapping_writably_mapped(mapping))
> > > +			flush_dcache_page(page);
> > > +
> > >  		pagefault_disable();
> > >  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
> > >  		pagefault_enable();
> > 
> > I'm not sure ARM cache coherency model. but I guess correct patch is here.
> > 
> > +		if (mapping_writably_mapped(mapping))
> > +			flush_dcache_page(page);
> > +
> >  		pagefault_disable();
> >  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
> >  		pagefault_enable();
> > -		flush_dcache_page(page);
> > 
> > Why do we need to call flush_dcache_page() twice?
> > 
> The latter flush_dcache_page is used to flush the kernel changes
> (iov_iter_copy_from_user_atomic), which makes the userspace to see the
> write,  and the one I added is used to flush the userspace changes.
> And I think it's better to split this function into two:
> 	flush_dcache_user_page(page);
> 	kmap_atomic(page);
> 	write to  page;
> 	kunmap_atomic(page);
> 	flush_dcache_kern_page(page);
> But currently there is no such API.

Why can't we create new api? this your pseudo code looks very fine to me.


note: if you don't like to create new api. I can agree your current patch.
but I have three requests.
 1. Move flush_dcache_page() into iov_iter_copy_from_user_atomic().
    Your above explanation indicate it is real intention. plus, change
    iov_iter_copy_from_user_atomic() fixes fuse too.
 2. Add some commnet. almost developer only have x86 machine. so, arm
    specific trick need additional explicit explanation. otherwise anybody
    might break this code in the future.
 3. Resend the patch. original mail isn't good patch format. please consider
    to reduce akpm suffer.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
