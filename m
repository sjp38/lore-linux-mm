Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE3D6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 10:22:30 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id gd6so8715665lab.3
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:22:29 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id m5si26755884wiy.53.2015.01.14.07.22.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 07:22:29 -0800 (PST)
Received: by mail-wi0-f182.google.com with SMTP id h11so11573534wiw.3
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:22:28 -0800 (PST)
Date: Wed, 14 Jan 2015 15:22:25 +0000
From: Petr Cermak <petrcermak@chromium.org>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-ID: <20150114152225.GB31484@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107172452.GA7922@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Hugh Dickins <hughd@google.com>

On Wed, Jan 07, 2015 at 07:24:52PM +0200, Kirill A. Shutemov wrote:
> And how it's not an ABI break?
I don't think this is an ABI break because the current behaviour is not
changed unless you write "5" to /proc/pid/clear_refs. If you do, you are
explicitly requesting the new functionality.

> We have never-lowering VmHWM for 9+ years. How can you know that nobody
> expects this behaviour?
This is why we sent an RFC [1] several weeks ago. We expect this to be
used mainly by performance-related tools (e.g. profilers) and from the
comments in the code [2] VmHWM seems to be a best-effort counter. If this
is strictly a no-go, I can only think of the following two alternatives:

  1. Add an extra resettable field to /proc/pid/status (e.g.
     resettable_hiwater_rss). While this doesn't violate the current
     definition of VmHWM, it adds an extra line to /proc/pid/status,
     which I think is a much bigger issue.
  2. Introduce a new proc fs file to task_mmu (e.g.
     /proc/pid/profiler_stats), but this feels like overengineering.

> And why do you reset hiwater_rss, but not hiwater_vm?
This is a good point. Should we reset both using the same flag, or
introduce a new one ("6")?

[1] lkml.iu.edu/hypermail/linux/kernel/1412.1/01877.html
[2] task_mmu.c:32: "... such snapshots can always be inconsistent."

Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
