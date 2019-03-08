Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9C2C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 194FF20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8Hr/M5Gi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 194FF20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2E58E0003; Thu,  7 Mar 2019 23:15:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B2A8E0002; Thu,  7 Mar 2019 23:15:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 624CD8E0003; Thu,  7 Mar 2019 23:15:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35AAC8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:03 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f70so14945786qke.8
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=7/t3e0/zYUawBXj9+EopDjHPelY75KptaGn3t9VpyZA=;
        b=SPw3ODBEmxO5KY55jZGU4YA/CgKyPf7FgJaiPGbkQAIyxpav3cJ8aPtYMagav4gn8D
         wltH8si751hTSCXZR+zcja/3XFnPJT8aweqCoUWd7K9jEczuDG1dPZCRjsarwx4Oz5BV
         kdIhjPiU872DCtkg75pxB+nrryRcaPJGfR0eapT4r6YA4lY/SpIJdb/AFqxClHoyKUny
         DMK9yn+MrsVTe22eVHWPE7gP4rTJZLb2OVyolunsEDRFy8F8JCM9DqGdf2zvz/78L2BA
         iEwIaoa504lxeGuuFHatSNYs6KfUvRzlIUzJzunLrBWQF0vnPdpZj55hBwMBTsqEOXeo
         IWng==
X-Gm-Message-State: APjAAAU7++cjirDlAYgAb1vWlm4/d6Y3/Y1UVl08EdEWvfGbii4mFixD
	U+qYfKqkR1oYCTpKPQbN3i2hgsaep930rGMLhTOc7VteV3M5GLpPDlcmS6n80LQOiMsfhFC6e20
	Z37QIV7kR+ArZgGzmmimB+o5qxle8u7bjAEIxi91ht2YxlDuuxLcd+FRDpchtVOg=
X-Received: by 2002:ac8:1888:: with SMTP id s8mr13409954qtj.338.1552018502772;
        Thu, 07 Mar 2019 20:15:02 -0800 (PST)
X-Google-Smtp-Source: APXvYqy0lvbmj9g/GN6/0si2OXZhBL8KDQvdQR2BZm1WWwyMEfjpgc1oat0Sdb/XbiMoxdgFbbdJ
X-Received: by 2002:ac8:1888:: with SMTP id s8mr13409912qtj.338.1552018501731;
        Thu, 07 Mar 2019 20:15:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018501; cv=none;
        d=google.com; s=arc-20160816;
        b=CzXUsnGgUu/VXQdPLL4Yy5M0qvFOlyAAWI1S6YmMn/ZkOEvB0sxbEJqQRMz6URxWG+
         DmAVh1VvGOa8uSVRZinOaFGiwGbP/o8cFZoKH8PQGsirXoF7BQP+pX/x70y9Ojb5lPCm
         xOkrtOVUcCI+j81INeO5By8NzWWvQNRBpiT9ej6I7tQj6oo+Seqft6egKbYgXKXqKx6e
         /+BedawiC1cbjOx5dcTVNTIYRWLtq1ROTEdA2duEV+sn5dt7tz4ADyTGH7ECWg/yenZs
         fKTJ4LPV5Q6NDhF0jV4BuLpb0KieJXPUEl3KW0OLJfCp52/Q0PeVTDU0l+fzqGDRCnQ6
         ZLCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=7/t3e0/zYUawBXj9+EopDjHPelY75KptaGn3t9VpyZA=;
        b=j4vo8NoyZkJnPrHJHU0npx8ra/AEWHllOm3MY/4BNH6DN06hlX1T/Koz4ocEiHoypm
         J9jEgX2/IAVPgQRgnFlayftcY1R+ckthe/6N4P/3uY33XFODztd8/5fpwDLtC9X6+a2F
         0KqiPDQ6Ar6eX/s7PadxK6Q3VTXsz/6Bt+v31m5BtsNVx1gSLkBGXVlyIGrC0fFfivHB
         Zi+5NqiurUSUIn7bfElH298qko37WSFNlwMPW3KukzKPvthj+Ay+oJHTW9sZY77n56/S
         /ojnvfqZhlP73njsPf1jq9KEJqbYFMG4xg6S34pVdCsyogKoBXdqxBGlrHRyJ33gcM+1
         GL3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="8Hr/M5Gi";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id p6si79001qkk.40.2019.03.07.20.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="8Hr/M5Gi";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 9AD2B3536;
	Thu,  7 Mar 2019 23:14:59 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:00 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=7/t3e0/zYUawBXj9+
	EopDjHPelY75KptaGn3t9VpyZA=; b=8Hr/M5GiKhCs8Z9et8zGvTL8mXvjusOf7
	Dp6j1RrL1bUco2RuNEB/NFua3JudSPk0xD0QfedqHzriEOEDctWh5KhUjUYdniHW
	5WhgJBx0zrYjSU1pIC8+OxrDHbUaWZkpyKr434YNTuPOK2qclnaDJgSOeWJ5NAlM
	y5A/p6P8+r+DNdVfibcHddrGCfS0fvc2EimwHQO5sW6d94lyzoOXTMeCPqwy9oCJ
	EpvHQoCJlHWiv3afAScPNs7dd1PRBIXUVS2hmiM1pRDTJzg1cDusH8DOMQGwTSDg
	FJ8ISEhSjJLvRizWKSkpUoJ5PxDVS1GVYLSaIBf4Ot3Bk7uDaw/4Q==
