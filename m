Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB9F6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 18:36:36 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so11867114wgh.8
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 15:36:35 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id fq5si6348494wib.55.2015.01.14.15.36.35
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 15:36:35 -0800 (PST)
Date: Thu, 15 Jan 2015 01:36:30 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150114233630.GA14615@node.dhcp.inet.fi>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
 <20150114152225.GB31484@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114152225.GB31484@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Wed, Jan 14, 2015 at 03:22:25PM +0000, Petr Cermak wrote:
> On Wed, Jan 07, 2015 at 07:24:52PM +0200, Kirill A. Shutemov wrote:
> > And how it's not an ABI break?
> I don't think this is an ABI break because the current behaviour is not
> changed unless you write "5" to /proc/pid/clear_refs. If you do, you are
> explicitly requesting the new functionality.

I'm not sure if it should be considered ABI break or not. Just asking.

I would like to hear opinion from other people.
 
> > We have never-lowering VmHWM for 9+ years. How can you know that nobody
> > expects this behaviour?
> This is why we sent an RFC [1] several weeks ago. We expect this to be
> used mainly by performance-related tools (e.g. profilers) and from the
> comments in the code [2] VmHWM seems to be a best-effort counter. If this
> is strictly a no-go, I can only think of the following two alternatives:
> 
>   1. Add an extra resettable field to /proc/pid/status (e.g.
>      resettable_hiwater_rss). While this doesn't violate the current
>      definition of VmHWM, it adds an extra line to /proc/pid/status,
>      which I think is a much bigger issue.

I don't think extra line is bigger issue. Sane applications would look for
a key, not line number. We do add lines there. I've posted patch which
adds one more just today ;)

>   2. Introduce a new proc fs file to task_mmu (e.g.
>      /proc/pid/profiler_stats), but this feels like overengineering.
> 
> > And why do you reset hiwater_rss, but not hiwater_vm?
> This is a good point. Should we reset both using the same flag, or
> introduce a new one ("6")?
> 
> [1] lkml.iu.edu/hypermail/linux/kernel/1412.1/01877.html
> [2] task_mmu.c:32: "... such snapshots can always be inconsistent."
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
