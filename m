Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABD486B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:16:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l33so3657882wrl.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:16:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g32si2478005ede.546.2017.12.14.10.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Dec 2017 10:16:18 -0800 (PST)
Date: Thu, 14 Dec 2017 13:16:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm/memcontrol.c:5364:1: warning: the frame size of 1032 bytes is
 larger than 1024 bytes [-Wframe-larger-than=]
Message-ID: <20171214181608.GA2476@cmpxchg.org>
References: <a16d8181-3bb4-90cc-3c4b-ac44529494ed@molgen.mpg.de>
 <20171214091917.GE16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171214091917.GE16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Paul Menzel <pmenzel+linux-cgroups@molgen.mpg.de>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, it+linux-cgroups@molgen.mpg.de

On Thu, Dec 14, 2017 at 10:19:17AM +0100, Michal Hocko wrote:
> On Thu 14-12-17 07:49:29, Paul Menzel wrote:
> > I enabled the undefined behavior sanitizer, and built Linusa?? master branch
> > under Ubuntu 17.10 with gcc (Ubuntu 7.2.0-8ubuntu3) 7.2.0.
> > 
> > ```
> > $ grep UBSAN /boot/config-4.15.0-rc3+
> > CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
> > # CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
> > CONFIG_UBSAN=y
> > CONFIG_UBSAN_SANITIZE_ALL=y
> > # CONFIG_UBSAN_ALIGNMENT is not set
> > CONFIG_UBSAN_NULL=y

> But this depends on the configuration because NR_VM_EVENT_ITEMS enables
> some counters depending on the config. The stack is really large but
> this is a function which is called from a shallow context wrt. stack so
> we should fit into a single page. One way we could do, though, is to
> make those large arrays static and use a internal lock around them.
> Something like the following. What do you think Johannes?

As you said, this is a very shallow stack. Why introduce a global lock
to save memory, when we have a statically allocated 16k kernel stack
which we know is plenty for that call chain? It introduces a potential
bottleneck for nothing in return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
