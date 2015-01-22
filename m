Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D42A96B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 19:22:15 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f12so34788243qad.10
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 16:22:15 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id c65si2390429qgc.124.2015.01.21.16.22.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 16:22:14 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id w8so35592364qac.3
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 16:22:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
	<20150114152225.GB31484@google.com>
	<20150114233630.GA14615@node.dhcp.inet.fi>
	<alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
Date: Thu, 22 Jan 2015 00:22:14 +0000
Message-ID: <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
From: Primiano Tucci <primiano@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Petr Cermak <petrcermak@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Jan 21, 2015 at 10:58 PM, David Rientjes <rientjes@google.com> wrote:
> I think the bigger concern would be that this, and any new line such as
> resettable_hiwater_rss, invalidates itself entirely.  Any process that
> checks the hwm will not know of other processes that reset it, so the
> value itself has no significance anymore.
>  It would just be the mark since the last clear at an unknown time.

How is that different from the current logic of clear_refs and the
corresponding PG_Referenced bit?

> Userspace can monitor the rss of a
> process by reading /proc/pid/stat, there's no need for the kernel to do
> something that userspace can do.

I disagree here. The driving motivation of this patch is precisely the
opposite. There are peak events that last for very short time (order:
10-100 ms) and are practically invisible from user-space (even doing
something awkward like polling in a tight loop). Concrete examples
are: GPU memory transfers, image decoding, compression /
decompression.
These kinds of tasks, which use scratch buffers for few ms, can create
significant (yet short lasting) memory pressure which is desirable to
monitor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
