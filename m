Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 206B76B007B
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 23:10:37 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id j5so4452068qga.29
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 20:10:36 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0208.outbound.protection.outlook.com. [207.46.163.208])
        by mx.google.com with ESMTPS id u3si14175195qge.31.2014.07.24.20.10.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 Jul 2014 20:10:36 -0700 (PDT)
From: "Sander, Ben" <ben.sander@amd.com>
Subject: Re: [PATCH 0/3] mmu_notifier: Allow to manage CPU external TLBs
Date: Fri, 25 Jul 2014 03:10:28 +0000
Message-ID: <D7B2CBFE-6D70-4999-AC45-48773872FA08@amd.com>
References: <1406212541-25975-1-git-send-email-joro@8bytes.org>,<20140724163303.df34065a3c3b26c0a4b3bab1@linux-foundation.org>
In-Reply-To: <20140724163303.df34065a3c3b26c0a4b3bab1@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, "jroedel@suse.de" <jroedel@suse.de>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Suthikulpanit, Suravee" <Suravee.Suthikulpanit@amd.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

Yes. AMD has tested this with the iommuv2 driver and verified it works corr=
ectly.  There is a corresponding change in the iommuv2 driver to use the ne=
w API.=20

> On Jul 24, 2014, at 6:33 PM, "Andrew Morton" <akpm@linux-foundation.org> =
wrote:
>=20
>> On Thu, 24 Jul 2014 16:35:38 +0200 Joerg Roedel <joro@8bytes.org> wrote:
>>=20
>> here is a patch-set to extend the mmu_notifiers in the Linux
>> kernel to allow managing CPU external TLBs. Those TLBs may
>> be implemented in IOMMUs or any other external device, e.g.
>> ATS/PRI capable PCI devices.
>>=20
>> The problem with managing these TLBs are the semantics of
>> the invalidate_range_start/end call-backs currently
>> available. Currently the subsystem using mmu_notifiers has
>> to guarantee that no new TLB entries are established between
>> invalidate_range_start/end. Furthermore the
>> invalidate_range_start() function is called when all pages
>> are still mapped and invalidate_range_end() when the pages
>> are unmapped an already freed.
>>=20
>> So both call-backs can't be used to safely flush any non-CPU
>> TLB because _start() is called too early and _end() too
>> late.
>>=20
>> In the AMD IOMMUv2 driver this is currently implemented by
>> assigning an empty page-table to the external device between
>> _start() and _end(). But as tests have shown this doesn't
>> work as external devices don't re-fault infinitly but enter
>> a failure state after some time.
>>=20
>> Next problem with this solution is that it causes an
>> interrupt storm for IO page faults to be handled when an
>> empty page-table is assigned.
>>=20
>> To solve this situation I wrote a patch-set to introduce a
>> new notifier call-back: mmu_notifer_invalidate_range(). This
>> notifier lifts the strict requirements that no new
>> references are taken in the range between _start() and
>> _end(). When the subsystem can't guarantee that any new
>> references are taken is has to provide the
>> invalidate_range() call-back to clear any new references in
>> there.
>>=20
>> It is called between invalidate_range_start() and _end()
>> every time the VMM has to wipe out any references to a
>> couple of pages. This are usually the places where the CPU
>> TLBs are flushed too and where its important that this
>> happens before invalidate_range_end() is called.
>>=20
>> Any comments and review appreciated!
>=20
> It looks pretty simple and harmless.
>=20
> I assume the AMD IOMMUv2 driver actually uses this and it's all
> tested and good?  What is the status of that driver?
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
