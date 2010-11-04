Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 322418D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 19:35:37 -0400 (EDT)
Received: by gyd8 with SMTP id 8so1572310gyd.14
        for <linux-mm@kvack.org>; Thu, 04 Nov 2010 16:35:35 -0700 (PDT)
Message-ID: <4CD34349.9010504@gmail.com>
Date: Thu, 04 Nov 2010 18:35:37 -0500
From: Steven Barrett <damentz@gmail.com>
MIME-Version: 1.0
Subject: Re: 2.6.36 io bring the system to its knees
References: <E1PE2Jp-00031X-Tx@approx.mit.edu>
In-Reply-To: <E1PE2Jp-00031X-Tx@approx.mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sanjoy Mahajan <sanjoy@olin.edu>
Cc: Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter.Zijl@MIT.EDU
List-ID: <linux-mm.kvack.org>

On 11/04/2010 11:05 AM, Sanjoy Mahajan wrote:
>> So this sounds like the backup is just thrashing your cache.
> 
> I think it's more than that.  Starting an rxvt shouldn't take 8 seconds,
> even with a cold cache.  Actually, it does take a while, so you do have
> a point.  I just did
> 
>   echo 3 > /proc/sys/vm/drop_caches
> 
> and then started rxvt.  That takes about 3 seconds (which seems long,
> but I don't know wherein that slowness lies), of which maybe 0.25
> seconds is loading and running 'date':
> 
> $ time rxvt -e date
> real	0m2.782s
> user	0m0.148s
> sys	0m0.032s
> 
> The 8-second delay during the rsync must have at least two causes: (1)
> the cache is wiped out, and (2) the rxvt binary cannot be paged in
> quickly because the disk is doing lots of other I/O.  
> 
> Can the system someknow that paging in the rxvt binary and shared
> libraries is interactive I/O, because it was started by an interactive
> process, and therefore should take priority over the rsync?
> 
>> Does rsync have the option to do an fadvise DONTNEED?
> 
> I couldn't find one.  It would be good to have a solution that is
> independent of the backup app.  (The 'locate' cron job does a similar
> thrashing of the interactive response.)

I'm definitely no expert in Linux' file cache management, but from what
I've experienced... isn't the real problem that the "interactive"
processes, like your web browser or file manager, lose their inode and
dentry cache when rsync runs?  Then while rsync is busy reading and
writing to the disk, whenever you click on your interactive application,
it tries to read what it lost to rsync from the disk while rsync is
still thrashing your inode/dentry cache.

This is a major problem even when my system has lots of ram (4gB on this
laptop).

What has helped me, however, is reducing vm.vfs_cache_pressure to a
smaller value (25 here) so that Linux prefers to retain the current
inode / dentry cache rather than suddenly give it up for a new greedy
I/O type of program.  The only side effect is that file copying is a
little slower than usual... totally worth it though.

> 
> -Sanjoy
> 
> `Until lions have their historians, tales of the hunt shall always
>  glorify the hunters.'  --African Proverb

	Steven Barrett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
