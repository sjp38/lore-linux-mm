Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9272802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 09:58:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p135so34478335ita.11
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 06:58:33 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id c66si7596129ioc.232.2017.06.30.06.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 06:58:32 -0700 (PDT)
Date: Fri, 30 Jun 2017 08:58:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm/slab: What is cache_reap work for?
In-Reply-To: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1706300856530.3291@east.gentwo.org>
References: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue, 27 Jun 2017, Tetsuo Handa wrote:

> I hit an unable to invoke the OOM killer lockup shown below. According to
> "cpus=2 node=0 flags=0x0 nice=0" part, it seems that cache_reap (in mm/slab.c)
> work stuck waiting for disk_events_workfn (in block/genhd.c) work to complete.

Cache reaping in SLAB is the expiration of objects since they are deemed
to be cache cold after while. Reaping is a tick driven worker thread that
calls other functions that are used during regular slab allocation and
freeing. Maybe someone added code that can cause deadlocks if invoked from
the tick?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
