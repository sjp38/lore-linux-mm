Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9EE6B027C
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 23:04:40 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so5572382igb.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:04:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n125si3079048ion.3.2015.09.30.20.04.39
        for <linux-mm@kvack.org>;
        Wed, 30 Sep 2015 20:04:39 -0700 (PDT)
From: "Drokin, Oleg" <oleg.drokin@intel.com>
Subject: Re: [PATCH 05/10] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Date: Thu, 1 Oct 2015 03:04:37 +0000
Message-ID: <B4928C43-609A-4BE8-90E1-6327352F9D46@intel.com>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-6-git-send-email-mgorman@techsingularity.net>
 <20150924205509.GI3009@cmpxchg.org>
 <20150925125106.GG3068@techsingularity.net>
 <20150925190138.GA16359@cmpxchg.org>
 <20150929133547.GI3068@techsingularity.net> <560BD4F0.3080402@suse.cz>
In-Reply-To: <560BD4F0.3080402@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3745342CA0A11C4BA73180BA81AA5A25@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Dilger, Andreas" <andreas.dilger@intel.com>

Hello!
On Sep 30, 2015, at 8:26 AM, Vlastimil Babka wrote:

> [diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging=
/lustre/lnet/lnet/router.c
>>=20
>> index 4fbae5ef44a9..dad9816dfee7 100644
>> --- a/drivers/staging/lustre/lnet/lnet/router.c
>> +++ b/drivers/staging/lustre/lnet/lnet/router.c
>> @@ -1246,7 +1246,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
>>  	for (i =3D 0; i < npages; i++) {
>>  		page =3D alloc_pages_node(
>>  				cfs_cpt_spread_node(lnet_cpt_table(), cpt),
>> -				__GFP_ZERO | GFP_IOFS, 0);
>> +				GFP_KERNEL | __GFP_ZERO, 0);
>>  		if (page =3D=3D NULL) {
>>  			while (--i >=3D 0)
>>  				__free_page(rb->rb_kiov[i].kiov_page);

This one is ok, it's in the non-fs part, so cannot enter via an fs operatio=
n.

>> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/sta=
ging/lustre/lnet/selftest/conrpc.c
>> index a1a4e08f7391..3fc37de8d304 100644
>> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
>> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> @@ -861,7 +861,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, =
unsigned feats,
>>  			bulk->bk_iovs[i].kiov_offset =3D 0;
>>  			bulk->bk_iovs[i].kiov_len    =3D len;
>>  			bulk->bk_iovs[i].kiov_page   =3D
>> -				alloc_page(GFP_IOFS);
>> +				alloc_page(GFP_KERNEL);
>>=20
>>  			if (bulk->bk_iovs[i].kiov_page =3D=3D NULL) {
>>  				lstcon_rpc_put(*crpc);
>> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/stagin=
g/lustre/lnet/selftest/rpc.c
>> index 6ae133138b17..aa0f88fbb221 100644
>> --- a/drivers/staging/lustre/lnet/selftest/rpc.c
>> +++ b/drivers/staging/lustre/lnet/selftest/rpc.c
>> @@ -146,7 +146,7 @@ srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned=
 bulk_len, int sink)
>>  		int nob;
>>=20
>>  		pg =3D alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(), cpt),
>> -				      GFP_IOFS, 0);
>> +				      GFP_KERNEL, 0);
>>  		if (pg =3D=3D NULL) {
>>  			CERROR("Can't allocate page %d of %d\n", i, bulk_npg);
>>  			srpc_free_bulk(bk);

These two are in "lnet-selftest" that is self-hosted. so also ok.

>> diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/sta=
ging/lustre/lustre/libcfs/module.c
>> index 806f9747a3a2..303143f28c06 100644
>> --- a/drivers/staging/lustre/lustre/libcfs/module.c
>> +++ b/drivers/staging/lustre/lustre/libcfs/module.c
>> @@ -321,7 +321,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile=
, unsigned long cmd, void *a
>>  	struct libcfs_ioctl_data *data;
>>  	int err =3D 0;
>>=20
>> -	LIBCFS_ALLOC_GFP(buf, 1024, GFP_IOFS);
>> +	LIBCFS_ALLOC_GFP(buf, 1024, GFP_KERNEL);
>>  	if (buf =3D=3D NULL)
>>  		return -ENOMEM;
>>=20
>> diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/=
staging/lustre/lustre/libcfs/tracefile.c
>> index effa2af58c13..a7d72f69c4eb 100644
>> --- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
>> +++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
>> @@ -810,7 +810,7 @@ int cfs_trace_allocate_string_buffer(char **str, int=
 nob)
>>  	if (nob > 2 * PAGE_CACHE_SIZE)	    /* string must be "sensible" */
>>  		return -EINVAL;
>>=20
>> -	*str =3D kmalloc(nob, GFP_IOFS | __GFP_ZERO);
>> +	*str =3D kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
>=20
> This could use kzalloc.
>=20
>>  	if (*str =3D=3D NULL)
>>  		return -ENOMEM;
>>=20
>> diff --git a/drivers/staging/lustre/lustre/llite/remote_perm.c b/drivers=
/staging/lustre/lustre/llite/remote_perm.c
>> index 39022ea88b5f..b27f016c3dd4 100644
>> --- a/drivers/staging/lustre/lustre/llite/remote_perm.c
>> +++ b/drivers/staging/lustre/lustre/llite/remote_perm.c
>> @@ -84,7 +84,7 @@ static struct hlist_head *alloc_rmtperm_hash(void)
>>=20
>>  	OBD_SLAB_ALLOC_GFP(hash, ll_rmtperm_hash_cachep,
>>  			   REMOTE_PERM_HASHSIZE * sizeof(*hash),
>> -			   GFP_IOFS);
>> +			   GFP_KERNEL);
>>  	if (!hash)
>>  		return NULL;
>>=20

