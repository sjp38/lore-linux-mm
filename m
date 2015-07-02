Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id AA0B89003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:01:09 -0400 (EDT)
Received: by qkei195 with SMTP id i195so42912207qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:01:09 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id 11si4677884qgl.25.2015.07.01.19.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:01:09 -0700 (PDT)
Received: by qkbp125 with SMTP id p125so42834637qkb.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:01:08 -0700 (PDT)
Date: Wed, 1 Jul 2015 22:01:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 33/51] writeback: make bdi_has_dirty_io() take multiple
 bdi_writeback's into account
Message-ID: <20150702020106.GG26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-34-git-send-email-tj@kernel.org>
 <20150630164824.GU7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630164824.GU7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Tue, Jun 30, 2015 at 06:48:24PM +0200, Jan Kara wrote:
> It looks OK although I find using total write bandwidth to detect whether
> any wb has any dirty IO rather hacky. Frankly I'd prefer to just iterate
> all wbs from bdi_has_dirty_io() since that isn't performance critical
> and we iterate all wbs in those paths anyway... Hmm?

When there are wb's to write out, maybe walking it twice isn't too
bad; however, the problem, I think, is when there's nothing to do.
When there are enough number of devices and cgroups, we end up making
what used to be a trivial operation something which can be
computationally significant.  ie. userland behaviors which used to be
completely fine because things are very cheap when there's nothing to
do can become scalability liabilities.

I don't think it's highly likely that this would become a visible
issue but I feel pretty uneasy about making O(1) noops O(N),
especially given that we need to maintain per-bdi fraction anyway.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
