Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 04D606B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 22:52:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G2qOoK002840
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Sep 2009 11:52:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FC4D45DE51
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:52:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2121145DE4F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:52:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 022C91DB803A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:52:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A67CE1DB803F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:52:23 +0900 (JST)
Date: Wed, 16 Sep 2009 11:50:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] devmem: check vmalloc address on kmem read/write
Message-Id: <20090916115015.0aeddc01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090916014958.836124324@intel.com>
References: <20090916013939.656308742@intel.com>
	<20090916014958.836124324@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Greg Kroah-Hartman <gregkh@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 09:39:41 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Otherwise vmalloc_to_page() will BUG().
> 
> This also makes the kmem read/write implementation aligned with mem(4):
> "References to nonexistent locations cause errors to be returned." Here
> we return -ENXIO (inspired by Hugh) if no bytes have been transfered
> to/from user space, otherwise return partial read/write results.
> 
seems reasonable.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> CC: Greg Kroah-Hartman <gregkh@suse.de>
> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  drivers/char/mem.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> --- linux-mm.orig/drivers/char/mem.c	2009-09-16 08:52:17.000000000 +0800
> +++ linux-mm/drivers/char/mem.c	2009-09-16 09:15:03.000000000 +0800
> @@ -443,6 +443,10 @@ static ssize_t read_kmem(struct file *fi
>  			return -ENOMEM;
>  		while (count > 0) {
>  			sz = size_inside_page(p, count);
> +			if (!is_vmalloc_or_module_addr((void *)p)) {
> +				err = -ENXIO;
> +				break;
> +			}
>  			err = vread(kbuf, (char *)p, sz);
>  			if (err)
>  				break;
> @@ -543,6 +547,10 @@ static ssize_t write_kmem(struct file * 
>  			unsigned long sz = size_inside_page(p, count);
>  			unsigned long n;
>  
> +			if (!is_vmalloc_or_module_addr((void *)p)) {
> +				err = -ENXIO;
> +				break;
> +			}
>  			n = copy_from_user(kbuf, buf, sz);
>  			if (n) {
>  				err = -EFAULT;
> 
> -- 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
