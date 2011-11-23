Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 43DBE6B0075
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 00:34:30 -0500 (EST)
Received: by iaek3 with SMTP id k3so1473841iae.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 21:34:27 -0800 (PST)
Date: Tue, 22 Nov 2011 21:34:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm/vmalloc.c: eliminate extra loop in pcpu_get_vm_areas
 error path
In-Reply-To: <20111118115955.410af035.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1111222134080.21009@chino.kir.corp.google.com>
References: <1321616630-28281-1-git-send-email-consul.kautuk@gmail.com> <20111118115955.410af035.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kautuk Consul <consul.kautuk@gmail.com>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Nov 2011, Andrew Morton wrote:

> > If either of the vas or vms arrays are not properly kzalloced,
> > then the code jumps to the err_free label.
> > 
> > The err_free label runs a loop to check and free each of the array
> > members of the vas and vms arrays which is not required for this
> > situation as none of the array members have been allocated till this
> > point.
> > 
> > Eliminate the extra loop we have to go through by introducing a new
> > label err_free2 and then jumping to it.
> > 
> > Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> > ---
> >  mm/vmalloc.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index b669aa6..1a0d4e2 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2352,7 +2352,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
> >  	vms = kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
> >  	vas = kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
> >  	if (!vas || !vms)
> > -		goto err_free;
> > +		goto err_free2;
> >  
> >  	for (area = 0; area < nr_vms; area++) {
> >  		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
> > @@ -2455,6 +2455,7 @@ err_free:
> >  		if (vms)
> >  			kfree(vms[area]);
> >  	}
> > +err_free2:
> >  	kfree(vas);
> >  	kfree(vms);
> >  	return NULL;
> 
> Which means we can also do the below, yes?  (please check my homework!)
> 
> --- a/mm/vmalloc.c~mm-vmallocc-eliminate-extra-loop-in-pcpu_get_vm_areas-error-path-fix
> +++ a/mm/vmalloc.c
> @@ -2449,10 +2449,8 @@ found:
>  
>  err_free:
>  	for (area = 0; area < nr_vms; area++) {
> -		if (vas)
> -			kfree(vas[area]);
> -		if (vms)
> -			kfree(vms[area]);
> +		kfree(vas[area]);
> +		kfree(vms[area]);
>  	}
>  err_free2:
>  	kfree(vas);

On both patches:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
