Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 13D776201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 06:56:22 -0400 (EDT)
Subject: Re: [PATCH -mmotm 12/30] selinux: tag avc cache alloc as non-critical
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
From: Mitchell Erblich <erblichs@earthlink.net>
In-Reply-To: <20100713101906.2835.83443.sendpatchset@danny.redhat>
Date: Tue, 13 Jul 2010 03:55:55 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <6E38A74E-B033-4D2A-9620-2A8BDF9E0AD1@earthlink.net>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat> <20100713101906.2835.83443.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>


On Jul 13, 2010, at 3:19 AM, Xiaotian Feng wrote:

> =46rom 6c3a91091b2910c23908a9f9953efcf3df14e522 Mon Sep 17 00:00:00 =
2001
> From: Xiaotian Feng <dfeng@redhat.com>
> Date: Tue, 13 Jul 2010 11:02:41 +0800
> Subject: [PATCH 12/30] selinux: tag avc cache alloc as non-critical
>=20
> Failing to allocate a cache entry will only harm performance not =
correctness.
> Do not consume valuable reserve pages for something like that.
>=20
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> ---
> security/selinux/avc.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/security/selinux/avc.c b/security/selinux/avc.c
> index 3662b0f..9029395 100644
> --- a/security/selinux/avc.c
> +++ b/security/selinux/avc.c
> @@ -284,7 +284,7 @@ static struct avc_node *avc_alloc_node(void)
> {
> 	struct avc_node *node;
>=20
> -	node =3D kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
> +	node =3D kmem_cache_zalloc(avc_node_cachep, =
GFP_ATOMIC|__GFP_NOMEMALLOC);
> 	if (!node)
> 		goto out;
>=20
> --=20
> 1.7.1.1
>=20

Why not just replace GFP_ATOMIC with GFP_NOWAIT?

This would NOT consume the valuable last pages.

Mitchell Erblich
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
