Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 50ED26B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 04:14:53 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so2567520dae.35
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 01:14:52 -0800 (PST)
Date: Mon, 4 Feb 2013 17:29:06 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [PATCH 0/6 RFC] Mapping range lock
Message-ID: <20130204092906.GA7503@gmail.com>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <20130131160757.06d7f1c2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130131160757.06d7f1c2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 31, 2013 at 04:07:57PM -0800, Andrew Morton wrote:
[snip]
> > c) i_mutex doesn't allow any paralellism of operations using it and some
> >    filesystems workaround this for specific cases (e.g. DIO reads). Using
> >    range locking allows for concurrent operations (e.g. writes, DIO) on
> >    different parts of the file. Of course, range locking itself isn't
> >    enough to make the parallelism possible. Filesystems still have to
> >    somehow deal with the concurrency when manipulating inode allocation
> >    data. But the range locking at least provides a common VFS mechanism for
> >    serialization VFS itself needs and it's upto each filesystem to
> >    serialize more if it needs to.
> 
> That would be useful to end-users, but I'm having trouble predicting
> *how* useful.

Hello Andrew,

I believe this would be useful for the end-user, at least for dio user, e.g.
database.  Now when we want to issue a direct io, i_mutex will serialize
concurrent reader/writer.  Some filesystems (xfs and ext4) try not to take
this locking in some conditions to improve the performance, especially for the
latency, because we don't need to wait on this locking.  But there are still
some cases that need to take it.  So range locking can make us reduce the
contention as far as possible.

Regards,
						- Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
