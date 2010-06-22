Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7CE1E6B01AC
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 17:10:46 -0400 (EDT)
Date: Tue, 22 Jun 2010 23:10:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH -mm 2/6] rmap: always add new vmas at the end
Message-ID: <20100622211040.GQ5787@random.random>
References: <20100621163146.4e4e30cb@annuminas.surriel.com>
 <20100621163349.7dbd1ef6@annuminas.surriel.com>
 <20100622140822.3d290151.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622140822.3d290151.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 02:08:22PM -0700, Andrew Morton wrote:
> On Mon, 21 Jun 2010 16:33:49 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > Subject: always add new vmas at the end
> > 
> > Make sure to always add new VMAs at the end of the list.  This
> > is important so rmap_walk does not miss a VMA that was created
> > during the rmap_walk.
> > 
> > The old code got this right most of the time due to luck, but
> > was buggy when anon_vma_prepare reused a mergeable anon_vma.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Rik van Riel <riel@redhat.com>
> > ---
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -149,7 +149,7 @@ int anon_vma_prepare(struct vm_area_stru
> >  			avc->anon_vma = anon_vma;
> >  			avc->vma = vma;
> >  			list_add(&avc->same_vma, &vma->anon_vma_chain);
> > -			list_add(&avc->same_anon_vma, &anon_vma->head);
> > +			list_add_tail(&avc->same_anon_vma, &anon_vma->head);
> >  			allocated = NULL;
> >  			avc = NULL;
> >  		}
> 
> Should this go into 2.6.35?

Well migrate got broken anyway in 2.6.34, so until the whole
root-anon-vma patchqueue is merged, it's not going to provide a safe
migrate anyway and it can as well wait with the rest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
