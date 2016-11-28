Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35F186B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 20:46:34 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so17904788wjc.0
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 17:46:34 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 15si23740086wml.145.2016.11.27.17.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 17:46:32 -0800 (PST)
Date: Mon, 28 Nov 2016 01:45:10 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161128014510.GZ1555@ZenIV.linux.org.uk>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
 <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk>
 <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk>
 <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
 <20161127224208.GA31101@dastard>
 <CA+55aFwmCVZECoMszXZkJ8tSpG5+Ynt-5EKxKqDepNtjUv5vkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwmCVZECoMszXZkJ8tSpG5+Ynt-5EKxKqDepNtjUv5vkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Sun, Nov 27, 2016 at 04:58:43PM -0800, Linus Torvalds wrote:
> You are living in some unrealistic dream-world where you think you can
> get the right tracepoint on the first try.
> 
> So there is no way in hell I would ever mark any tracepoint "stable"
> until it has had a fair amount of use, and there are useful tools that
> actually make use of it, and it has shown itself to be the right
> trace-point.
> 
> And once that actually happens, what's the advantage of marking it
> stable? None. It's a catch-22. Before it has uses and has been tested
> and found to be good, it's not stable. And after, it's pointless.
> 
> So at no point does such a "stable" tracepoint marking make sense. At
> most, you end up adding a comment saying "this tracepoint is used by
> tools such-and-such".

I can't speak for Dave, but I suspect that it's more about "this, this and
that tracepoints are purely internal and we can and will change them whenever
we bloody feel like that; stick your fingers in those and they _will_ get
crushed".

Incidentally, take a look at
        trace_ocfs2_file_aio_read(inode, filp, filp->f_path.dentry,
                        (unsigned long long)OCFS2_I(inode)->ip_blkno,
                        filp->f_path.dentry->d_name.len,
                        filp->f_path.dentry->d_name.name,
                        to->nr_segs);   /* GRRRRR */
Note that there is nothing whatsoever protecting the use of ->d_name in
there (not that poking in iov_iter guts was a good idea).  Besides, suppose
something *did* grab a hold of that one a while ago.  What would we have
to do to avoid stepping on its toes every time when somebody call ocfs2
->splice_read(), which has recently started to go through ->read_iter()
calls?  Prepend something like if (!(to->type & ITER_PIPE)) to it?

I'm very tempted to just go and remove it, along with its analogues.
If nothing else, the use of ->d_name *is* racy, and while it might be
tolerable for occasional debugging, for anything in heavier use it's
asking for trouble...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
