Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1167C6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:46:34 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so19055066wiw.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:46:33 -0800 (PST)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id o17si6257646wij.87.2015.01.15.08.46.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 08:46:33 -0800 (PST)
Received: by mail-wi0-f172.google.com with SMTP id n3so36330459wiv.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:46:32 -0800 (PST)
Date: Thu, 15 Jan 2015 16:46:25 +0000
From: Petr Cermak <petrcermak@chromium.org>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150115164625.GA11015@google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
 <20150114152225.GB31484@google.com>
 <20150114233954.GB14615@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114233954.GB14615@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Thu, Jan 15, 2015 at 01:36:30AM +0200, Kirill A. Shutemov wrote:
> On Wed, Jan 14, 2015 at 03:22:25PM +0000, Petr Cermak wrote:
> > On Wed, Jan 07, 2015 at 07:24:52PM +0200, Kirill A. Shutemov wrote:
> > > And how it's not an ABI break?
> > I don't think this is an ABI break because the current behaviour is not
> > changed unless you write "5" to /proc/pid/clear_refs. If you do, you are
> > explicitly requesting the new functionality.
> 
> I'm not sure if it should be considered ABI break or not. Just asking.
> 
> I would like to hear opinion from other people.

We would like to get more feedback as well.

> > > We have never-lowering VmHWM for 9+ years. How can you know that nobody
> > > expects this behaviour?
> > This is why we sent an RFC [1] several weeks ago. We expect this to be
> > used mainly by performance-related tools (e.g. profilers) and from the
> > comments in the code [2] VmHWM seems to be a best-effort counter. If this
> > is strictly a no-go, I can only think of the following two alternatives:
> > 
> >   1. Add an extra resettable field to /proc/pid/status (e.g.
> >      resettable_hiwater_rss). While this doesn't violate the current
> >      definition of VmHWM, it adds an extra line to /proc/pid/status,
> >      which I think is a much bigger issue.
> 
> I don't think extra line is bigger issue. Sane applications would look for
> a key, not line number. We do add lines there. I've posted patch which
> adds one more just today ;)

In that case, should we add an extra field to /proc/pid/status?

> >   2. Introduce a new proc fs file to task_mmu (e.g.
> >      /proc/pid/profiler_stats), but this feels like overengineering.
> 
> BTW, we have memory.max_usage_in_byte in memory cgroup. And it's resetable.
> Wouldn't it be enough for your profiling use-case?

This is a very interesting point, but it doesn't cover all use cases.
Our specific use case is memory profiling of the Chromium browser, but I
think that the same considerations below apply to any other use case
which involves child sub-processes:

  1. The process must be added to the control group explicitly by root.
     Hence, the Chromium process cannot do this itself.
  2. All forked children are implicitly grouped in the same control
     group. This is a problem because we want to be able to measure
     memory usage of the child processes separately.

The advantage of using clear_refs instead is that Chomium would be able
to profile its memory usage without any external intervention (as it's
already the case with performance profiling).

> > > And why do you reset hiwater_rss, but not hiwater_vm?
> > This is a good point. Should we reset both using the same flag, or
> > introduce a new one ("6")?
> > 
> > [1] lkml.iu.edu/hypermail/linux/kernel/1412.1/01877.html
> > [2] task_mmu.c:32: "... such snapshots can always be inconsistent."

Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
