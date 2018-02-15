Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED2F46B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 18:10:35 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id e64so66186itd.1
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:10:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h10sor4390626ioh.275.2018.02.15.15.10.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 15:10:34 -0800 (PST)
Date: Thu, 15 Feb 2018 17:10:27 -0600
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH 2/3] percpu: add __GFP_NORETRY semantics to the percpu
 balancing path
Message-ID: <20180215231027.GA79973@localhost>
References: <cover.1518668149.git.dennisszhou@gmail.com>
 <d51c5dc100f0d7423bbf5bb32760f91646097b9f.1518668149.git.dennisszhou@gmail.com>
 <20180215213909.GU695913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215213909.GU695913@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tejun,

On Thu, Feb 15, 2018 at 01:39:09PM -0800, Tejun Heo wrote:
> On Thu, Feb 15, 2018 at 10:08:15AM -0600, Dennis Zhou wrote:
> > -static struct pcpu_chunk *pcpu_create_chunk(void)
> > +static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
> >  {
> >  	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
> >  	struct pcpu_chunk *chunk;
> >  	struct page *pages;
> >  	int i;
> >  
> > -	chunk = pcpu_alloc_chunk();
> > +	chunk = pcpu_alloc_chunk(gfp);
> >  	if (!chunk)
> >  		return NULL;
> >  
> > -	pages = alloc_pages(GFP_KERNEL, order_base_2(nr_pages));
> > +	pages = alloc_pages(gfp | GFP_KERNEL, order_base_2(nr_pages));
> 
> Is there a reason to set GFP_KERNEL in this function?  I'd prefer
> pushing this to the callers.
> 

Not particularly. As I wasn't sure of the original decision to use
GFP_KERNEL for all percpu underlying allocations, I didn't want to
add the gfp passthrough and remove functionality.

> > diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
> > index 9158e5a..ea9906a 100644
> > --- a/mm/percpu-vm.c
> > +++ b/mm/percpu-vm.c
> > @@ -37,7 +37,7 @@ static struct page **pcpu_get_pages(void)
> >  	lockdep_assert_held(&pcpu_alloc_mutex);
> >  
> >  	if (!pages)
> > -		pages = pcpu_mem_zalloc(pages_size);
> > +		pages = pcpu_mem_zalloc(pages_size, 0);
>                                                   ^^^^
> 						  because this is confusing

Yeah.. The next patch removes this as the additional gfp flags is weird.

> >  static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
> > -			    struct page **pages, int page_start, int page_end)
> > +			    struct page **pages, int page_start, int page_end,
> > +			    gfp_t gfp)
> >  {
> > -	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM;
> >  	unsigned int cpu, tcpu;
> >  	int i;
> >  
> > +	gfp |=  GFP_KERNEL | __GFP_HIGHMEM;
>               ^^
> 	      double space
> 

I'll fix this with any other updates.

> So, setting __GFP_HIGHMEM unconditionally here makes sense because
> it's indicating the types of pages we can use (we also accept high
> pages); however, I'm not sure GFP_KERNEL makes sense.  That's about
> "how to allocate" and looks like it should be left to the caller.
> 

That makes sense, I can remove the forced GFP_KERNEL use in the next
patch as that patch moves the flags to the caller.

I'd rather be explicit though and whitelist GFP_KERNEL as I don't have a
full grasp of all the flags. Our use case is a little different because
we ultimately become the owner of the pages until the chunk is freed. So
there are certain flags such as __GFP_HARDWALL (poor example), the
difference between GFP_KERNEL and GFP_USER, which don't make sense here.

Regarding high pages, I think you're referring to GFP_ATOMIC
allocations? We actually never allocate on this path as allocations must
be served out of parts of chunks that are already backed.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
