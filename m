Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D448CC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 15:29:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8742320657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 15:29:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8742320657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20ADC6B0007; Thu, 16 May 2019 11:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195306B0008; Thu, 16 May 2019 11:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0351E6B000A; Thu, 16 May 2019 11:29:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D20266B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 11:29:41 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id q1so3083032qkq.4
        for <linux-mm@kvack.org>; Thu, 16 May 2019 08:29:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=z1lQlAi0FB8l3bCtRiLVqdn7QK/wt8ebjcs4vqlpYr0=;
        b=Nh89dF0aZWaLve76l2iWF1AWSNlwCkcRrTgel+QqxTPHlGAZpymkVirPsyDfD+MvO3
         PS1Iyr8ZnNo0BtDSqKWlgFZLA41gFqBaHQwAL0Nr2mNJyz8G7Qx5MYCWyjGi2c6wQpjw
         qTACWaLBXwM8S1ORrR9d8uDo+0Tqjg6Q7y5q5MGxEY63j1fhiAP7NMag7UeObh5MsOWE
         B+QiP3zWR0w97GQota+G1Ro1nehgOETAQnIhsYs5Fo/wxeM3hfcG6tWNyXuOdBgFZvsL
         lHxTIKDLsMRE4QlPXYAo9nUeVOfCbPINilHEiiGw6KMOFexXgTN5R2Hn74JjoCjoqWO0
         Yh/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3M7/0pAAxfIh3EDRwdNEtvbh/N+VA8CNewFlSO9tQI/W0a2XC
	br7jUYKeO430ZYvkFO+6XixBbV+uar0XSLVVK2nKCIjNBTNXEN1TKLk3fSumc96HUKSeLu1+4Uu
	hV44lSqNDEpddnKzXM5ptttFTN2qaEAR/vMqtHb2BVGKX4VFft4Sg0rd5FEYcGVWgmw==
X-Received: by 2002:a37:8885:: with SMTP id k127mr39413120qkd.59.1558020581373;
        Thu, 16 May 2019 08:29:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZtbzIN/ZyT4aZtHfiLNeOoTuzLVdUeWwGdqS6+iphwRDHYpROVBS5r3I0Om5m5Ybe8VI2
X-Received: by 2002:a37:8885:: with SMTP id k127mr39413058qkd.59.1558020580601;
        Thu, 16 May 2019 08:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558020580; cv=none;
        d=google.com; s=arc-20160816;
        b=iFrc+lAKulHHPxk/blgsNvxsMfSmSd9WzlK+2klK7loF/cdwVigJQOU0Ms374nu/jI
         NNnHNoONHChgDCsFl87EUzGC/q7JMB3jHWzhkSkcyOVA0kxFnu3TH+uI0zDDov9DkHNQ
         R4tJM66kTa+cqYGrEAZ+R2BQ2OK1tzyBtJrK1xVQpvZGwlbTOigTYtryFKoMU6Wn6wx4
         /GRtD8tU9HGNpdles9h1KKlSI6hW2TJSuc4HQvK3nC5USKeSt2IbWZYl6uZXdpGkf9oL
         eZ4dEHYszcMOjnpornOQuA+a1gFnYuVRIf8aVM+TO3edKD9vAAd1wyxjzqVQGHt3gqNe
         sPsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=z1lQlAi0FB8l3bCtRiLVqdn7QK/wt8ebjcs4vqlpYr0=;
        b=n2x3++Ki1Qc1SG21JzlHzxUxtZvD7Sj7iuBIi1podmnu4aHE4iStlji9ClRSNTna+f
         0bXO4roRSpHJE9/Y2UZu/OWGRYLm9KhzJMN62V0e/BR4eSnU9acLvoaeqbPMibMJiim0
         eGIf0ABPS95CNAxGLRQO6VWdSPuQ+YuNJpS0Gz8gFiOHqkud8uq894121P0IQYczUxMn
         HydNgNRi6ZEUFf4CYeXsLMNBxdhfom30VYPNlc7t0osPeCPahD90zM9PPkyeQ8RuCrGT
         L1EiKrzspz3POX6pLhFNcVLHGqi9qDCiP4hYEUJ0bDoZyeT1qFXg2TYHPi6DFqZOAwV5
         zapQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m2si109263qtp.280.2019.05.16.08.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 08:29:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 51C93307C940;
	Thu, 16 May 2019 15:29:39 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 371B45D6A9;
	Thu, 16 May 2019 15:29:39 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 902B31806B11;
	Thu, 16 May 2019 15:29:38 +0000 (UTC)
Date: Thu, 16 May 2019 11:29:35 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Will Deacon <will.deacon@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, peterz@infradead.org, 
	namit@vmware.com, minchan@kernel.org, mgorman@suse.de, 
	stable@vger.kernel.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
