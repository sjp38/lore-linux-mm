Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6C786B0038
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 17:42:13 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so190499007pfy.2
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 14:42:13 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id 23si52822861pfy.91.2016.11.27.14.42.11
        for <linux-mm@kvack.org>;
        Sun, 27 Nov 2016 14:42:12 -0800 (PST)
Date: Mon, 28 Nov 2016 09:42:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161127224208.GA31101@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
 <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk>
 <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk>
 <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Fri, Nov 25, 2016 at 11:51:26AM -0800, Linus Torvalds wrote:
> On Thu, Nov 24, 2016 at 11:37 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > My impression is that nobody (at least kernel-side) wants them to be
> > a stable ABI, so long as nobody in userland screams about their code
> > being broken, everything is fine.  As usual, if nobody notices an ABI
> > change, it hasn't happened.  The question is what happens when somebody
> > does.
> 
> Right. There is basically _no_ "stable API" for the kernel anywhere,
> it's just an issue of "you can't break workflow for normal people".
> 
> And if somebody writes his own trace scripts, and some random trace
> point goes away (or changes semantics), that's easy: he can just fix
> his script. Tracepoints aren't ever going to be stable in that sense.
> 
> But when then somebody writes a trace script that is so useful that
> distros pick it up, and people start using it and depending on it,
> then _that_ trace point may well have become effectively locked in
> stone.

And that's exactly why we need a method of marking tracepoints as
stable. How else are we going to know whether a specific tracepoint
is stable if the kernel code doesn't document that it's stable? And
how are we going to know why it's considered stable if there isn't a
commit message that explains why it was made stable?

> We do have filesystem code that is just disgusting. As an example:
> fs/afs/ tends to have these crazy "_enter()/_exit()" macros in every
> single function. If you want that, use the function tracer. That seems
> to be just debugging code that has been left around for others to
> stumble over. I do *not* believe that we should encourage that kind of
> "machine gun spray" use of tracepoints.

Inappropriate use of tracepoints is a different problem. The issue
here is getting rid of the uncertainty caused by the handwavy
"tracepoints a mutable until someone, somewhere decides to use it in
userspace" policy.

> But tracing actual high-level things like IO and faults? I think that
> makes perfect sense, as long as the data that is collected is also the
> actual event data, and not so much a random implementation issue of
> the day.

IME, a tracepoint that doesn't expose detailed context specific
information isn't really useful for complex problem diagnosis...

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
