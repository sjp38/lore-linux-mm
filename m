Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f206.google.com (mail-ob0-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 34AE66B0031
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 14:39:31 -0500 (EST)
Received: by mail-ob0-f206.google.com with SMTP id vb8so99902obc.5
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 11:39:30 -0800 (PST)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id ql3si3485829bkb.110.2014.01.24.07.44.23
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 07:44:23 -0800 (PST)
Date: Fri, 24 Jan 2014 09:44:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
In-Reply-To: <20140124110928.GR4963@suse.de>
Message-ID: <alpine.DEB.2.10.1401240941190.12665@nuc>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com> <20140122093435.GS4963@suse.de> <alpine.DEB.2.10.1401231436300.8031@nuc> <20140124110928.GR4963@suse.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ric Wheeler <rwheeler@redhat.com>, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, 24 Jan 2014, Mel Gorman wrote:

> That'd be okish for 64-bit at least although it would show up as
> degraded performance in some cases when virtually contiguous buffers were
> used. Aside from the higher setup, access costs and teardown costs of a
> virtual contiguous buffer, the underlying storage would no longer gets
> a single buffer as part of the IO request. Would that not offset many of
> the advantages?

It would offset some of that. But the major benefit of large order page
cache was the reduction of the number of operations that the kernel has to
perform. A 64k page contains 16 4k pages. So there is only one kernel
operation required instead of 16. If the page is virtually allocated then
the higher level kernel functions still only operate on one page struct.
The lower levels (bio) then will have to deal with the virtuall mappings
and create a scatter gather list. This is some more overhead but not much.

Doing something like this will put more stress on the defragmentation
logic in the kernel. In general I think we need more contiguous physical
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
