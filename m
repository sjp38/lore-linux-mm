Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id DCF836B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 16:36:17 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id x12so3986584qac.11
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 13:36:17 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id d64si13894169qgf.4.2015.01.09.13.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 13:36:17 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id c9so11012530qcz.10
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 13:36:16 -0800 (PST)
Date: Fri, 9 Jan 2015 16:36:13 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150109213613.GC2785@htj.dyndns.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
 <20150108093057.GD14705@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150108093057.GD14705@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com

Hello, Jan.

On Thu, Jan 08, 2015 at 10:30:57AM +0100, Jan Kara wrote:
> > * An inode may have pages dirtied by different memcgs, which naturally
> >   means that it should be able to be dirtied against multiple wb's.
> >   To support linking an inode against multiple wb's, iwbl
> >   (inode_wb_link) is introduced.  An inode has multiple iwbl's
> >   associated with it if it's dirty against multiple wb's.
>
>   Is the ability for inode to belong to multiple memcgs really worth the
> effort? It brings significant complications (see also Dave's email) and
> the last time we were discussing cgroup writeback support the demand from
> users for this was small... How hard would it be to just start with an
> implementation which attaches the inode to the first memcg that dirties it
> (and detaches it when inode gets clean)? And implement sharing of inodes
> among mecgs only if there's a real demand for it?

This was something I spent quite some time debating back and forth.
IMO, the complexity added from having to handle dirtying against
multiple cgroups isn't that high in the scheme of things.  It enables
use cases where different regions of an inode are actively shared by
multiple cgroups and more importantly makes unexpected behaviors a lot
less likely by aligning what writeback and blkcg sees with memcg's
perception.  As mentioned in the head message, this gives us the
ability to hook up dirty ratio handling correctly for each memcg.
That working properly strongly hinges on everybody involved seeing the
same picture.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
