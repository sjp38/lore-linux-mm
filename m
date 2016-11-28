Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 696AA6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:09:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so204586312pfv.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:09:28 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id k79si54301121pfj.2.2016.11.28.01.09.26
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 01:09:27 -0800 (PST)
Date: Mon, 28 Nov 2016 20:09:23 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161128090923.GB31101@dastard>
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
Cc: Al Viro <viro@zeniv.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Sun, Nov 27, 2016 at 04:58:43PM -0800, Linus Torvalds wrote:
> On Sun, Nov 27, 2016 at 2:42 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > And that's exactly why we need a method of marking tracepoints as
> > stable. How else are we going to know whether a specific tracepoint
> > is stable if the kernel code doesn't document that it's stable?
> 
> You are living in some unrealistic dream-world where you think you can
> get the right tracepoint on the first try.

No, I'm  under no illusions that we'd get stable tracepoints right
the first go. I don't care about how we stabilise stable
tracepoints, because nothing I maintain will use stable tracepoints.
However, I will point out that we have /already solved these ABI
development problems/.

$ ls Documentation/ABI/
obsolete  README  removed  stable  testing
$

Expands this to include stable tracepoints, not just sysfs files.
New stable stuff gets classified as "testing" meaning it is supposed
to be stable but may change before being declared officially stable.
"stable" is obvious, are "obsolete" and "removed".


> So there is no way in hell I would ever mark any tracepoint "stable"
> until it has had a fair amount of use, and there are useful tools that
> actually make use of it, and it has shown itself to be the right
> trace-point.
> 
> And once that actually happens, what's the advantage of marking it
> stable? None. It's a catch-22. Before it has uses and has been tested
> and found to be good, it's not stable. And after, it's pointless.

And that "catch-22" is *precisely the problem we need to solve*.

Pointing out that there's a catch-22 doesn't help anyone - all the
developers that are telling you that they really need a way to mark
stable tracepoints already understand this catch-22 and they want a
way to avoid it.  Being able to either say "this is stable and we'll
support it forever" or "this will never be stable so use at your own
risk" is a simple way of avoiding the catch-22. If an unstable
tracepoint is useful to applications *and it can be implemented in a
maintainable, stable form* then it can go through the process of
being made stable and documented in Documentation/ABI/stable.

Problem is solved, catch-22 is gone.

All we want is some method of making a clear, unambiguous statement
about the nature of a specific tracepoint and a process for
transitioning a tracepoint to a stable, maintainable form. We do it
for other ABI interfaces, so why can't we do this for tracepoints?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
