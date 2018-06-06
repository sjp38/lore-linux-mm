Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 694AE6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 14:20:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k193-v6so2532749pge.3
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 11:20:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor3581261pls.117.2018.06.06.11.20.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 11:20:09 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mremap: Increase LATENCY_LIMIT of mremap to reduce the
 number of TLB shootdowns
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180606174723.bag3o55fvqp6nbvc@techsingularity.net>
Date: Wed, 6 Jun 2018 11:20:08 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <70CFD0DC-FEBD-4B51-9AE9-0786AF66149F@gmail.com>
References: <20180606140255.br5ztpeqdmwfto47@techsingularity.net>
 <C86F5DE4-DAAE-4C12-B509-E5807ADA471E@gmail.com>
 <20180606174723.bag3o55fvqp6nbvc@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Jun 06, 2018 at 08:55:15AM -0700, Nadav Amit wrote:
>>> -#define LATENCY_LIMIT	(64 * PAGE_SIZE)
>>> +#define LATENCY_LIMIT	(PMD_SIZE)
>>>=20
>>> unsigned long move_page_tables(struct vm_area_struct *vma,
>>> 		unsigned long old_addr, struct vm_area_struct *new_vma,
>>=20
>> This LATENCY_LIMIT is only used in move_page_tables() in the =
following
>> manner:
>>=20
>>  next =3D (new_addr + PMD_SIZE) & PMD_MASK;
>>  if (extent > next - new_addr)
>>      extent =3D next - new_addr;
>>  if (extent > LATENCY_LIMIT)
>>      extent =3D LATENCY_LIMIT;
>>=20
>> If LATENCY_LIMIT is to be changed to PMD_SIZE, then IIUC the last =
condition
>> is not required, and LATENCY_LIMIT can just be removed (assuming =
there is no
>> underflow case that hides somewhere).
>=20
> I see no problem removing it other than we may forget that we ever =
limited
> PTE lock hold times for any reason. I'm skeptical it will matter =
unless
> mremap-intensive workloads are a lot more common than I believe.

I have no opinion regarding the behavior change. It is just that code =
with
no effect is oftentimes confusing. A comment (if needed) can replace the
code, and git history would provide how it was once supported.
