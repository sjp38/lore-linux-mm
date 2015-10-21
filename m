Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 204FF82F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:14:29 -0400 (EDT)
Received: by qgad10 with SMTP id d10so38068508qga.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:14:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si9725797qgd.122.2015.10.21.13.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:14:28 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 00/14] HMM anomymous memory migration to device memory
Date: Wed, 21 Oct 2015 17:10:05 -0400
Message-Id: <1445461819-2675-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

Minor fixes since last post, apply on top of 4.3rc6. Tree with
the patchset:

git://people.freedesktop.org/~glisse/linux hmm-v11 branch

This patchset implement anonymous memory migration for HMM.
See HMM patchset for full description of what is HMM and why
doing HMM :

https://lkml.org/lkml/2015/10/21/739

Seamless migration from system memory to device memory ie on CPU
access we migrate memory back to system memory so CPU can access
it again.

Design is simple, a new special swap type is added and CPU pte are
set to this special swap type for migrated memory. On CPU page fault
HMM use its mirror page table to find proper page into device memory
and migrate it back to system memory.

Migration to device memory involves several steps :
  - First CPU page table is updated to special pte and current
    pte is save to temporary array.
  - We check that all pte are for normal/real pages.
  - We check that no one holds an extra reference on the page.
  - At this point we know we are the only one know about that
    memory and we can safely copy it to device memory.
  - Once everything is copied and fine on device side we free
    the system ram pages.

Migration from device memory back to system memory is simpler:
  - We get exclusive access for each pte we want to migrate back
    (special swap pte value).
  - We allocate system memory (memcg and anon_vma handled here).
  - We copy back device memory content into system memory and
    update device page table to point to system memory.
  - We update CPU page table to point to new system memory.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
