Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id EBF2A6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 05:56:32 -0500 (EST)
Received: by wiwh11 with SMTP id h11so37665119wiw.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 02:56:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt4si18373471wib.38.2015.03.05.02.56.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 02:56:31 -0800 (PST)
Date: Thu, 5 Mar 2015 11:56:26 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3 v2] dax: use pfn_mkwrite to update c/mtime + freeze
 protection
Message-ID: <20150305105626.GB2836@quack.suse.cz>
References: <54F733BD.7060807@plexistor.com>
 <54F73746.5020300@plexistor.com>
 <20150304171935.GA5443@quack.suse.cz>
 <54F820E2.9060109@plexistor.com>
 <54F822A9.7090707@plexistor.com>
 <20150305103529.GA2836@quack.suse.cz>
 <54F83442.2060101@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F83442.2060101@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu 05-03-15 12:47:30, Boaz Harrosh wrote:
> On 03/05/2015 12:35 PM, Jan Kara wrote:
> > On Thu 05-03-15 11:32:25, Boaz Harrosh wrote:
> >> On 03/05/2015 11:24 AM, Boaz Harrosh wrote:
> <>
> >>
> >> Just as curiosity, does the freezing code goes and turns all mappings
> >> into read-only, Also for pfn mapping?
> >   Hum, that's a good question. Probably we don't end up doing that. For
> >
> > normal filesystems we sync all inodes which also writeprotects all pages
> > (in clear_page_dirty_for_io() - for normal filesystems we know that if page
> > is writeably mapped it is dirty). However this won't happen for pfn
> > mapping as we don't have dirty pages. So we probably need dax_freeze()
> > implementation that will walk through all inodes with writeable mappings and
> > writeprotect them.
> > 
> 
> I'll go head and try my shot on implementing a dax_freeze(). But I will
> please need help with where to call it from.
> 
> Probably something like:
> 	if (IS_DAX(inode))
> 		dax_freeze(inode);
> 	else
> 		sync(inode)
  We normally call sync_filesystem() from fs/superblock:freeze_super(). For
DAX filesystems we'd also need to call the special function after that.
Maybe dax_freeze() isn't the best name. It could be called something like
dax_writeprotect(sb) or something like that.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
