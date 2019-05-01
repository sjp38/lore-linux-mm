Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92E0BC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FF9221743
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:03:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FF9221743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7D036B0006; Wed,  1 May 2019 10:03:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54546B0008; Wed,  1 May 2019 10:03:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B43DE6B000A; Wed,  1 May 2019 10:03:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA626B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:03:02 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j1so8888957pll.13
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:03:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=BrOzmXnIzsSiGUlKZXB4gt7eO43RqcR07QiW9cmu6r4=;
        b=Kfe+RUFaRIWtJkPyEd6McDqgwfaVkZ2RifKxiPaHH5hZ0AiYknYgTVIYSL0fqx+NwC
         lfvT9I3TXas/dqQ8kshEuPbwAH8W/D7hvDdgHBJVBib3BqxvEJ5wCsUnX7sCUK1iTti2
         jAb/Mq7iBQRCg9Pwyetr2AvJVgigU4/1sAM0VOpHLt72dIgQh/Fa/1uoIYL5/J53TipJ
         8xiR1GnFLv3pXI87mBHdsuG6nupB2lj4hJ0npBNGQNT62JLP06eTKzdLJASVpe1xferX
         jKnN+yJ0N8kuwBeUefOvndsAZVXkEzR29TbRQA8a2tFLu5xPaD/D4c+OL0oeIbLIL4cK
         uRng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWEtlZ9MoKILzvkhrR/uGT1WYPqqo8iHn/xVTmaZhJwMpPxzjOB
	DSf+yhzGMkycukS7f3038crepvBN4ljeuN3d3wqdrZs81qnsA4cHLe2Pl4jh48EhVYAUBoWfAtl
	Tp663V05uJ70fmjzWWRfNn4dYJqhQPiOw0avpJPE1gL+4OlebC8SZjaa5s8u4d1o+5w==
X-Received: by 2002:a17:902:28e4:: with SMTP id f91mr32672406plb.321.1556719382115;
        Wed, 01 May 2019 07:03:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynpzJE4Ceu+U7D5uGRjqY6/XpY4YxXkyfQEVYqyhfgBUXR9kYvWJBJcDoM1ENncQ7bQyGV
X-Received: by 2002:a17:902:28e4:: with SMTP id f91mr32672301plb.321.1556719381107;
        Wed, 01 May 2019 07:03:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556719381; cv=none;
        d=google.com; s=arc-20160816;
        b=uJiSkvq4tpiw19Et3TsB9L7QXxMtUIOnPKhcNLqLPbW48sm0Fn/2ks2nWT9dRpgmfU
         qnLIUBFFH/yYfmM8h3wuYudfUjzfbxuRzaLDWChZRpGH45D7bnL+wzJEz03e4vstGuSp
         FHEQe48rgROwXK+mvem0UdtlWvQGabaj1lee43SYT4NFXytzrY0IZsSBL0fgDXGmse7A
         FX/KFfvuI8YiJcYYp+Fz+sX9n+3Wy9nfvMyN45mB8pQHh8EnOjMieqFIs/Fg+Jvl6ocV
         388ZXPWa3FCYs+Yx3edNxpm7P/OQz0g9nQO9QJJz7W7NOdF31bhtvIzxRHYjoNcmnJG8
         lB9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from;
        bh=BrOzmXnIzsSiGUlKZXB4gt7eO43RqcR07QiW9cmu6r4=;
        b=rUIn5Cc4+cmVDJ9dDinSAdMlYw+8WaOHT1T0bU7gYUpEC5k8qAVyR2pRR/Oyy+vlBm
         pXAH9Vz2Z+/mRU6K1x0diSPks+vrjA4K7+KcrI9gfOVbct/UbPzf7CpeHBYjLOb2MgjY
         i8PtlRbF0PD/I19C/QBa7LuKz/S0iSUGOyI997WQA4FAGHllDL5Bevnjgktes17NtxVb
         oiAxY1hQsDmPMWn+Lt1AsBJd5FSKM0U8YbIXjqqmRUTZyWu4HLf4aRicvwCCqvh7PLjL
         iXRlmtFPHixdWIN4HJX5/+9xDd1DuYIsYjIdh4PkmXJuxLb8My+b31N5a9a8100aUg2/
         cjTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q25si38000486pgv.534.2019.05.01.07.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 07:03:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 07:02:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,417,1549958400"; 
   d="scan'208";a="145141383"
Received: from nperf12.hd.intel.com ([10.127.88.161])
  by fmsmga008.fm.intel.com with ESMTP; 01 May 2019 07:02:58 -0700
From: Brian Welty <brian.welty@intel.com>
To: cgroups@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [RFC PATCH 0/5] cgroup support for GPU devices
Date: Wed,  1 May 2019 10:04:33 -0400
Message-Id: <20190501140438.9506-1-brian.welty@intel.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In containerized or virtualized environments, there is desire to have
controls in place for resources that can be consumed by users of a GPU
device.  This RFC patch series proposes a framework for integrating 
use of existing cgroup controllers into device drivers.
The i915 driver is updated in this series as our primary use case to
leverage this framework and to serve as an example for discussion.

The patch series enables device drivers to use cgroups to control the
following resources within a GPU (or other accelerator device):
*  control allocation of device memory (reuse of memcg)
and with future work, we could extend to:
*  track and control share of GPU time (reuse of cpu/cpuacct)
*  apply mask of allowed execution engines (reuse of cpusets)

Instead of introducing a new cgroup subsystem for GPU devices, a new
framework is proposed to allow devices to register with existing cgroup
controllers, which creates per-device cgroup_subsys_state within the
cgroup.  This gives device drivers their own private cgroup controls
(such as memory limits or other parameters) to be applied to device
resources instead of host system resources.
Device drivers (GPU or other) are then able to reuse the existing cgroup
controls, instead of inventing similar ones.

Per-device controls would be exposed in cgroup filesystem as:
    mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
such as (for example):
    mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
    mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
    mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
    mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight

The drm/i915 patch in this series is based on top of other RFC work [1]
for i915 device memory support.

AMD [2] and Intel [3] have proposed related work in this area within the
last few years, listed below as reference.  This new RFC reuses existing
cgroup controllers and takes a different approach than prior work.

Finally, some potential discussion points for this series:
* merge proposed <subsys_name>.devices into a single devices directory?
* allow devices to have multiple registrations for subsets of resources?
* document a 'common charging policy' for device drivers to follow?

[1] https://patchwork.freedesktop.org/series/56683/
[2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
[3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html


Brian Welty (5):
  cgroup: Add cgroup_subsys per-device registration framework
  cgroup: Change kernfs_node for directories to store
    cgroup_subsys_state
  memcg: Add per-device support to memory cgroup subsystem
  drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
  drm/i915: Use memory cgroup for enforcing device memory limit

 drivers/gpu/drm/drm_drv.c                  |  12 +
 drivers/gpu/drm/drm_gem.c                  |   7 +
 drivers/gpu/drm/i915/i915_drv.c            |   2 +-
 drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
 include/drm/drm_device.h                   |   3 +
 include/drm/drm_drv.h                      |   8 +
 include/drm/drm_gem.h                      |  11 +
 include/linux/cgroup-defs.h                |  28 ++
 include/linux/cgroup.h                     |   3 +
 include/linux/memcontrol.h                 |  10 +
 kernel/cgroup/cgroup-v1.c                  |  10 +-
 kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
 mm/memcontrol.c                            | 183 +++++++++++-
 13 files changed, 552 insertions(+), 59 deletions(-)

-- 
2.21.0

