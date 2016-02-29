Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D0A596B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 14:42:06 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so5901938wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:42:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w133si21773945wma.109.2016.02.29.11.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 11:42:05 -0800 (PST)
Date: Mon, 29 Feb 2016 14:41:59 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: readahead: do not cap readahead() and MADV_WILLNEED
Message-ID: <20160229194159.GB29896@cmpxchg.org>
References: <1456277927-12044-1-git-send-email-hannes@cmpxchg.org>
 <CA+55aFzQr-8fOfzA97nZd07L8EFRgXSLSorrw1xVm_KMYinfdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzQr-8fOfzA97nZd07L8EFRgXSLSorrw1xVm_KMYinfdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Tue, Feb 23, 2016 at 06:34:59PM -0800, Linus Torvalds wrote:
> Why do you think that "Just do what the user asked for" is obviously
> the right thing?

In our situation, we are trying to prime the cache for what we know
will be the definite workingset of the application. We don't care if
it maxes out the IO capacity, and we don't care if it throws out any
existing cache to accomplish the task. In fact, if you're sure about
the workingset, that is desired behavior. It's basically read(), but
without the pointless copying and waiting for completion.

One of the mistakes I made was to look only at the manpage, and not at
how readahead() is or has historically been used in the field.

One such usecase is warming the system during bootup, where system
software fires off readahead against all manner of libraries and
executables that are likely to be used. In that scenario the caller
really doesn't know for sure it's reading the right thing. And if not,
the optimistic readahead shouldn't vaccuum up all the resources and
interfere with the IO and memory demands of the *actual* workingset.

It seems that the optimistic readahead during bootup is being phased
out nowadays. Systemd took over with systemd-readahead, then dropped
it eventually citing lack of desired performance benefits and
relevance; there is another project called preload but it appears
defunct as well. For all we know, though, there still are people who
fire off optimistic readahead, and we can't regress them. Certainly
older or customized userspace still running bootup readahead, or maybe
comparable applications where workingsets are estimated by heuristics.

It's unfortunate, because I frankly doubt we ever got the "else" part,
the not-interfering-with-the-real-workload part, working anyway. The
fact that distros are moving away from it or that we ended up limiting
the window to near-ineffective levels seem to be a symptoms of that.
That means the facility is now stuck somewhere in between questionable
for optimistic readahead and not useful for reliable cache priming.

We can't really make it work for both cases as their requirements are
in direct conflict with each other. Lowering the limit from cache+free
to 128k was a regression for priming a big known workingset, but there
is also no point in going back now and risk regressing the other side.

So it appears best to add a new syscall with clearly defined semantics
to forcefully prime the cache.

That, or switch to read() from a separate thread for cache priming.

Hmm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
