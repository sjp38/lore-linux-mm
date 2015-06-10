Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 415F26B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 19:58:12 -0400 (EDT)
Received: by payr10 with SMTP id r10so43263535pay.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 16:58:11 -0700 (PDT)
Received: from mail-pd0-x243.google.com (mail-pd0-x243.google.com. [2607:f8b0:400e:c02::243])
        by mx.google.com with ESMTPS id t3si16303174pdj.75.2015.06.10.16.58.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 16:58:11 -0700 (PDT)
Received: by pdbht2 with SMTP id ht2so11414349pdb.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 16:58:11 -0700 (PDT)
Date: Thu, 11 Jun 2015 08:58:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in
 zpool_destroy_pool()
Message-ID: <20150610235836.GB499@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
 <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Joe Perches <joe@perches.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/10/15 16:59), Dan Streetman wrote:
> On Tue, Jun 9, 2015 at 8:04 AM, Sergey Senozhatsky
> <sergey.senozhatsky@gmail.com> wrote:
> > zpool_destroy_pool() does not tolerate a NULL zpool pointer
> > argument and performs a NULL-pointer dereference. Although
> > there is only one zpool_destroy_pool() user (as of 4.1),
> > still update it to be coherent with the corresponding
> > destroy() functions of the remainig pool-allocators (slab,
> > mempool, etc.), which now allow NULL pool-pointers.
> >
> > For consistency, tweak zpool_destroy_pool() and NULL-check the
> > pointer there.
> >
> > Proposed by Andrew Morton.
> >
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reported-by: Andrew Morton <akpm@linux-foundation.org>
> > LKML-reference: https://lkml.org/lkml/2015/6/8/583
> 
> Acked-by: Dan Streetman <ddstreet@ieee.org>

Thanks.

Shall we ask Joe to add zpool_destroy_pool() to the
"$func(NULL) is safe and this check is probably not required" list?

	-ss

> > ---
> >  mm/zpool.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/zpool.c b/mm/zpool.c
> > index bacdab6..2f59b90 100644
> > --- a/mm/zpool.c
> > +++ b/mm/zpool.c
> > @@ -202,6 +202,9 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
> >   */
> >  void zpool_destroy_pool(struct zpool *zpool)
> >  {
> > +       if (unlikely(!zpool))
> > +               return;
> > +
> >         pr_info("destroying pool type %s\n", zpool->type);
> >
> >         spin_lock(&pools_lock);
> > --
> > 2.4.3.368.g7974889
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
