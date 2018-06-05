Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6026B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 18:53:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id c6-v6so2140630pll.4
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 15:53:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r27-v6sor3135360pfl.7.2018.06.05.15.53.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 15:53:55 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180605200800.emb3yfdtnpjgmxb7@techsingularity.net>
Date: Tue, 5 Jun 2018 15:53:51 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <4635880A-CC44-4E06-B3DB-597DE6F5B530@gmail.com>
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
 <EAD124C4-FFA4-4894-AE8B-33949CD6731B@gmail.com>
 <20180605200800.emb3yfdtnpjgmxb7@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Mel Gorman <mgorman@techsingularity.net> wrote:

> On Tue, Jun 05, 2018 at 12:53:57PM -0700, Nadav Amit wrote:
>> While I do not have a specific reservation regarding the logic, I =
find the
>> current TLB invalidation scheme hard to follow and inconsistent. I =
guess
>> should_force_flush() can be extended and used more commonly to make =
things
>> clearer.
>>=20
>> To be more specific and to give an example: Can should_force_flush() =
be used
>> in zap_pte_range() to set the force_flush instead of the current =
code?
>>=20
>>  if (!PageAnon(page)) {
>> 	if (pte_dirty(ptent)) {
>> 		force_flush =3D 1;
>> 		...
>>  	}
>=20
> That check is against !PageAnon pages where it's potentially critical
> that the dirty PTE bit be propogated to the page. You could split the
> separate the TLB flush from the dirty page setting but it's not the =
same
> class of problem and without perf data, it's not clear it's =
worthwhile.
>=20
> Note that I also didn't handle the huge page moving because it's =
already
> naturally batching a larger range with a lower potential factor of TLB
> flushing and has different potential race conditions.

I noticed.

>=20
> I agree that the TLB handling would benefit from being simplier but =
it's
> not a simple search/replace job to deal with the different cases that =
apply.

I understand. It=E2=80=99s not just a matter of performance: having a =
consistent
implementation can prevent bugs and allow auditing of the invalidation
scheme.

Anyhow, if I find some free time, I=E2=80=99ll give it a shot.
