Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E391A6B69DE
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:00:21 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so7270813pgs.13
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:00:21 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i13si13087062pgg.100.2018.12.03.10.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 10:00:20 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm/memcg: Fix min/low usage in
 propagate_protected_usage()
Date: Mon, 3 Dec 2018 18:00:11 +0000
Message-ID: <20181203180008.GB31090@castle.DHCP.thefacebook.com>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
In-Reply-To: <20181203080119.18989-1-xlpang@linux.alibaba.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <93E17A46B4BEB947BD00ACE85CB7A17E@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Dec 03, 2018 at 04:01:17PM +0800, Xunlei Pang wrote:
> When usage exceeds min, min usage should be min other than 0.
> Apply the same for low.
>=20
> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
> ---
>  mm/page_counter.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
>=20
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index de31470655f6..75d53f15f040 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_coun=
ter *c,
>  		return;
> =20
>  	if (c->min || atomic_long_read(&c->min_usage)) {
> -		if (usage <=3D c->min)
> -			protected =3D usage;
> -		else
> -			protected =3D 0;
> -
> +		protected =3D min(usage, c->min);

This change makes sense in the combination with the patch 3, but not as a
standlone "fix". It's not a bug, it's a required thing unless you start sca=
nning
proportionally to memory.low/min excess.

Please, reflect this in the commit message. Or, even better, merge it into
the patch 3.

Also, please, make sure that cgroup kselftests are passing after your chang=
es.

Thanks!
