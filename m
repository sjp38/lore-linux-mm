Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id E5F186B025E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 22:03:25 -0400 (EDT)
Received: by mail-io0-f180.google.com with SMTP id 124so24928124iov.3
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 19:03:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160320015511.GZ17997@ZenIV.linux.org.uk>
References: <20160120195957.GV6033@dastard>
	<CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
	<20160120204449.GC12249@kvack.org>
	<20160120214546.GX6033@dastard>
	<CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
	<20160123043922.GF6033@dastard>
	<20160314171737.GK17923@kvack.org>
	<CA+55aFx7JJdYNWRSs6Nbm_xyQjgUVoBQh=RuNDeavKS1Jr+-ow@mail.gmail.com>
	<20160320012610.GX17997@ZenIV.linux.org.uk>
	<CA+55aFxW9iWji3hd2PVWoMGeG1O3L5eYPgABEFtU3Cs7vpqXXg@mail.gmail.com>
	<20160320015511.GZ17997@ZenIV.linux.org.uk>
Date: Sat, 19 Mar 2016 19:03:25 -0700
Message-ID: <CA+55aFzabMmLzkOJ8+Jm2F43cubwbfMQdrm_YjG8HeP06ppUtg@mail.gmail.com>
Subject: Re: aio openat Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Sat, Mar 19, 2016 at 6:55 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> What would make unlazy_walk() fail?  And if it succeeds, you are not
> in RCU mode anymore *without* restarting from scratch...

I don't see your point.

You don't want to be in RCU mode any more. You want to either succeed
or fail with ECHILD/ESTALE. Then, in the failure case, you go to the
thread.

What I meant by restarting was the restart that do_filp_open() does,
and there it just restarts with "op->lookup_flags", which has
RCU_LOOKUP still set, so it would just try to do the RCU lookup again.

But I actually notice now that Ben actually disabled that restart if
LOOKUP_RCU was set, so that ends up not even happening.

Anyway, I'm not saying it's polished and pretty. I think the changes
to do_filp_open() are a bit silly, and the code should just use
path_openat() directly. Possibly using a new helper (ie perhaps just
introduce a "rcu_filp_openat()" thing). But from a design perspective,
I think this all looks fine.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
