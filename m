Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC8E6B0397
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:41:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a80so229669wrc.19
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:41:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h130si3761946wmh.133.2017.04.11.09.41.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 09:41:40 -0700 (PDT)
Date: Tue, 11 Apr 2017 18:41:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170411164134.GA21171@dhcp22.suse.cz>
References: <20170404151600.GN15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz>
 <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 11-04-17 11:16:42, Cristopher Lameter wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
> 
> >  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
> > @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
> >  {
> >  	struct kmem_cache *c;
> >  	unsigned long flags;
> > +	struct page *page;
> >
> >  	trace_kfree(_RET_IP_, objp);
> >
> >  	if (unlikely(ZERO_OR_NULL_PTR(objp)))
> >  		return;
> > +	page = virt_to_head_page(obj);
> > +	if (CHECK_DATA_CORRUPTION(!PageSlab(page)))
> 
> There is a flag SLAB_DEBUG_OBJECTS that is available for this check.

Which is way too late, at least for the kfree path. page->slab_cache
on anything else than PageSlab is just a garbage. And my understanding
of the patch objective is to stop those from happening.

> Consistency checks are configuraable in the slab allocator.

and they have to be compiled in (at least for SLAB) AFAIR.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
