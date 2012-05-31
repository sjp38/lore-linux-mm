Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0B7326B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:25:16 -0400 (EDT)
Date: Thu, 31 May 2012 13:25:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] tmpfs not interleaving properly
Message-Id: <20120531132515.6af60152.akpm@linux-foundation.org>
In-Reply-To: <4FC7CFEB.5040009@gmail.com>
References: <20120531143916.GA16162@gulag1.americas.sgi.com>
	<4FC7CFEB.5040009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, hughd@google.com, npiggin@gmail.com, cl@linux.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, riel@redhat.com

On Thu, 31 May 2012 16:09:15 -0400
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -929,7 +929,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
> >   	/*
> >   	 * alloc_page_vma() will drop the shared policy reference
> >   	 */
> > -	return alloc_page_vma(gfp,&pvma, 0);
> > +	return alloc_page_vma(gfp,&pvma, info->node_offset<<  PAGE_SHIFT );
> 
> 3rd argument of alloc_page_vma() is an address. This is type error.

Well, it's an unsigned long...

But yes, it is conceptually wrong and *looks* weird.  I think we can
address that by overcoming our peculair aversion to documenting our
code, sigh.  This?

--- a/mm/shmem.c~tmpfs-implement-numa-node-interleaving-fix
+++ a/mm/shmem.c
@@ -927,9 +927,12 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 
 	/*
-	 * alloc_page_vma() will drop the shared policy reference
+	 * alloc_page_vma() will drop the shared policy reference.
+	 *
+	 * To avoid allocating all tmpfs pages on node 0, we fake up a virtual
+	 * address based on this file's predetermined preferred node.
 	 */
-	return alloc_page_vma(gfp, &pvma, info->node_offset << PAGE_SHIFT );
+	return alloc_page_vma(gfp, &pvma, info->node_offset << PAGE_SHIFT);
 }
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
