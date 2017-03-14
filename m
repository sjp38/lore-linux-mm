Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2FC96B0038
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:57:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v66so51777342wrc.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:57:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z41si5794388wrb.48.2017.03.14.09.57.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 09:57:47 -0700 (PDT)
Date: Tue, 14 Mar 2017 17:57:45 +0100
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v2] xfs: remove kmem_zalloc_greedy
Message-ID: <20170314165745.GB28800@wotan.suse.de>
References: <20170308003528.GK5280@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308003528.GK5280@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>, sebastian.parschauer@suse.com, AlNovak@suse.com, jack@suse.cz

On Tue, Mar 07, 2017 at 04:35:28PM -0800, Darrick J. Wong wrote:
> The sole remaining caller of kmem_zalloc_greedy is bulkstat, which uses
> it to grab 1-4 pages for staging of inobt records.  The infinite loop in
> the greedy allocation function is causing hangs[1] in generic/269, so
> just get rid of the greedy allocator in favor of kmem_zalloc_large.
> This makes bulkstat somewhat more likely to ENOMEM if there's really no
> pages to spare, but eliminates a source of hangs.
> 
> [1] http://lkml.kernel.org/r/20170301044634.rgidgdqqiiwsmfpj%40XZHOUW.usersys.redhat.com
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
> v2: remove single-page fallback
> ---

Since this fixes a hang how about *at the very least* a respective Fixes tag ?
This fixes an existing hang so what are the stable considerations here ? I
realize the answer is not easy but figured its worth asking.

FWIW I trace kmem_zalloc_greedy()'s introduction back to 2006 77e4635ae1917
("[XFS] Add a greedy allocation interface, allocating within a min/max size
range.") through v2.6.19 days...

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
