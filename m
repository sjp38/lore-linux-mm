Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9D646B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:40:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l145so58787708ita.14
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:40:56 -0700 (PDT)
Received: from omzsmtpe02.verizonbusiness.com (omzsmtpe02.verizonbusiness.com. [199.249.25.209])
        by mx.google.com with ESMTPS id c1si1672069itd.74.2017.06.02.00.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 00:40:55 -0700 (PDT)
From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH 1/9] mm: introduce kv[mz]alloc helpers
Date: Fri, 2 Jun 2017 07:40:12 +0000
Message-ID: <20170602074008.wctxj5il3rqnnpbf@sasha-lappy>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103032.2540-2-mhocko@kernel.org>
 <20170602071718.zk3ujm64xesoqyrr@sasha-lappy>
 <20170602072855.GB29840@dhcp22.suse.cz>
In-Reply-To: <20170602072855.GB29840@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <45AC844B5179814AAD5D5FB40FE7AC3F@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Jun 02, 2017 at 09:28:56AM +0200, Michal Hocko wrote:
> On Fri 02-06-17 07:17:22, Sasha Levin wrote:
> > On Mon, Mar 06, 2017 at 11:30:24AM +0100, Michal Hocko wrote:
> > > +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > > +{
> > > +	gfp_t kmalloc_flags =3D flags;
> > > +	void *ret;
> > > +
> > > +	/*
> > > +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page =
tables)
> > > +	 * so the given set of flags has to be compatible.
> > > +	 */
> > > +	WARN_ON_ONCE((flags & GFP_KERNEL) !=3D GFP_KERNEL);
> >=20
> > Hm, there are quite a few locations in the kernel that do something lik=
e:
> >=20
> > 	__vmalloc(len, GFP_NOFS, PAGE_KERNEL);
> >=20
> > According to your patch, vmalloc can't really do GFP_NOFS, right?
>=20
> Yes. It is quite likely that they will just work because the hardcoded
> GFP_KERNEL inside the vmalloc path is in unlikely paths (page table
> allocations for example) but yes they are broken. I didn't convert some
> places which opencode the kvmalloc with GFP_NOFS because I strongly
> _believe_ that the GFP_NOFS should be revisited, checked whether it is
> needed, documented if so and then memalloc_nofs__{save,restore} be used
> for the scope which is reclaim recursion unsafe. This would turn all
> those vmalloc users to the default GFP_KERNEL and still do the right
> thing.

While you haven't converted those paths, other folks have picked up
on that:

	commit beeeccca9bebcec386cc31c250cff8a06cf27034
	Author: Vinnie Magro <vmagro@fb.com>
	Date:   Thu May 25 12:18:02 2017 -0700

	    btrfs: Use kvzalloc instead of kzalloc/vmalloc in alloc_bitmap
	[...]

Maybe we should make kvmalloc_node() fail non-GFP_KERNEL allocations
rather than just warn on them to make this error more evident? I'm not
sure how these warnings were missed during testing.

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
