Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id D7A2A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:37:40 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so18923937qkd.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:37:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b69si5461459qgb.50.2015.08.13.12.37.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:37:40 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 00/15] HMM anonymous memory migration.
Date: Thu, 13 Aug 2015 15:37:16 -0400
Message-Id: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

Minor fixes since last post (1), apply on top of rc6 done
that because conflict in infiniband are harder to solve then
conflict with mm tree.

Tree with the patchset:
git://people.freedesktop.org/~glisse/linux hmm-v10 branch

This part of the patchset implement anonymous memory migration.
It allows to migrate anonymous memory seamlessly to device
memory and to have migration back to system memory if CPU try
to access migrated memory.

For the rational behind HMM please refer to core HMM patchset

https://lkml.org/lkml/2015/8/13/623

Cheers,
JA(C)rA'me

To: "Andrew Morton" <akpm@linux-foundation.org>,
To: <linux-kernel@vger.kernel.org>,
To: linux-mm <linux-mm@kvack.org>,
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
Cc: "Mel Gorman" <mgorman@suse.de>,
Cc: "H. Peter Anvin" <hpa@zytor.com>,
Cc: "Peter Zijlstra" <peterz@infradead.org>,
Cc: "Linda Wang" <lwang@redhat.com>,
Cc: "Kevin E Martin" <kem@redhat.com>,
Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
Cc: "Johannes Weiner" <jweiner@redhat.com>,
Cc: "Larry Woodman" <lwoodman@redhat.com>,
Cc: "Rik van Riel" <riel@redhat.com>,
Cc: "Dave Airlie" <airlied@redhat.com>,
Cc: "Jeff Law" <law@redhat.com>,
Cc: "Brendan Conoboy" <blc@redhat.com>,
Cc: "Joe Donohue" <jdonohue@redhat.com>,
Cc: "Christophe Harle" <charle@nvidia.com>,
Cc: "Duncan Poole" <dpoole@nvidia.com>,
Cc: "Sherry Cheung" <SCheung@nvidia.com>,
Cc: "Subhash Gutti" <sgutti@nvidia.com>,
Cc: "John Hubbard" <jhubbard@nvidia.com>,
Cc: "Mark Hairgrove" <mhairgrove@nvidia.com>,
Cc: "Lucien Dunning" <ldunning@nvidia.com>,
Cc: "Cameron Buschardt" <cabuschardt@nvidia.com>,
Cc: "Arvind Gopalakrishnan" <arvindg@nvidia.com>,
Cc: "Haggai Eran" <haggaie@mellanox.com>,
Cc: "Or Gerlitz" <ogerlitz@mellanox.com>,
Cc: "Sagi Grimberg" <sagig@mellanox.com>
Cc: "Shachar Raindel" <raindel@mellanox.com>,
Cc: "Liran Liss" <liranl@mellanox.com>,
Cc: "Roland Dreier" <roland@purestorage.com>,
Cc: "Sander, Ben" <ben.sander@amd.com>,
Cc: "Stoner, Greg" <Greg.Stoner@amd.com>,
Cc: "Bridgman, John" <John.Bridgman@amd.com>,
Cc: "Mantor, Michael" <Michael.Mantor@amd.com>,
Cc: "Blinzer, Paul" <Paul.Blinzer@amd.com>,
Cc: "Morichetti, Laurent" <Laurent.Morichetti@amd.com>,
Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
Cc: "Leonid Shamis" <Leonid.Shamis@amd.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
