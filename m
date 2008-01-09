Date: Wed, 9 Jan 2008 13:22:28 +0100
From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
Message-ID: <20080109122228.GG25527@unthought.net>
References: <1199728459.26463.11.camel@codedot> <4df4ef0c0801090332y345ccb67se98409edc65fd6bf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4df4ef0c0801090332y345ccb67se98409edc65fd6bf@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, joe@evalesco.com
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 02:32:53PM +0300, Anton Salikhmetov wrote:
...
> 
> This bug causes backup systems to *miss* changed files.
> 

This problem is seen with both Amanda and TSM (Tivoli Storage Manager).

A site running Amanda with, say, a full backup weekly and incremental backups
daily, will only get weekly backups of their mmap modified databases.

However, large sites running TSM will be hit even harder by this because TSM
will always perform incremental backups from the client (managing which
versions to keep for how long on the server side). TSM will *never* again take
a backup of the mmap modified database.

The really nasty part is; nothing is failing. Everything *appears* to work.
Your data is just not backed up because it appears to be untouched.

So, if you run TSM (or pretty much any other backup solution actually) on
Linux, maybe you should run a
 find / -type f -print0 | xargs -0 touch
before starting your backup job. Sort of removes the point of using proper
backup software, but at least you'll get your data backed up.


-- 

 / jakob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
