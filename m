Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C25B66B016B
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:26:13 -0400 (EDT)
Date: Wed, 10 Aug 2011 06:26:04 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/2] fuse: delete dead .write_begin and .write_end aops
Message-ID: <20110810102604.GB6117@infradead.org>
References: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
 <20110725204942.GA12183@infradead.org>
 <87aabkeyfj.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87aabkeyfj.fsf@tucsk.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, fuse-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 08, 2011 at 05:05:20PM +0200, Miklos Szeredi wrote:
> > The loop code still calls them uncondtionally.  This actually is a big
> > as write_begin and write_end require filesystems specific locking,
> > and might require code in the filesystem to e.g. update the ctime
> > properly.  I'll let Miklos chime in if leaving them in was intentional,
> > and if it was a comment is probably justified.
> 
> Loop checks for ->write_begin() and falls back to ->write if the former
> isn't defined.
> 
> So I think the patch is fine.  I tested loop over fuse, and it still
> works after the patch.

It works, but it involves another data copy, which will slow down
various workloads that people at least historically cared about.

And yes, unconditionally above was wrong - calls them if present without
taking care of filesystem specific locking would be the right term.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
