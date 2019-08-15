Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43FC4C32757
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:10:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC5D208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:10:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="XsReatup"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC5D208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FC0B6B0005; Wed, 14 Aug 2019 20:10:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B3446B0007; Wed, 14 Aug 2019 20:10:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001E66B0008; Wed, 14 Aug 2019 20:10:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id D52C46B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:10:01 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4C4544FED
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:10:01 +0000 (UTC)
X-FDA: 75822729402.24.hook90_748a4817dc142
X-HE-Tag: hook90_748a4817dc142
X-Filterd-Recvd-Size: 7290
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:10:00 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id j15so601671qtl.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:10:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=SjWxEd5trWQnubGgd93z8JQghkn2ieuomaNUqpFunr8=;
        b=XsReatupBTmqJdBQODBjcynGCD+EFRZj1C84UwqKxIHDJry1koHSXZhFLNthqLNrdI
         sJvO2xr4Yf8efKKyOEPzz7lmm+x5GdcACC+54eKm4Ge4AB3iU9YvjJ+GUY28eyC1XgX1
         yHn7fdbhBHZEjgohLQ+eJwsIhykXJmXNP4Ad2fzIbW68tY8NtCAmf+n/uw1CrUSltNtz
         Di2z0LFvJ3NxwlbScerLC+k3cfD1cixFWpONt/9P09Wv9Gezy+22yPiI3marKmyMBzcg
         UiogqqKUE89OdisyiimkZeCXTgAaWaEz0svYJBDgWT9nFweVWM05nK9xTUKar+rpAnbC
         nO+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=SjWxEd5trWQnubGgd93z8JQghkn2ieuomaNUqpFunr8=;
        b=dKpQavSQMGkygypjZSd1lz9awdr1DAn8GvbpWIt2c2hPzbsza0nWRQ5pTOSPgEkK/a
         BicsM2f3GvuQe/d+XC7Q6zualNTYu7G63fg0vnu4Ov2jwup1pDlVrUZa0DlKxTKs3zdn
         fJVzD2geoF3l9qe/pr5SIVvBMQagfcMMnx8f9PaWxOC2tI6+BkwVpvHaWcMTufq3m9pg
         wHbJE8RFkpYPaMIwPVY2fnZ6fq4K44FvDbnlokMDNSD7ICWtlTFgoBRcKBGdPQJgJ25T
         I4Sbn9iMCAR9Dpfwj9qQNotwk8iXk85tOYKY2zSgLcQ6bMyMWbWUXCz+yeMB3rkyzbws
         yN6w==
X-Gm-Message-State: APjAAAXMI/CkM5vN4uML0QEvgOCfAaU9TBumEaoV87TLdFR082WCjXAT
	Rsf27iBDT+t3DwiLNOseM7WFEcVQDEk=
X-Google-Smtp-Source: APXvYqwC0rxcQM957klycTBJaDgJCD9Gy1ym2szZ/ytVdS5cdCa5lGsUTdGHMpvakUUVdZWkhvfAPQ==
X-Received: by 2002:a0c:fa89:: with SMTP id o9mr1559689qvn.165.1565827800115;
        Wed, 14 Aug 2019 17:10:00 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n21sm762512qtc.70.2019.08.14.17.09.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 17:09:59 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hy3L5-0003Ys-7h; Wed, 14 Aug 2019 21:09:59 -0300
Date: Wed, 14 Aug 2019 21:09:59 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/5] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20190815000959.GD11200@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-5-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190814202027.18735-5-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:20:26PM +0200, Daniel Vetter wrote:
> This is a similar idea to the fs_reclaim fake lockdep lock. It's
> fairly easy to provoke a specific notifier to be run on a specific
> range: Just prep it, and then munmap() it.
>=20
> A bit harder, but still doable, is to provoke the mmu notifiers for
> all the various callchains that might lead to them. But both at the
> same time is really hard to reliable hit, especially when you want to
> exercise paths like direct reclaim or compaction, where it's not
> easy to control what exactly will be unmapped.
>=20
> By introducing a lockdep map to tie them all together we allow lockdep
> to see a lot more dependencies, without having to actually hit them
> in a single challchain while testing.
>=20
> Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> this out for the invaliate_range_start callback. If there's
> interest, we should probably roll this out to all of them. But my
> undestanding of core mm is seriously lacking, and I'm not clear on
> whether we need a lockdep map for each callback, or whether some can
> be shared.

I was thinking about doing something like this..

IMHO only range_end needs annotation, the other ops are either already
non-sleeping or only used by KVM.

BTW, I have found it strange that i915 only uses
invalidate_range_start. Not really sure how it is able to do
that. Would love to know the answer :)

> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>  include/linux/mmu_notifier.h | 6 ++++++
>  mm/mmu_notifier.c            | 7 +++++++
>  2 files changed, 13 insertions(+)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.=
h
> index b6c004bd9f6a..9dd38c32fc53 100644
> +++ b/include/linux/mmu_notifier.h
> @@ -42,6 +42,10 @@ enum mmu_notifier_event {
> =20
>  #ifdef CONFIG_MMU_NOTIFIER
> =20
> +#ifdef CONFIG_LOCKDEP
> +extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
> +#endif

I wonder what the trade off is having a global map vs a map in each
mmu_notifier_mm ?

>  /*
>   * The mmu notifier_mm structure is allocated and installed in
>   * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
> @@ -310,10 +314,12 @@ static inline void mmu_notifier_change_pte(struct=
 mm_struct *mm,
>  static inline void
>  mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  {
> +	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
>  	if (mm_has_notifiers(range->mm)) {
>  		range->flags |=3D MMU_NOTIFIER_RANGE_BLOCKABLE;
>  		__mmu_notifier_invalidate_range_start(range);
>  	}
> +	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
>  }

Also range_end should have this too - it has all the same
constraints. I think it can share the map. So 'range_start_map' is
probably not the right name.

It may also make some sense to do a dummy acquire/release under the
mm_take_all_locks() to forcibly increase map coverage and reduce the
scenario complexity required to hit bugs.

And if we do decide on the reclaim thing in my other email then the
reclaim dependency can be reliably injected by doing:

 fs_reclaim_acquire();
 lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 fs_reclaim_release();

If I understand lockdep properly..

Jason

