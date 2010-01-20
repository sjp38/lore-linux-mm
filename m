Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E23E6B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:52:47 -0500 (EST)
Date: Wed, 20 Jan 2010 17:52:42 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: cache alias in mmap + write
Message-ID: <20100120095242.GA5672@desktop>
References: <20100120082610.GA5155@desktop> <20100120174630.4071.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100120174630.4071.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, jamie@shareable.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 20, 2010 at 06:10:11PM +0900, KOSAKI Motohiro wrote:
> Hello,
> 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 96ac6b0..07056fb 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2196,6 +2196,9 @@ again:
> >  		if (unlikely(status))
> >  			break;
> >  
> > +		if (mapping_writably_mapped(mapping))
> > +			flush_dcache_page(page);
> > +
> >  		pagefault_disable();
> >  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
> >  		pagefault_enable();
> 
> I'm not sure ARM cache coherency model. but I guess correct patch is here.
> 
> +		if (mapping_writably_mapped(mapping))
> +			flush_dcache_page(page);
> +
>  		pagefault_disable();
>  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
>  		pagefault_enable();
> -		flush_dcache_page(page);
> 
> 
> Why do we need to call flush_dcache_page() twice?
> 
The latter flush_dcache_page is used to flush the kernel changes
(iov_iter_copy_from_user_atomic), which makes the userspace to see the
write,  and the one I added is used to flush the userspace changes.
And I think it's better to split this function into two:
	flush_dcache_user_page(page);
	kmap_atomic(page);
	write to  page;
	kunmap_atomic(page);
	flush_dcache_kern_page(page);
But currently there is no such API.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
