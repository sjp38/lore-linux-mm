Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D57E4C04E53
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C3A208CA
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:15:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C3A208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B0C06B0003; Tue, 14 May 2019 03:15:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363166B0005; Tue, 14 May 2019 03:15:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 250A46B0007; Tue, 14 May 2019 03:15:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 026BD6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:15:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o32so16975892qtf.1
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:15:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=Adm5dVNWcMYcdiiS7a3fE7y+ekKdIWA1qkWUn5RDuFA=;
        b=ppD9PwgTSjArvau8M78AK0UuCutr9fbF7MMDz6iW/RorDItwQ84LRuTRQRrjAfRHdR
         CbK7++mJ3tZSnjC7s/QmKVIhQs0PGogCpX/m4jL8rSQYkHAocUUgHqDVSPJXaFIzzr/k
         Iz8nZp0VeGrQigP3UGKfK9rTrAJdlVsYLLobTdZv3HTpPbYMaUcQM73zfI777eX/57fI
         OJogIoAkve9SKemSuxCsscf8EeMd1PyLHpdA0bzrmbjkVf+nFNkELkZaS3ypa3JH0Xjy
         APubmVpWGNKEG1jS0JC/8JEWUhCvPh743TUtigVWwnqNbJDg9EbxK5YFkdijYnmYK8mA
         2zJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWO3mXCQGZ4xqvLR4XL6UyVZCZXGW4PgYanp707bcFbnEGjNtO/
	o72vvONS7RxwlgNxzZ3WUiUHB+ruEOdgittb8WvNIJCU+t9kt3dE4OVDBSA+8HOjyJs/czZxduD
	TJ5xd6gz/xPNrShB4jGPMVFVIrVu9yu1TtMPo9kUENw+6Xj7dPEFe8HGXvZ44K+xGag==
X-Received: by 2002:ac8:954:: with SMTP id z20mr28034193qth.20.1557818141793;
        Tue, 14 May 2019 00:15:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+r8n9MvWLwtOH3WBe0SLnyvuzGbt83SXQ9IEyQ1nCkUyxBRQV7g45/5vpbUdHqyczji1g
X-Received: by 2002:ac8:954:: with SMTP id z20mr28034154qth.20.1557818141126;
        Tue, 14 May 2019 00:15:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557818141; cv=none;
        d=google.com; s=arc-20160816;
        b=Sj+25l+Ubp/uAuLgX5x98CJ2ZTCUVOsT9rgz5OgXPiXKgq9zrOOxv1sU5wMZQZdAHA
         45AjSsvl6BQExTNtsMXqF33JwzTHV7BXRsOXOtgEIvvBJYsgJ84YVgWnbb1Jwpy9L8mb
         DLt5844kNnG8afTJsDR9tYDMse5kdwxX/59aEboJJlWaJxb3LxqHudJIR75Sbcn9XJZC
         IAnorcOkJgO/YpWtNap9DVkxISJw/7aV4j9ldh+PTjacrAZBTJwzRs2vm4Cz6q42eVoC
         suUjW08GvUCBLIoqKJLCT57BTRh3E1q7i+RPym0BWMZ/VRr8+hDZ4E1A0SoqWj9OGVH9
         fCKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=Adm5dVNWcMYcdiiS7a3fE7y+ekKdIWA1qkWUn5RDuFA=;
        b=pKENWPay7g3IMm+oRrn9hp8Gyes3SvyUCICxyzspvQ1oDqAxj3CC4heK9FULXH9r3Y
         Qq+VZxfRp2qbKPsW5RhenSWGmSnAkMWYAEgevmtcc7aG8OsTkYAZRzPECwEAddvd/ebM
         GhhtJ89JiQafNQrf68+8EZLe3NIdbOZ5Tc+T0GORMpJvaCwGkE7iJ3+vhXrC6GzlvsCO
         3XsoRXcBRNnlp4TJ1aN6txJsMz9QyY1TJsLEuoVUNRkvgd0UFtXFwizngsCFXijaPKN5
         OBbYgtNnpSCuive1baGZsPJhU2RPzOAr+k0jmToGot4UiwT4f9dO/01kcFnbZA92jL5/
         wdAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o37si634761qte.143.2019.05.14.00.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 00:15:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC599859FC;
	Tue, 14 May 2019 07:15:39 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BC7D918EE4;
	Tue, 14 May 2019 07:15:39 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id A35EC18089C8;
	Tue, 14 May 2019 07:15:39 +0000 (UTC)
