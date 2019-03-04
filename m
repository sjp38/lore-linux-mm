Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2483DC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4A3621019
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pnN5Fm/m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4A3621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DB698E0003; Mon,  4 Mar 2019 01:44:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C698E0001; Mon,  4 Mar 2019 01:44:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556918E0003; Mon,  4 Mar 2019 01:44:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 121458E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 01:44:26 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 27so3886050pgv.14
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 22:44:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OZuUAj6EPjSLvPrzy7kKD/7kOJbSkOJZ9wk5yksu5Mc=;
        b=A5wtjDsAfJFojHIsG5xRSLIoU3UQjYTWCa56Bc6VWZBjicygGXPuCOjLcKIZ0fwI8s
         IG9gsMnUa/9lLydKVFJvOK6O+OQ7Vb3w88DdHCmEGKmF4IB5K3PayvaGvstA5t9bKmBS
         6Zy5zQOUDoaO9ulbW0ceQzAb5Aq7V35Haolwxt3sHo8p+tj2aBkjORi0LJQYG+Y+trV6
         alXHilA39RFLT6NI1rR0d/iJd+ZUDAYmH94R6tVedNqJqBnwPyIKAEhlQkCVjShjX4OJ
         GowEqCi5+l7/oyGMTIaMui1ukKt0CbKcQy6r/gEezULH9LsNyYT8LeN9lQWfAaW24nxd
         SFfA==
X-Gm-Message-State: APjAAAXQYfjCP68QjWp35T2gwE0VsVFczNGAg8dafLZQSVNYg97sbCT/
	wBoagH4a8fd5NmRZFwcgKhgr/+ys1XyP6yR1HBADftjsgQti781vBw2q0TbuR8sYvnEULFfLd4B
	ZUjHwNtBm4h31f/lN7j4arlushdRFoFakMenrp/TuW7FbUhRe7PfF9EdsqdH6HerZWA==
X-Received: by 2002:a62:ee03:: with SMTP id e3mr18952510pfi.241.1551681865568;
        Sun, 03 Mar 2019 22:44:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqzJbz5yeR9KQxCTulB4TQG0XC4+5B57fNwsa6dbWhSAOvHzFN85ZVeyF1VwK1nSonzL1+mZ
