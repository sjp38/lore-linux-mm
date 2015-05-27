Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BA4E16B0120
	for <linux-mm@kvack.org>; Wed, 27 May 2015 01:09:33 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so68010993pdb.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 22:09:33 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id sw10si24208510pab.71.2015.05.26.22.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 26 May 2015 22:09:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 27 May 2015 10:39:29 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 283E6125804F
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:41:46 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4R59Onw61210820
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:39:25 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4R59NV8007017
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:39:24 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/36] mmu_notifier: keep track of active invalidation ranges v3
In-Reply-To: <1432236705-4209-3-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-3-git-send-email-j.glisse@gmail.com>
Date: Wed, 27 May 2015 10:39:23 +0530
Message-ID: <871ti2mwsc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

j.glisse@gmail.com writes:

> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> The mmu_notifier_invalidate_range_start() and mmu_notifier_invalidate_ran=
ge_end()
> can be considered as forming an "atomic" section for the cpu page table u=
pdate
> point of view. Between this two function the cpu page table content is un=
reliable
> for the address range being invalidated.
>
> Current user such as kvm need to know when they can trust the content of =
the cpu
> page table. This becomes even more important to new users of the mmu_noti=
fier
> api (such as HMM or ODP).

I don't see kvm using the new APIs in this patch. Also what is that HMM use=
 this
for, to protect walking of mirror page table ?. I am sure you are
covering that in the later patches. May be you may want to mention
the details here too.=20

>
> This patch use a structure define at all call site to invalidate_range_st=
art()
> that is added to a list for the duration of the invalidation. It adds two=
 new
> helpers to allow querying if a range is being invalidated or to wait for =
a range
> to become valid.
>
> For proper synchronization, user must block new range invalidation from i=
nside
> there invalidate_range_start() callback, before calling the helper functi=
ons.
> Otherwise there is no garanty that a new range invalidation will not be a=
dded
> after the call to the helper function to query for existing range.
>
> Changed since v1:
>   - Fix a possible deadlock in mmu_notifier_range_wait_valid()
>
> Changed since v2:
>   - Add the range to invalid range list before calling ->range_start().
>   - Del the range from invalid range list after calling ->range_end().
>   - Remove useless list initialization.
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
