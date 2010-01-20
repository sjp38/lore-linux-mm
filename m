Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 68FCE6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:10:16 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K9ADwc026918
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Jan 2010 18:10:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75CDE45DE54
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:10:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2393C45DE51
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:10:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D24671DB8042
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:10:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE9E5E38002
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:10:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: cache alias in mmap + write
In-Reply-To: <20100120082610.GA5155@desktop>
References: <20100120082610.GA5155@desktop>
Message-Id: <20100120174630.4071.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Jan 2010 18:10:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, jamie@shareable.org
List-ID: <linux-mm.kvack.org>

Hello,

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 96ac6b0..07056fb 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2196,6 +2196,9 @@ again:
>  		if (unlikely(status))
>  			break;
>  
> +		if (mapping_writably_mapped(mapping))
> +			flush_dcache_page(page);
> +
>  		pagefault_disable();
>  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
>  		pagefault_enable();

I'm not sure ARM cache coherency model. but I guess correct patch is here.

+		if (mapping_writably_mapped(mapping))
+			flush_dcache_page(page);
+
 		pagefault_disable();
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		pagefault_enable();
-		flush_dcache_page(page);


Why do we need to call flush_dcache_page() twice?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
