Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E48656B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 03:46:28 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k40so4056557lfi.5
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 00:46:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u127si6138037wmd.17.2017.10.09.00.46.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 00:46:27 -0700 (PDT)
Date: Mon, 9 Oct 2017 09:46:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171009074625.b7qztlyoa4u7lyy7@dhcp22.suse.cz>
References: <201710022205.IGD04659.HSOMJFFQtFOLOV@I-love.SAKURA.ne.jp>
 <20171002131330.5c5mpephrosfuxsa@dhcp22.suse.cz>
 <201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
 <20171002171641-mutt-send-email-mst@kernel.org>
 <201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
 <201710072030.HGE12424.HFFMVLJOOStFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710072030.HGE12424.HFFMVLJOOStFQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mst@redhat.com, linux-mm@kvack.org

On Sat 07-10-17 20:30:19, Tetsuo Handa wrote:
[...]
> >From 6a0fd8a5e013ac63a6bcd06bd2ae6fdb25a4f3de Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 7 Oct 2017 19:29:21 +0900
> Subject: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
> 
> In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> serialize against fill_balloon(). But in fill_balloon(),
> alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> is specified, this allocation attempt might depend on somebody else's
> __GFP_DIRECT_RECLAIM memory allocation.

How would that dependency look like? Is the holder of the lock doing
only __GFP_NORETRY?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
