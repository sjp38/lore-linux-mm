Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 197426B0253
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 21:45:20 -0400 (EDT)
Received: by mail-io0-f179.google.com with SMTP id m184so177035607iof.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:45:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160320012610.GX17997@ZenIV.linux.org.uk>
References: <20160115202131.GH6330@kvack.org>
	<CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
	<20160120195957.GV6033@dastard>
	<CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
	<20160120204449.GC12249@kvack.org>
	<20160120214546.GX6033@dastard>
	<CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
	<20160123043922.GF6033@dastard>
	<20160314171737.GK17923@kvack.org>
	<CA+55aFx7JJdYNWRSs6Nbm_xyQjgUVoBQh=RuNDeavKS1Jr+-ow@mail.gmail.com>
	<20160320012610.GX17997@ZenIV.linux.org.uk>
Date: Sat, 19 Mar 2016 18:45:19 -0700
Message-ID: <CA+55aFxW9iWji3hd2PVWoMGeG1O3L5eYPgABEFtU3Cs7vpqXXg@mail.gmail.com>
Subject: Re: aio openat Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Sat, Mar 19, 2016 at 6:26 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Umm...  You do realize that LOOKUP_RCU in flags does *NOT* guarantee that
> it won't block, right?  At the very least one would need to refuse to
> fall back on non-RCU mode without a full restart.

It actually does seem to do that, although in an admittedly rather
questionable way.

I think it should use path_openat() rather than do_filp_open(), but
passing in LOOKUP_RCU to do_filp_open() actually does work: it just
means that the retry after ECHILD/ESTALE will just do it *again* with
LOOKUP_RCU. It won't fall back to non-rcu mode, it just won't or in
the LOOKUP_RCU flag that is already set.

So I agree that it should be cleaned up, but the basic model seems
fine. I'm sure you're right about do_last() not necessarily being the
best place either. But that doesn't really change that the approach
seems *much* better than the old unconditional "do in a work queue".

Also, the whole "no guarantees of never blocking" is a specious argument.

Just copying the iocb from user space can block. Copying the pathname
likewise (or copying the iovec in the case of reads and writes). So
the aio interface at no point is "guaranteed to never block". Blocking
will happen. You can block on allocating the "struct file", or on
extending the filp table.

In the end it's about _performance_, and if the performance is better
with very unlikely blocking synchronous calls, then that's the right
thing to do.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
