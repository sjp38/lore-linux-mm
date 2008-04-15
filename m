Received: by py-out-1112.google.com with SMTP id f47so1635116pye.20
        for <linux-mm@kvack.org>; Mon, 14 Apr 2008 19:28:47 -0700 (PDT)
Subject: Re: [PATCH] use vmalloc for mem_cgroup allocation. v2
From: Harvey Harrison <harvey.harrison@gmail.com>
In-Reply-To: <20080414192042.c50d8d58.akpm@linux-foundation.org>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080415111038.ffac0e12.kamezawa.hiroyu@jp.fujitsu.com>
	 <48040E19.2090007@cn.fujitsu.com>
	 <20080414192042.c50d8d58.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 14 Apr 2008 19:28:48 -0700
Message-Id: <1208226528.11920.55.camel@brick>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-04-14 at 19:20 -0700, Andrew Morton wrote:
> On Tue, 15 Apr 2008 10:08:25 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > @@ -992,8 +993,10 @@ mem_cgroup_create(struct cgroup_subsys *
> > >  	if (unlikely((cont->parent) == NULL)) {
> > >  		mem = &init_mem_cgroup;
> > >  		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> > > -	} else
> > > -		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
> > > +	} else {
> > > +		mem = vmalloc(sizeof(struct mem_cgroup));
> > > +		memset(mem, 0, sizeof(*mem));
> > 
> > what if mem == NULL. ;)
> > 
> > > +	}
> > >  
> > >  	if (mem == NULL)
> > >  		return ERR_PTR(-ENOMEM);
> > 
> > So we can move this NULL check to the above else branch, in the if brach,
> > mem won't be NULL.
> 
> err, yes.
> 
> So I have:
> 
> 	if (unlikely((cont->parent) == NULL)) {

	if (unlikely(cont->parent == NULL)) {

> 		mem = &init_mem_cgroup;
> 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
> 	} else {
> 		mem = vmalloc(sizeof(struct mem_cgroup));
> 		if (mem == NULL)

		if (!mem)

> 			return ERR_PTR(-ENOMEM);
> 		memset(mem, 0, sizeof(*mem));
> 	}
> 

Cheers,

Harvey


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
