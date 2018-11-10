Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35106B076F
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 22:48:22 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j6-v6so3414232wre.1
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 19:48:22 -0800 (PST)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id z2-v6si7670725wrv.437.2018.11.09.19.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 19:48:21 -0800 (PST)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
 initialization within each node
Date: Sat, 10 Nov 2018 03:48:14 +0000
Message-ID: <AT5PR8401MB1169798EBEF1EE5EBA3ABFFFABC70@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-12-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-12-daniel.m.jordan@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>

> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org <linux-kernel-
> owner@vger.kernel.org> On Behalf Of Daniel Jordan
> Sent: Monday, November 05, 2018 10:56 AM
> Subject: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
> initialization within each node
>=20
> ...  The kernel doesn't
> know the memory bandwidth of a given system to get the most efficient
> number of threads, so there's some guesswork involved. =20

The ACPI HMAT (Heterogeneous Memory Attribute Table) is designed to report
that kind of information, and could facilitate automatic tuning.

There was discussion last year about kernel support for it:
https://lore.kernel.org/lkml/20171214021019.13579-1-ross.zwisler@linux.inte=
l.com/


> In testing, a reasonable value turned out to be about a quarter of the
> CPUs on the node.
...
> +	/*
> +	 * We'd like to know the memory bandwidth of the chip to
>         calculate the
> +	 * most efficient number of threads to start, but we can't.
> +	 * In testing, a good value for a variety of systems was a
>         quarter of the CPUs on the node.
> +	 */
> +	nr_node_cpus =3D DIV_ROUND_UP(cpumask_weight(cpumask), 4);


You might want to base that calculation on and limit the threads to
physical cores, not hyperthreaded cores.

---
Robert Elliott, HPE Persistent Memory
