Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 80B506B0182
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:44:31 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id p6so100065qcv.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:44:31 -0800 (PST)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id kz1si48658056qcb.14.2015.01.06.13.44.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:44:30 -0800 (PST)
Received: by mail-qg0-f52.google.com with SMTP id i50so81990qgf.25
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:44:30 -0800 (PST)
Date: Tue, 6 Jan 2015 16:44:26 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150106214426.GA24106@htj.dyndns.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com

Hello, again.  A bit of addition.

On Tue, Jan 06, 2015 at 04:25:37PM -0500, Tejun Heo wrote:
...
> Overall design
> --------------

What's going on in this patchset is fairly straight forward.  The main
thing which is happening is that a bdi is being split into multiple
per-cgroup pieces.  Each split bdi, represented by bdi_writeback,
behaves mostly identically with how bdi behaved before.

Complications mostly arise from filesystems and inodes having to deal
with multiple split bdi's instead of one, but those are mostly
straight-forward 1:N mapping issues.  It does get tedious here and
there but doesn't complicate the overall picture.  This
straight-forwardness pays off when dealing with interaction issues
which would have been extremely hairy otherwise.  More on this while
discussing balance_dirty_pages.

...
> Missing pieces
> --------------
...
> * balance_dirty_pages currently doesn't consider the task's memcg when
>   calculating the number of dirtyable pages.  This means that tasks in
>   memcg won't have the benefit of smooth background writeback and will
>   bump into direct reclaim all the time.  This has always been like
>   this but with cgroup writeback support, this is also finally
>   fixable.  I'll work on this as the earlier part gets settled.

This has always been a really thorny issue but now that each wb
behaves as an independent writeback domain, this can be solved nicely.
Each cgroup can carry the fraction of writebandwidth against the whole
system and each task can carry its fraction against its memcg.
balance_dirty_pages can now stagger these two ratios and then apply it
against the memory which *may* be dirtyable to the task's memcg and
then throttle the dirtier accordingly.  This works out exactly as a
straight-forward extension of the global logic which is proven to
work.  This really is pieces falling into places.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