X-Received: by 2002:a62:ee03:: with SMTP id e3mr18952464pfi.241.1551681864619;
        Sun, 03 Mar 2019 22:44:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551681864; cv=none;
        d=google.com; s=arc-20160816;
        b=We3nH2tXswcieBu0xh7LAsl73GsvoBZ8wqYLv56zLKOUVXPgCyQDS1Z+RPSe3EfEwM
         pLLPqEg/2FbAUXPhHbvpomOOIxIpiwF9k1YffeLuMn+tRYJgKDLBvcosFs73y6FMzudC
         /8wQVV3b+bg3S3hNg0ev25zErQddFotzDbGKu1DUYf/3ZzwGdQTPkJPuswbT797/dDEf
         NrG3joFDHuvJoL6feBUrc/2TdAyobYdOtzDlmG1InC81bsd3SeGMvMgq1kbX58rAWmj3
         Xb7xjnZ6qpQ2fwICi31Uxv/ptfU1m5l9p0IZrHfQgNJQ3W+fNI/s49KsLaeR4i3WHYrD
         dmjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OZuUAj6EPjSLvPrzy7kKD/7kOJbSkOJZ9wk5yksu5Mc=;
        b=vQ484b3svmGegg+bA/obzVpp/24UADr6++sIF2ByGkFtd6DvYz+n1pPH2IvYaK5nXn
         Kn2xgnNanVy7FebxcSqJW2I1tVXLyaDRlo5TOxczA6HibdN6SH9Jsnfv6T/d4EsbRJkP
         7TItlZtCT+hSFYvHYawcfjLjI64o/wIDkFfK8WkXOrn1iEbzoObDiWtTPsactUFG5/GU
         jG7D8wSTG+BLowYFC7ZmorQ40IeKhKS3VJzxExLxaGlbTfYpHutaZ4j7x9i8ZlTXHAOo
         16HBYB3kQjkPVEf+i7LnAcoIT3CGAooZmj2qNpgLJGiM0VDplnaHH0l4FpDp0G9FIBR9
         rcfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="pnN5Fm/m";
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j4si4681929pll.286.2019.03.03.22.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 22:44:24 -0800 (PST)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="pnN5Fm/m";
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [77.138.135.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8A19E2082F;
	Mon,  4 Mar 2019 06:44:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551681864;
	bh=crHFy1cpJqZyf5dNDD0zXD/XdINNyPPFt0iGyFNptaE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=pnN5Fm/mbIzZKdHLBLLoNaPHVvWx4hA3nv9afNVmeeX3BA5btN6ETlh6aBec8nusH
	 6Ul4NCC5gCtgOPlzv0jd5Ls2z8viaBgVegyvP08n1B6UMmF7D9so395DmRMInUehft
	 6m6EakV0Byaow8xRN7HKchhKjF8An/tp08ea1I/I=
Date: Mon, 4 Mar 2019 08:44:19 +0200
From: Leon Romanovsky <leon@kernel.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190304064419.GB15253@mtr-leonro.mtl.com>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Zd8I2GZVcdxtyaG/"
Content-Disposition: inline
In-Reply-To: <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Zd8I2GZVcdxtyaG/
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 03, 2019 at 02:37:33PM -0800, John Hubbard wrote:
> On 3/3/19 1:52 AM, Artemy Kovalyov wrote:
> >
> >
> > On 02/03/2019 21:44, Ira Weiny wrote:
> > >
> > > On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrot=
e:
> > > > From: John Hubbard <jhubbard@nvidia.com>
> > > >
> > > > ...
> > > > 3. Dead code removal: the check for (user_virt & ~page_mask)
> > > > is checking for a condition that can never happen,
> > > > because earlier:
> > > >
> > > > =A0=A0=A0=A0 user_virt =3D user_virt & page_mask;
> > > >
> > > > ...so, remove that entire phrase.
> > > >
> > > > =A0=A0=A0=A0=A0=A0=A0=A0=A0 bcnt -=3D min_t(size_t, npages << PAGE_=
SHIFT, bcnt);
> > > > =A0=A0=A0=A0=A0=A0=A0=A0=A0 mutex_lock(&umem_odp->umem_mutex);
> > > > =A0=A0=A0=A0=A0=A0=A0=A0=A0 for (j =3D 0; j < npages; j++, user_vir=
t +=3D PAGE_SIZE) {
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (user_virt & ~page_mask) {
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 p +=3D PAGE_SIZE;
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (page_to_phys(loc=
al_page_list[j]) !=3D p) {
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ret =3D =
-EFAULT;
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 break;
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 put_page(local_page_=
list[j]);
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
> > > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
> > > > -
> > >
> > > I think this is trying to account for compound pages. (ie page_mask c=
ould
> > > represent more than PAGE_SIZE which is what user_virt is being incrim=
ented by.)
> > > But putting the page in that case seems to be the wrong thing to do?
> > >
> > > Yes this was added by Artemy[1] now cc'ed.
> >
> > Right, this is for huge pages, please keep it.
> > put_page() needed to decrement refcount of the head page.
> >
>
> OK, thanks for explaining! Artemy, while you're here, any thoughts about =
the
> release_pages, and the change of the starting point, from the other part
> of the patch:

Your release pages code is right fix, it will be great if you prepare
proper and standalone patch.

Thanks

>
> @@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp
> *umem_odp, u64 user_virt,
> 	mutex_unlock(&umem_odp->umem_mutex);
>
>  		if (ret < 0) {
> -			/* Release left over pages when handling errors. */
> -			for (++j; j < npages; ++j)
> -				put_page(local_page_list[j]);
> +			/*
> +			 * Release pages, starting at the the first page
> +			 * that experienced an error.
> +			 */
> +			release_pages(&local_page_list[j], npages - j);
>  			break;
>  		}
>  	}
>
> ?
>
> thanks,
> --
> John Hubbard
> NVIDIA
>

--Zd8I2GZVcdxtyaG/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJcfMlDAAoJEORje4g2clin72MP/ibsjGMdgjy0b+1RJm1NeF5f
OtglTfABByBidkhy1S+YICCsf0inIiBAnm3bHGzHT7DycmnHLBLVmHvARo3HeHNS
NCCWvE5dNImmalxiu7CrMoeVhzLowBxXfLINxITC1TZr9+3nrJxRakh6p6tVVdYd
u2403inffoLuBuTT2f5f8sk/U9ogLOmkSF4S4z2VQxjz1S58BpclLlDDanIak+R+
ne4Lz6tFlnPBMbtXhzEucqbsEoielmh1I7bVtg05qtWqaVFFISiImq1qKTfrIvjR
S8VEoYF06uV+O7XCRMP5yvHLDijnTOCwwFHImGo3/JYLwWVFs8rkYK/y2XjKuqpZ
uo1UMyKJgpT1XTdRp19+iM9Bc9Sxk7fb+5WsCgyHTTKf+8E3u4sylASetKCCdZWy
GO10Wf6ZgveMk1z/BNiVjiHCQtkzS2weNNkFqKnfxUnrnNXH1oXVQxpqJg2Td9hA
9Y7miv0Q8mgsZbfNuYOzsry25cihN+RPQgzdnKOweNKuBNy83tQTuxRv6N3yszJo
xWunaSZOX9GU4IHmTRZi0LC8FNDY0M3PM3ISmRI1Q69SAfBFN2ACaF0hYTxE74iw
H6K46M2YF8DhHOV8TV/NjIh+x7PHBK9IXw3rQuPrE3FDeIrwwuif5uszJSEdS4jp
jHFOkAAWZh2EAc5wwMjc
=+eOE
-----END PGP SIGNATURE-----

--Zd8I2GZVcdxtyaG/--

