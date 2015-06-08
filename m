Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7A76D6B0071
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 11:10:31 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so68981347pdj.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 08:10:31 -0700 (PDT)
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com. [209.85.192.170])
        by mx.google.com with ESMTPS id k4si4480324pbq.230.2015.06.08.08.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 08:10:29 -0700 (PDT)
Received: by pdjm12 with SMTP id m12so106676214pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 08:10:29 -0700 (PDT)
Message-ID: <5575B061.6060603@kernel.dk>
Date: Mon, 08 Jun 2015 09:10:25 -0600
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH block/for-4.2-writeback] v9fs: fix error handling in v9fs_session_init()
References: <1432329245-5844-1-git-send-email-tj@kernel.org> <1432329245-5844-17-git-send-email-tj@kernel.org> <55739536.5040509@oracle.com> <20150608055731.GD21465@mtj.duckdns.org>
In-Reply-To: <20150608055731.GD21465@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On 06/07/2015 11:57 PM, Tejun Heo wrote:
> On failure, v9fs_session_init() returns with the v9fs_session_info
> struct partially initialized and expects the caller to invoke
> v9fs_session_close() to clean it up; however, it doesn't track whether
> the bdi is initialized or not and curiously invokes bdi_destroy() in
> both vfs_session_init() failure path too.
>
> A. If v9fs_session_init() fails before the bdi is initialized, the
>     follow-up v9fs_session_close() will invoke bdi_destroy() on an
>     uninitialized bdi.
>
> B. If v9fs_session_init() fails after the bdi is initialized,
>     bdi_destroy() will be called twice on the same bdi - once in the
>     failure path of v9fs_session_init() and then by
>     v9fs_session_close().
>
> A is broken no matter what.  B used to be okay because bdi_destroy()
> allowed being invoked multiple times on the same bdi, which BTW was
> broken in its own way - if bdi_destroy() was invoked on an initialiezd
> but !registered bdi, it'd fail to free percpu counters.  Since
> f0054bb1e1f3 ("writeback: move backing_dev_info->wb_lock and
> ->worklist into bdi_writeback"), this no longer work - bdi_destroy()
> on an initialized but not registered bdi works correctly but multiple
> invocations of bdi_destroy() is no longer allowed.
>
> The obvious culprit here is v9fs_session_init()'s odd and broken error
> behavior.  It should simply clean up after itself on failures.  This
> patch makes the following updates to v9fs_session_init().
>
> * @rc -> @retval error return propagation removed.  It didn't serve
>    any purpose.  Just use @rc.
>
> * Move addition to v9fs_sessionlist to the end of the function so that
>    incomplete sessions are not put on the list or iterated and error
>    path doesn't have to worry about it.
>
> * Update error handling so that it cleans up after itself.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>

Added to for-4.2/writeback, thanks.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
