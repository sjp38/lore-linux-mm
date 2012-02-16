Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 840846B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:43:48 -0500 (EST)
Date: Thu, 16 Feb 2012 01:43:42 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
Message-ID: <20120216004342.GB21685@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <20120214133337.9de7835b.akpm@linux-foundation.org>
 <20120214225922.GA12394@thinkpad>
 <20120214152220.4f621975.akpm@linux-foundation.org>
 <20120215012957.GA1728@thinkpad>
 <20120216084831.0a6ef4f2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120216084831.0a6ef4f2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 16, 2012 at 08:48:31AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Feb 2012 02:35:24 +0100
> Andrea Righi <andrea@betterlinux.com> wrote:
> 
> > On Tue, Feb 14, 2012 at 03:22:20PM -0800, Andrew Morton wrote:
> > > On Tue, 14 Feb 2012 23:59:22 +0100
> > > Andrea Righi <andrea@betterlinux.com> wrote:
> > > 
> > > > On Tue, Feb 14, 2012 at 01:33:37PM -0800, Andrew Morton wrote:
> > > > > On Sun, 12 Feb 2012 01:21:35 +0100
> > > > > Andrea Righi <andrea@betterlinux.com> wrote: 
> > > > > And yes, a container-based approach is pretty crude, and one can
> > > > > envision applications which only want modified reclaim policy for one
> > > > > particualr file.  But I suspect an application-wide reclaim policy
> > > > > solves 90% of the problems.
> > > > 
> > > > I really like the container-based approach. But for this we need a
> > > > better file cache control in the memory cgroup; now we have the
> > > > accounting of file pages, but there's no way to limit them.
> > > 
> > > Again, if/whem memcg becomes sufficiently useful for this application
> > > we're left maintaining the obsolete POSIX_FADVISE_NOREUSE for ever.
> > 
> > Yes, totally agree. For the future a memcg-based solution is probably
> > the best way to go.
> > 
> > This reminds me to the old per-memcg dirty memory discussion
> > (http://thread.gmane.org/gmane.linux.kernel.mm/67114), cc'ing Greg.
> > 
> > Maybe the generic feature to provide that could solve both problems is
> > a better file cache isolation in memcg.
> > 
> 
> Can you think of example interface for us ?
> I'd like to discuss this in mm-summit if we have a chance.
> 
> Thanks,
> -Kame

Sure! I'll try to write down more detailed ideas.

For now the best interface that I can see is to add something like
memory.file.* in cgroupfs.

The NOREUSE-like policy that I was trying to implement via fadvise() can
be probably implemented by setting memory.file.limit_in_bytes=0 (or
using a very small value).

A cgroup like this could use any amount of memory (according to the
other memory.* settings), but it should drop any file cache page as soon
as possible, if the page was not present in memory before. IOW, this
cgroup shouldn't disturb the state of the page cache for the other
cgroups.

Another interesting usage is to provide different levels of service. For
example, using different values for memory.file.limit_in_byte would make
possible to specify that file cache pages of certain cgroups are
reclaimed before others. This would be a very nice feature IMHO, also
for those who want to provide different levels of service per-user.

Thoughts?

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
