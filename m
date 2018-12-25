Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 132D78E0001
	for <linux-mm@kvack.org>; Tue, 25 Dec 2018 10:39:35 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e8-v6so4626793ljg.22
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 07:39:35 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id g8-v6si29917005lji.127.2018.12.25.07.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Dec 2018 07:39:33 -0800 (PST)
From: Konstantin Khorenko <khorenko@virtuozzo.com>
Subject: [RFC PATCH 0/1] mm: add a warning about high order allocations
Date: Tue, 25 Dec 2018 18:39:26 +0300
Message-Id: <20181225153927.2873-1-khorenko@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khorenko <khorenko@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.com>

Q: Why do we need to bother at all?
A: If a node is highly loaded and its memory is significantly fragmented
(unfortunately almost any node with serious load has highly fragmented memory)
then any high order memory allocation can trigger massive memory shrink and
result in quite a big allocation latency. And the node becomes less responsive
and users don't like it.
The ultimate solution here is to get rid of large allocations, but we need an
instrument to detect them.

Q: Why warning? Use tracepoints!
A: Well, this is a matter of magic defaults.
Yes, you can use tracepoints to catch large allocations, but you need to do this
on purpose and regularly and this is to be done by every developer which is
quite unreal.
On the other hand if you develop something and get a warning, you'll have to
think about the reason and either succeed with reworking the code to use
smaller allocation sizes (and thus decrease allocation latency!) or just use
kvmalloc() if you don't really need physically continuos chunk or come to the
conclusion you definitely need physically continuos memory and shut up the
warning.

Q: Why compile time config option?
A: In order not to decrease the performance even a bit in case someone does not
want to hunt for large allocations.
In an ideal life i'd prefer this check/warning is enabled by default and may be
even without a config option so it works on every node. Once we find and rework
or mark all large allocations that would be good by default. Until that though
it will be noisy.

Another option is to rework the patch via static keys (having the warning
disabled by default surely). That makes it possible to turn on the feature
without recompiling the kernel - during testing period for example.

If you prefer this way, i would be happy to rework the patch via static keys.

Konstantin Khorenko (1):
  mm/page_alloc: add warning about high order allocations

 kernel/sysctl.c | 15 +++++++++++++++
 mm/Kconfig      | 18 ++++++++++++++++++
 mm/page_alloc.c | 25 +++++++++++++++++++++++++
 3 files changed, 58 insertions(+)

-- 
2.15.1
