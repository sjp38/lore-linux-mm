Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 040046B0055
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 05:03:42 -0400 (EDT)
In-reply-to: <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
Message-Id: <E1MCVKj-0007O3-Rp@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 05 Jun 2009 11:03:29 +0200
Sender: owner-linux-mm@kvack.org
To: ebiederm@xmission.com
Cc: viro@ZenIV.linux.org.uk, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org, ebiederm@aristanetworks.com
List-ID: <linux-mm.kvack.org>

Hi Eric,

Very interesting work.

On Mon,  1 Jun 2009, Eric W. Biederman wrote:
> The file_hotplug_lock has a very unique implementation necessitated by
> the need to have no performance impact on existing code.  Classic locking
> primitives and reference counting cause pipeline stalls, except for rcu
> which provides no ability to preventing reading a data structure while
> it is being updated.

Well, the simple solution to that is to add another level of indirection:

old:

  fdtable -> file

new:

  fdtable -> persistent_file -> file

Then it is possible to replace persistent_file->file with a revoked
one under RCU.  This has the added advantage that it supports
arbitrary file replacements, not just ones which return EIO.

Another advantage is that dereferencing can normally be done "under
the hood" in fget()/fget_light().  Only code which wants to
permanently store a file pointer (like the SCM_RIGHTS thing) would
need to be aware of the extra complexity.

Would that work, do you think?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
