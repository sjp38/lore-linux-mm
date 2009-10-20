Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9FFC6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 16:41:39 -0400 (EDT)
Date: Tue, 20 Oct 2009 14:41:36 -0600
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH 4/5] mm: add numa node symlink for cpu devices in sysfs
Message-ID: <20091020204136.GB23675@ldl.fc.hp.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213430.32729.78995.stgit@bob.kio> <alpine.DEB.1.00.0910192016010.25264@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0910192016010.25264@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com>:
> On Mon, 19 Oct 2009, Alex Chiang wrote:
> 
> > You can discover which CPUs belong to a NUMA node by examining
> > /sys/devices/system/node/$node/
> > 
> 
> You mean /sys/devices/system/node/node# ?

Hm, in PCI land, I've been using $foo to indicate a variable in
documentation I've written, but I can certainly use foo# if
that's the preferred style.

> > However, it's not convenient to go in the other direction, when looking at
> > /sys/devices/system/cpu/$cpu/
> > 
> 
> .../cpu/cpu# ?
> 
> > Yes, you can muck about in sysfs, but adding these symlinks makes
> > life a lot more convenient.
> > 
> > Signed-off-by: Alex Chiang <achiang@hp.com>
> > ---
> > 
> >  drivers/base/node.c |    9 ++++++++-
> >  1 files changed, 8 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > index ffda067..47a4997 100644
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -227,6 +227,7 @@ struct node node_devices[MAX_NUMNODES];
> >   */
> >  int register_cpu_under_node(unsigned int cpu, unsigned int nid)
> >  {
> > +	int ret;
> >  	struct sys_device *obj;
> >  
> >  	if (!node_online(nid))
> > @@ -236,9 +237,13 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
> >  	if (!obj)
> >  		return 0;
> >  
> > -	return sysfs_create_link(&node_devices[nid].sysdev.kobj,
> > +	ret = sysfs_create_link(&node_devices[nid].sysdev.kobj,
> >  				&obj->kobj,
> >  				kobject_name(&obj->kobj));
> > +
> > +	return sysfs_create_link(&obj->kobj,
> > +				 &node_devices[nid].sysdev.kobj,
> > +				 kobject_name(&node_devices[nid].sysdev.kobj));
> >  }
> >  
> >  int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
> 
> That can't be right, you're ignoring the return value of the first 
> sysfs_create_link().

This was a simple oversight. my intent was to return early if the
first call to sysfs_create_link() failed.

> The return values of register_cpu_under_node() and 
> unregister_cpu_under_node() are always ignored, so it would probably be 
> best to convert these to be void functions.  That doesn't mean you can 
> simply ignore the result of the first sysfs_create_link(), though: the 
> second should probably be suppressed if the first returns an error.
> 

I didn't want to change too much in the patch. Changing the
function signature seems a bit overeager, but if you have strong
feelings, I can do so.

Thanks for the review.

/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
