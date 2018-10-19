Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDE7F6B0007
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 21:17:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e5-v6so19660583eda.4
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 18:17:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19-v6sor16291127edj.8.2018.10.18.18.17.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 18:17:48 -0700 (PDT)
MIME-Version: 1.0
References: <20181009063500.GB3555@osiris> <CAFgQCTsnWRyN--dS0oVCzPykkt33M=9so2sv2a3+iu-kCdpV7A@mail.gmail.com>
 <CAFgQCTtQ2+bu44top5Fy=7KWRVrpFLnsRGupksK1ixR9oFZs+g@mail.gmail.com> <20181016073629.GA3194@osiris>
In-Reply-To: <20181016073629.GA3194@osiris>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 19 Oct 2018 09:17:36 +0800
Message-ID: <CAFgQCTsRP_gEMzDo6jYTeFMmkRJDPxg_sAUDWQ2Xpa=HpbqejQ@mail.gmail.com>
Subject: Re: [BUG -next 20181008] list corruption with "mm/slub: remove
 useless condition in deactivate_slab"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: heiko.carstens@de.ibm.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 16, 2018 at 3:36 PM Heiko Carstens
<heiko.carstens@de.ibm.com> wrote:
>
> On Tue, Oct 16, 2018 at 02:29:28PM +0800, Pingfan Liu wrote:
> > > I think it is caused by the uinon page->lru and page->next. It can be fixed by:
> > > diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> > > index 3a1a1db..4aa0fb5 100644
> > > --- a/include/linux/slub_def.h
> > > +++ b/include/linux/slub_def.h
> > > @@ -56,6 +56,7 @@ struct kmem_cache_cpu {
> > >  #define slub_set_percpu_partial(c, p)          \
> > >  ({                                             \
> > >         slub_percpu_partial(c) = (p)->next;     \
> > > +       p->next = NULL; \
> > >  })
> > >
> > > I will do some test and post the fix.
> > >
> > Please ignore the above comment. And after re-check the code, I am
> > sure that all callers of deactivate_slab(), pass c->page, which means
> > that page should not be on any list. But your test result "list_add
> > double add: new=000003d1029ecc08,
> > prev=000000008ff846d0,next=000003d1029ecc08"  indicates that
> > page(new) is already on a list. I think that maybe something else is
> > wrong which is covered.
> > I can not reproduce this bug on x86. Could you share your config and
> > cmdline? Any do you turn on any debug option of slub?
>
> You can re-create the config with "make ARCH=s390 debug_defconfig".
>
> Not sure which machine I used to reproduce this but most likely it was
> a machine with these command line options:
>
> dasd=e12d root=/dev/dasda1 userprocess_debug numa_debug sched_debug
> ignore_loglevel sclp_con_drop=1 sclp_con_pages=32 audit=0
> crashkernel=128M ignore_rlimit_data
>
> You can ignore the dasd and sclp* command line options. These are
> s390 specific. The rest should be available on any architecture.
>
Thank you for the info. I can reproduce the bug, and find that this
bug is caused by this commit. In deactivate_slab(), page is firstly
add_full(), then hit the redo condition, hence it should be
remove_full(). This wrong commit erases the related code.

Regards,
Pingfan
