Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB176B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 00:23:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w7-v6so1414033pgv.1
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 21:23:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m13-v6si2217763pls.70.2018.07.17.21.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 21:23:08 -0700 (PDT)
Date: Tue, 17 Jul 2018 21:23:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some
 machines
Message-Id: <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
In-Reply-To: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruce Merry <bmerry@ska.ac.za>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

(cc linux-mm)

On Tue, 3 Jul 2018 08:43:23 +0200 Bruce Merry <bmerry@ska.ac.za> wrote:

> Hi
> 
> I've run into an odd performance issue in the kernel, and not being a
> kernel dev or knowing terribly much about cgroups, am looking for
> advice on diagnosing the problem further (I discovered this while
> trying to pin down high CPU load in cadvisor).
> 
> On some machines in our production system, cat
> /sys/fs/cgroup/memory/memory.stat is extremely slow (500ms on one
> machine), while on other nominally identical machines it is fast
> (2ms).
> 
> One other thing I've noticed is that the affected machines generally
> have much larger values for SUnreclaim in /proc/memstat (up to several
> GB), and slabtop reports >1GB of dentry.
> 
> Before I tracked the original problem (high CPU usage in cadvisor)
> down to this, I rebooted one of the machines and the original problem
> went away, so it seems to be cleared by a reboot; I'm reluctant to
> reboot more machines to confirm since I don't have a sure-fire way to
> reproduce the problem again to debug it.
> 
> The machines are running Ubuntu 16.04 with kernel 4.13.0-41-generic.
> They're running Docker, which creates a bunch of cgroups, but not an
> excessive number: there are 106 memory.stat files in
> /sys/fs/cgroup/memory.
> 
> Digging a bit further, cat
> /sys/fs/cgroup/memory/system.slice/memory.stat also takes ~500ms, but
> "find /sys/fs/cgroup/memory/system.slice -mindepth 2 -name memory.stat
> | xargs cat" takes only 8ms.
> 
> Any thoughts, particularly on what I should compare between the good
> and bad machines to narrow down the cause, or even better, how to
> prevent it happening?
> 
> Thanks
> Bruce
> -- 
> Bruce Merry
> Senior Science Processing Developer
> SKA South Africa
