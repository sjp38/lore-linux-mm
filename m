Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E32B6B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 16:26:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so78495043wmw.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 13:26:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh2si66892966wjb.232.2016.04.18.13.26.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 13:26:15 -0700 (PDT)
Date: Mon, 18 Apr 2016 22:26:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
Message-ID: <20160418202610.GA17889@quack2.suse.cz>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Toshi Kani <toshi.kani@hpe.com>, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 15-04-16 22:05:31, Andrew Morton wrote:
> On Thu, 14 Apr 2016 10:48:29 -0600 Toshi Kani <toshi.kani@hpe.com> wrote:
> 
> > When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
> > size.  This feature relies on both mmap virtual address and FS
> > block (i.e. physical address) to be aligned by the pmd page size.
> > Users can use mkfs options to specify FS to align block allocations.
> > However, aligning mmap address requires code changes to existing
> > applications for providing a pmd-aligned address to mmap().
> > 
> > For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
> > It calls mmap() with a NULL address, which needs to be changed to
> > provide a pmd-aligned address for testing with DAX pmd mappings.
> > Changing all applications that call mmap() with NULL is undesirable.
> > 
> > This patch-set extends filesystems to align an mmap address for
> > a DAX file so that unmodified applications can use DAX pmd mappings.
> 
> Matthew sounded unconvinced about the need for this patchset, but I
> must say that
> 
> : The point is that we do not need to modify existing applications for using
> : DAX PMD mappings.
> : 
> : For instance, fio with "ioengine=mmap" performs I/Os with mmap(). 
> : https://github.com/caius/fio/blob/master/engines/mmap.c
> : 
> : With this change, unmodified fio can be used for testing with DAX PMD
> : mappings.  There are many examples like this, and I do not think we want
> : to modify all applications that we want to evaluate/test with.
> 
> sounds pretty convincing?
> 
> 
> And if we go ahead with this, it looks like 4.7 material to me - it
> affects ABI and we want to get that stabilized asap.  What do people
> think?

So I think Mathew didn't question the patch set as a whole. I think we all
agree that we should align the virtual address we map to so that PMD
mappings can be used. What Mathew was questioning was whether we really
need to play tricks when logical offset in the file where mmap is starting
is not aligned (and similarly for map length). Whether allowing PMD
mappings for unaligned file offsets is worth the complication is IMO a
valid question.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
