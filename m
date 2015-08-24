Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8E27B6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:29:45 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so65934721wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:29:45 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id em12si30977679wjd.52.2015.08.24.02.29.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 02:29:44 -0700 (PDT)
Received: by wijp15 with SMTP id p15so71485629wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:29:43 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:29:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150824092942.GA1994@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150824015945.58b25f3a@brouer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824015945.58b25f3a@brouer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <netdev@brouer.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Mon, Aug 24, 2015 at 01:59:45AM +0200, Jesper Dangaard Brouer wrote:
> On Wed, 19 Aug 2015 12:21:45 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Hugh has pointed that compound_head() call can be unsafe in some
> > context. There's one example:
> > 
> [...]
> 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0735bc0a351a..a4c4b7d07473 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> 
> [...]
> > -/*
> > - * If we access compound page synchronously such as access to
> > - * allocated page, there is no need to handle tail flag race, so we can
> > - * check tail flag directly without any synchronization primitive.
> > - */
> > -static inline struct page *compound_head_fast(struct page *page)
> > -{
> > -	if (unlikely(PageTail(page)))
> > -		return page->first_page;
> > -	return page;
> > -}
> > -
> [...]
> 
> > @@ -548,13 +508,7 @@ static inline struct page *virt_to_head_page(const void *x)
> >  {
> >  	struct page *page = virt_to_page(x);
> >  
> > -	/*
> > -	 * We don't need to worry about synchronization of tail flag
> > -	 * when we call virt_to_head_page() since it is only called for
> > -	 * already allocated page and this page won't be freed until
> > -	 * this virt_to_head_page() is finished. So use _fast variant.
> > -	 */
> > -	return compound_head_fast(page);
> > +	return compound_head(page);
> >  }
> 
> I hope this does not slow down the SLAB/slub allocator?
> (which calls virt_to_head_page() frequently)

It should be slightly faster.

Before:

00002e90 <test_virt_to_head_page>:
    2e90:	8b 15 00 00 00 00    	mov    0x0,%edx
    2e96:	05 00 00 00 40       	add    $0x40000000,%eax
    2e9b:	c1 e8 0c             	shr    $0xc,%eax
    2e9e:	c1 e0 05             	shl    $0x5,%eax
    2ea1:	01 d0                	add    %edx,%eax
    2ea3:	8b 10                	mov    (%eax),%edx
    2ea5:	f6 c6 80             	test   $0x80,%dh
    2ea8:	75 06                	jne    2eb0 <test_virt_to_head_page+0x20>
    2eaa:	c3                   	ret    
    2eab:	90                   	nop
    2eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    2eb0:	8b 40 1c             	mov    0x1c(%eax),%eax
    2eb3:	c3                   	ret    

After:

00003070 <test_virt_to_head_page>:
    3070:	8b 15 00 00 00 00    	mov    0x0,%edx
    3076:	05 00 00 00 40       	add    $0x40000000,%eax
    307b:	c1 e8 0c             	shr    $0xc,%eax
    307e:	c1 e0 05             	shl    $0x5,%eax
    3081:	01 d0                	add    %edx,%eax
    3083:	8b 50 14             	mov    0x14(%eax),%edx
    3086:	8d 4a ff             	lea    -0x1(%edx),%ecx
    3089:	f6 c2 01             	test   $0x1,%dl
    308c:	0f 45 c1             	cmovne %ecx,%eax
    308f:	c3                   	ret    

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
