Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F447900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:03:41 -0400 (EDT)
Date: Fri, 15 Apr 2011 18:59:16 +0300
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
	parameters
Message-ID: <20110415155916.GD7112@esdhcp04044.research.nokia.com>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com> <20110415145133.GO15707@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415145133.GO15707@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ext Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15/04/11 16:51 +0200, ext Andrea Arcangeli wrote:
> Hello Phil,
> 
> On Fri, Apr 15, 2011 at 12:56:16PM +0300, Phil Carmody wrote:
> > 
> > Sending this one its own as it either becomes an enabler for further
> > related patches, or if nacked, shuts the door on them. Better to test
> > the water before investing too much time on such things.
> > 
> > Whilst following a few static code analysis warnings, it became clear
> > that either the tool (which I believe is considered practically state of
> > the art) was very dumb when sniffing into called functions, or that a
> > simple const flag would either help it not make the incorrect paranoid
> > assumptions that it did, or help me dismiss the report as a false
> > positive more quickly.
> > 
> > Of course, this is core core code, and shouldn't be diddled with lightly,
> > but it's because it's core code that it's an enabler.
> > 
> > Awaiting the judgement of the Solomons,
> 
> What's the benefit of having it const other than shutdown the warnings
> from the static code analysis? I doubt gcc can generate any better
> output from this change because it's all inline anyway.

Yup, the only improvement occurs if there's an opaque layer between this
lower level code and a client that could benefit from making a const
assumption, and that opaque layer could also inherit/propagate the
constness.

> I guess the only chance this could help is if we call an extern
> function and we read the pointer before and after the external call,
> in that case gcc could assume the memory didn't change across the
> extern function and just cache the value in callee-saved register
> without having to re-read memory after the extern function
> returns. But there isn't any extern function there...

Yup, that direction's a dead end, but there is potential for clients of
clients. I'm unfortunately unable to find the example that prompted me
to look down this path, as it would depend on an as-yet-unwritten client
of these functions to propagate constness up another layer. It was
probably in FUSE, as that's the warning at the top of my screen
currently.

> I guess the static code analysis shouldn't suggest a const if it's all
> inline and gcc has full visibility on everything that is done inside
> those functions at build time.
> 
> But maybe I'm missing something gcc could do better with const that it
> can't now.

I think gcc itself is smart enough to have already concluded what it 
can and it will not immediately benefit the build from just this change.

I don't think the static analysis tools are as smart as gcc though, by
any means. GCC actually inlines, so everything is visible to it. The
static analysis tools only remember the subset of information that they
think is useful, and apparently 'didn't change anything, even though it 
could' isn't considered so useful.

I'm just glad this wasn't an insta-nack, as I am quite a fan of consts,
and hopefully something can be worked out.

Thanks for your input,
Phil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
