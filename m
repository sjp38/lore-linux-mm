Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 969C86B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:24:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v20so3881348qtg.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:24:47 -0700 (PDT)
Received: from mail-qt0-f172.google.com (mail-qt0-f172.google.com. [209.85.216.172])
        by mx.google.com with ESMTPS id c12si535703qkg.20.2017.06.14.10.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 10:24:46 -0700 (PDT)
Received: by mail-qt0-f172.google.com with SMTP id u19so7946761qta.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:24:46 -0700 (PDT)
Message-ID: <1497461083.6752.7.camel@redhat.com>
Subject: Re: [PATCH v6 12/20] fs: add a new fstype flag to indicate how
 writeback errors are tracked
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 14 Jun 2017 13:24:43 -0400
In-Reply-To: <20170614064731.GB3598@infradead.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
	 <20170612122316.13244-15-jlayton@redhat.com>
	 <20170612124513.GC18360@infradead.org> <1497349472.5762.1.camel@redhat.com>
	 <20170614064731.GB3598@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Tue, 2017-06-13 at 23:47 -0700, Christoph Hellwig wrote:
> On Tue, Jun 13, 2017 at 06:24:32AM -0400, Jeff Layton wrote:
> > That's definitely what I want for the endgame here. My plan was to add
> > this flag for now, and then eventually reverse it (or drop it) once all
> > or most filesystems are converted.
> > 
> > We can do it that way from the get-go if you like. It'll mean tossing in
> >  a patch add this flag to all filesystems that have an fsync operation
> > and that use the pagecache, and then gradually remove it from them as we
> > convert them.
> > 
> > Which method do you prefer?
> 
> Please do it from the get-go.  Or in fact figure out if we can get
> away without it entirely.  Moving the error reporting into ->fsync
> should help greatly with that, so what's missing after that?

In this smaller set, it's only really used for DAX. In the larger patch
series I have (which needs updating on top of this), there are other
things that key off of it:

sync_file_range: ->fsync isn't called directly there, and I think we
probably want similar semantics to fsync() for it

JBD2: will try to re-set the error after clearing it with
filemap_fdatawait. That's problematic with the new infrastructure so we
need some way to avoid it.

What I think I'll do for now is add a new FS_DAX_WB_ERRSEQ flag that
will go away by the end of the series. As the need arises for a similar
flag in other areas, I'll add them then.

The overall goal is not to need these flags. It may take a bit of time
to get there though.

Thanks for the review so far!
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
