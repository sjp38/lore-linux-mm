Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF9456B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 06:51:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g36-v6so1042969edb.3
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 03:51:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4-v6si2269618edb.79.2018.10.02.03.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 03:51:00 -0700 (PDT)
Date: Tue, 2 Oct 2018 12:50:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002105058.GE18342@dhcp22.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002100531.GC4135@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jthumshirn@suse.de

On Tue 02-10-18 12:05:31, Jan Kara wrote:
> Hello,
> 
> commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> mean time certain customer of ours started poking into /proc/<pid>/smaps
> and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> flags, the application just fails to start complaining that DAX support is
> missing in the kernel. The question now is how do we go about this?

Do they need to check for a general DAX support or do they need a per
mapping granularity?

> Strictly speaking, this is a userspace visible regression (as much as I
> think that application poking into VMA flags at this level is just too
> bold). Is there any precedens in handling similar issues with smaps which
> really exposes a lot of information that is dependent on kernel
> implementation details?

Yeah, exposing all the vma flags was just a terrible idea. We have had a
similar issue recently [1] for other flag that is no longer set while
the implementation of the feature is still in place. I guess we really
want to document that those flags are for debugging only and no stable
and long term API should rely on it.

Considering how new the thing really is (does anybody do anything
production like out there?) I would tend to try a better interface
rather than chasing after random vma flags. E.g. what prevents a
completely unrelated usage of VM_MIXEDMAP?
-- 
Michal Hocko
SUSE Labs
