Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE026B19A3
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:30:50 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id y6so7006492lfy.11
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:30:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h5-v6sor19665502ljj.15.2018.11.19.00.30.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 00:30:48 -0800 (PST)
Date: Mon, 19 Nov 2018 11:30:45 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181119083045.m5rhvbsze4h5l6jq@esperanza>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dong <bauers@126.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, Nov 18, 2018 at 08:44:14AM +0800, dong wrote:
> First of all,I can see memory leak when I run a??free -ga?? command.

This doesn't mean there's a leak. The kernel may postpone freeing memory
until there's memory pressure. In particular cgroup objects are not
released until there are objects allocated from the corresponding kmem
caches. Those objects may be inodes or dentries, which are freed lazily.
Looks like restarting a service causes recreation of a memory cgroup and
hence piling up dead cgroups. Try to drop caches.

>So I enabled kmemleak. I got the messages above. When I run a??cat
>/sys/kernel/debug/kmemleaka??, nothing came up. Instead, the a??dmesga??
>command show me the leak messages. So the messages is not the leak
>reasoni 1/4 ?How can I detect the real memory leaki 1/4 ?Thanksi 1/4 ?
