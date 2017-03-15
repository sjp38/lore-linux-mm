Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9D516B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 04:35:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h188so3676023wma.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:35:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y67si1738920wmd.34.2017.03.15.01.35.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 01:35:31 -0700 (PDT)
Date: Wed, 15 Mar 2017 09:35:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] xfs: remove kmem_zalloc_greedy
Message-ID: <20170315083529.GD32620@dhcp22.suse.cz>
References: <20170308003528.GK5280@birch.djwong.org>
 <20170314165745.GB28800@wotan.suse.de>
 <20170314180738.GV5280@birch.djwong.org>
 <20170315001427.GI28800@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315001427.GI28800@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Brian Foster <bfoster@redhat.com>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, sebastian.parschauer@suse.com, AlNovak@suse.com, jack@suse.cz, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Wed 15-03-17 01:14:27, Luis R. Rodriguez wrote:
> On Tue, Mar 14, 2017 at 11:07:38AM -0700, Darrick J. Wong wrote:
> > On Tue, Mar 14, 2017 at 05:57:45PM +0100, Luis R. Rodriguez wrote:
> > > On Tue, Mar 07, 2017 at 04:35:28PM -0800, Darrick J. Wong wrote:
> > > > The sole remaining caller of kmem_zalloc_greedy is bulkstat, which uses
> > > > it to grab 1-4 pages for staging of inobt records.  The infinite loop in
> > > > the greedy allocation function is causing hangs[1] in generic/269, so
> > > > just get rid of the greedy allocator in favor of kmem_zalloc_large.
> > > > This makes bulkstat somewhat more likely to ENOMEM if there's really no
> > > > pages to spare, but eliminates a source of hangs.
> > > > 
> > > > [1] http://lkml.kernel.org/r/20170301044634.rgidgdqqiiwsmfpj%40XZHOUW.usersys.redhat.com
> > > > 
> > > > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > > > ---
> > > > v2: remove single-page fallback
> > > > ---
> > > 
> > > Since this fixes a hang how about *at the very least* a respective Fixes tag ?
> > > This fixes an existing hang so what are the stable considerations here ? I
> > > realize the answer is not easy but figured its worth asking.
> > 
> > I didn't think it was appropriate to "Fixes: 77e4635ae1917" since we're
> > not fixing _greedy so much as we are killing it.  The patch fixes an
> > infinite retry hang when bulkstat tries a memory allocation that cannot
> > be satisfied; and having done that, realizes there are no remaining
> > callers of _greedy and garbage collects it.  The code that was there
> > before also seems capable of sleeping forever, I think.
> > 
> > So the minimally invasive fix is to apply the allocation conversion in
> > bulkstat, and if there aren't any other callers of _greedy then you can
> > get rid of it too.
> 
> For the stake of stable XFS users then why not do the less invasive change
> first, Cc stable, and then move on to the less backward portable solution ?

The thing is that the permanent failures for vmalloc were so unlikely
prior to 5d17a73a2ebe ("vmalloc: back off when the current task is
killed") that this was basically a non-issue before this (4.11) merge
window.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
