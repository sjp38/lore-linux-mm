Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 191926B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:03:20 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id rl12so2273321iec.39
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:03:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bq4si8022021icb.44.2014.06.25.15.03.19
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 15:03:19 -0700 (PDT)
Date: Wed, 25 Jun 2014 15:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
Message-Id: <20140625150318.4355468ab59a5293e870605e@linux-foundation.org>
In-Reply-To: <20140624201614.18273.39034.stgit@zurg>
References: <20140624201606.18273.44270.stgit@zurg>
	<20140624201614.18273.39034.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Wed, 25 Jun 2014 00:16:14 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch prints warning (if CONFIG_DEBUG_VM=y) when
> memory commitment becomes too negative.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -134,6 +134,12 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  {
>  	unsigned long free, allowed, reserve;
>  
> +#ifdef CONFIG_DEBUG_VM
> +	WARN_ONCE(percpu_counter_read(&vm_committed_as) <
> +			-(s64)vm_committed_as_batch * num_online_cpus(),
> +			"memory commitment underflow");
> +#endif
> +
>  	vm_acct_memory(pages);

The changelog doesn't describe the reasons for making the change.

I assume this warning will detect the situation which the previous two
patches just fixed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
