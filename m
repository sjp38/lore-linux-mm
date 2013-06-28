Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5FFEE6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 00:34:15 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so1927448pad.30
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 21:34:14 -0700 (PDT)
Date: Thu, 27 Jun 2013 21:34:11 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628043411.GA9100@teo>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
 <20130628000201.GB15637@bbox>
 <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
 <20130628005852.GA8093@teo>
 <20130627181353.3d552e64.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130627181353.3d552e64.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, Jun 27, 2013 at 06:13:53PM -0700, Andrew Morton wrote:
> On Thu, 27 Jun 2013 17:58:53 -0700 Anton Vorontsov <anton@enomsg.org> wrote:
> > Current frequency is 1/(2MB). Suppose we ended up scanning the whole
> > memory on a 2GB host, this will give us 1024 hits. Doesn't feel too much*
> > to me... But for what it worth, I am against adding read() to the
> > interface -- just because we can avoid the unnecessary switch into the
> > kernel.
> 
> What was it they said about premature optimization?
> 
> I think I'd rather do nothing than add a mode hack (already!).
> 
> The information Luiz wants is already available with the existing
> interface, so why not just use it until there is a real demonstrated
> problem?
> 
> But all this does point at the fact that the chosen interface was not a
> good one.  And it's happening so soon :( A far better interface would
> be to do away with this level filtering stuff in the kernel altogether.

OK, I am convinced that modes might be not necessary, but I see no big
problem in current situation, we can add the strict mode and deprecate the
"filtering" -- basically we'll implement the idea of requiring that
userspace registers a separate fd for each level.

As one of the ways to change the interface, we can do the strict mode by
writing levels in uppercase, and warn_once on lowercase levels, describing
that the old behaviour will go away. Once (if ever) we remove the old
behaviour, the apps trying the old-style lowercase levels will fail
gracefully with EINVAL.

Or we can be honest and admit that we can't be perfect and just add an
explicit versioning to the interface. :)

It might be unfortunate that we did not foresee this and have to change
things that soon, but we did change interfaces in the past for a lot of
sysfs and proc knobs, so it is not something new. Once the vmpressure
feature will get even wider usage exposure, we might realize that we need
to make even more changes...

> (Why didn't vmpressure use netlink, btw?  Then we'd have decent payload
> delivery)

Because we decided to be a part of memcg and thus we used standard cgroups
notifications. And we didn't need the payload (and still don't need it if
we go with the multiple fds interface).

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
