Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FF636B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:42:52 -0500 (EST)
Message-ID: <4B7F05BA.4080903@redhat.com>
Date: Fri, 19 Feb 2010 16:42:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] mm: Share the anon_vma ref counts between KSM and
 page migration
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1266516162-14154-4-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/18/2010 01:02 PM, Mel Gorman wrote:

>   struct anon_vma {
>   	spinlock_t lock;	/* Serialize access to vma list */
> -#ifdef CONFIG_KSM
> -	atomic_t ksm_refcount;
> -#endif
> -#ifdef CONFIG_MIGRATION
> -	atomic_t migrate_refcount;
> +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
> +
> +	/*
> +	 * The refcount is taken by either KSM or page migration
> +	 * to take a reference to an anon_vma when there is no
> +	 * guarantee that the vma of page tables will exist for
> +	 * the duration of the operation. A caller that takes
> +	 * the reference is responsible for clearing up the
> +	 * anon_vma if they are the last user on release
> +	 */
> +	atomic_t refcount;

Calling it just refcount is probably confusing, since
the anon_vma is also referenced by being on the chain
with others.

Maybe "other_refcount" because it is refcounts taken
by things other than VMAs?  I am sure there is a better
name possible...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
