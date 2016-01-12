Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6F979680F81
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:20:43 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id mw1so121969636igb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:20:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160112011128.GC6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
	<80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
	<20160112011128.GC6033@dastard>
Date: Mon, 11 Jan 2016 17:20:42 -0800
Message-ID: <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 5:11 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Insufficient. Needs the range to be passed through and call
> vfs_fsync_range(), as I implemented here:

And I think that's insufficient *also*.

What you actually want is "sync_file_range()", with the full set of arguments.

Yes, really. Sometimes you want to start the writeback, sometimes you
want to wait for it. Sometimes you want both.

For example, if you are doing your own manual write-behind logic, it
is not sufficient for "wait for data". What you want is "start IO on
new data" followed by "wait for old data to have been written out".

I think this only strengthens my "stop with the idiotic
special-case-AIO magic already" argument.  If we want something more
generic than the usual aio, then we should go all in. Not "let's make
more limited special cases".

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
