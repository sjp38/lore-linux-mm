Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72C716B05E1
	for <linux-mm@kvack.org>; Fri, 18 May 2018 11:49:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v26-v6so3044346pgc.14
        for <linux-mm@kvack.org>; Fri, 18 May 2018 08:49:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 133-v6sor196640pgh.117.2018.05.18.08.49.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 08:49:46 -0700 (PDT)
Date: Fri, 18 May 2018 09:49:45 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
Message-ID: <20180518154945.GC15611@ziepe.ca>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Fri, May 18, 2018 at 02:37:52PM +0000, Christopher Lameter wrote:
> There was a session at the Linux Filesystem and Memory Management summit
> on issues that are caused by devices using get_user_pages() or elevated
> refcounts to pin pages and then do I/O on them.
> 
> See https://lwn.net/Articles/753027/
> 
> Basically filesystems need to mark the pages readonly during writeback.
> Concurrent DMA into the page while it is written by a filesystem can cause
> corrupted data being written to the disk, cause incorrect checksums etc
> etc.
> 
> The solution that was proposed at the meeting was that mmu notifiers can
> remedy that situation by allowing callbacks to the RDMA device to ensure
> that the RDMA device and the filesystem do not do concurrent writeback.

This keeps coming up, and I understand why it seems appealing from the
MM side, but the reality is that very little RDMA hardware supports
this, and it carries with it a fairly big performance penalty so many
users don't like using it.

> This issue has been around for a long time and so far not caused too much
> grief it seems. Doing I/O to two devices from the same memory location is
> naturally a bit inconsistent in itself.

Well, I've seen various reports of FS's oopsing and what not, as the
LWN article points out.. So it is breaking stuff for some users.

> But could we do more to prevent issues here? I think what may be useful is
> to not allow the memory registrations of file back writable mappings
> unless the device driver provides mmu callbacks or something like that.

Why does every proposed solution to this involve crippling RDMA? Are
there really no ideas no ideas to allow the FS side to accommodate
this use case??

> There may even be more issues if DAX is being used but the FS writeback
> has the potential of biting anyone at this point it seems.

I think Dan already 'solved' this via get_user_pages_longterm which
just fails for DAX backed pages.

Jason
