Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0111E4403DC
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 21:24:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o88so582233wrb.18
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 18:24:55 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 194si2422688wmv.166.2017.11.07.18.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 18:24:54 -0800 (PST)
Date: Wed, 8 Nov 2017 02:24:49 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] vfs: remove might_sleep() from clear_inode()
Message-ID: <20171108022448.GW21978@ZenIV.linux.org.uk>
References: <20171108004354.40308-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108004354.40308-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 07, 2017 at 04:43:54PM -0800, Shakeel Butt wrote:
> Commit 7994e6f72543 ("vfs: Move waiting for inode writeback from
> end_writeback() to evict_inode()") removed inode_sync_wait() from
> end_writeback() and commit dbd5768f87ff ("vfs: Rename end_writeback()
> to clear_inode()") renamed end_writeback() to clear_inode(). After
> these patches there is no sleeping operation in clear_inode(). So,
> remove might_sleep() from it.

Point, but... this is far from the worst annoyance in clear_inode().
Starting with "BUG_ON() under spin_lock_irq() is antisocial and
not in a good way", of course, but that's not all - the whole
cycling of ->tree_lock has already been done back in
truncate_inode_pages_final() and we'd better have called that
in all cases when ->i_data might have ever contained anything.

The whole thing looks bogus these days...  I wonder if we should
simply move the remaining paranoia into destroy_inode() and get
rid of the I_CLEAR completely...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
