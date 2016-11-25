Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC8FE6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 18:38:43 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t93so143283991ioi.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 15:38:43 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 66si34316037iod.85.2016.11.25.15.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 15:38:43 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id r94so12015943ioe.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 15:38:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161125214840.kexe5mj2yn4jtazi@thunk.org>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk> <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk> <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk> <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
 <20161125214840.kexe5mj2yn4jtazi@thunk.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Nov 2016 15:38:41 -0800
Message-ID: <CA+55aFyF_J-ib9W6FVfzeWOmYY0i_pAZcm3gRs-p9KD-j_WEdw@mail.gmail.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>

On Fri, Nov 25, 2016 at 1:48 PM, Theodore Ts'o <tytso@mit.edu> wrote:
>
> There is a reason why people want to be able to do that, and that's
> because kprobes doesn't give you access to the arguments and return
> codes to the functions.

Honestly, that's simply not a good reason.

What if everybody did this? Do we pollute the whole kernel with this crap? No.

And if not, then what's so special about something like afs that it
would make sense there?

The thing is, with function tracing, you *can* get the return value
and arguments. Sure, you'll probably need to write eBPF and just
attach it to that fentry call point, and yes, if something is inlined
you're just screwed, but Christ, if you do debugging that way you
shouldn't be writing kernel code in the first place.

If you cannot do filesystem debugging without tracing every single
function entry, you are doing something seriously wrong. Add a couple
of relevant and valid trace points to get the initial arguments etc
(and perhaps to turn on the function tracing going down the stack).

> After all, we need *some* way of saying this can never be considered
> stable.

Oh, if you pollute the kernel with random idiotic trace points, not
only are they not going to be considered stable, after a while people
should stop pulling from you.

I do think we should probably add a few generic VFS level breakpoints
to make it easier for people to catch the arguments they get from the
VFS layer (not every system call - if you're a filesystem person, you
_shouldn't_ care about all the stuff that the VFS layer caches for you
so that you never even have to see it). I do think that Al's "no trace
points what-so-ever" is too strict.

But I think a lot of people add complete crap with the "maybe it's
needed some day" kind of mentality.

The tracepoints should have a good _specific_ reason, and they should
make sense. Not be randomly sprinkled "just because".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
