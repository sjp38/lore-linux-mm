Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA28243
	for <linux-mm@kvack.org>; Fri, 24 Jan 2003 11:12:25 -0800 (PST)
Date: Fri, 24 Jan 2003 11:12:49 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm5
Message-Id: <20030124111249.227a40d6.akpm@digeo.com>
In-Reply-To: <m3lm1au51v.fsf@lexa.home.net>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<946253340.1043406208@[192.168.100.5]>
	<20030124031632.7e28055f.akpm@digeo.com>
	<m3d6mmvlip.fsf@lexa.home.net>
	<20030124035017.6276002f.akpm@digeo.com>
	<m3lm1au51v.fsf@lexa.home.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alex Tomas <bzzz@tmi.comex.ru>
Cc: linux-kernel@alex.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alex Tomas <bzzz@tmi.comex.ru> wrote:
>
> >>>>> Andrew Morton (AM) writes:
> 
>  AM> That's correct.  Reads are usually synchronous and writes are
>  AM> rarely synchronous.
> 
>  AM> The most common place where the kernel forces a user process to
>  AM> wait on completion of a write is actually in unlink (truncate,
>  AM> really).  Because truncate must wait for in-progress I/O to
>  AM> complete before allowing the filesystem to free (and potentially
>  AM> reuse) the affected blocks.
> 
> looks like I miss something here.
> 
> why do wait for write completion in truncate? 

We cannot free disk blocks until I/O against them has completed.  Otherwise
the block could be reused for something else, then the old IO will scribble
on the new data.

What we _can_ do is to defer the waiting - only wait on the I/O when someone
reuses the disk blocks.  So there are actually unused blocks with I/O in
flight against them.

We do that for metadata (the wait happens in unmap_underlying_metadata()) but
for file data blocks there is no mechanism in place to look them up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
