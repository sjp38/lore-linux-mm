Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DFBAC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C21622084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:22:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="IIfhAZBQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C21622084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D19E6B026D; Wed,  3 Apr 2019 00:22:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57FE06B026F; Wed,  3 Apr 2019 00:22:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4704F6B0272; Wed,  3 Apr 2019 00:22:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 271036B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:22:48 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g48so15646788qtk.19
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:22:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5hYI8b2F/hMNndGsuIPxlYyfuOY04PDt4MqicmCvTbs=;
        b=NUyODvlZMXhjzK8Yo71Q4u9A78XOHDCsr8YgqAP7nIRmN45kxQJ+GePyhMAv/+n+RD
         engRnCv00OgJsYpXWxouppWr1DInV1H0XqNyfbchB4ysfvuyQfBCO3SyOhlRpi5r67X4
         AkiQy0dhsOgZ3JMsQ1ewUACPUQk2P2U6warCrPxQbq0dIBcxt6NabUI+sSBzDW8jbSO+
         R4xi6xA8GWeQog6BbXa9R44ZI7b7WWpMP82ELG0Jvx16utcZSSRFpewSoZGnCiaciS0l
         31XZw8KkyKmOmhAFaaOL733UQEjm849K8MU+nVOUm02x67pUdTd0FAowYrrXGxlHqjcN
         F16Q==
X-Gm-Message-State: APjAAAWvE1mWm0lstmAQuqQ8r5SHNxJKjnijdYyiTKNTY9Emd8iIEfG6
	+xhY0JD4kBXsqCqI+ZLSYflqoa3W2BuZzsKmts0GHcEtQc9Gp26l1od9/+EfVW7hzz4PeHS1WWM
	Kf4lu495GWrKjLNdiAGqZQwkW/eQ1RDUBYXardGQCzpHdfFaOvs2+aM5FIF+VVko=
X-Received: by 2002:ac8:3126:: with SMTP id g35mr37939498qtb.244.1554265367851;
        Tue, 02 Apr 2019 21:22:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpNpS3TuMIfjKvjnFlyzo6DcDkrgEgQ60b0A1JVQmz47QBs7bt0NdZsdBTuZc0rlJFIhVO
X-Received: by 2002:ac8:3126:: with SMTP id g35mr37939459qtb.244.1554265366869;
        Tue, 02 Apr 2019 21:22:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265366; cv=none;
        d=google.com; s=arc-20160816;
        b=TO7H62cmLvph6vFB4RRdlLw0I8yC7SycC6o3QAXXlYZ5fSgAI7wRdf5TWHi+ad/CoQ
         Bo5kJxsaBHAubTh+zMosVjdkJrsB+VGeKXWzba2/hEy/tzC7GvyYiMiSHR4U88eZ19GJ
         6GrKZQrEef9NcwvIPww4T+aEnt6aJuT5b3XXEQP8RXU5yTSeN+K52Aa1dwkNZDG1jGjg
         XZB2nYyYdHjJ13xHsJKui/cv2qOZO8eNl/qDwqzp8PykCEId5T52J7TDUapeOqBSYzZr
         tcW4zJhmyivvGCq3MMtYl5LQ8ksTx2IRfUdjX9XTkksRlRUjpDT6VJhhtD4UBCUixIJa
         P2lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5hYI8b2F/hMNndGsuIPxlYyfuOY04PDt4MqicmCvTbs=;
        b=zew0jkT1GHFYHavT9VSwImdJii8gRNVnSzVrCkZtYruplLmLQBvwg3LKh0ThXxKuvA
         VE4hRaXYianYqphtiFfFxJ12iaEB3vb2c2tWa4t+ELok8l4AF0fQO6xtQqRwa4WxRJiN
         YLvMUT4uxitCfETtlKL28pI5vtTHOu9HJLJfL6XeF84QWv4iR4XKbDPoHuaYJFjiGnIq
         b/kAE+ON5rrHUyKXuzuPhHHwg4IXKO9SnBVH/vqUf+wy5NDV0SbjLTu6Ze0q9BhSl3Fr
         J79fPQStlp+LiAoirOPrc/qSHK/R6amKuTHehkhqGptBS2DhEBMbbBCk51FMiBTW15Gh
         muPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IIfhAZBQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id c14si3267447qkl.125.2019.04.02.21.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:22:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IIfhAZBQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7E95921B10;
	Wed,  3 Apr 2019 00:22:46 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:22:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=5hYI8b2F/hMNndGsu
	IPxlYyfuOY04PDt4MqicmCvTbs=; b=IIfhAZBQeDc9DxpDfTu9PVqYMIbSDcGCG
	s7kMZuvPb4QScrIRMGAZmQQfmTqKzlZwWsMJT8PCuWMbz5OLpltDzKuIL/uITi1D
	sIrtot4H/D9S7S7CTK7vhxzTC1sDaNyN3HHUvFMAGRxTs444UZ/4FT2ZGBQiqBP3
	R00cauuLdcrcQVsRmkdJ5wL5/csX8fcAXYIgnfaIvksmD6xgnuLLDoruRHzq5nTh
	SPYyZsmu1+w/++V6E+vPnbY21OHB+YfEqq6fNWctuEdV6pW0CPCz064t3rk8k1pQ
	mzD+k/g7vymzsG1yEUlfL+coFhH+fsUSu/iX7DBlEz8eG/rg5dAOQ==
