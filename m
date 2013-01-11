Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id B910D6B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 02:52:56 -0500 (EST)
Date: Fri, 11 Jan 2013 16:52:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
Message-ID: <20130111075253.GB2346@lge.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
 <1356449082-3016-1-git-send-email-js1304@gmail.com>
 <CAAmzW4Nz6if==JjxLQGYwwQwKPDXfUbeioyPHWZQQFNu=xXUeQ@mail.gmail.com>
 <CAAvDA17eH0A_pr9siX7PTipe=Jd7WFZxR7mkUi6K0_djkH=FPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAvDA17eH0A_pr9siX7PTipe=Jd7WFZxR7mkUi6K0_djkH=FPA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Hargrove <phhargrove@lbl.gov>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Jan 10, 2013 at 08:47:39PM -0800, Paul Hargrove wrote:
> I just had a look at patch-3.7.2-rc1, and this change doesn't appear to
> have made it in yet.
> Am I missing something?
> 
> -Paul

I try to check it.
Ccing to Greg.

Hello, Pekka and Greg.

v3.8-rcX has already fixed by another stuff, but it is not simple change.
So I made a new patch and sent it.

How this kind of patch (only for stable v3.7) go into stable tree?
through Pekka's slab tree? or send it to Greg, directly?

I don't know how to submit this kind of patch to stable tree exactly.
Could anyone help me?

Thanks.

> On Tue, Dec 25, 2012 at 7:30 AM, JoonSoo Kim <js1304@gmail.com> wrote:
> 
> > 2012/12/26 Joonsoo Kim <js1304@gmail.com>:
> > > commit cce89f4f6911286500cf7be0363f46c9b0a12ce0('Move kmem_cache
> > > refcounting to common code') moves some refcount manipulation code to
> > > common code. Unfortunately, it also removed refcount assignment for
> > > kmalloc_caches. So, kmalloc_caches's refcount is initially 0.
> > > This makes errornous situation.
> > >
> > > Paul Hargrove report that when he create a 8-byte kmem_cache and
> > > destory it, he encounter below message.
> > > 'Objects remaining in kmalloc-8 on kmem_cache_close()'
> > >
> > > 8-byte kmem_cache merge with 8-byte kmalloc cache and refcount is
> > > increased by one. So, resulting refcount is 1. When destory it, it hit
> > > refcount = 0, then kmem_cache_close() is executed and error message is
> > > printed.
> > >
> > > This patch assign initial refcount 1 to kmalloc_caches, so fix this
> > > errornous situtation.
> > >
> > > Cc: <stable@vger.kernel.org> # v3.7
> > > Cc: Christoph Lameter <cl@linux.com>
> > > Reported-by: Paul Hargrove <phhargrove@lbl.gov>
> > > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> > >
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index a0d6984..321afab 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -3279,6 +3279,7 @@ static struct kmem_cache *__init
> > create_kmalloc_cache(const char *name,
> > >         if (kmem_cache_open(s, flags))
> > >                 goto panic;
> > >
> > > +       s->refcount = 1;
> > >         list_add(&s->list, &slab_caches);
> > >         return s;
> > >
> > > --
> > > 1.7.9.5
> > >
> >
> > I missed some explanation.
> > In v3.8-rc1, this problem is already solved.
> > See create_kmalloc_cache() in mm/slab_common.c.
> > So this patch is just for v3.7 stable.
> >
> 
> 
> 
> -- 
> Paul H. Hargrove                          PHHargrove@lbl.gov
> Future Technologies Group
> Computer and Data Sciences Department     Tel: +1-510-495-2352
> Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
