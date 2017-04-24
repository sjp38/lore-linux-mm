Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 706E86B02C4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:20:37 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l11so213070417iod.15
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 03:20:37 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e6si3255167pgf.93.2017.04.24.03.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 03:20:36 -0700 (PDT)
From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 2/5] mm: convert anon_vma.refcount from atomic_t to
 refcount_t
Date: Mon, 24 Apr 2017 10:20:32 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C8EC39@IRSMSX102.ger.corp.intel.com>
References: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
 <1487587754-10610-3-git-send-email-elena.reshetova@intel.com>
 <58FB33FD.3010909@huawei.com>
In-Reply-To: <58FB33FD.3010909@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "luto@kernel.org" <luto@kernel.org>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

> Hi, Elean
>=20
> Do the issue had really occured,  use-after-free. but why the patch
>  is not received.   or is is possible for the situation.

Hi Zhongjiang,=20

We have had such issues happening and being exploited in other places of
kernel in the past. Therefore the intention with this and all other similar=
 patches
is to prevent the whole classes of bugs that might come even somewhere in t=
he future
by converting the "true" refcounters to a safe new type refcount_t.
That makes sure if you ever have a bug in your code (now or in the future),=
 it cannot be
misused by attackers.=20

So you can look at it as a safety net for your code.=20

Best Regards,
Elena.=20


>=20
> Thanks
> zhongjiang
> On 2017/2/20 18:49, Elena Reshetova wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> >
> > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > ---
> >  include/linux/rmap.h |  7 ++++---
> >  mm/rmap.c            | 14 +++++++-------
> >  2 files changed, 11 insertions(+), 10 deletions(-)
> >
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index 8c89e90..a8f4a97 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -10,6 +10,7 @@
> >  #include <linux/rwsem.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/highmem.h>
> > +#include <linux/refcount.h>
> >
> >  /*
> >   * The anon_vma heads a list of private "related" vmas, to scan if
> > @@ -35,7 +36,7 @@ struct anon_vma {
> >  	 * the reference is responsible for clearing up the
> >  	 * anon_vma if they are the last user on release
> >  	 */
> > -	atomic_t refcount;
> > +	refcount_t refcount;
> >
> >  	/*
> >  	 * Count of child anon_vmas and VMAs which points to this
> anon_vma.
> > @@ -102,14 +103,14 @@ enum ttu_flags {
> >  #ifdef CONFIG_MMU
> >  static inline void get_anon_vma(struct anon_vma *anon_vma)
> >  {
> > -	atomic_inc(&anon_vma->refcount);
> > +	refcount_inc(&anon_vma->refcount);
> >  }
> >
> >  void __put_anon_vma(struct anon_vma *anon_vma);
> >
> >  static inline void put_anon_vma(struct anon_vma *anon_vma)
> >  {
> > -	if (atomic_dec_and_test(&anon_vma->refcount))
> > +	if (refcount_dec_and_test(&anon_vma->refcount))
> >  		__put_anon_vma(anon_vma);
> >  }
> >
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 8774791..3321c86 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -77,7 +77,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
> >
> >  	anon_vma =3D kmem_cache_alloc(anon_vma_cachep,
> GFP_KERNEL);
> >  	if (anon_vma) {
> > -		atomic_set(&anon_vma->refcount, 1);
> > +		refcount_set(&anon_vma->refcount, 1);
> >  		anon_vma->degree =3D 1;	/* Reference for first
> vma */
> >  		anon_vma->parent =3D anon_vma;
> >  		/*
> > @@ -92,7 +92,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
> >
> >  static inline void anon_vma_free(struct anon_vma *anon_vma)
> >  {
> > -	VM_BUG_ON(atomic_read(&anon_vma->refcount));
> > +	VM_BUG_ON(refcount_read(&anon_vma->refcount));
> >
> >  	/*
> >  	 * Synchronize against page_lock_anon_vma_read() such that
> > @@ -421,7 +421,7 @@ static void anon_vma_ctor(void *data)
> >  	struct anon_vma *anon_vma =3D data;
> >
> >  	init_rwsem(&anon_vma->rwsem);
> > -	atomic_set(&anon_vma->refcount, 0);
> > +	refcount_set(&anon_vma->refcount, 0);
> >  	anon_vma->rb_root =3D RB_ROOT;
> >  }
> >
> > @@ -470,7 +470,7 @@ struct anon_vma *page_get_anon_vma(struct page
> *page)
> >  		goto out;
> >
> >  	anon_vma =3D (struct anon_vma *) (anon_mapping -
> PAGE_MAPPING_ANON);
> > -	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
> > +	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
> >  		anon_vma =3D NULL;
> >  		goto out;
> >  	}
> > @@ -529,7 +529,7 @@ struct anon_vma *page_lock_anon_vma_read(struct
> page *page)
> >  	}
> >
> >  	/* trylock failed, we got to sleep */
> > -	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
> > +	if (!refcount_inc_not_zero(&anon_vma->refcount)) {
> >  		anon_vma =3D NULL;
> >  		goto out;
> >  	}
> > @@ -544,7 +544,7 @@ struct anon_vma *page_lock_anon_vma_read(struct
> page *page)
> >  	rcu_read_unlock();
> >  	anon_vma_lock_read(anon_vma);
> >
> > -	if (atomic_dec_and_test(&anon_vma->refcount)) {
> > +	if (refcount_dec_and_test(&anon_vma->refcount)) {
> >  		/*
> >  		 * Oops, we held the last refcount, release the lock
> >  		 * and bail -- can't simply use put_anon_vma()
> because
> > @@ -1577,7 +1577,7 @@ void __put_anon_vma(struct anon_vma *anon_vma)
> >  	struct anon_vma *root =3D anon_vma->root;
> >
> >  	anon_vma_free(anon_vma);
> > -	if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount))
> > +	if (root !=3D anon_vma && refcount_dec_and_test(&root-
> >refcount))
> >  		anon_vma_free(root);
> >  }
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
