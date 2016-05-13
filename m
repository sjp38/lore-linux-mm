Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 103D66B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:05:09 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so167229944pac.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:05:09 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id dy1si24360562pab.117.2016.05.13.05.05.07
        for <linux-mm@kvack.org>;
        Fri, 13 May 2016 05:05:08 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Fri, 13 May 2016 12:05:05 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023C721B@IRSMSX103.ger.corp.intel.com>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com> <20160511075313.GE16677@dhcp22.suse.cz>
In-Reply-To: <20160511075313.GE16677@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 05-11-16 09:53:00, Michal Hocko wrote:
> Yes I think this makes sense. The only case where it would be suboptimal
> is when the pagevec was already full and then we just created a single
> page pvec to drain it. This can be handled better though by:
>=20
> diff --git a/mm/swap.c b/mm/swap.c
> index 95916142fc46..3fe4f180e8bf 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
> 	struct pagevec *pvec =3D &get_cpu_var(lru_add_pvec);
> =20
> 	get_page(page);
>-	if (!pagevec_space(pvec))
>+	if (!pagevec_add(pvec, page) || PageCompound(page))
> 		__pagevec_lru_add(pvec);
>-	pagevec_add(pvec, page);
> 	put_cpu_var(lru_add_pvec);
 >}
=20
Oh yeah, that's exactly what I meant, couldn't find such elegant way of
handling this special case and didn't want to obscure the idea.

I'll do the tests proposed by Date and be back here with results next week.

Thank you guys for the involvement,
Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
