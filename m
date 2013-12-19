Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF42B6B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:16:15 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so273449eek.20
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:16:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si3408207eel.154.2013.12.19.01.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:16:15 -0800 (PST)
Date: Thu, 19 Dec 2013 10:16:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/6] slab: cleanup kmem_cache_create_memcg()
Message-ID: <20131219091614.GE9331@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <20131218165603.GB31080@dhcp22.suse.cz>
 <52B292CF.5030002@parallels.com>
 <20131219084447.GA9331@dhcp22.suse.cz>
 <52B2B39A.7070303@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B2B39A.7070303@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 19-12-13 12:51:38, Vladimir Davydov wrote:
> On 12/19/2013 12:44 PM, Michal Hocko wrote:
> > On Thu 19-12-13 10:31:43, Vladimir Davydov wrote:
> >> On 12/18/2013 08:56 PM, Michal Hocko wrote:
> >>> On Wed 18-12-13 17:16:52, Vladimir Davydov wrote:
> >>>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> >>>> Cc: Michal Hocko <mhocko@suse.cz>
> >>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >>>> Cc: Glauber Costa <glommer@gmail.com>
> >>>> Cc: Christoph Lameter <cl@linux.com>
> >>>> Cc: Pekka Enberg <penberg@kernel.org>
> >>>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Dunno, is this really better to be worth the code churn?
> >>>
> >>> It even makes the generated code tiny bit bigger:
> >>> text    data     bss     dec     hex filename
> >>> 4355     171     236    4762    129a mm/slab_common.o.after
> >>> 4342     171     236    4749    128d mm/slab_common.o.before
> >>>
> >>> Or does it make the further changes much more easier? Be explicit in the
> >>> patch description if so.
> >> Hi, Michal
> >>
> >> IMO, undoing under labels looks better than inside conditionals, because
> >> we don't have to repeat the same deinitialization code then, like this
> >> (note three calls to kmem_cache_free()):
> > Agreed but the resulting code is far from doing nice undo on different
> > conditions. You have out_free_cache which frees everything regardless
> > whether name or cache registration failed. So it doesn't help with
> > readability much IMO.
> 
> AFAIK it's common practice not to split kfree's to be called under
> different labels on fail paths, because kfree(NULL) results in a no-op.
> Since on undo, we only call kfree, I introduce the only label. Of course
> I could do something like
> 
>     s->name=...
>     if (!s->name)
>         goto out_free_name;
>     err = __kmem_new_cache(...)
>     if (err)
>         goto out_free_name;
> <...>
> out_free_name:
>     kfree(s->name);
> out_free_cache:
>     kfree(s);
>     goto out_unlock;
> 
> But I think using only out_free_cache makes the code look clearer.

I disagree. It is much easier to review code for mem leaks when you have
explicit cleanup gotos. But this is a matter of taste I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