Date: Tue, 14 May 2019 03:15:39 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Will Deacon <will.deacon@arm.com>, 
	peterz@infradead.org, minchan@kernel.org, mgorman@suse.de, 
	stable@vger.kernel.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
Message-ID: <914836977.22577826.1557818139522.JavaMail.zimbra@redhat.com>
In-Reply-To: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
References: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.43.17.163, 10.4.195.30]
Thread-Topic: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Index: AQHVCfj1/ZS8SZ4p0ke1CH5gp1S1IPlIMumf
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 14 May 2019 07:15:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


----- Original Message -----
> 
> 
> On May 13, 2019 4:01 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
> 
> 
> On 5/13/19 9:38 AM, Will Deacon wrote:
> > On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> >> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> >> index 99740e1..469492d 100644
> >> --- a/mm/mmu_gather.c
> >> +++ b/mm/mmu_gather.c
> >> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >>   {
> >>       /*
> >>        * If there are parallel threads are doing PTE changes on same range
> >> -     * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> >> -     * flush by batching, a thread has stable TLB entry can fail to flush
> >> -     * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> >> -     * forcefully if we detect parallel PTE batching threads.
> >> +     * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> >> +     * flush by batching, one thread may end up seeing inconsistent PTEs
> >> +     * and result in having stale TLB entries.  So flush TLB forcefully
> >> +     * if we detect parallel PTE batching threads.
> >> +     *
> >> +     * However, some syscalls, e.g. munmap(), may free page tables, this
> >> +     * needs force flush everything in the given range. Otherwise this
> >> +     * may result in having stale TLB entries for some architectures,
> >> +     * e.g. aarch64, that could specify flush what level TLB.
> >>        */
> >> -    if (mm_tlb_flush_nested(tlb->mm)) {
> >> -            __tlb_reset_range(tlb);
> >> -            __tlb_adjust_range(tlb, start, end - start);
> >> +    if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
> >> +            /*
> >> +             * Since we can't tell what we actually should have
> >> +             * flushed, flush everything in the given range.
> >> +             */
> >> +            tlb->freed_tables = 1;
> >> +            tlb->cleared_ptes = 1;
> >> +            tlb->cleared_pmds = 1;
> >> +            tlb->cleared_puds = 1;
> >> +            tlb->cleared_p4ds = 1;
> >> +
> >> +            /*
> >> +             * Some architectures, e.g. ARM, that have range invalidation
> >> +             * and care about VM_EXEC for I-Cache invalidation, need
> >> force
> >> +             * vma_exec set.
> >> +             */
> >> +            tlb->vma_exec = 1;
> >> +
> >> +            /* Force vma_huge clear to guarantee safer flush */
> >> +            tlb->vma_huge = 0;
> >> +
> >> +            tlb->start = start;
> >> +            tlb->end = end;
> >>       }
> > Whilst I think this is correct, it would be interesting to see whether
> > or not it's actually faster than just nuking the whole mm, as I mentioned
> > before.
> >
> > At least in terms of getting a short-term fix, I'd prefer the diff below
> > if it's not measurably worse.
> 
> I did a quick test with ebizzy (96 threads with 5 iterations) on my x86
> VM, it shows slightly slowdown on records/s but much more sys time spent
> with fullmm flush, the below is the data.
> 
>                                      nofullmm                 fullmm
> ops (records/s)              225606                  225119
> sys (s)                            0.69                        1.14
> 
> It looks the slight reduction of records/s is caused by the increase of
> sys time.
> 
> >
> > Will
> >
> > --->8
> >
> > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > index 99740e1dd273..cc251422d307 100644
> > --- a/mm/mmu_gather.c
> > +++ b/mm/mmu_gather.c
> > @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >         * forcefully if we detect parallel PTE batching threads.
> >         */
> >        if (mm_tlb_flush_nested(tlb->mm)) {
> > +             tlb->fullmm = 1;
> >                __tlb_reset_range(tlb);
> > -             __tlb_adjust_range(tlb, start, end - start);
> > +             tlb->freed_tables = 1;
> >        }
> >
> >        tlb_flush_mmu(tlb);
> 
> 
> I think that this should have set need_flush_all and not fullmm.
> 

Wouldn't that skip the flush?

If fulmm == 0, then __tlb_reset_range() sets tlb->end = 0.
  tlb_flush_mmu
    tlb_flush_mmu_tlbonly
      if (!tlb->end)
         return

Replacing fullmm with need_flush_all, brings the problem back / reproducer hangs.