Message-ID: <1158926942.23199905.1558020575293.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190514145445.GB2825@fuggles.cambridge.arm.com>
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com> <20190513163804.GB10754@fuggles.cambridge.arm.com> <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com> <20190514145445.GB2825@fuggles.cambridge.arm.com>
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.43.17.163, 10.4.195.10]
Thread-Topic: mmu_gather: remove __tlb_reset_range() for force flush
Thread-Index: uzKTPt4zsaol+2IqXYgAH+t+3N7Fug==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 16 May 2019 15:29:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Mon, May 13, 2019 at 04:01:09PM -0700, Yang Shi wrote:
> >=20
> >=20
> > On 5/13/19 9:38 AM, Will Deacon wrote:
> > > On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> > > > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > > > index 99740e1..469492d 100644
> > > > --- a/mm/mmu_gather.c
> > > > +++ b/mm/mmu_gather.c
> > > > @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> > > >   {
> > > >   =09/*
> > > >   =09 * If there are parallel threads are doing PTE changes on same=
 range
> > > > -=09 * under non-exclusive lock(e.g., mmap_sem read-side) but defer=
 TLB
> > > > -=09 * flush by batching, a thread has stable TLB entry can fail to=
 flush
> > > > -=09 * the TLB by observing pte_none|!pte_dirty, for example so flu=
sh TLB
> > > > -=09 * forcefully if we detect parallel PTE batching threads.
> > > > +=09 * under non-exclusive lock (e.g., mmap_sem read-side) but defe=
r TLB
> > > > +=09 * flush by batching, one thread may end up seeing inconsistent=
 PTEs
> > > > +=09 * and result in having stale TLB entries.  So flush TLB forcef=
ully
> > > > +=09 * if we detect parallel PTE batching threads.
> > > > +=09 *
> > > > +=09 * However, some syscalls, e.g. munmap(), may free page tables,=
 this
> > > > +=09 * needs force flush everything in the given range. Otherwise t=
his
> > > > +=09 * may result in having stale TLB entries for some architecture=
s,
> > > > +=09 * e.g. aarch64, that could specify flush what level TLB.
> > > >   =09 */
> > > > -=09if (mm_tlb_flush_nested(tlb->mm)) {
> > > > -=09=09__tlb_reset_range(tlb);
> > > > -=09=09__tlb_adjust_range(tlb, start, end - start);
> > > > +=09if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
> > > > +=09=09/*
> > > > +=09=09 * Since we can't tell what we actually should have
> > > > +=09=09 * flushed, flush everything in the given range.
> > > > +=09=09 */
> > > > +=09=09tlb->freed_tables =3D 1;
> > > > +=09=09tlb->cleared_ptes =3D 1;
> > > > +=09=09tlb->cleared_pmds =3D 1;
> > > > +=09=09tlb->cleared_puds =3D 1;
> > > > +=09=09tlb->cleared_p4ds =3D 1;
> > > > +
> > > > +=09=09/*
> > > > +=09=09 * Some architectures, e.g. ARM, that have range invalidatio=
n
> > > > +=09=09 * and care about VM_EXEC for I-Cache invalidation, need for=
ce
> > > > +=09=09 * vma_exec set.
> > > > +=09=09 */
> > > > +=09=09tlb->vma_exec =3D 1;
> > > > +
> > > > +=09=09/* Force vma_huge clear to guarantee safer flush */
> > > > +=09=09tlb->vma_huge =3D 0;
> > > > +
> > > > +=09=09tlb->start =3D start;
> > > > +=09=09tlb->end =3D end;
> > > >   =09}
> > > Whilst I think this is correct, it would be interesting to see whethe=
r
> > > or not it's actually faster than just nuking the whole mm, as I menti=
oned
> > > before.
> > >=20
> > > At least in terms of getting a short-term fix, I'd prefer the diff be=
low
> > > if it's not measurably worse.
> >=20
> > I did a quick test with ebizzy (96 threads with 5 iterations) on my x86=
 VM,
> > it shows slightly slowdown on records/s but much more sys time spent wi=
th
> > fullmm flush, the below is the data.
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 nofullmm=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 fullmm
> > ops (records/s) =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 225606=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 225119
> > sys (s)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 0.69=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 1.14
> >=20
> > It looks the slight reduction of records/s is caused by the increase of=
 sys
> > time.
>=20
> That's not what I expected, and I'm unable to explain why moving to fullm=
m
> would /increase/ the system time. I would've thought the time spent doing
> the invalidation would decrease, with the downside that the TLB is cold
> when returning back to userspace.
>=20

I tried ebizzy with various parameters (malloc vs mmap, ran it for hour),
but performance was very similar for both patches.

So, I was looking for workload that would demonstrate the largest differenc=
e.
Inspired by python xml-rpc, which can handle each request in new thread,
I tried following [1]:

16 threads, each looping 100k times over:
  mmap(16M)
  touch 1 page
  madvise(DONTNEED)
  munmap(16M)

This yields quite significant difference for 2 patches when running on
my 46 CPU arm host. I checked it twice - applied patch, recompiled, reboote=
d,
but numbers stayed +- couple seconds the same.

Does it somewhat match your expectation?

v2 patch
---------
real    2m33.460s
user    0m3.359s
sys     15m32.307s

real    2m33.895s
user    0m2.749s
sys     16m34.500s

real    2m35.666s
user    0m3.528s
sys     15m23.377s

real    2m32.898s
user    0m2.789s
sys     16m18.801s

real    2m33.087s
user    0m3.565s
sys     16m23.815s


fullmm version
---------------
real    0m46.811s
user    0m1.596s
sys     1m47.500s

real    0m47.322s
user    0m1.803s
sys     1m48.449s

real    0m46.668s
user    0m1.508s
sys     1m47.352s

real    0m46.742s
user    0m2.007s
sys     1m47.217s

real    0m46.948s
user    0m1.785s
sys     1m47.906s

[1] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_s=
tall/mmap8.c

