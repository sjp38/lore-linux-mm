Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5711A6B0069
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:16:24 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x66so1616469pfe.21
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 23:16:24 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a12si427022pfl.63.2017.11.16.23.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 23:16:23 -0800 (PST)
From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 12/16] nsproxy: convert nsproxy.count to refcount_t
Date: Fri, 17 Nov 2017 07:16:17 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B802BF5F8@IRSMSX102.ger.corp.intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
	<1510754620-27088-13-git-send-email-elena.reshetova@intel.com>
 <87lgj733dn.fsf@xmission.com>
In-Reply-To: <87lgj733dn.fsf@xmission.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "tj@kernel.org" <tj@kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "lizefan@huawei.com" <lizefan@huawei.com>, "acme@kernel.org" <acme@kernel.org>, "alexander.shishkin@linux.intel.com" <alexander.shishkin@linux.intel.com>, "eparis@redhat.com" <eparis@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "luto@kernel.org" <luto@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvhart@infradead.org" <dvhart@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "axboe@kernel.dk" <axboe@kernel.dk>

> The middle of the merge window is the wrong time to send patches as
> maintaner attention is going to making certain the merge goes smoothly
> and nothing is missed.

Sorry Eric, please feel free to ignore the patch until you have time.=20
It is very difficult to figure out the correct time, since it varies vary m=
uch
by the maintainer when they want patches, so I am sending them to be
"in the mailbox" until people believe it is the right time.=20

Best Regards,
Elena.


>=20
> Eric
>=20
>=20
>=20
> Elena Reshetova <elena.reshetova@intel.com> writes:
>=20
> > atomic_t variables are currently used to implement reference
> > counters with the following properties:
> >  - counter is initialized to 1 using atomic_set()
> >  - a resource is freed upon counter reaching zero
> >  - once counter reaches zero, its further
> >    increments aren't allowed
> >  - counter schema uses basic atomic operations
> >    (set, inc, inc_not_zero, dec_and_test, etc.)
> >
> > Such atomic variables should be converted to a newly provided
> > refcount_t type and API that prevents accidental counter overflows
> > and underflows. This is important since overflows and underflows
> > can lead to use-after-free situation and be exploitable.
> >
> > The variable nsproxy.count is used as pure reference counter.
> > Convert it to refcount_t and fix up the operations.
> >
> > **Important note for maintainers:
> >
> > Some functions from refcount_t API defined in lib/refcount.c
> > have different memory ordering guarantees than their atomic
> > counterparts.
> > The full comparison can be seen in
> > https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
> > in state to be merged to the documentation tree.
> > Normally the differences should not matter since refcount_t provides
> > enough guarantees to satisfy the refcounting use cases, but in
> > some rare cases it might matter.
> > Please double check that you don't have some undocumented
> > memory guarantees for this variable usage.
> >
> > For the nsproxy.count it might make a difference
> > in following places:
> >  - put_nsproxy() and switch_task_namespaces(): decrement in
> >    refcount_dec_and_test() only provides RELEASE ordering
> >    and control dependency on success vs. fully ordered
> >    atomic counterpart
> >
> > Suggested-by: Kees Cook <keescook@chromium.org>
> > Reviewed-by: David Windsor <dwindsor@gmail.com>
> > Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
> > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > ---
> >  include/linux/nsproxy.h | 6 +++---
> >  kernel/nsproxy.c        | 6 +++---
> >  2 files changed, 6 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> > index 2ae1b1a..90f09ff 100644
> > --- a/include/linux/nsproxy.h
> > +++ b/include/linux/nsproxy.h
> > @@ -29,7 +29,7 @@ struct fs_struct;
> >   * nsproxy is copied.
> >   */
> >  struct nsproxy {
> > -	atomic_t count;
> > +	refcount_t count;
> >  	struct uts_namespace *uts_ns;
> >  	struct ipc_namespace *ipc_ns;
> >  	struct mnt_namespace *mnt_ns;
> > @@ -75,14 +75,14 @@ int __init nsproxy_cache_init(void);
> >
> >  static inline void put_nsproxy(struct nsproxy *ns)
> >  {
> > -	if (atomic_dec_and_test(&ns->count)) {
> > +	if (refcount_dec_and_test(&ns->count)) {
> >  		free_nsproxy(ns);
> >  	}
> >  }
> >
> >  static inline void get_nsproxy(struct nsproxy *ns)
> >  {
> > -	atomic_inc(&ns->count);
> > +	refcount_inc(&ns->count);
> >  }
> >
> >  #endif
> > diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> > index f6c5d33..5bfe691 100644
> > --- a/kernel/nsproxy.c
> > +++ b/kernel/nsproxy.c
> > @@ -31,7 +31,7 @@
> >  static struct kmem_cache *nsproxy_cachep;
> >
> >  struct nsproxy init_nsproxy =3D {
> > -	.count			=3D ATOMIC_INIT(1),
> > +	.count			=3D REFCOUNT_INIT(1),
> >  	.uts_ns			=3D &init_uts_ns,
> >  #if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
> >  	.ipc_ns			=3D &init_ipc_ns,
> > @@ -52,7 +52,7 @@ static inline struct nsproxy *create_nsproxy(void)
> >
> >  	nsproxy =3D kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
> >  	if (nsproxy)
> > -		atomic_set(&nsproxy->count, 1);
> > +		refcount_set(&nsproxy->count, 1);
> >  	return nsproxy;
> >  }
> >
> > @@ -225,7 +225,7 @@ void switch_task_namespaces(struct task_struct *p, =
struct
> nsproxy *new)
> >  	p->nsproxy =3D new;
> >  	task_unlock(p);
> >
> > -	if (ns && atomic_dec_and_test(&ns->count))
> > +	if (ns && refcount_dec_and_test(&ns->count))
> >  		free_nsproxy(ns);
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
