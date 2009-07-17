Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4016B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:09:22 -0400 (EDT)
Date: Fri, 17 Jul 2009 11:09:22 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: xfs mr_lock vs mmap_sem lock inversion?
Message-ID: <20090717150922.GA434@infradead.org>
References: <1247580955.7500.97.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247580955.7500.97.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


It's a problem in the VM code, which we already discussed a while
ago.  The problem is that the VMA manipultation code calls fput
under the mmap_sem, while we can take mmap_sem ue to a page fault
from inside generic_file_aio_read/write.  So any filesystem
that nees the same lock held over read/write also in release is
crewed.

Now on the positive side I think we can actually get rid of taking
the iolock in ->release in XFS, but I'm sure other filesystems
might continue hitting similar issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
