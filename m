Message-ID: <20020405195240.22435.qmail@london.rubylane.com>
From: jim@rubylane.com
Subject: Re: 2.2.20 suspends everything then recovers during heavy I/O
Date: Fri, 5 Apr 2002 11:52:40 -0800 (PST)
In-Reply-To: <1648866003.1018003647@[10.10.2.3]> from "Martin J. Bligh" at Apr 05, 2002 10:47:28 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin.Bligh@us.ibm.com
Cc: jim@rubylane.com, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

But tar & rsync don't work on raw partitions.  There are lots of times
when individual file data has to be processed, and lots of it, like
running stats on large web server logs, compressing the logs, copying
a DB backup to a remote machine for offsite backup, sorting a huge
file, etc. where putting the file in the buffer cache is a waste.

Even in the case of a sort, where you are going to go back and
reference the data again, these often work by reading sequential
through the data once, sorting the keys, then reordering the file.
The initial sequential scan won't benefit from the buffer cache unless
the whole file fits in memory.  The reorder pass would benefit.

An idea I had a while back was to keep track of whether a file has
been randomly positioned or not.  If not, and you have more than a
certain amount of the file already in memory, start reusing buffers
with early parts of the file instead of hogging more.  To me this
is not as good of a solution because there are likely many cases
where this will hurt performance, like repeatedly fgreping a file
larger than the threshold.  If there was a manual tweak, it would
be guaranteed to be used in only the right places.  If tar used
the flag, I guess it's theoretically possible someone would do
repeated tars of the same data, but that seems improbable.  And if
they do that and it takes longer, it's still probably better than
hogging buffers.  Who cares how long a tar takes?

Jim

> 
> > What would be really great is some way to indicate, maybe with an
> > O_SEQ flag or something, that an application is going to sequentially
> > access a file, so cacheing it is a no-win proposition.  Production
> > servers do have situations where lots of data has to be copied or
> > accessed, for example, to do a backup, but doing a backup shouldn't
> > mean that all of the important stuff gets continuously thrown out of
> > memory while the backup is running.  Saving metadata during a backup
> > is useful.  Saving file data isn't.  It's seems hard to do this
> > without an application hint because I may scan a database
> > sequentially but I'd still want those buffers to stay resident.
> 
> Doesn't the raw IO stuff do this, effectively?
> 
> M.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
