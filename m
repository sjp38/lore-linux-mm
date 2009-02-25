Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F40CF6B00E8
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:42:54 -0500 (EST)
Message-ID: <49A5750A.1080006@oracle.com>
Date: Wed, 25 Feb 2009 08:42:50 -0800
From: Zach Brown <zach.brown@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
References: <20090225093629.GD22785@wotan.suse.de>
In-Reply-To: <20090225093629.GD22785@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Mark Fasheh <mfasheh@suse.com>, Sage Weil <sage@newdream.net>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> I want to have the page be protected by page lock between page_mkwrite
> notification to the filesystem, and the actual setting of the page
> dirty. Do this by holding the page lock over page_mkwrite, and keep it
> held until after set_page_dirty.

I fear that this will end up creating lock inversions with file systems
who grab cross-node locks, which are ordered outside of the page lock,
inside their ->page_mkwrite().  See ocfs2's call of ocfs2_inode_lock()
from ocfs2_page_mkwrite().

In a sense, it's prepare_write() all over again.  Please don't call into
file systems after having acquired the page lock.

Instead, can we get a helper that the file system would call after
having acquired its locks and the page lock?  Something like that.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
