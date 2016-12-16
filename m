Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96A696B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:01:24 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so37571091wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:01:24 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id z14si5333929wmh.153.2016.12.16.14.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 14:01:23 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id j10so16058745wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:01:23 -0800 (PST)
Date: Fri, 16 Dec 2016 23:01:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/9 v2] xfs: introduce and use KM_NOLOCKDEP to silence
 reclaim lockdep false positives
Message-ID: <20161216220121.GC7645@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-3-mhocko@kernel.org>
 <20161216154041.GA7645@dhcp22.suse.cz>
 <20161216163749.GE8447@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216163749.GE8447@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri 16-12-16 11:37:50, Brian Foster wrote:
> On Fri, Dec 16, 2016 at 04:40:41PM +0100, Michal Hocko wrote:
> > Updated patch after Mike noticed a BUG_ON when KM_NOLOCKDEP is used.
> > ---
> > From 1497e713e11639157aef21cae29052cb3dc7ab44 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 15 Dec 2016 13:06:43 +0100
> > Subject: [PATCH] xfs: introduce and use KM_NOLOCKDEP to silence reclaim
> >  lockdep false positives
> > 
> > Now that the page allocator offers __GFP_NOLOCKDEP let's introduce
> > KM_NOLOCKDEP alias for the xfs allocation APIs. While we are at it
> > also change KM_NOFS users introduced by b17cb364dbbb ("xfs: fix missing
> > KM_NOFS tags to keep lockdep happy") and use the new flag for them
> > instead. There is really no reason to make these allocations contexts
> > weaker just because of the lockdep which even might not be enabled
> > in most cases.
> > 
> 
> Hi Michal,
> 
> I haven't gone back to fully grok b17cb364dbbb ("xfs: fix missing
> KM_NOFS tags to keep lockdep happy"), so I'm not really familiar with
> the original problem. FWIW, there was another KM_NOFS instance added by
> that commit in xlog_cil_prepare_log_vecs() that is now in
> xlog_cil_alloc_shadow_bufs(). Perhaps Dave can confirm whether the
> original issue still applies..?

Yes, I've noticed that but the reworked code looked sufficiently
different that I didn't dare to simply convert it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
