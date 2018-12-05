Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 908AE6B76CF
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 18:11:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so10629448edb.5
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 15:11:23 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d56si467094eda.343.2018.12.05.15.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 15:11:22 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm/memcg: Fix min/low usage in
 propagate_protected_usage()
Date: Wed, 5 Dec 2018 23:11:16 +0000
Message-ID: <20181205231110.GA11330@castle.DHCP.thefacebook.com>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203180008.GB31090@castle.DHCP.thefacebook.com>
 <03652447-d9ba-45ea-3365-46a4caf96748@linux.alibaba.com>
In-Reply-To: <03652447-d9ba-45ea-3365-46a4caf96748@linux.alibaba.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E662CE51E0E9F542824D65D18AFDE335@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Dec 05, 2018 at 04:58:31PM +0800, Xunlei Pang wrote:
> Hi Roman,
>=20
> On 2018/12/4 AM 2:00, Roman Gushchin wrote:
> > On Mon, Dec 03, 2018 at 04:01:17PM +0800, Xunlei Pang wrote:
> >> When usage exceeds min, min usage should be min other than 0.
> >> Apply the same for low.
> >>
> >> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
> >> ---
> >>  mm/page_counter.c | 12 ++----------
> >>  1 file changed, 2 insertions(+), 10 deletions(-)
> >>
> >> diff --git a/mm/page_counter.c b/mm/page_counter.c
> >> index de31470655f6..75d53f15f040 100644
> >> --- a/mm/page_counter.c
> >> +++ b/mm/page_counter.c
> >> @@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_c=
ounter *c,
> >>  		return;
> >> =20
> >>  	if (c->min || atomic_long_read(&c->min_usage)) {
> >> -		if (usage <=3D c->min)
> >> -			protected =3D usage;
> >> -		else
> >> -			protected =3D 0;
> >> -
> >> +		protected =3D min(usage, c->min);
> >=20
> > This change makes sense in the combination with the patch 3, but not as=
 a
> > standlone "fix". It's not a bug, it's a required thing unless you start=
 scanning
> > proportionally to memory.low/min excess.
> >=20
> > Please, reflect this in the commit message. Or, even better, merge it i=
nto
> > the patch 3.
>=20
> The more I looked the more I think it's a bug, but anyway I'm fine with
> merging it into patch 3 :-)

It's not. I've explained it back to the time when we've been discussing tha=
t
patch. TL;DR because the decision to scan or to skip is binary now, to
prioritize one cgroup over other it's necessary to do this trick. Otherwise
both cgroups can have their usages above effective memory protections, and
will be scanned with the same pace.

If you have any doubts, you can try to run memcg kselftests with and withou=
t
this change, you'll see the difference.

Thanks!