This is called from ll_inode_permission (the inode ops->permission method),=
 so I imagine this must be GFP_NOFS.

>> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/s=
taging/lustre/lustre/mgc/mgc_request.c
>> index 019ee2f256aa..79551319d754 100644
>> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> @@ -198,7 +198,7 @@ struct config_llog_data *do_config_log_add(struct ob=
d_device *obd,
>>  	CDEBUG(D_MGC, "do adding config log %s:%p\n", logname,
>>  	       cfg ? cfg->cfg_instance : NULL);
>>=20
>> -	cld =3D kzalloc(sizeof(*cld) + strlen(logname) + 1, GFP_NOFS);
>> +	cld =3D kzalloc(sizeof(*cld) + strlen(logname) + 1, GFP_KERNEL);
>>  	if (!cld)
>>  		return ERR_PTR(-ENOMEM);
>>=20
>> @@ -1127,7 +1127,7 @@ static int mgc_apply_recover_logs(struct obd_devic=
e *mgc,
>>  	LASSERT(cfg->cfg_instance !=3D NULL);
>>  	LASSERT(cfg->cfg_sb =3D=3D cfg->cfg_instance);
>>=20
>> -	inst =3D kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
>> +	inst =3D kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
>>  	if (!inst)
>>  		return -ENOMEM;
>>=20
>> @@ -1334,14 +1334,14 @@ static int mgc_process_recover_log(struct obd_de=
vice *obd,
>>  	if (cfg->cfg_last_idx =3D=3D 0) /* the first time */
>>  		nrpages =3D CONFIG_READ_NRPAGES_INIT;
>>=20
>> -	pages =3D kcalloc(nrpages, sizeof(*pages), GFP_NOFS);
>> +	pages =3D kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
>>  	if (pages =3D=3D NULL) {
>>  		rc =3D -ENOMEM;
>>  		goto out;
>>  	}
>>=20
>>  	for (i =3D 0; i < nrpages; i++) {
>> -		pages[i] =3D alloc_page(GFP_IOFS);
>> +		pages[i] =3D alloc_page(GFP_KERNEL);
>>  		if (pages[i] =3D=3D NULL) {
>>  			rc =3D -ENOMEM;
>>  			goto out;
>> @@ -1492,7 +1492,7 @@ static int mgc_process_cfg_log(struct obd_device *=
mgc,
>>  	if (cld->cld_cfg.cfg_sb)
>>  		lsi =3D s2lsi(cld->cld_cfg.cfg_sb);
>>=20
>> -	env =3D kzalloc(sizeof(*env), GFP_NOFS);
>> +	env =3D kzalloc(sizeof(*env), GFP_KERNEL);
>>  	if (!env)
>>  		return -ENOMEM;

These should live in it's own separate thread so I imagine should be fine.

>> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drive=
rs/staging/lustre/lustre/obdecho/echo_client.c
>> index 27bd170c3a28..7c8443644300 100644
>> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
>> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
>> @@ -1561,7 +1561,7 @@ static int echo_client_kbrw(struct echo_device *ed=
, int rw, struct obdo *oa,
>>  		  (oa->o_valid & OBD_MD_FLFLAGS) !=3D 0 &&
>>  		  (oa->o_flags & OBD_FL_DEBUG_CHECK) !=3D 0);
>>=20
>> -	gfp_mask =3D ((ostid_id(&oa->o_oi) & 2) =3D=3D 0) ? GFP_IOFS : GFP_HIG=
HUSER;
>> +	gfp_mask =3D ((ostid_id(&oa->o_oi) & 2) =3D=3D 0) ? GFP_KERNEL : GFP_H=
IGHUSER;
>>=20
>>  	LASSERT(rw =3D=3D OBD_BRW_WRITE || rw =3D=3D OBD_BRW_READ);
>>  	LASSERT(lsm !=3D NULL);

This is it's own thing, so ok

>> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/sta=
ging/lustre/lustre/osc/osc_cache.c
>> index c72035e048aa..6fa6bc6874ab 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> @@ -346,7 +346,7 @@ static struct osc_extent *osc_extent_alloc(struct os=
c_object *obj)
>>  {
>>  	struct osc_extent *ext;
>>=20
>> -	OBD_SLAB_ALLOC_PTR_GFP(ext, osc_extent_kmem, GFP_IOFS);
>> +	OBD_SLAB_ALLOC_PTR_GFP(ext, osc_extent_kmem, GFP_KERNEL);
>>  	if (ext =3D=3D NULL)
>>  		return NULL;
>>=20

These are called in IO path, so should be GFP_NOFS, really.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
