Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 288876B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:11:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so89726026pfy.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 17:11:55 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z18si2448035pfg.247.2017.01.12.17.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 17:11:54 -0800 (PST)
From: "Dilger, Andreas" <andreas.dilger@intel.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Fri, 13 Jan 2017 01:11:51 +0000
Message-ID: <0B164192-F549-4D5E-BB07-B51886D936B0@intel.com>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FCAE4B7494D2EB4C9A20DA989F97BADD@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, "Luck, Tony" <tony.luck@intel.com>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent
 Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Boris
 Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei
 Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>


> On Jan 12, 2017, at 08:37, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> From: Michal Hocko <mhocko@suse.com>
>=20
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests < 64kB are basically never failing and invoke OOM killer to
> satisfy the allocation. This sounds too disruptive for something that
> has a reasonable fallback - the vmalloc. On the other hand those
> requests might fallback to vmalloc even when the memory allocator would
> succeed after several more reclaim/compaction attempts previously. There
> is no guarantee something like that happens though.
>=20
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Lustre part can be
Acked-by: Andreas Dilger <andreas.dilger@intel.com>

[snip]

> diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drive=
rs/staging/lustre/lnet/libcfs/linux/linux-mem.c
> index a6a76a681ea9..8f638267e704 100644
> --- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
> +++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
> @@ -45,15 +45,6 @@ EXPORT_SYMBOL(libcfs_kvzalloc);
> void *libcfs_kvzalloc_cpt(struct cfs_cpt_table *cptab, int cpt, size_t si=
ze,
> 			  gfp_t flags)
> {
> -	void *ret;
> -
> -	ret =3D kzalloc_node(size, flags | __GFP_NOWARN,
> -			   cfs_cpt_spread_node(cptab, cpt));
> -	if (!ret) {
> -		WARN_ON(!(flags & (__GFP_FS | __GFP_HIGH)));
> -		ret =3D vmalloc_node(size, cfs_cpt_spread_node(cptab, cpt));
> -	}
> -
> -	return ret;
> +	return kvzalloc_node(size, flags, cfs_cpt_spread_node(cptab, cpt));
> }
> EXPORT_SYMBOL(libcfs_kvzalloc_cpt);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
