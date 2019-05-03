Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A14FC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 21:14:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E92B2070B
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 21:14:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E92B2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC89F6B0005; Fri,  3 May 2019 17:14:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7A2A6B0006; Fri,  3 May 2019 17:14:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6A946B0007; Fri,  3 May 2019 17:14:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D75B6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 17:14:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a141so3821115pfa.13
        for <linux-mm@kvack.org>; Fri, 03 May 2019 14:14:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oysCqOazn6QLnwWfU7vacoQ60C5CuZGkG2ZSh6WvVD0=;
        b=pp+6KECDI44nJV+BVAXpgxJgkubkh2oxyAeONHRq8Iio53KzgPQkvTKstwJDI6ir/7
         O5EEqQiXuwihmzmlGW2oIOonxjvAdBoKCXBFjo69dLUVEj1ATQ0B/+VgCvwOMF9bbN0d
         shr3+71/XVqArAjdl9SLr3ypNTIGz+ILuHw3asYLsddWQK1KGy3iorYfuOUrAg1QAf4H
         RIcjTMdVNQ1ecrwQ556BnHUmlq7NjG5PE5/MNgthgydT3WLetNTOXXrSfJ5OYIjLiJ5q
         WAb/9biLlAwrhlOrdWQmd5yI0ijUb3pKQv4nJ97iKfm4OSsYvO7TqXCQ1Q21v5bCjvJU
         cNVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVP2HE3J9Jdq31dBkfofWHUkRrobJN8vKTaGXhdEOr4Ri3KP8yV
	B+ILhO5GyQnrjp7cFoK7pKJOMllNFIKIQtYXfkoMu+LIoEouM4DnJhGhI+xTrecvHkYPzMHi/qq
	PyOb30LH1UOO/IG1EwjTr4boVBFCHkiZLDFhMfnYhFOrVCBWBpRDr5uIVNU3C18nweQ==
X-Received: by 2002:a17:902:4603:: with SMTP id o3mr13254770pld.121.1556918077070;
        Fri, 03 May 2019 14:14:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjmH0g+qFvuJ6S4eU7z0Omxk7fCZP7OL6QyW7DkECN4nBVD1AxiR1zlM9+zrG413o6+qBn
X-Received: by 2002:a17:902:4603:: with SMTP id o3mr13254636pld.121.1556918076022;
        Fri, 03 May 2019 14:14:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556918076; cv=none;
        d=google.com; s=arc-20160816;
        b=jIpatujDurjX6T4l8GJqtdb5VdDVLBjnOwGTQcWWhgUJKZn2Dl9PSo5Zs2nr45DCdj
         IH2XidEYxORMVBEFtvMkVCF8UtmZ/mHRdrO2fQOheYjXYYMjG1vlsSmJFwwjZWy0Kdu3
         aB4aGlCI39f7O4Pk6F6+P/vrRq1QLJeWdDSk09cr5KBmOFKoSM11bovZD4fmVVebsrNu
         rgffiOvv+uLXJT4UB61gKX8Ilxwy0bMXMBeJFJqvTd+FkK3J8dGCFCZTyx9b1gtSibY1
         PV20iEXooug4KJZlZnfRyvJgYgFA40kln9Mr+LaGW79e80gliIiZymIeFmrzqe3i3yEY
         E1jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oysCqOazn6QLnwWfU7vacoQ60C5CuZGkG2ZSh6WvVD0=;
        b=ipC0/zEl9hK7Gp1Vq1aTfGt1pIm5RH7YPWuILJWc39WjnU6M2W/GueKB3WVKR2imsJ
         3mnenK7dwLdxeOz+XoEriPRewA1to4bwzLWoLClC3sziGLU1pUoHPQkoEQvtqQaIUSEt
         40qfDV6qU3okxmHv5BCL+r/IOdSPjUBmGnO2saexOdL+cPx1APPGbi5fU7ColgV1NrkG
         Vogruu1GW2DwIF5UFCOXK9/zXcYFd6hKZ2o+L5zJ53kJI67xpsBLuxKrbhrXGpv2VN0B
         BEHd0GZ3I9f9+cWI5PUW0xbPnUUAKp3I1drHq8srppW0pPUrUUS/fOX2lI4Klmuo7EQN
         bw9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t24si4083669pgj.147.2019.05.03.14.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 14:14:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 May 2019 14:14:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,427,1549958400"; 
   d="scan'208";a="296812649"
