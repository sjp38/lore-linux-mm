Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A72DBC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A21F205C9
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:16:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Gfz6Scb+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A21F205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E996B0005; Mon,  6 May 2019 11:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0E076B0006; Mon,  6 May 2019 11:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C617C6B0007; Mon,  6 May 2019 11:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBDE6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 11:16:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z12so8213672pgs.4
        for <linux-mm@kvack.org>; Mon, 06 May 2019 08:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1u7drWIJX0vlIQB/ygcUGyKLjxAddZMS8JK32/Eg9hU=;
        b=DDQ76TOxlxsMiLsXIYVEfT7bva0ZHNLOQEq9Mlc7A/s12xHVjh5Eq5sHKv9aSO/Yn4
         YU+XIF1i4Y50n6WAtf9WxtpZjgT9S+A5uiMjDQ8z1cNBcR0gdFvH1YskkGH5SZ6KL91B
         zxqg7MD+7JoXTiK9Go1sWYkhsTJQWm4aq1V59C1sPABk4pdji/J6968BlmwkXfa1G4iC
         bd6lud/MJcFlL1scLCli+iwBUlb+r76RLPwmvaE1H1VNMwzsYiwedpo+9t3m3qoK7tYA
         Gdebr9cSE2yQpguowf2ON+ZjCtpAQFLIrKC6/P3MnZs+MvtNyCgfP2hc6EABPqJNa17Y
         eQ/w==
X-Gm-Message-State: APjAAAUm5hkLqwAs3MFKgGT7f7uQsm5sUibPmhmbESj9lCFvOgpQ0XlB
	cukJqZ1t5PvYYZMG5hXYDBb8lh8JT1qmran1D+wyY6l0FV7W43c/+eOhhlcCXODtfTuGyCd/xhu
	ygElD7dOULJas/iAuNGCdMQV4m1o9DuGVwGAzj9J3DyukEbR7Yb4UVwr/JwJWe1i5Vg==
X-Received: by 2002:a63:e52:: with SMTP id 18mr33262487pgo.3.1557155780205;
        Mon, 06 May 2019 08:16:20 -0700 (PDT)
X-Received: by 2002:a63:e52:: with SMTP id 18mr33262306pgo.3.1557155778723;
        Mon, 06 May 2019 08:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557155778; cv=none;
        d=google.com; s=arc-20160816;
        b=K8FoOvKKtDpoZ9+SFfOQKlSb354s26i/itpIvq8799biKQr26lygUSojCNvYBouh8P
         IP1aeUywDNu9nwdCIWDDEVr5iOBzdXlGYt3OcPshmM+qaWQsoWseD2+Mpx4A6j6U4a8t
         ZRMkp/XkhXqw1eztmuieLGgGrX4Fdqm0bI4U4xR9CdXDgwb2wD1oXNrr3HvAPsEDmmBz
         ohsTINv5SslznHObaZgVH6Zhyoenbhf+b1dMsO7ZSH3KnWIHI9Q+HOh6ti8H8fhrLGPT
         JaDl3byOkuu+01yVv1JSsoP7aYVnTiWL7vtX30nsofvXEc2owWO24HiSPjmzTptkYzt7
         FDMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1u7drWIJX0vlIQB/ygcUGyKLjxAddZMS8JK32/Eg9hU=;
        b=pqdv6TK/ASDH9uRQ6uXBPrYwfJJww3J2GYWob5vGFh5/YdXIPcASGYC3qEiyncEKa6
         D/ZZymO3BaHvCahz5jzepWStzu8RweF+9hOtvFpRW6q7hNIcCLtE4/Rj4fVT4grhyBLL
         qS0fo+Q7lPnAC33mwmnhrSFnbUPhekpqMxxrE2bN9k4Nn1IqcGjLJo6Ky379kQ6YOMZ0
         EtbgLM8WlcpHtbKCzQJWI5FWoDkNwJ/Mp3eje6d3IWSvVvqRW8VnpMhhey3qXdEsarEi
         knXjNTLXJsdiiPcrUQaqVPwR8QnfLVYLaBZMy60vUGxuszXvPysskNXPo9yTtaSRS6RV
         3lBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Gfz6Scb+;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bg1sor12447829plb.20.2019.05.06.08.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 08:16:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Gfz6Scb+;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1u7drWIJX0vlIQB/ygcUGyKLjxAddZMS8JK32/Eg9hU=;
        b=Gfz6Scb+O2dfTb/uucuXrirZqRMDgF4/Zjl9BTGZrZWKo+QHDsRDtuCj0izcdOXzTi
         MRBYqwsmnC2e2iTWV7mY/5X9K21nxVs2DTJAYxgib2P1a+J58VF/oe3ppYcf122tjBG0
         TdTWNtw0PM50AuDnCjlp6SQh1sXgMUgz3L3qfAAH8WUHGjcdrxTBumA4E5k4dL4a/tnk
         NuAuY8j86JpTdsunWHDaWqHuo1cFDDCNrIvoaG4ce5U7gbS8hrHFTAAS8fdpC9vdt2f4
         EE5MHAXTmTgxlGGESYMm5dW8lsmAavNw3P1AYOoXPR1FPuJoAow1sFOgo+ssLmNOwUao
         fB1Q==
