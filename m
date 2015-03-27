Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6D06B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 17:41:58 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so138612883qgf.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:41:58 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id y64si3141387qgy.79.2015.03.27.14.41.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 14:41:57 -0700 (PDT)
Received: by qgep97 with SMTP id p97so145746175qge.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:41:57 -0700 (PDT)
Date: Fri, 27 Mar 2015 17:41:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 21/48] writeback: make backing_dev_info host
 cgroup-specific bdi_writebacks
Message-ID: <20150327214154.GE638@htj.duckdns.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
 <1427086499-15657-22-git-send-email-tj@kernel.org>
 <20150327210612.GA23840@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327210612.GA23840@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello Vivek.

On Fri, Mar 27, 2015 at 05:06:13PM -0400, Vivek Goyal wrote:
> I was curious to know that why do we need this "struct page *page" when
> trying to attach a inode to a bdi_writeback. Is using current's cgroup
> always not sufficient?

So, memcg's page ownership is first-use based and it never gets
updated once set till the page is released which means that there can
be corner cases where an inode is mostly faulted in by one cgroup and
then constantly dirtied by another.  Because the ownership belongs to
the initial cgroup which instantiated those pages, cgroup writeback
ends up considering the pages as belonging to that initial cgroup and
the foreign detection will trigger if it's being written by a
different cgroup.  Hmmmm... this isn't a huge problem as once the
foreign detection triggers, the problem will be corrected but still
when the page is availalbe, I think it makes sense to attach to the
page as that's what actually defines the ownership.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
