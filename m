Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD116B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 17:54:30 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e75so1255850itd.16
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 14:54:30 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id 68si4136074iod.229.2017.03.30.14.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 14:54:29 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id f84so28641556ioj.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 14:54:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEe=SxmpXD=f9N_i+xe6gFUKKUefJYvBd8dSwxSM+7rbBBTniw@mail.gmail.com>
References: <20170317231636.142311-1-timmurray@google.com> <20170330155123.GA3929@cmpxchg.org>
 <CAEe=SxmpXD=f9N_i+xe6gFUKKUefJYvBd8dSwxSM+7rbBBTniw@mail.gmail.com>
From: Tim Murray <timmurray@google.com>
Date: Thu, 30 Mar 2017 14:54:28 -0700
Message-ID: <CAEe=Sxmj6wHN9HzAix9F4HDhk9ojYaMrStE1b1MxB0VvMzd=Ug@mail.gmail.com>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>

On Thu, Mar 30, 2017 at 12:40 PM, Tim Murray <timmurray@google.com> wrote:
> The current critical vmpressure event
> hasn't been that successful in avoiding oom-killer (on 3.18, at
> least)--I've been able to get oom-killer to trigger without a
> vmpressure event.

Looked at this some more, and this is almost certainly because
vmpressure relies on workqueues. Scheduling delay from CFS workqueues
would explain vmpressure latency that results in oom-killer running
long before the critical vmpressure notification is received in
userspace, even if userspace is running as FIFO. We regularly see
10ms+ latency on workqueues, even when an Android device isn't heavily
loaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
