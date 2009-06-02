Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA29B6B00BB
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:20:55 -0400 (EDT)
Date: Tue, 2 Jun 2009 09:14:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
Message-ID: <20090602071411.GE31556@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 02:50:29PM -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> Introduce the file_hotplug_lock to protect file->f_op, file->private,
> file->f_path from revoke operations.
> 
> The file_hotplug_lock is used typically as:
> error = -EIO;
> if (!file_hotplug_read_trylock(file))
> 	goto out;
> ....
> file_hotplug_read_unlock(file);

Why is it called hotplug? Does it have anything to do with hardware?
Because every concurrently changed software data structure in the
kernel can be "hot"-modified, right?

Wouldn't file_revoke_lock be more appropriate?


> In addition for a complete solution we need:
> - A reliable way the file structures that we need to revoke.
> - To wait for but not tamper with ongoing file creation and cleanup.
> - A guarantee that all with user space controlled duration are removed.
> 
> The file_hotplug_lock has a very unique implementation necessitated by
> the need to have no performance impact on existing code.  Classic locking

Well, it isn't no performance impact. Function calls, branches, icache
and dcache...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