Received: from brianwel-mobl1.amr.corp.intel.com (HELO [10.254.61.9]) ([10.254.61.9])
  by orsmga004.jf.intel.com with ESMTP; 03 May 2019 14:14:33 -0700
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
To: Kenny Ho <y2kenny@gmail.com>, Leon Romanovsky <leon@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>,
 Parav Pandit <parav@mellanox.com>, David Airlie <airlied@linux.ie>,
 intel-gfx@lists.freedesktop.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, dri-devel@lists.freedesktop.org,
 Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, Li Zefan <lizefan@huawei.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 cgroups@vger.kernel.org, =?UTF-8?Q?Christian_K=c3=b6nig?=
 <christian.koenig@amd.com>, RDMA mailing list <linux-rdma@vger.kernel.org>,
 kenny.ho@amd.com, Harish.Kasiviswanathan@amd.com, daniel@ffwll.ch
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
From: "Welty, Brian" <brian.welty@intel.com>
Message-ID: <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com>
Date: Fri, 3 May 2019 14:14:33 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/2/2019 3:48 PM, Kenny Ho wrote:
> On 5/2/2019 1:34 AM, Leon Romanovsky wrote:
>> Count us (Mellanox) too, our RDMA devices are exposing special and
>> limited in size device memory to the users and we would like to provide
>> an option to use cgroup to control its exposure.

Hi Leon, great to hear and happy to work with you and RDMA community
to shape this framework for use by RDMA devices as well.  The intent
was to support more than GPU devices.

Incidentally, I also wanted to ask about the rdma cgroup controller
and if there is interest in updating the device registration implemented
in that controller.  It could use the cgroup_device_register() that is
proposed here.   But this is perhaps future work, so can discuss separately.


> Doesn't RDMA already has a separate cgroup?  Why not implement it there?
> 

Hi Kenny, I can't answer for Leon, but I'm hopeful he agrees with rationale
I gave in the cover letter.  Namely, to implement in rdma controller, would
mean duplicating existing memcg controls there.

Is AMD interested in collaborating to help shape this framework?
It is intended to be device-neutral, so could be leveraged by various
types of devices.
If you have an alternative solution well underway, then maybe
we can work together to merge our efforts into one.
In the end, the DRM community is best served with common solution.


> 
>>> and with future work, we could extend to:
>>> *  track and control share of GPU time (reuse of cpu/cpuacct)
>>> *  apply mask of allowed execution engines (reuse of cpusets)
>>>
>>> Instead of introducing a new cgroup subsystem for GPU devices, a new
>>> framework is proposed to allow devices to register with existing cgroup
>>> controllers, which creates per-device cgroup_subsys_state within the
>>> cgroup.  This gives device drivers their own private cgroup controls
>>> (such as memory limits or other parameters) to be applied to device
>>> resources instead of host system resources.
>>> Device drivers (GPU or other) are then able to reuse the existing cgroup
>>> controls, instead of inventing similar ones.
>>>
>>> Per-device controls would be exposed in cgroup filesystem as:
>>>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
>>> such as (for example):
>>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
>>>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
>>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
>>>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight
>>>
>>> The drm/i915 patch in this series is based on top of other RFC work [1]
>>> for i915 device memory support.
>>>
>>> AMD [2] and Intel [3] have proposed related work in this area within the
>>> last few years, listed below as reference.  This new RFC reuses existing
>>> cgroup controllers and takes a different approach than prior work.
>>>
>>> Finally, some potential discussion points for this series:
>>> * merge proposed <subsys_name>.devices into a single devices directory?
>>> * allow devices to have multiple registrations for subsets of resources?
>>> * document a 'common charging policy' for device drivers to follow?
>>>
>>> [1] https://patchwork.freedesktop.org/series/56683/
>>> [2] https://lists.freedesktop.org/archives/dri-devel/2018-November/197106.html
>>> [3] https://lists.freedesktop.org/archives/intel-gfx/2018-January/153156.html
>>>
>>>
>>> Brian Welty (5):
>>>   cgroup: Add cgroup_subsys per-device registration framework
>>>   cgroup: Change kernfs_node for directories to store
>>>     cgroup_subsys_state
>>>   memcg: Add per-device support to memory cgroup subsystem
>>>   drm: Add memory cgroup registration and DRIVER_CGROUPS feature bit
>>>   drm/i915: Use memory cgroup for enforcing device memory limit
>>>
>>>  drivers/gpu/drm/drm_drv.c                  |  12 +
>>>  drivers/gpu/drm/drm_gem.c                  |   7 +
>>>  drivers/gpu/drm/i915/i915_drv.c            |   2 +-
>>>  drivers/gpu/drm/i915/intel_memory_region.c |  24 +-
>>>  include/drm/drm_device.h                   |   3 +
>>>  include/drm/drm_drv.h                      |   8 +
>>>  include/drm/drm_gem.h                      |  11 +
>>>  include/linux/cgroup-defs.h                |  28 ++
>>>  include/linux/cgroup.h                     |   3 +
>>>  include/linux/memcontrol.h                 |  10 +
>>>  kernel/cgroup/cgroup-v1.c                  |  10 +-
>>>  kernel/cgroup/cgroup.c                     | 310 ++++++++++++++++++---
>>>  mm/memcontrol.c                            | 183 +++++++++++-
>>>  13 files changed, 552 insertions(+), 59 deletions(-)
>>>
>>> --
>>> 2.21.0
>>>
>> _______________________________________________
>> dri-devel mailing list
>> dri-devel@lists.freedesktop.org
>> https://lists.freedesktop.org/mailman/listinfo/dri-devel

