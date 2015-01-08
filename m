Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BE59A6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 06:49:53 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so10809467pdb.5
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 03:49:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ib3si8035257pbb.224.2015.01.08.03.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 03:49:52 -0800 (PST)
Date: Thu, 8 Jan 2015 03:49:50 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: pread2/ pwrite2
Message-ID: <20150108114950.GB3351@infradead.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org>
 <20141210141211.GD2220@wil.cx>
 <20150105184143.GA665@infradead.org>
 <20150106004714.6d63023c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150106004714.6d63023c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Milosz Tanski <milosz@adfin.com>

On Tue, Jan 06, 2015 at 12:47:14AM -0800, Andrew Morton wrote:
> > progress, which is a bit frustrating.
> 
> I took a look at pread2() as well and I have two main issues:
> 
> - The patchset includes a pwrite2() syscall which has nothing to do
>   with nonblocking reads and which was poorly described and had little
>   justification for inclusion.

It allows to do O_SYNC writes on a per-I/O basis.  This is very useful
for file servers (smb, cifs) as well as storage target devices.

Note: that part was my addition, and the complaint about lacking
description ever made it to me.  Can you point to the relevant
questions?

> - We've talked for years about implementing this via fincore+pread
>   and at least two fincore implementations are floating about.  Now
>   along comes pread2() which does it all in one hit.
> 
>   Which approach is best?  I expect fincore+pread is simpler, more
>   flexible and more maintainable.  But pread2() will have lower CPU
>   consumption and lower average-case latency.

fincore+pread is inherently racy and thus entirely unsuitable for the
use case of a non-blockign main thread.

Nevermind that the pread2 path is way simpler than any of the proposed
fincore patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
