Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4286B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:14:47 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so1134091pab.12
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:14:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x13si4196394pdk.119.2014.10.24.06.14.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 06:14:46 -0700 (PDT)
Date: Fri, 24 Oct 2014 15:14:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141024131440.GZ21513@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
 <20141021170948.GA25964@node.dhcp.inet.fi>
 <20141021175603.GI3219@twins.programming.kicks-ass.net>
 <5448DB05.5050803@cn.fujitsu.com>
 <20141023110438.GQ21513@worktop.programming.kicks-ass.net>
 <20141024075423.GA24479@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141024075423.GA24479@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 24, 2014 at 09:54:23AM +0200, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Thu, Oct 23, 2014 at 06:40:05PM +0800, Lai Jiangshan wrote:
> > > On 10/22/2014 01:56 AM, Peter Zijlstra wrote:
> > > > On Tue, Oct 21, 2014 at 08:09:48PM +0300, Kirill A. Shutemov wrote:
> > > >> It would be interesting to see if the patchset affects non-condended case.
> > > >> Like a one-threaded workload.
> > > > 
> > > > It does, and not in a good way, I'll have to look at that... :/
> > > 
> > > Maybe it is blamed to find_vma_srcu() that it doesn't take the advantage of
> > > the vmacache_find() and cause more cache-misses.
> > 
> > Its what I thought initially, I tried doing perf record with and
> > without, but then I ran into perf diff not quite working for me and I've
> > yet to find time to kick that thing into shape.
> 
> Might be the 'perf diff' regression fixed by this:
> 
>   9ab1f50876db perf diff: Add missing hists__init() call at tool start
> 
> I just pushed it out into tip:master.

I was on tip/master, so unlikely to be that as I was likely already
having it.

perf-report was affected too, for some reason my CONFIG_DEBUG_INFO=y
vmlinux wasn't showing symbols (and I double checked that KASLR crap was
disabled, so that wasn't confusing stuff either).

When I forced perf-report to use kallsyms it works, however perf-diff
doesn't have that option.

So there's two issues there, 1) perf-report failing to generate useful
output and 2) per-diff lacking options to force it to behave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
