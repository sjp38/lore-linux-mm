Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55164C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5160207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nM0+XCot"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5160207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33D1A6B0269; Tue,  2 Apr 2019 19:06:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EC7E6B026D; Tue,  2 Apr 2019 19:06:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B60B6B0272; Tue,  2 Apr 2019 19:06:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA8D66B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:28 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c67so13078487qkg.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=l8c5endvJscPewd22ZTuMis3Zjlpf6zi6ZDP1+P2ofI=;
        b=ujJ7aiCIS9UiGNmEd1upfM/hqam9ka6IyBFnsAa0VYKc4LVJs1+V/QZIwtvSVkBeJP
         z9cjX2azrvfzSQEP/Bu9RVvbA/MFEtvP+t5IebXFyciq0taYavsTbo/kQEq6hyujqAAS
         HKsuQ5ekio3PvZc1fGzymCRqKJTedENj1ogFWre8TYbRs9IMC0AkrdcSLoIOQ9J5Wpct
         QrZrzbXRgLhQW66Q1PFoLzl/1355xNIWzqosyyteP9XgXhVmgiG8mBu/afX5SXOvKTnG
         BUw76XzL3wiiLSrkEyZjOfi3c8te/uvffRfOrp23aoAmmta+UJsH+PMiE4Yvv21v3/cw
         PU9Q==
X-Gm-Message-State: APjAAAWFS0ybEif5TIjE4l91A7+fnHaDmif3BDv+cgYLI67emDk0hJWe
	drMVORsbS9+zLPnpnzP55GpDqzhc+U9/j1NT70Q90nKvJ1XXo3l0ZzaFR42oLF5g0RPMmZg+Ym2
	HqpdRGZbgGtjrHjZZJTlZJPjIflZrgkUSHgI8m+X75QWXZ5T51Us95on9PfsGJBs=
X-Received: by 2002:a0c:f68a:: with SMTP id p10mr58020529qvn.126.1554246388623;
        Tue, 02 Apr 2019 16:06:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzawSEaJti6g5pIuOSxKfIvFXFvaLT/KLWoOA5o1N/qV908oEAuVvG+rgJcHNM3nplcPEYN
X-Received: by 2002:a0c:f68a:: with SMTP id p10mr58020462qvn.126.1554246387742;
        Tue, 02 Apr 2019 16:06:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246387; cv=none;
        d=google.com; s=arc-20160816;
        b=QZsD8/tCoi480jE/gyxcdZsL3FcH8C0t/hav/s1X8mXpAaT/7XTId8iWxmlNM+1lsF
         nk/kw2k/+i/EO6GG5/km6ah/IP27J2HU/Wt0DFfF5JRViaYyie5zjaZvjPr+5S7/wUMC
         EcREd/xquqRjrHpTCQelFTm6jpDCxpFN6oU1F+twu3Fbq9+QDZhxpIpfk0efCJY30BCm
         mzE4H550ovAZTvZS/1Xz6+z4ZDtx/97+A1H/bdkfxN7Xyaxpr7O4z410aXgISOvSA50J
         2rOI4Tp8yIODT3gwNKChleF8lx0vuRcqJJcW5WIijA3NdLzpKm+PSGbZ0jvslmL+51Eo
         eYSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=l8c5endvJscPewd22ZTuMis3Zjlpf6zi6ZDP1+P2ofI=;
        b=D+4FgDSunJrBs6ewC7fz37JkSxKx7Yir1Qr+7IVXmiea3lK9oY8KH/ISx69MbrVAyi
         ePsAwUIW/SCqOzhk2XRzOSslvyC8foVnRgK79mU0DjPba9LcyknOgwX39pFo6QfolSpf
         71BL1cYFlXBQeEM5/TmYIY5HjFUsxGJWe/6BX+ApwFtEGj3jE3HfOeZ7Z+Dy/v6rWDqD
         21dfcy4N18io+p54DAIsZqHszNRq4cTWD2bUrEBCVpo9+TaL3BY3wU50Oit2rUsEZFcA
         AXfnbAqePSCXnq+wMPsldVbezT2wnt8pKqrj191DZpexuQ+heUVWSAowBMzsYw8z+Ppg
         gLYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nM0+XCot;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id u56si2473828qtb.161.2019.04.02.16.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=nM0+XCot;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5D9D721F01;
	Tue,  2 Apr 2019 19:06:27 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=l8c5endvJscPewd22
	ZTuMis3Zjlpf6zi6ZDP1+P2ofI=; b=nM0+XCotwYgyyp+aIrzkVuUlO3vBiZiMl
	NhDd+NNkIrwuxQatdvngcz0uoq4WFUzaYghV7U04+LyAKqRSrfj3SYCu/619irQ1
	otkqhxHfvErJHKMpH7bersJh6JXmdWljB1PUnhFrJzoC477+DrS9hGVPnHKq+5zK
	tIxUPns+amcbKkfeyKAmth9d5II/lsXmvKCn/8jCsEjydZUzWp5W5DMClKRIFDec
	NKNVxCmX+4Qu92a/iQ68wty/d7tkXBm4T/Krpqoia3AUGbWZFlahm/dC7rCnNejJ
	ToVjT24JgmdKtvlVHYjFxDFVx0qmZFRfX1LlzuEKP+dl28tNy7Hkg==
