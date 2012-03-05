Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id E1B9C6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 17:18:49 -0500 (EST)
Date: Mon, 5 Mar 2012 17:18:43 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Lsf-pc] [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120305221843.GH18546@redhat.com>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305202330.GD11238@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305202330.GD11238@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrea Righi <andrea@betterlinux.com>, Suresh Jayaraman <sjayaraman@suse.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Mon, Mar 05, 2012 at 09:23:30PM +0100, Jan Kara wrote:

[..]
> Having the limits for dirty rate and other IO separate means I
> have to be rather pesimistic in setting the bounds so that combination of
> dirty rate + other IO limit doesn't exceed the desired bound but this is
> usually unnecessarily harsh...

We had solved this issue in my previous posting.

https://lkml.org/lkml/2011/6/28/243

I was accounting the buffered writes to associated block group in 
balance dirty pages and throttling it if group was exceeding upper
limit. This had common limit for all kind of writes (direct + buffered +
sync etc).

But it also had its share of issues.

- Control was per device (not global) and was not applicable to NFS.
- Will not prevent IO spikes at devices (caused by flusher threads).

Dave Chinner preferred to throttle IO at devices much later.

I personally think that "dirty rate limit" does not solve all problems
but has some value and it will be interesting to merge any one
implementation and see if it solves a real world problem. It does not
block any other idea of buffered write proportional control or even
implementing upper limit in blkcg. We could put "dirty rate limit" in
memcg and develop rest of the ideas in blkcg, writeback etc.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
