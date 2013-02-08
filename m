Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id BDE5C6B000A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 01:50:17 -0500 (EST)
Date: Fri, 8 Feb 2013 01:50:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] Comments and questions
Message-ID: <20130208065011.GA7511@cmpxchg.org>
References: <201301210343.r0L3h0rP030204@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301210343.r0L3h0rP030204@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org

On Mon, Jan 21, 2013 at 02:43:00PM +1100, paul.szabo@sydney.edu.au wrote:
> The setting of highmem_is_dirtyable seems used only to calculate limits
> and threshholds, not used in any decisions: seems odd.

That's okay.  We prefer placing page cache in highmem either way, this
flag is just about whether the amount of allowable dirty cache scales
with the amount of available lowmem or whether it scales with all of
memory, including highmem.  Per default we scale with the amount of
lowmem.  Because even though the user data can live in highmem, the
management of this data requires lowmem, so lowmem ends up being the
bottle neck.  The flag is for people that know how to set up their
systems such as not to exhaust lowmem and avoid OOM kills.

> [Subtraction of min_free_kbytes reported previously.]

This is fixed upstream with these two commits:

commit ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d
Author: Johannes Weiner <jweiner@redhat.com>
Date:   Tue Jan 10 15:07:42 2012 -0800

    mm: exclude reserved pages from dirtyable memory

commit c8b74c2f6604923de91f8aa6539f8bb934736754
Author: Sonny Rao <sonnyrao@chromium.org>
Date:   Thu Dec 20 15:05:07 2012 -0800

    mm: fix calculation of dirtyable memory

Since this was a conceptual fix and not based on actual bug reports,
it was never included in -stable kernels.  Unless I am mistaken, we
still do not have an actual bug report that demands for these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
