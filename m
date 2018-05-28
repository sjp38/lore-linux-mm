Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D74AB6B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 17:06:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f6-v6so3193876pgs.13
        for <linux-mm@kvack.org>; Mon, 28 May 2018 14:06:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o12-v6si30865018plg.463.2018.05.28.14.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 14:05:59 -0700 (PDT)
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
	<20180528083451.GE1517@dhcp22.suse.cz>
	<f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
	<20180528132410.GD27180@dhcp22.suse.cz>
In-Reply-To: <20180528132410.GD27180@dhcp22.suse.cz>
Message-Id: <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
Date: Tue, 29 May 2018 06:05:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin.marinas@arm.com, chuhu@redhat.com

Michal Hocko wrote:
> I've found the previous report [1] finally. Adding Chunyu Hu to the CC
> list. The report which triggered this one is [2]
> 
> [1] http://lkml.kernel.org/r/1524243513-29118-1-git-send-email-chuhu@redhat.com
> [2] http://lkml.kernel.org/r/CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com
> 
> I am not really familiar with the kmemleak code but the expectation that
> you can make a forward progress in an unknown allocation context seems
> broken to me. Why kmemleak cannot pre-allocate a pool of object_cache
> and refill it from a reasonably strong contexts (e.g. in a sleepable
> context)?

Or, we can undo the original allocation if the kmemleak allocation failed?

kmalloc(size, gfp) {
  ptr = do_kmalloc(size, gfp);
  if (ptr) {
    object = do_kmalloc(size, gfp_kmemleak_mask(gfp));
    if (!object) {
      kfree(ptr);
      return NULL;
    }
    // Store information of ptr into object.
  }
  return ptr;
}
