Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38AC96B0005
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:36:38 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 203-v6so12449180ybf.19
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 00:36:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t137-v6si4372068ywf.391.2018.10.16.00.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 00:36:37 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9G7Xdso133270
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:36:37 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n5b2d9rqr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 03:36:36 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 16 Oct 2018 08:36:35 +0100
Date: Tue, 16 Oct 2018 09:36:29 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG -next 20181008] list corruption with "mm/slub: remove
 useless condition in deactivate_slab"
References: <20181009063500.GB3555@osiris>
 <CAFgQCTsnWRyN--dS0oVCzPykkt33M=9so2sv2a3+iu-kCdpV7A@mail.gmail.com>
 <CAFgQCTtQ2+bu44top5Fy=7KWRVrpFLnsRGupksK1ixR9oFZs+g@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAFgQCTtQ2+bu44top5Fy=7KWRVrpFLnsRGupksK1ixR9oFZs+g@mail.gmail.com>
Message-Id: <20181016073629.GA3194@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 16, 2018 at 02:29:28PM +0800, Pingfan Liu wrote:
> > I think it is caused by the uinon page->lru and page->next. It can be fixed by:
> > diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> > index 3a1a1db..4aa0fb5 100644
> > --- a/include/linux/slub_def.h
> > +++ b/include/linux/slub_def.h
> > @@ -56,6 +56,7 @@ struct kmem_cache_cpu {
> >  #define slub_set_percpu_partial(c, p)          \
> >  ({                                             \
> >         slub_percpu_partial(c) = (p)->next;     \
> > +       p->next = NULL; \
> >  })
> >
> > I will do some test and post the fix.
> >
> Please ignore the above comment. And after re-check the code, I am
> sure that all callers of deactivate_slab(), pass c->page, which means
> that page should not be on any list. But your test result "list_add
> double add: new=000003d1029ecc08,
> prev=000000008ff846d0,next=000003d1029ecc08"  indicates that
> page(new) is already on a list. I think that maybe something else is
> wrong which is covered.
> I can not reproduce this bug on x86. Could you share your config and
> cmdline? Any do you turn on any debug option of slub?

You can re-create the config with "make ARCH=s390 debug_defconfig".

Not sure which machine I used to reproduce this but most likely it was
a machine with these command line options:

dasd=e12d root=/dev/dasda1 userprocess_debug numa_debug sched_debug
ignore_loglevel sclp_con_drop=1 sclp_con_pages=32 audit=0
crashkernel=128M ignore_rlimit_data

You can ignore the dasd and sclp* command line options. These are
s390 specific. The rest should be available on any architecture.
