Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDDC8E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 03:04:32 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id r11so2663951wmg.1
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 00:04:32 -0800 (PST)
Received: from mail.osadl.at (178.115.242.59.static.drei.at. [178.115.242.59])
        by mx.google.com with ESMTP id u187si9604652wmf.22.2018.12.22.00.04.30
        for <linux-mm@kvack.org>;
        Sat, 22 Dec 2018 00:04:30 -0800 (PST)
Date: Sat, 22 Dec 2018 09:04:21 +0100
From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181222080421.GB26155@osadl.at>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nicholas Mc Guire <hofrat@osadl.org>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 871e41c..1c118d7 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> >  
> >  	/* Import existing vmlist entries. */
> >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> >  		va->flags = VM_VM_AREA;
> >  		va->va_start = (unsigned long)tmp->addr;
> >  		va->va_end = va->va_start + tmp->size;
> 
> Hi Nicholas,
> 
> You're right that this looks wrong because there's no guarantee that va is 
> actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> we're not giving the page allocator a chance to reclaim so this would 
> likely just end up looping forever instead of crashing with a NULL pointer 
> dereference, which would actually be the better result.
>
tried tracing the __GFP_NOFAIL path and had concluded that it would
end in out_of_memory() -> panic("System is deadlocked on memory\n");
which also should point cleanly to the cause - but I�m actually not
that sure if that trace was correct in all cases.
 
> You could do
> 
> 	BUG_ON(!va);
> 
> to make it obvious why we crashed, however.  It makes it obvious that the 
> crash is intentional rather than some error in the kernel code.

makes sense - that atleast makes it imediately clear from the code
that there is no way out from here.

thx!
hofrat
