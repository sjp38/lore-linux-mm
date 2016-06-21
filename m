Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB35E6B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:39:35 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id c1so7506838lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 01:39:35 -0700 (PDT)
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com. [209.85.215.48])
        by mx.google.com with ESMTPS id i80si26875259lfg.166.2016.06.21.01.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 01:31:56 -0700 (PDT)
Received: by mail-lf0-f48.google.com with SMTP id h129so12176799lfh.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 01:31:56 -0700 (PDT)
Date: Tue, 21 Jun 2016 10:31:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160621083154.GA30848@dhcp22.suse.cz>
References: <201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp>
 <20160613111943.GB6518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613111943.GB6518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Mon 13-06-16 13:19:43, Michal Hocko wrote:
[...]
> I am trying to remember why we are disabling oom killer before kernel
> threads are frozen but not really sure about that right away.

OK, I guess I remember now. Say that a task would depend on a freezable
kernel thread to get to do_exit (stuck in wait_event etc...). We would
simply get stuck in oom_killer_disable for ever. So we need to address
it a different way.

One way would be what you are proposing but I guess it would be more
systematic to never call exit_oom_victim on a remote task.  After [1] we
have a solid foundation to rely only on MMF_REAPED even when TIF_MEMDIE
is set. It is more code than your patch so I can see a reason to go with
yours if the following one seems too large or ugly.

[1] http://lkml.kernel.org/r/1466426628-15074-1-git-send-email-mhocko@kernel.org

What do you think about the following?
---
