Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 73FA86B0071
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 03:17:23 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:17:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm, rmap: allocate anon_vma_chain before starting to
 link anon_vma_chain
Message-ID: <20130807071726.GB32449@lge.com>
References: <1375778620-31593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375778620-31593-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20130807060803.GJ1845@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807060803.GJ1845@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Wed, Aug 07, 2013 at 02:08:03AM -0400, Johannes Weiner wrote:
> >  
> >  	list_for_each_entry_reverse(pavc, &src->anon_vma_chain, same_vma) {
> >  		struct anon_vma *anon_vma;
> >  
> > -		avc = anon_vma_chain_alloc(GFP_NOWAIT | __GFP_NOWARN);
> > -		if (unlikely(!avc)) {
> > -			unlock_anon_vma_root(root);
> > -			root = NULL;
> > -			avc = anon_vma_chain_alloc(GFP_KERNEL);
> > -			if (!avc)
> > -				goto enomem_failure;
> > -		}
> > +		avc = list_entry((&avc_list)->next, typeof(*avc), same_vma);
> 
> list_first_entry() please

Okay. I will send next version soon.

> 
> > +		list_del(&avc->same_vma);
> >  		anon_vma = pavc->anon_vma;
> >  		root = lock_anon_vma_root(root, anon_vma);
> >  		anon_vma_chain_link(dst, avc, anon_vma);
> > @@ -259,8 +262,11 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
> >  	unlock_anon_vma_root(root);
> >  	return 0;
> >  
> > - enomem_failure:
> > -	unlink_anon_vmas(dst);
> > +enomem_failure:
> > +	list_for_each_entry_safe(avc, pavc, &avc_list, same_vma) {
> > +		list_del(&avc->same_vma);
> > +		anon_vma_chain_free(avc);
> > +	}
> >  	return -ENOMEM;
> >  }
> 
> Otherwise, looks good.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
