Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 734C26B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 10:22:37 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AE78882C473
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 10:22:36 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id I6ZuUZEi6Gqm for <linux-mm@kvack.org>;
	Thu, 12 Nov 2009 10:22:36 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E114D82C474
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 10:22:31 -0500 (EST)
Date: Thu, 12 Nov 2009 10:20:29 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] show per-process swap usage via procfs v3
In-Reply-To: <20091111112539.71dfac31.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911121017180.28271@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com> <20091106084806.7503b165.kamezawa.hiroyu@jp.fujitsu.com> <20091106134030.a94665d1.kamezawa.hiroyu@jp.fujitsu.com>
 <28c262360911060719y45f4b58ex2f13853f0d142656@mail.gmail.com> <20091111112539.71dfac31.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:

>
> Index: mm-test-kernel/include/linux/mm_types.h
> ===================================================================
> --- mm-test-kernel.orig/include/linux/mm_types.h
> +++ mm-test-kernel/include/linux/mm_types.h
> @@ -228,6 +228,7 @@ struct mm_struct {
>  	 */
>  	mm_counter_t _file_rss;
>  	mm_counter_t _anon_rss;
> +	mm_counter_t _swap_usage;

This is going to be another hit on vm performance if we get down this
road.

At least put

#ifdef CONFIG_SWAP ?

around this so that we can switch it off?

> @@ -597,7 +600,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  						 &src_mm->mmlist);
>  				spin_unlock(&mmlist_lock);
>  			}
> -			if (is_write_migration_entry(entry) &&
> +			if (!non_swap_entry(entry))
> +				rss[2]++;
> +			else if (is_write_migration_entry(entry) &&
>  					is_cow_mapping(vm_flags)) {
>  				/*

What are the implications for fork performance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
