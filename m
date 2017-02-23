Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16DB86B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:06:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 2so25083105pfz.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 00:06:08 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id j61si3620655plb.336.2017.02.23.00.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 00:06:07 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 03/14] mm/migrate: Add copy_pages_mthread function
Date: Thu, 23 Feb 2017 08:02:17 +0000
Message-ID: <20170223080216.GA9486@hori1.linux.bs1.fc.nec.co.jp>
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-4-zi.yan@sent.com>
 <20170223060649.GA7336@hori1.linux.bs1.fc.nec.co.jp>
 <ff44b5a5-d022-5c68-b067-634614f0a28c@linux.vnet.ibm.com>
In-Reply-To: <ff44b5a5-d022-5c68-b067-634614f0a28c@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5089A2EE88B42D4D8663D67406AABC1D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Thu, Feb 23, 2017 at 01:20:16PM +0530, Anshuman Khandual wrote:
...
> >=20
> >> +
> >> +	cthreads =3D nr_copythreads;
> >> +	cthreads =3D min_t(unsigned int, cthreads, cpumask_weight(cpumask));
> >=20
> > nitpick, but looks a little wordy, can it be simply like below?
> >=20
> >   cthreads =3D min_t(unsigned int, nr_copythreads, cpumask_weight(cpuma=
sk));
> >=20
> >> +	cthreads =3D (cthreads / 2) * 2;
> >=20
> > I'm not sure the intention here. # of threads should be even number?
>=20
> Yes.
>=20
> > If cpumask_weight() is 1, cthreads is 0, that could cause zero division=
.
> > So you had better making sure to prevent it.
>=20
> If cpumask_weight() is 1, then min_t(unsigned int, 8, 1) should be
> greater that equal to 1. Then cthreads can end up in 0. That is
> possible. But how there is a chance of zero division ?=20

Hi Anshuman,

I just thought like above when reading the line your patch introduces:

       chunk_size =3D PAGE_SIZE * nr_pages / cthreads
                                           ~~~~~~~~
                                           (this can be 0?)

- Naoya

> May be its
> possible if we are trying move into a CPU less memory only node
> where cpumask_weight() is 0 ?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
