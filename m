Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 452058E0085
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 10:30:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so7038512qte.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 07:30:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n36si527570qtk.240.2019.01.24.07.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 07:30:50 -0800 (PST)
Date: Thu, 24 Jan 2019 10:30:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v4 8/9] gpu/drm/i915: optimize out the case when a range
 is updated to read only
Message-ID: <20190124153032.GA5030@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190123222315.1122-9-jglisse@redhat.com>
 <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>, linux-fsdevel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>

On Thu, Jan 24, 2019 at 02:09:12PM +0200, Joonas Lahtinen wrote:
> Hi Jerome,
> 
> This patch seems to have plenty of Cc:s, but none of the right ones :)

So sorry, i am bad with git commands.

> For further iterations, I guess you could use git option --cc to make
> sure everyone gets the whole series, and still keep the Cc:s in the
> patches themselves relevant to subsystems.

Will do.

> This doesn't seem to be on top of drm-tip, but on top of your previous
> patches(?) that I had some comments about. Could you take a moment to
> first address the couple of question I had, before proceeding to discuss
> what is built on top of that base.

It is on top of Linus tree so roughly ~ rc3 it does not depend on any
of the previous patch i posted. I still intended to propose to remove
GUP from i915 once i get around to implement the equivalent of GUP_fast
for HMM and other bonus cookies with it.

The plan is once i have all mm bits properly upstream then i can propose
patches to individual driver against the proper driver tree ie following
rules of each individual device driver sub-system and Cc only people
there to avoid spamming the mm folks :)


> 
> My reply's Message-ID is:
> 154289518994.19402.3481838548028068213@jlahtine-desk.ger.corp.intel.com
> 
> Regards, Joonas
> 
> PS. Please keep me Cc:d in the following patches, I'm keen on
> understanding the motive and benefits.
> 
> Quoting jglisse@redhat.com (2019-01-24 00:23:14)
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > When range of virtual address is updated read only and corresponding
> > user ptr object are already read only it is pointless to do anything.
> > Optimize this case out.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Christian König <christian.koenig@amd.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Matthew Wilcox <mawilcox@microsoft.com>
> > Cc: Ross Zwisler <zwisler@kernel.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Cc: Radim Krčmář <rkrcmar@redhat.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: kvm@vger.kernel.org
> > Cc: dri-devel@lists.freedesktop.org
> > Cc: linux-rdma@vger.kernel.org
> > Cc: linux-fsdevel@vger.kernel.org
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++++++++
> >  1 file changed, 16 insertions(+)
> > 
> > diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > index 9558582c105e..23330ac3d7ea 100644
> > --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> > +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > @@ -59,6 +59,7 @@ struct i915_mmu_object {
> >         struct interval_tree_node it;
> >         struct list_head link;
> >         struct work_struct work;
> > +       bool read_only;
> >         bool attached;
> >  };
> >  
> > @@ -119,6 +120,7 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> >                 container_of(_mn, struct i915_mmu_notifier, mn);
> >         struct i915_mmu_object *mo;
> >         struct interval_tree_node *it;
> > +       bool update_to_read_only;
> >         LIST_HEAD(cancelled);
> >         unsigned long end;
> >  
> > @@ -128,6 +130,8 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> >         /* interval ranges are inclusive, but invalidate range is exclusive */
> >         end = range->end - 1;
> >  
> > +       update_to_read_only = mmu_notifier_range_update_to_read_only(range);
> > +
> >         spin_lock(&mn->lock);
> >         it = interval_tree_iter_first(&mn->objects, range->start, end);
> >         while (it) {
> > @@ -145,6 +149,17 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> >                  * object if it is not in the process of being destroyed.
> >                  */
> >                 mo = container_of(it, struct i915_mmu_object, it);
> > +
> > +               /*
> > +                * If it is already read only and we are updating to
> > +                * read only then we do not need to change anything.
> > +                * So save time and skip this one.
> > +                */
> > +               if (update_to_read_only && mo->read_only) {
> > +                       it = interval_tree_iter_next(it, range->start, end);
> > +                       continue;
> > +               }
> > +
> >                 if (kref_get_unless_zero(&mo->obj->base.refcount))
> >                         queue_work(mn->wq, &mo->work);
> >  
> > @@ -270,6 +285,7 @@ i915_gem_userptr_init__mmu_notifier(struct drm_i915_gem_object *obj,
> >         mo->mn = mn;
> >         mo->obj = obj;
> >         mo->it.start = obj->userptr.ptr;
> > +       mo->read_only = i915_gem_object_is_readonly(obj);
> >         mo->it.last = obj->userptr.ptr + obj->base.size - 1;
> >         INIT_WORK(&mo->work, cancel_userptr);
> >  
> > -- 
> > 2.17.2
> > 
> > _______________________________________________
> > dri-devel mailing list
> > dri-devel@lists.freedesktop.org
> > https://lists.freedesktop.org/mailman/listinfo/dri-devel
