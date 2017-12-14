Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B97786B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:19:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l33so2875494wrl.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:19:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j16si2949662wme.109.2017.12.14.01.19.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 01:19:20 -0800 (PST)
Date: Thu, 14 Dec 2017 10:19:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm/memcontrol.c:5364:1: warning: the frame size of 1032 bytes is
 larger than 1024 bytes [-Wframe-larger-than=]
Message-ID: <20171214091917.GE16951@dhcp22.suse.cz>
References: <a16d8181-3bb4-90cc-3c4b-ac44529494ed@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a16d8181-3bb4-90cc-3c4b-ac44529494ed@molgen.mpg.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Paul Menzel <pmenzel+linux-cgroups@molgen.mpg.de>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, it+linux-cgroups@molgen.mpg.de

On Thu 14-12-17 07:49:29, Paul Menzel wrote:
> Dear Linux folks,
> 
> 
> I enabled the undefined behavior sanitizer, and built Linusa?? master branch
> under Ubuntu 17.10 with gcc (Ubuntu 7.2.0-8ubuntu3) 7.2.0.
> 
> ```
> $ grep UBSAN /boot/config-4.15.0-rc3+
> CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
> # CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
> CONFIG_UBSAN=y
> CONFIG_UBSAN_SANITIZE_ALL=y
> # CONFIG_UBSAN_ALIGNMENT is not set
> CONFIG_UBSAN_NULL=y
> ```
> 
> The warning below is shown when building Linux.
> 
> ```
> $ git describe --tags
> v4.15-rc3-37-gd39a01eff9af
> $ git log --oneline -1
> d39a01eff9af (HEAD -> master, origin/master, origin/HEAD) Merge tag
> 'platform-drivers-x86-v4.15-3' of
> git://git.infradead.org/linux-platform-drivers-x86
> [a?|]
> $ make -j
> [a?|]
> mm/memcontrol.c: In function a??memory_stat_showa??:
> mm/memcontrol.c:5364:1: warning: the frame size of 1032 bytes is larger than
> 1024 bytes [-Wframe-larger-than=]

Interesting. My compiler does this
$ scripts/stackusage mm/memcontrol.o
$ grep memory_stat_show /tmp/stackusage.1405.RTP8
./mm/memcontrol.c:5526  memory_stat_show        976     static

But this depends on the configuration because NR_VM_EVENT_ITEMS enables
some counters depending on the config. The stack is really large but
this is a function which is called from a shallow context wrt. stack so
we should fit into a single page. One way we could do, though, is to
make those large arrays static and use a internal lock around them.
Something like the following. What do you think Johannes?
---
