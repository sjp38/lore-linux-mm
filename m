Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7114B82995
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:27:26 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so138018430qgf.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:27:26 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id j5si11268947qhc.33.2015.03.22.22.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:27:25 -0700 (PDT)
Received: by qcbjx9 with SMTP id jx9so98319551qcb.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:27:25 -0700 (PDT)
Date: Mon, 23 Mar 2015 01:27:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 18/18] mm: vmscan: remove memcg stalling on writeback
 pages during direct reclaim
Message-ID: <20150323052722.GB8991@htj.duckdns.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
 <1427087267-16592-19-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427087267-16592-19-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Vladimir Davydov <vdavydov@parallels.com>

On Mon, Mar 23, 2015 at 01:07:47AM -0400, Tejun Heo wrote:
> Because writeback wasn't cgroup aware before, the usual dirty
> throttling mechanism in balance_dirty_pages() didn't work for
> processes under memcg limit.  The writeback path didn't know how much
> memory is available or how fast the dirty pages are being written out
> for a given memcg and balance_dirty_pages() didn't have any measure of
> IO back pressure for the memcg.
> 
> To work around the issue, memcg implemented an ad-hoc dirty throttling
> mechanism in the direct reclaim path by stalling on pages under
> writeback which are encountered during direct reclaim scan.  This is
> rather ugly and crude - none of the configurability, fairness, or
> bandwidth-proportional distribution of the normal path.
> 
> The previous patches implemented proper memcg aware dirty throttling
> and the ad-hoc mechanism is no longer necessary.  Remove it.

Oops, just realized that this can't be removed, at least yet.
!unified path still depends on it.  I'll update the patch to disable
these checks only on the unified hierarchy.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