X-ME-Sender: <xms:QuyBXGQuoNtWO5tOJ2yhF3l_BWJ8bQN_-Canj2fG1qRVxu6hOopK3g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucffohhmrg
    hinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrdduieelrdehrdduheeknecurfgr
    rhgrmhepmhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhush
    htvghrufhiiigvpedt
X-ME-Proxy: <xmx:QuyBXHpr9t-HH1Y1rb-CUchlp7Bsly2x6SBvVspjn7oGXI5FjcLWGw>
    <xmx:QuyBXA16vnD1HMxtBt5aVORi6Y0f3C608aDFBuJWkhFm5_qFaVKONQ>
    <xmx:QuyBXG4Q76kYUcPW2vVaYIcqRFGZZmlMdUuc13DxsPUZqaMa2tn-hA>
    <xmx:Q-yBXK1cd0Yl75EwTYJ63xF8bo2POczBbcCcs0u6KgSdjZb3r9OAMg>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6CB7EE4383;
	Thu,  7 Mar 2019 23:14:55 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 00/15] mm: Implement Slab Movable Objects (SMO)
Date: Fri,  8 Mar 2019 15:14:11 +1100
Message-Id: <20190308041426.16654-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here is a patch set implementing movable objects within the SLUB
allocator.  This is work based on Christopher's patch set:

 https://lore.kernel.org/patchwork/project/lkml/list/?series=377335

The original code logic is from that set and implemented by Christopher.
Clean up, refactoring, documentation, and additional features by myself.
Blame for any bugs remaining falls solely with myself.  Patches using
Christopher's code use the Co-developed-by tag.

After movable objects are implemented a number of useful features become
possible.  Some of these are implemented in this series, including:

 - Cache defragmentation.	   

    Currently the SLUB allocator is susceptible to internal
    fragmentation.  This occurs when a large number of cached objects
    are allocated and then freed in an arbitrary order.  As the cache
    fragments the number of pages used by the partial slabs list
    increases.  This wastes memory.

    Patch set implements the machinery to facilitate conditional cache
    defragmentation (via kmem_cache_defrag()) and unconditional
    defragmentation (via kmem_cache_shrink()).  Various sysfs knobs are
    provided to interact with and configure this.

    Patch set implements movable objects and cache defragmentation for
    the XArray.

 - Moving objects to and from a specific NUMA node.

 - Balancing objects across all NUMA nodes.

We add a test module to facilitate playing around with movable objects
and a python test suite that uses the module.

Everything except the NUMA stuff was tested on bare metal, the NUMA
stuff was tested with Qemu NUMA emulation.

Possible further work:

1. Implementing movable objects for the inode and dentry caches.

2. Tying into the page migration and page defragmentation logic so that
   so far unmovable pages that are in the way of creating a contiguous
   block of memory will become movable.  This would mean checking for
   slab pages in the migration logic and calling slab to see if it can
   move the page by migrating all objects.


Patch 1-4 - Implement Slab Movable Objects.
Patch 5-9 - Implement slab cache defragmentation.
Patch 10 - Adds the test module.
Patch 11 - Adds the test suite.
Patch 12-13 - Adds object migration to the XArray (and test code).
Patch 14 - Adds moving objects to and from a specified NUMA node.
Patch 15 - Adds object balancing across all NUMA nodes.

Patch 12 introduces an build warning, I tried a bunch of things and I
couldn't work out what it should be.

  linux/lib/xarray.c:1961:16: warning: comparison between pointer and
  zero character constant [-Wpointer-compare] 
    if (!xa || xa == XA_FREE_MARK)
                ^~
  linux/lib/xarray.c:1961:13: note: did you mean to dereference the pointer?
    if (!xa || xa == XA_FREE_MARK)

Perhaps you will put me out of my misery Willy and just tell me what its
supposed to be.

Patch 14 and 15 are particularly early stage (I hacked those :) 

thanks,
Tobin.


Tobin C. Harding (15):
  slub: Create sysfs field /sys/slab/<cache>/ops
  slub: Add isolate() and migrate() methods
  tools/vm/slabinfo: Add support for -C and -F options
  slub: Enable Slab Movable Objects (SMO)
  slub: Sort slab cache list
  tools/vm/slabinfo: Add remote node defrag ratio output
  slub: Add defrag_used_ratio field and sysfs support
  tools/vm/slabinfo: Add defrag_used_ratio output
  slub: Enable slab defragmentation using SMO
  tools/testing/slab: Add object migration test module
  tools/testing/slab: Add object migration test suite
  xarray: Implement migration function for objects
  tools/testing/slab: Add XArray movable objects tests
  slub: Enable move _all_ objects to node
  slub: Enable balancing slab objects across nodes

 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 include/linux/slab.h                        |  70 ++
 include/linux/slub_def.h                    |  10 +
 lib/radix-tree.c                            |  13 +
 lib/xarray.c                                |  44 ++
 mm/Kconfig                                  |   7 +
 mm/slab_common.c                            |   6 +-
 mm/slub.c                                   | 800 ++++++++++++++++++--
 tools/testing/slab/Makefile                 |  10 +
 tools/testing/slab/slub_defrag.c            | 567 ++++++++++++++
 tools/testing/slab/slub_defrag.py           | 451 +++++++++++
 tools/testing/slab/slub_defrag_xarray.c     | 211 ++++++
 tools/vm/slabinfo.c                         |  51 +-
 13 files changed, 2172 insertions(+), 82 deletions(-)
 create mode 100644 tools/testing/slab/Makefile
 create mode 100644 tools/testing/slab/slub_defrag.c
 create mode 100755 tools/testing/slab/slub_defrag.py
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

-- 
2.21.0