X-Google-Smtp-Source: APXvYqwIbUKO147fnZOB17UUDrHH0ucZxXj2tg3GkjqUJZP2G1mbEvn9k/V2uaDJP2/lyedoAKCdVw==
X-Received: by 2002:a17:902:a5ca:: with SMTP id t10mr33215767plq.234.1557155775870;
        Mon, 06 May 2019 08:16:15 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:32a0])
        by smtp.gmail.com with ESMTPSA id 9sm18661441pgv.5.2019.05.06.08.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 08:16:14 -0700 (PDT)
Date: Mon, 6 May 2019 11:16:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Brian Welty <brian.welty@intel.com>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190506151613.GB11505@cmpxchg.org>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:04:33AM -0400, Brian Welty wrote:
> In containerized or virtualized environments, there is desire to have
> controls in place for resources that can be consumed by users of a GPU
> device.  This RFC patch series proposes a framework for integrating 
> use of existing cgroup controllers into device drivers.
> The i915 driver is updated in this series as our primary use case to
> leverage this framework and to serve as an example for discussion.
> 
> The patch series enables device drivers to use cgroups to control the
> following resources within a GPU (or other accelerator device):
> *  control allocation of device memory (reuse of memcg)
> and with future work, we could extend to:
> *  track and control share of GPU time (reuse of cpu/cpuacct)
> *  apply mask of allowed execution engines (reuse of cpusets)

Please create a separate controller for your purposes.

The memory controller is for traditional RAM. I don't see it having
much in common with what you're trying to do, and it's barely reusing
any of the memcg code. You can use the page_counter API directly.

> Instead of introducing a new cgroup subsystem for GPU devices, a new
> framework is proposed to allow devices to register with existing cgroup
> controllers, which creates per-device cgroup_subsys_state within the
> cgroup.  This gives device drivers their own private cgroup controls
> (such as memory limits or other parameters) to be applied to device
> resources instead of host system resources.
> Device drivers (GPU or other) are then able to reuse the existing cgroup
> controls, instead of inventing similar ones.
> 
> Per-device controls would be exposed in cgroup filesystem as:
>     mount/<cgroup_name>/<subsys_name>.devices/<dev_name>/<subsys_files>
> such as (for example):
>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.max
>     mount/<cgroup_name>/memory.devices/<dev_name>/memory.current
>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.stat
>     mount/<cgroup_name>/cpu.devices/<dev_name>/cpu.weight

Subdirectories for anything other than actual cgroups are a no-go. If
you need a hierarchy, use dotted filenames:

gpu.memory.max
gpu.cycles.max

etc. and look at Documentation/admin-guide/cgroup-v2.rst's 'Format'
and 'Conventions', as well as how the io controller works, to see how
multi-key / multi-device control files are implemented in cgroup2.

