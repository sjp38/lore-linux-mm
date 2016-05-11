Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9696B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:53:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so92483087pfb.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:53:07 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id a1si10383307pfj.104.2016.05.11.08.53.06
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 08:53:06 -0700 (PDT)
Date: Wed, 11 May 2016 09:52:22 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160511155222.GB21041@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <20160506203308.GA12506@linux.intel.com>
 <20160509093828.GF11897@quack2.suse.cz>
 <20160510152814.GQ11897@quack2.suse.cz>
 <20160510203003.GA5314@linux.intel.com>
 <20160510223937.GA10222@linux.intel.com>
 <20160511091930.GE14744@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160511091930.GE14744@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, May 11, 2016 at 11:19:30AM +0200, Jan Kara wrote:
> On Tue 10-05-16 16:39:37, Ross Zwisler wrote:
> > On Tue, May 10, 2016 at 02:30:03PM -0600, Ross Zwisler wrote:
> > > On Tue, May 10, 2016 at 05:28:14PM +0200, Jan Kara wrote:
> > > > On Mon 09-05-16 11:38:28, Jan Kara wrote:
> > > > Somehow, I'm not able to reproduce the warnings... Anyway, I think I see
> > > > what's going on. Can you check whether the warning goes away when you
> > > > change the condition at the end of page_cache_tree_delete() to:
> > > > 
> > > >         if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
> > > >             list_empty(&node->private_list)) {
> > > 
> > > Yep, this took care of both of the issues that I reported.  I'll restart my
> > > testing with this in my baseline, but as of this fix I don't have any more
> > > open testing issues. :)
> > 
> > Well, looks like I spoke too soon.  The two tests that were failing for me are
> > now passing, but I can still create what looks like a related failure using
> > XFS, DAX, and the two xfstests generic/231 and generic/232 run back-to-back.
> 
> Hum, full xfstests run completes for me just fine. Can you reproduce the
> issue with the attached debug patch? Thanks!

Here's the resulting debug:

[  212.541923] Wrong node->count 244.
[  212.542316] Host sb pmem0p2 ino 2097257
[  212.542696] Node dump: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
