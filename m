Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 14D4E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 18:30:00 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so1007378pbc.33
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 15:29:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gx4si233991pbc.111.2014.01.28.15.29.58
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 15:29:58 -0800 (PST)
Date: Tue, 28 Jan 2014 15:29:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: slub: fix page->_count corruption (again)
Message-Id: <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org>
In-Reply-To: <20140128231722.E7387E6B@viggo.jf.intel.com>
References: <20140128231722.E7387E6B@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, pshelar@nicira.com

On Tue, 28 Jan 2014 15:17:22 -0800 Dave Hansen <dave@sr71.net> wrote:

> Commit abca7c496 notes that we can not _set_ a page->counters
> directly, except when using a real double-cmpxchg.  Doing so can
> lose updates to ->_count.
> 
> That an absolute rule:
> 
>         You may not *set* page->counters except via a cmpxchg.
> 
> Commit abca7c496 fixed this for the folks who have the slub
> cmpxchg_double code turned off at compile time, but it left the
> bad alone.  It can still be reached, and the same bug triggered
> in two cases:
> 1. Turning on slub debugging at runtime, which is available on
>    the distro kernels that I looked at.
> 2. On 64-bit CPUs with no CMPXCHG16B (some early AMD x86-64
>    cpus, evidently)
> 
> There are at least 3 ways we could fix this:
> 
> 1. Take all of the exising calls to cmpxchg_double_slab() and
>    __cmpxchg_double_slab() and convert them to take an old, new
>    and target 'struct page'.
> 2. Do (1), but with the newly-introduced 'slub_data'.
> 3. Do some magic inside the two cmpxchg...slab() functions to
>    pull the counters out of new_counters and only set those
>    fields in page->{inuse,frozen,objects}.

This code is borderline insane.

Yes, struct page is special and it's worth spending time and doing
weird things to optimise it.  But sheesh.

An alternative is to make that cmpxchg quietly go away.  Is it more
trouble than it is worth?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
