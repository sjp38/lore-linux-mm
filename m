Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B136C6B0085
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 08:49:01 -0500 (EST)
Received: by qyk10 with SMTP id 10so1561359qyk.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 05:48:58 -0800 (PST)
From: Ben Gamari <bgamari@gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <20101122103756.E236.A69D9226@jp.fujitsu.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <874obawvlt.fsf@gmail.com> <20101122103756.E236.A69D9226@jp.fujitsu.com>
Date: Tue, 23 Nov 2010 08:48:53 -0500
Message-ID: <87mxp09mm2.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 16:16:55 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > On Sun, 21 Nov 2010 23:30:23 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
> > > 
> > > Ben, Remain thing is to modify rsync and use
> > > fadvise(POSIX_FADV_DONTNEED). Could you test it?
> > 
> > Thanks a ton for the patch. Looks good. Testing as we speak.
> 
For the record, this was a little premature. As I spoke the kernel was
building but I still haven't had a chance to take any data. Any
suggestions for how to determine the effect (or hopefully lack thereof)
of rsync on the system's working set?

> If possible, can you please post your rsync patch and your testcase
> (or your rsync option + system memory size info + data size info)?
> 
Patch coming right up.

The original test case is a backup script for my home directory. rsync
is invoked with,

rsync --archive --update --progress --delete --delete-excluded
--exclude-from=~/.backup/exclude --log-file=~/.backup/rsync.log -e ssh
/home/ben ben@myserver:/mnt/backup/current

My home directory is 120 GB with typical delta sizes of tens of
megabytes between backups (although sometimes deltas can be gigabytes,
after which the server has severe interactivity issues). The server is
unfortunately quite memory constrained with only 1.5GB of memory (old
inherited hardware). Given the size of my typical deltas, I'm worried
that even simply walking the directory hierarchy might be enough to push
out my working set.

Looking at the rsync access pattern with strace it seems that it does
a very good job of avoid duplicate reads which is good news for these
patches.

Cheers,

- Ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
