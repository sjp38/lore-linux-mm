Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4206B026D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:37:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id t14-v6so4600900wrr.23
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:37:28 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id u66-v6si1773825wma.231.2018.06.22.08.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 08:37:27 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20180622150242.16558-1-mhocko@kernel.org>
References: <20180622150242.16558-1-mhocko@kernel.org>
Message-ID: <152968180950.11773.3374981930722769733@mail.alporthouse.com>
Subject: Re: [Intel-gfx] [RFC PATCH] mm,
 oom: distinguish blockable mode for mmu notifiers
Date: Fri, 22 Jun 2018 16:36:49 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: "Michal Hocko  <mhocko@suse.com>, kvm@vger.kernel.org,  =?utf-8?b?IiBSYWRpbSBLcsSNbcOhxZk=?= <rkrcmar@redhat.com>,  David Airlie" <airlied@linux.ie>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, =?utf-8?b?IiBKw6lyw7RtZSBHbGlzc2U=?= <jglisse@redhat.com>, Rodrigo@kvack.org, Vivi@kvack.org, " <rodrigo.vivi@intel.com>,  "@kvack.org, Boris@kvack.org, Ostrovsky@kvack.org, " <boris.ostrovsky@oracle.com>,  "@kvack.org, Juergen@kvack.org, Gross@kvack.org, " <jgross@suse.com>,  "@kvack.org, Mike@kvack.org, Marciniszyn@kvack.org, " <mike.marciniszyn@intel.com>,  "@kvack.org, Dennis@kvack.org, Dalessandro@kvack.org, " <dennis.dalessandro@intel.com>,  "@kvack.org, Ashutosh@kvack.org, Dixit@kvack.org, " <ashutosh.dixit@intel.com>,  "@kvack.org, Alex@kvack.org, Deucher@kvack.org, " <alexander.deucher@amd.com>,  "@kvack.org, Paolo@kvack.org, Bonzini@kvack.org, " <pbonzini@redhat.com>,  =?utf-8?q?=22_Christian_K=C3=B6nig?= <christian.koenig@amd.com>"@kvack.org

Quoting Michal Hocko (2018-06-22 16:02:42)
> Hi,
> this is an RFC and not tested at all. I am not very familiar with the
> mmu notifiers semantics very much so this is a crude attempt to achieve
> what I need basically. It might be completely wrong but I would like
> to discuss what would be a better way if that is the case.
> =

> get_maintainers gave me quite large list of people to CC so I had to trim
> it down. If you think I have forgot somebody, please let me know

> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i9=
15/i915_gem_userptr.c
> index 854bd51b9478..5285df9331fa 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
>         mo->attached =3D false;
>  }
>  =

> -static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifi=
er *_mn,
> +static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifie=
r *_mn,
>                                                        struct mm_struct *=
mm,
>                                                        unsigned long star=
t,
> -                                                      unsigned long end)
> +                                                      unsigned long end,
> +                                                      bool blockable)
>  {
>         struct i915_mmu_notifier *mn =3D
>                 container_of(_mn, struct i915_mmu_notifier, mn);
> @@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_star=
t(struct mmu_notifier *_mn,
>         LIST_HEAD(cancelled);
>  =

>         if (RB_EMPTY_ROOT(&mn->objects.rb_root))
> -               return;
> +               return 0;

The principle wait here is for the HW (even after fixing all the locks
to be not so coarse, we still have to wait for the HW to finish its
access). The first pass would be then to not do anything here if
!blockable.

Jerome keeps on shaking his head and telling us we're doing it all
wrong, so maybe it'll all fall out of HMM before we have to figure out
how to differentiate between objects that can be invalidated immediately
and those that need to acquire locks and/or wait.
-Chris
