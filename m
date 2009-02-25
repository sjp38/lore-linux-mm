Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D32796B00EB
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:55:05 -0500 (EST)
Date: Wed, 25 Feb 2009 17:55:01 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090225165501.GK22785@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de> <49A5750A.1080006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49A5750A.1080006@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Zach Brown <zach.brown@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Mark Fasheh <mfasheh@suse.com>, Sage Weil <sage@newdream.net>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 08:42:50AM -0800, Zach Brown wrote:
> Nick Piggin wrote:
> > I want to have the page be protected by page lock between page_mkwrite
> > notification to the filesystem, and the actual setting of the page
> > dirty. Do this by holding the page lock over page_mkwrite, and keep it
> > held until after set_page_dirty.
> 
> I fear that this will end up creating lock inversions with file systems
> who grab cross-node locks, which are ordered outside of the page lock,
> inside their ->page_mkwrite().  See ocfs2's call of ocfs2_inode_lock()
> from ocfs2_page_mkwrite().

Is ocfs2 immune to the races that get covered by this patch?

 
> In a sense, it's prepare_write() all over again.  Please don't call into
> file systems after having acquired the page lock.

It is very much an opt-out thing with page_mkwrite. The filesystem
if it thinks it is really smart can unlock the page if it likes. I'm
sure it will probably introduce some obscure race or another, but hey ;)


> Instead, can we get a helper that the file system would call after
> having acquired its locks and the page lock?  Something like that.

Well, the critical part is holding the same page lock over the
"important" part of the page_mkwrite operation and setting the
pte dirty and marking the page dirty. So there isn't really a
helper it can call.

Hmm, actually possibly we can enter page_mkwrite with the page unlocked,
but exit with the page locked? Slightly more complex, but should save
complexity elsewhere. Yes I think this might be the best way to go.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
