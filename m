Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 121F78E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 07:09:21 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so3791127pgi.14
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 04:09:21 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d1si22589408pla.412.2019.01.24.04.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 04:09:19 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
In-Reply-To: <20190123222315.1122-9-jglisse@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190123222315.1122-9-jglisse@redhat.com>
Message-ID: <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
Subject: Re: [PATCH v4 8/9] gpu/drm/i915: optimize out the case when a range is
 updated to read only
Date: Thu, 24 Jan 2019 14:09:12 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Ralph Campbell <rcampbell@nvidia.com>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>, =?utf-8?b?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>, linux-fsdevel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>

Hi Jerome,

This patch seems to have plenty of Cc:s, but none of the right ones :)

For further iterations, I guess you could use git option --cc to make
sure everyone gets the whole series, and still keep the Cc:s in the
patches themselves relevant to subsystems.

This doesn't seem to be on top of drm-tip, but on top of your previous
patches(?) that I had some comments about. Could you take a moment to
first address the couple of question I had, before proceeding to discuss
what is built on top of that base.

My reply's Message-ID is:
154289518994.19402.3481838548028068213@jlahtine-desk.ger.corp.intel.com

Regards, Joonas

PS. Please keep me Cc:d in the following patches, I'm keen on
understanding the motive and benefits.

Quoting jglisse@redhat.com (2019-01-24 00:23:14)
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> =

> When range of virtual address is updated read only and corresponding
> user ptr object are already read only it is pointless to do anything.
> Optimize this case out.
> =

> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> =

> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i9=
15/i915_gem_userptr.c
> index 9558582c105e..23330ac3d7ea 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -59,6 +59,7 @@ struct i915_mmu_object {
>         struct interval_tree_node it;
>         struct list_head link;
>         struct work_struct work;
> +       bool read_only;
>         bool attached;
>  };
>  =

> @@ -119,6 +120,7 @@ static int i915_gem_userptr_mn_invalidate_range_start=
(struct mmu_notifier *_mn,
>                 container_of(_mn, struct i915_mmu_notifier, mn);
>         struct i915_mmu_object *mo;
>         struct interval_tree_node *it;
> +       bool update_to_read_only;
>         LIST_HEAD(cancelled);
>         unsigned long end;
>  =

> @@ -128,6 +130,8 @@ static int i915_gem_userptr_mn_invalidate_range_start=
(struct mmu_notifier *_mn,
>         /* interval ranges are inclusive, but invalidate range is exclusi=
ve */
>         end =3D range->end - 1;
>  =

> +       update_to_read_only =3D mmu_notifier_range_update_to_read_only(ra=
nge);
> +
>         spin_lock(&mn->lock);
>         it =3D interval_tree_iter_first(&mn->objects, range->start, end);
>         while (it) {
> @@ -145,6 +149,17 @@ static int i915_gem_userptr_mn_invalidate_range_star=
t(struct mmu_notifier *_mn,
>                  * object if it is not in the process of being destroyed.
>                  */
>                 mo =3D container_of(it, struct i915_mmu_object, it);
> +
> +               /*
> +                * If it is already read only and we are updating to
> +                * read only then we do not need to change anything.
> +                * So save time and skip this one.
> +                */
> +               if (update_to_read_only && mo->read_only) {
> +                       it =3D interval_tree_iter_next(it, range->start, =
end);
> +                       continue;
> +               }
> +
>                 if (kref_get_unless_zero(&mo->obj->base.refcount))
>                         queue_work(mn->wq, &mo->work);
>  =

> @@ -270,6 +285,7 @@ i915_gem_userptr_init__mmu_notifier(struct drm_i915_g=
em_object *obj,
>         mo->mn =3D mn;
>         mo->obj =3D obj;
>         mo->it.start =3D obj->userptr.ptr;
> +       mo->read_only =3D i915_gem_object_is_readonly(obj);
>         mo->it.last =3D obj->userptr.ptr + obj->base.size - 1;
>         INIT_WORK(&mo->work, cancel_userptr);
>  =

> -- =

> 2.17.2
> =

> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel
