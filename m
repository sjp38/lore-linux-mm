Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id DAA14617
	for <linux-mm@kvack.org>; Fri, 24 Jan 2003 03:16:09 -0800 (PST)
Date: Fri, 24 Jan 2003 03:16:32 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm5
Message-Id: <20030124031632.7e28055f.akpm@digeo.com>
In-Reply-To: <946253340.1043406208@[192.168.100.5]>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<946253340.1043406208@[192.168.100.5]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alex Bligh - linux-kernel <linux-kernel@alex.org.uk> wrote:
>
> 
> 
> --On 23 January 2003 19:50 -0800 Andrew Morton <akpm@digeo.com> wrote:
> 
> >   So what anticipatory scheduling does is very simple: if an application
> >   has performed a read, do *nothing at all* for a few milliseconds.  Just
> >   return to userspace (or to the filesystem) in the expectation that the
> >   application or filesystem will quickly submit another read which is
> >   closeby.
> 
> I'm sure this is a really dumb question, as I've never played
> with this subsystem, in which case I apologize in advance.
> 
> Why not follow (by default) the old system where you put the reads
> effectively at the back of the queue. Then rather than doing nothing
> for a few milliseconds, you carry on with doing the writes. However,
> promote the reads to the front of the queue when you have a "good
> lump" of them.

That is the problem.  Reads do not come in "lumps".  They are dependent. 
Consider the case of reading a file:

1: Read the directory.

   This is a single read, and we cannot do anything until it has
   completed.

2: The directory told us where the inode is.  Go read the inode.

   This is a single read, and we cannot do anything until it has
   completed.

3: Go read the first 12 blocks of the file and the first indirect.


   This is a single read, and we cannot do anything until it has
   completed.

The above process can take up to three trips through the request queue.


In this very common scenario, the only way we'll ever get "lumps" of reads is
if some other processes come in and happen to want to read nearby sectors. 
In the best case, the size of the lump is proportional to the number of
processes which are concurrently trying to read something.  This just doesn't
happen enough to be significant or interesting.

But writes are completely different.  There is no dependency between them and
at any point in time we know where on-disk a lot of writes will be placed. 
We don't know that for reads, which is why we need to twiddle thumbs until the
application or filesystem makes up its mind.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