X-ME-Sender: <xms:8OqjXAgBJr2e1HK8XbZF6S4hNaT-P7KhnhmaSBY9F893eWAk7PpyWA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgggfestdekredtredttdenucfh
    rhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvg
    hlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiii
    gvpedt
X-ME-Proxy: <xmx:8OqjXF51mRj2Nx7U703Tn1p2rc9G2UEeKN7pYize8-njg2wMLCjMVw>
    <xmx:8OqjXH0i_hxkJlbj3JvQJhZ6aY4yKWwbHPK3o1YpEMKrqN0aGWQ35Q>
    <xmx:8OqjXAst7V3hoW50X66Wz3Jpv-2OBnipWKJK79EiUE5jwB0X708RVw>
    <xmx:8-qjXMAeBWoYpAJc-79Roxk8qpcb9vGVV4PeI8mOLUyAFPIzQQT-Tg>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9A2171030F;
	Tue,  2 Apr 2019 19:06:21 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 0/7] mm: Use slab_list list_head instead of lru
Date: Wed,  3 Apr 2019 10:05:38 +1100
Message-Id: <20190402230545.2929-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Here is the updated series that caused the bug found by 0day test
robot.  To ease the load on your memory, this series is aimed at
replacing the following:

Original buggy series:

 mm-remove-stale-comment-from-page-struct.patch
 slub-use-slab_list-instead-of-lru.patch
 slab-use-slab_list-instead-of-lru.patch
 slob-use-slab_list-instead-of-lru.patch
 slub-add-comments-to-endif-pre-processor-macros.patch
 slob-respect-list_head-abstraction-layer.patch
 list-add-function-list_rotate_to_front.patch

And the bug fix patch:

 slob-only-use-list-functions-when-safe-to-do-so.patch

Applies cleanly on top of Linus' tree (tag: v5.1-rc3).

This series differs from the bug fix above by adding a separate return
parameter to slob_page_alloc() instead of using a double pointer.  This
is defensive in case later someone adds code that accesses sp (struct
page *), also it is easier to read/verify the code since its less 'tricky'.

Tested by building and booting a kernel using the SLOB allocator and
with CONFIG_DEBUG_LIST.

From v4 ... 

Currently the slab allocators (ab)use the struct page 'lru' list_head.
We have a list head for slab allocators to use, 'slab_list'.

During v2 it was noted by Christoph that the SLOB allocator was reaching
into a list_head, this version adds 2 patches to the front of the set to
fix that.

Clean up all three allocators by using the 'slab_list' list_head instead
of overloading the 'lru' list_head.

Changes since v4:
 - Add return parameter to slob_page_alloc() to indicate whether the
   page is removed from the freelist during allocation.
 - Only do list rotate optimisation if the page was _not_ removed from
   the freelist (fix bug found by 0day test robot).

Changes since v3:

 - Change all ->lru to ->slab_list in slob (thanks Roman).

Changes since v2:

 - Add list_rotate_to_front().
 - Fix slob to use list_head API.
 - Re-order patches to put the list.h changes up front.
 - Add acks from Christoph.

Changes since v1:

 - Verify object files are the same before and after the patch set is
   applied (suggested by Matthew).
 - Add extra explanation to the commit logs explaining why these changes
   are safe to make (suggested by Roman).
 - Remove stale comment (thanks Willy).


thanks,
Tobin.


Tobin C. Harding (7):
  list: Add function list_rotate_to_front()
  slob: Respect list_head abstraction layer
  slob: Use slab_list instead of lru
  slub: Add comments to endif pre-processor macros
  slub: Use slab_list instead of lru
  slab: Use slab_list instead of lru
  mm: Remove stale comment from page struct

 include/linux/list.h     | 18 ++++++++++++
 include/linux/mm_types.h |  2 +-
 mm/slab.c                | 49 ++++++++++++++++----------------
 mm/slob.c                | 59 +++++++++++++++++++++++++++------------
 mm/slub.c                | 60 ++++++++++++++++++++--------------------
 5 files changed, 115 insertions(+), 73 deletions(-)

-- 
2.21.0

