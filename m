Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 595C16B006E
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 10:42:09 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so9912819pdi.21
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 07:42:09 -0800 (PST)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com. [209.85.220.46])
        by mx.google.com with ESMTPS id w6si14439311pdo.135.2014.12.15.07.42.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 07:42:07 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so11453197pab.33
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 07:42:07 -0800 (PST)
Date: Mon, 15 Dec 2014 07:42:03 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 1/8] nfs: follow direct I/O write locking convention
Message-ID: <20141215154203.GA20161@mew>
References: <cover.1418618044.git.osandov@osandov.com>
 <7561c096c7de603ac39fcfcff7bd2ec80589cae1.1418618044.git.osandov@osandov.com>
 <CAABAsM4jMcox1emR1nSxORUOPNMDYmCcmMD4YymJ9R_BM_UU4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAABAsM4jMcox1emR1nSxORUOPNMDYmCcmMD4YymJ9R_BM_UU4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 15, 2014 at 07:49:20AM -0500, Trond Myklebust wrote:
> On Mon, Dec 15, 2014 at 12:26 AM, Omar Sandoval <osandov@osandov.com> wrote:
> > The generic callers of direct_IO lock i_mutex before doing a write. NFS
> > doesn't use the generic write code, so it doesn't follow this
> > convention. This is now a problem because the interface introduced for
> > swap-over-NFS calls direct_IO for a write without holding i_mutex, but
> > other implementations of direct_IO will expect to have it locked.
> 
> I really don't care much about swap-over-NFS performance; that's a
> niche usage at best. I _do_ care about O_DIRECT performance, and the
> ability to run multiple WRITE calls in parallel.
> 
> IOW: Patch NACKed... Please find another solution.
> 
> Trond

So the patch formatting doesn't make it completely clear what's going on
here, but here's what the original nfs_file_direct_write code did:

- called with i_mutex unlocked
- collects stats and does some generic checks
- locks i_mutex
- syncs the mapping, schedules the write
- unlocks i_mutex
- waits for the write to complete if synchronous

After this patch, nfs_file_direct_write works like:

- called with i_mutex locked
- collects stats and does some generic checks
- syncs the mapping, schedules the write
- drops i_mutex
- waits for the write to complete if synchronous
- picks i_mutex back up

There's an extra lock and unlock as a result and a slightly longer
critical section, but we drop i_mutex to wait for the write, so multiple
writes still work in parallel.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
