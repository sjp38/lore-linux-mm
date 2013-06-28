Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 5EC726B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:04:52 -0400 (EDT)
Date: Fri, 28 Jun 2013 18:04:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628090450.GA9956@bbox>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
 <20130628000201.GB15637@bbox>
 <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
 <20130628005852.GA8093@teo>
 <20130627181353.3d552e64.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627181353.3d552e64.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vorontsov <anton@enomsg.org>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, Jun 27, 2013 at 06:13:53PM -0700, Andrew Morton wrote:
> On Thu, 27 Jun 2013 17:58:53 -0700 Anton Vorontsov <anton@enomsg.org> wrote:
> 
> > On Thu, Jun 27, 2013 at 05:34:33PM -0700, Andrew Morton wrote:
> > > > If so, userland daemon would receive lots of events which are no interest.
> > > 
> > > "lots"?  If vmpressure is generating events at such a high frequency that
> > > this matters then it's already busted?
> > 
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
> Register for events and you get all the events, simple.  Or require that
> userspace register a separate time for each level, or whatever.
> 
> Something clean and simple which leaves the policy in userspace,
> please.  Not this.

Anton, Michal,

Tend to agree. I have been thought that current vmpressure heuristic
could be much fluctuated with various workloads so that how we could make
it stable with another parameters in future so everyone has satisfactory
result with just common general value of low/medium/critical but
different window size. It's not easy for kernel to handle it, IMO.
So as Andrew says, how about leaving the policy in userspace?

For example, we kernel just can expose linear index(ex, 0~100) using
some algorithm(ex, current vmpressure_win/reclaimed/scan) and userland
could poll it with his time granularity and handle the situation and
reset it.

It's a just simple example without enough considering.
Anyway the point is that isn't it worth to think over userspace policy
and what's indicator kernel could expose to user space?


> 
> (Why didn't vmpressure use netlink, btw?  Then we'd have decent payload
> delivery)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
