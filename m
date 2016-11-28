Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F26D06B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:33:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so35057412wms.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 00:33:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk10si53468118wjb.17.2016.11.28.00.33.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 00:33:31 -0800 (PST)
Date: Mon, 28 Nov 2016 09:33:27 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161128083327.GA2590@quack2.suse.cz>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
 <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk>
 <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk>
 <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
 <20161125214840.kexe5mj2yn4jtazi@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161125214840.kexe5mj2yn4jtazi@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>

On Fri 25-11-16 16:48:40, Ted Tso wrote:
> On Fri, Nov 25, 2016 at 11:51:26AM -0800, Linus Torvalds wrote:
> > We do have filesystem code that is just disgusting. As an example:
> > fs/afs/ tends to have these crazy "_enter()/_exit()" macros in every
> > single function. If you want that, use the function tracer. That seems
> > to be just debugging code that has been left around for others to
> > stumble over. I do *not* believe that we should encourage that kind of
> > "machine gun spray" use of tracepoints.
> 
> There is a reason why people want to be able to do that, and that's
> because kprobes doesn't give you access to the arguments and return
> codes to the functions.  Maybe there could be a way to do this more
> easily using DWARF information and EBPF magic, perhaps?  It won't help
> for inlined functions, of course, but most of the functions where
> people want to do this aren't generally functions which are going to
> be inlined, but rather things like write_begin, writepages, which are
> called via a struct ops table and so will never be inlined to begin
> with.

Actually, you can print register & stack contents from a kprobe and you can
get a function return value from a kretprobe (see
Documentation/trace/kprobetrace.txt). Since calling convention is fixed
(arg 1 in RDI, arg 2 in RSI...) you can relatively easily dump function
arguments on entry and dump return value on return for arbitrary function
of your choice. I was already debugging issues like that several times (in
VFS actually because of missing trace points ;)). You can even create a
kprobe to dump register contents in the middle of the function (although
there it takes more effort reading the dissasembly to see what you are
interested in).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
