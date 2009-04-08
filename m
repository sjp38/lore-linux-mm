Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A254F5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 23:41:48 -0400 (EDT)
From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH 1/2] Avoid putting a bad page back on the LRU
Date: Wed, 8 Apr 2009 05:43:15 +0200
References: <20090408001133.GB27170@sgi.com>
In-Reply-To: <20090408001133.GB27170@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904080543.16454.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Hi Russ,

On Wednesday 08 April 2009, Russ Anderson wrote:
> --- linux-next.orig/mm/migrate.c	2009-04-07 18:32:12.781949840 -0500
> +++ linux-next/mm/migrate.c	2009-04-07 18:34:19.169736260 -0500
> @@ -693,6 +696,26 @@ unlock:
>   		 * restored.
>   		 */
>   		list_del(&page->lru);
> +#ifdef CONFIG_MEMORY_FAILURE
> +		if (PagePoison(page)) {
> +			if (rc == 0)
> +				/*
> +				 * A page with a memory error that has
> +				 * been migrated will not be moved to
> +				 * the LRU.
> +				 */
> +				goto move_newpage;
> +			else
> +				/*
> +				 * The page failed to migrate and will not
> +				 * be added to the bad page list.  Clearing
> +				 * the error bit will allow another attempt
> +				 * to migrate if it gets another correctable
> +				 * error.
> +				 */
> +				ClearPagePoison(page);

Clearing the flag doesn't change the fact, that this page is representing 
permanently bad RAM.

What about removing it from the LRU and adding it to a bad RAM list in every case?
After hot swapping the physical RAM banks it could be moved back, not before.


Best Regards

Ingo Oeser

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
