Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A017E6B000D
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 13:41:51 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id w11-v6so110425lfc.12
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 10:41:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q37-v6si26654815lfi.117.2018.10.20.10.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Oct 2018 10:41:49 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Memory management issue in 4.18.15
Date: Sat, 20 Oct 2018 17:41:00 +0000
Message-ID: <20181020174053.GA6149@castle.DHCP.thefacebook.com>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <a655c898-0701-f10d-bbf3-8a0090544560@infradead.org>
In-Reply-To: <a655c898-0701-f10d-bbf3-8a0090544560@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <124A14B832841745B95D28394CA443FC@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Spock <dairinin@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Sasha Levin <alexander.levin@microsoft.com>

On Sat, Oct 20, 2018 at 08:37:28AM -0700, Randy Dunlap wrote:
> [add linux-mm mailing list + people]
>=20
>=20
> On 10/20/18 4:41 AM, Spock wrote:
> > Hello,
> >=20
> > I have a workload, which creates lots of cache pages. Before 4.18.15,
> > the behavior was very stable: pagecache is constantly growing until it
> > consumes all the free memory, and then kswapd is balancing it around
> > low watermark. After 4.18.15, once in a while khugepaged is waking up
> > and reclaims almost all the pages from pagecache, so there is always
> > around 2G of 8G unused. THP is enabled only for madvise case and are
> > not used.
> >=20
> > The exact change that leads to current behavior is
> > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit=
/?h=3Dlinux-4.18.y&id=3D62aad93f09c1952ede86405894df1b22012fd5ab
> >=20

Hello!

Can you, please, describe your workload in more details?
Do you use memory cgroups? How many of them? What's the ratio between slabs
and pagecache in the affected cgroup? Is the pagecache mmapped by some proc=
ess?
Is the majority of the pagecache created by few cached files or the number
of files is big?

This is definitely a strange effect. The change shouldn't affect pagecache
reclaim directly, so the only possibility I see is that because we started
applying some minimal pressure on slabs, we also started reclaim some inter=
nal
fs structures under background memory pressure, which leads to a more aggre=
ssive
pagecache reclaim.

Thanks!
