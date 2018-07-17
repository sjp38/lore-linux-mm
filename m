Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD5D66B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:03:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e19-v6so4373663pgv.11
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:03:59 -0700 (PDT)
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70082.outbound.protection.outlook.com. [40.107.7.82])
        by mx.google.com with ESMTPS id l4-v6si31732085plb.213.2018.07.16.21.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jul 2018 21:03:58 -0700 (PDT)
Date: Tue, 17 Jul 2018 07:03:47 +0300
From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180717040347.GT3152@mtr-leonro.mtl.com>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cW+P/jduATWpL925"
Content-Disposition: inline
In-Reply-To: <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>


--cW+P/jduATWpL925
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 16, 2018 at 04:12:49PM -0700, Andrew Morton wrote:
> On Mon, 16 Jul 2018 13:50:58 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>
> > From: Michal Hocko <mhocko@suse.com>
> >
> > There are several blockable mmu notifiers which might sleep in
> > mmu_notifier_invalidate_range_start and that is a problem for the
> > oom_reaper because it needs to guarantee a forward progress so it cannot
> > depend on any sleepable locks.
> >
> > Currently we simply back off and mark an oom victim with blockable mmu
> > notifiers as done after a short sleep. That can result in selecting a
> > new oom victim prematurely because the previous one still hasn't torn
> > its memory down yet.
> >
> > We can do much better though. Even if mmu notifiers use sleepable locks
> > there is no reason to automatically assume those locks are held.
> > Moreover majority of notifiers only care about a portion of the address
> > space and there is absolutely zero reason to fail when we are unmapping an
> > unrelated range. Many notifiers do really block and wait for HW which is
> > harder to handle and we have to bail out though.
> >
> > This patch handles the low hanging fruid. __mmu_notifier_invalidate_range_start
> > gets a blockable flag and callbacks are not allowed to sleep if the
> > flag is set to false. This is achieved by using trylock instead of the
> > sleepable lock for most callbacks and continue as long as we do not
> > block down the call chain.
>
> I assume device driver developers are wondering "what does this mean
> for me".  As I understand it, the only time they will see
> blockable==false is when their driver is being called in response to an
> out-of-memory condition, yes?  So it is a very rare thing.

I can't say for everyone, but at least for me (mlx5), it is not rare event.
I'm seeing OOM very often while I'm running my tests in low memory VMs.

Thanks

>
> Any suggestions regarding how the driver developers can test this code
> path?  I don't think we presently have a way to fake an oom-killing
> event?  Perhaps we should add such a thing, given the problems we're
> having with that feature.

--cW+P/jduATWpL925
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbTWqjAAoJEORje4g2clinGqAP+gKzC/GfmPDn9AVen4vgye2r
8ZHefQ6uHWv4nJE61TvooYoxviDwWVXtXhUT+MnvEvQ43UMMtfUc4ZyBaHovPPmr
a6eXZGQP9+08P4l3nl3dPg1H9D1ynkxSqKLJykEM+xSzWy16+F3JYQXUnTcujqrn
m/eiJ9hHXL2sS2w7Xwj1BLmCmeMJ/e7v6Og0eUkXeCIYHrtBfUziO+XhMwU6BEKE
uNsyROY/ua4XvzuHWwGmUbM0pT1Pk/qvkHGK8RP1jkBbzS0nlYZoKKtlgH0E3Cot
ifa7ZfLQT4kG1KttzXX7ZVuwxK+wyKHhykJxlJIRl/uDSbmdEjRcNPFwAwzAsQLG
ZMjnx2wo9tqlBMSdwlwtZBc8H8MPagM5pLypQTIFdMmvD/lGVGXk2/rwP2dixw/W
V/j9V5eWAkjkp2hg5KxZLSW0nK7e1bEreZesEejfWb/tZGpEWjOtDfv+F9drZZ8O
iqvT56/bALDpLSvSDaCTxbfVpZf6wm+eKE4DkwIBzl8cTyRp7136JKnDJ0FVse/Z
OGqa7WWV1LTVMAHzRsHpX9HrTPpRKxFuZYYB8Z5NTeHa0TVqjsuOYo5uf5SfVsS5
3BeOAh2ncekLrn5WyVnY78PaXLzJ1vUCtvQGOYMX6fwI15+63z3+BH8t46ulmJed
MuCRD555f27+kAwtDYmE
=gzyd
-----END PGP SIGNATURE-----

--cW+P/jduATWpL925--