X-ME-Sender: <xms:EzWkXHSCUlBPTPtVdDwRBd3KwFa7FEZJ_IHTvUr-VzyKNh2DhD6hWQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgggfestdekredtredttdenucfh
    rhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvg
    hlrdhorhhgqeenucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecukfhppeduvdegrddu
    ieelrddvjedrvddtkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrh
    hnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:EzWkXOxi2Qc38QyiSAgHn9gpRjM1tXvMeXkuNYJliTY6jY7f56zD8A>
    <xmx:EzWkXKccSLSc1A1dUeF5En6prLVAELe_QH1tBajG7bv2QO3l94JhAA>
    <xmx:EzWkXCKGQPCJ4kYhRSsiC-SVE-W0BNTkklzhVb71kVfNqSX25xKbcQ>
    <xmx:FjWkXKrafd-T_cD3OOZ00l8I4DTXFp_qjozQ9Pv2dUMNbdSOow6NKw>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id E728710319;
	Wed,  3 Apr 2019 00:22:36 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 00/14] Slab Movable Objects (SMO)
Date: Wed,  3 Apr 2019 15:21:13 +1100
Message-Id: <20190403042127.18755-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Version 2 re-structured to better follow the structure of Chirstoph's
original patchset (linked below).  Functions renamed and other suggestions
on v1 from Roman implemented.

This version also adds an attempt at implementing object migration for
the dcache, appropriate filesystem folk CC'd.  Please see comments
below in 'dcache' section.

Applies on top of Linus' tree (tag: v5.1-rc3).

This is a patch set implementing movable objects within the SLUB
allocator.  This is work based on Christopher's patch set:

 https://lore.kernel.org/patchwork/project/lkml/list/?series=377335

The original code logic is from that set and implemented by Christopher.
Clean up, refactoring, documentation, and additional features by myself.
Blame for any bugs remaining falls solely with myself.  Patches using
Christopher's code use the Co-developed-by tag but do not currently have
his SOB tag.

The core of the implementation is now contained within the first 4
patches (primarily patch #4).

Patches 7,8,10 add test code including a test modules to play around
with this.  With the series applied one can see functionality in
action by using the slabinfo command on the xarray slab cache

	slabinfo radix_tree_node -r

The NUMA stuff works as claimed with the radix_tree_node slab cache.

dcache
------

The dcache patches are my best effort on top of Christoph's original
work.  The dcache has changed a lot since then (2009).  FTR one month
ago was the first time I have ever opened fs/dcache.c.

I have been playing with this for at least two weeks without any
functional changes to the dcache patches - I do not think me playing
with it more is going to improve my understanding of the dcache so I am
asking for help here.  I've been testing in Qemu (both using ramdisk
filesystem and a disk image filesystem) as well as on bare metal.

Shrinking the dcache with:

	slabinfo dentry -s

produces _more_ partial slabs than before and repeated calls continue to
increase the number of partial slabs.  Although the initial calls do
decrease the total number of cached objects.  I cannot explain this.

During development I added a bunch of printks and the majority of dentry
slab objects are skipped during the isolation function due to the
following check from d_isolate():
	
	if (dentry->d_inode &&
	    !mapping_cap_writeback_dirty(dentry->d_inode->i_mapping))
	    ...
	    /* skip object*/
		     
I cannot explain the large number of dentry objects skipped by this
clause.

Any suggestions no matter how wild very much appreciated.  Tips on files
I should study or anything else I could do to better understand what is
needed to understand to work with this.  So far I have been primarily
trying to grok the VFS and the dcache in particular via:

fs/dcache.c
include/linux/fs.h
include/linux/dcache.h
Documentation/filesystems/vfs.txt

I also tried using the cache shrinkers

	echo 2 > /proc/sys/vm/drop_caches

Then shrinking the dentry slab cache.  This resulted in a bunch of
things disappearing e.g. sysfs gets unmounted, /home directory contents
disappear.  Again, I cannot explain this.  Should this be doable if this
series was implemented correctly?

Thanks for taking the time to look at this.

	Tobin.


Tobin C. Harding (14):
  slub: Add isolate() and migrate() methods
  tools/vm/slabinfo: Add support for -C and -M options
  slub: Sort slab cache list
  slub: Slab defrag core
  tools/vm/slabinfo: Add remote node defrag ratio output
  tools/vm/slabinfo: Add defrag_used_ratio output
  tools/testing/slab: Add object migration test module
  tools/testing/slab: Add object migration test suite
  xarray: Implement migration function for objects
  tools/testing/slab: Add XArray movable objects tests
  slub: Enable moving objects to/from specific nodes
  slub: Enable balancing slabs across nodes
  dcache: Provide a dentry constructor
  dcache: Implement object migration

 Documentation/ABI/testing/sysfs-kernel-slab |  14 +
 fs/dcache.c                                 | 124 ++-
 include/linux/slab.h                        |  71 ++
 include/linux/slub_def.h                    |  10 +
 lib/radix-tree.c                            |  13 +
 lib/xarray.c                                |  46 ++
 mm/Kconfig                                  |   7 +
 mm/slab_common.c                            |   2 +-
 mm/slub.c                                   | 819 ++++++++++++++++++--
 tools/testing/slab/Makefile                 |  10 +
 tools/testing/slab/slub_defrag.c            | 567 ++++++++++++++
 tools/testing/slab/slub_defrag.py           | 451 +++++++++++
 tools/testing/slab/slub_defrag_xarray.c     | 211 +++++
 tools/vm/slabinfo.c                         |  51 +-
 14 files changed, 2303 insertions(+), 93 deletions(-)
 create mode 100644 tools/testing/slab/Makefile
 create mode 100644 tools/testing/slab/slub_defrag.c
 create mode 100755 tools/testing/slab/slub_defrag.py
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

-- 
2.21.0

