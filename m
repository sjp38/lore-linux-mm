Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D212C282C3
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 12:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD6C320855
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 12:09:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD6C320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B66E8E0083; Thu, 24 Jan 2019 07:09:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C188E0082; Thu, 24 Jan 2019 07:09:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 554928E0083; Thu, 24 Jan 2019 07:09:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 121F78E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 07:09:21 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so3791127pgi.14
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 04:09:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:organization:in-reply-to:cc
         :references:message-id:user-agent:subject:date;
        bh=1PH/izeuNe/zL6mo9xfIMOVIa7furPS9e6R8ZNvSE1M=;
        b=QB3Ucs4uNsxrGpCZn0rs26ke9aPon3otvcUYwCUGd4rMZuGK+zK3MflS/crO8NGRmL
         5BudGzZn7EQdxNZsX5Q0yUi/A7MUUHODXHgbYV8wSDEDCnPlk4P1Y3lFAxdHccuNtD9t
         +LswRFv1WeloRC21SXCqv3lS6UnJODfHgQuSrZWkUfqPtjFC3cF+JShutXuus26+6rtU
         B6MbWeqxP9I864DewMyr9JTFKz9XxsNb3dfX4BdOnVRtyt2jHjHzFhUjSYLTIFuY4Rt+
         gYoyc8Cmj/1cWjiXP+3cMLivghIqcIVOvlkwaTj5CPueuNxh0ApQwxrdTxY+8mApUKKT
         lDmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdWG4vCQUIiN6ZSDeiLiugO74wwGico0f9lDbkNIlyqPQHAnrSu
	WwtqWk6u0+YdcDRaoB0noEDI6LPE3BJ6agr8vL1sqaUK3gBsh8otdrh0/y1txC1XQLMQMZv7ETw
	QJhYikoCNMXFHwUPyYh71D32+lUYfDcxHUZLOAvzgK/35zV1VmV3gJxDpfWXLN+4lXA==
X-Received: by 2002:a62:b80a:: with SMTP id p10mr6203050pfe.32.1548331760706;
        Thu, 24 Jan 2019 04:09:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5NTJAL7HqMbxksp6vqxjH1CwMuQMDi9/UkTi6ljca4EhvIahW+wUuZBPVQnfkBVDrCuY4z
X-Received: by 2002:a62:b80a:: with SMTP id p10mr6202963pfe.32.1548331759412;
        Thu, 24 Jan 2019 04:09:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548331759; cv=none;
        d=google.com; s=arc-20160816;
        b=V/LzBlniATm/5YgygFN+VLTuBXFXnTNsWubU5dPciUIX20Qbu/9Vl4/1LAeY83ZT8D
         i5hyAsuHREkNICLbxNz2MbMDV1fMNCtmLfcG8vSHsKwhkPo13LmiE4RAViWEsfAk99mf
         EyLr3ISPNtuCKgPBMhQDpW9LdMTkdWobWCmi37kjfPpOyS3ZW0eDoVvFdzMv3WXscnCF
         /6ZHTJ43E0WZWws/0/A8zEPVA/qV3PijV8DhzUZ0wTPP77RfJfNnhejbwCLQKoB1BT6f
         7+35ZqY0PYRzgnbdRCLjj4Jes1UFv0jTZ0jFYfIDyTwOW22lYl/p9LEyc4OXol6DckUm
         DA5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to
         :organization:from:to:content-transfer-encoding:mime-version;
        bh=1PH/izeuNe/zL6mo9xfIMOVIa7furPS9e6R8ZNvSE1M=;
        b=YKA5gl9YK+SdKUtwZjSqjTgAhT6p7/pdA+fB0mb9sR6j1BJ6gCUqgmUfD6kCtEgpR2
         eDUNI+R3AP67fjUOTclMmNt42mZE+oiaMraSMelzUxG8qCUjpVl3zP6q+TcLZAuQ7ykS
         ATgNEJRLrA8abnvfHBAtZE5HvwUfz8s3VUzmS/zjG30Yx6JW+Av7u0DeE8reOGvJe7PA
         gamQ5oJ3UtmLcXwobDenb7oSpdcX6yVxz9ZjS2/Bb8QR3KpkdDpaQxeh87LI+GcOMsmk
         V7NjYDN6HZ9NWRA3OVFkMQZ8XAz1gGe4RCGXzQBYmtpqXrnCiF07C3YC/iy2jQ6PkpFr
         ykbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d1si22589408pla.412.2019.01.24.04.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 04:09:19 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 04:09:18 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,516,1539673200"; 
   d="scan'208";a="138383085"
Received: from jlahtine-desk.ger.corp.intel.com (HELO localhost) ([10.252.7.47])
  by fmsmga004.fm.intel.com with ESMTP; 24 Jan 2019 04:09:13 -0800
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: jglisse@redhat.com, linux-mm@kvack.org
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
In-Reply-To: <20190123222315.1122-9-jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, Jan Kara <jack@suse.cz>,
 Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
 Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org,
 John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
 =?utf-8?b?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>,
 =?utf-8?b?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>,
 linux-fsdevel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190123222315.1122-9-jglisse@redhat.com>
Message-ID:
 <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4 8/9] gpu/drm/i915: optimize out the case when a range is
 updated to read only
Date: Thu, 24 Jan 2019 14:09:12 +0200
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190124120912.-8w9k7zqxBo5qCD254ZSc8qQzFCadvEXmKdeQtfLl9c@z>

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

