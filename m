Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C08456B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:50:22 -0400 (EDT)
Subject: Re: [PATCH] vmalloc: add warning in __vmalloc
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <CAPa8GCCzyB7iSX+wTzsqfe7GHvfWT2wT4aQgK30ycRnkc_BNAQ@mail.gmail.com>
References: <1335932890-25294-1-git-send-email-minchan@kernel.org>
	 <20120502124610.175e099c.akpm@linux-foundation.org>
	 <4FA1D93C.9000306@kernel.org>
	 <Pine.LNX.4.64.1205022241560.18540@cobra.newdream.net>
	 <CAPa8GCCzyB7iSX+wTzsqfe7GHvfWT2wT4aQgK30ycRnkc_BNAQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 May 2012 14:48:36 +0100
Message-ID: <1336052916.7030.7.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Sage Weil <sage@newdream.net>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com, rientjes@google.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, "David S.
 Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Hi,

On Thu, 2012-05-03 at 16:30 +1000, Nick Piggin wrote:
> On 3 May 2012 15:46, Sage Weil <sage@newdream.net> wrote:
> > On Thu, 3 May 2012, Minchan Kim wrote:
> >> On 05/03/2012 04:46 AM, Andrew Morton wrote:
> >> > Well.  What are we actually doing here?  Causing the kernel to spew a
> >> > warning due to known-buggy callsites, so that users will report the
> >> > warnings, eventually goading maintainers into fixing their stuff.
> >> >
> >> > This isn't very efficient :(
> >>
> >>
> >> Yes. I hope maintainers fix it before merging this.
> >>
> >> >
> >> > It would be better to fix that stuff first, then add the warning to
> >> > prevent reoccurrences.  Yes, maintainers are very naughty and probably
> >> > do need cattle prods^W^W warnings to motivate them to fix stuff, but we
> >> > should first make an effort to get these things fixed without
> >> > irritating and alarming our users.
> >> >
> >> > Where are these offending callsites?
> >
> > Okay, maybe this is a stupid question, but: if an fs can't call vmalloc
> > with GFP_NOFS without risking deadlock, calling with GFP_KERNEL instead
> > doesn't fix anything (besides being more honest).  This really means that
> > vmalloc is effectively off-limits for file systems in any
> > writeback-related path, right?
> 
> Anywhere it cannot reenter the filesystem, yes. GFP_NOFS is effectively
> GFP_KERNEL when calling vmalloc.
> 
> Note that in writeback paths, a "good citizen" filesystem should not require
> any allocations, or at least it should be able to tolerate allocation failures.
> So fixing that would be a good idea anyway.

For cluster filesystems, there is an additional issue. When we allocate
memory with GFP_KERNEL we might land up pushing inodes out of cache,
which can also mean deallocating them. That process involves taking
cluster locks, and so it is not valid to do this while holding another
cluster lock (since the locks may be taken in random order).

In the GFS2 use case for vmalloc, this is being done if kmalloc fails
and also if the memory required is too large for kmalloc (very unlikely,
but possible with very large directories). Also, it is being done under
a cluster lock (shared mode).

I recently looked back at the thread which resulted in that particular
vmalloc call being left there:
http://www.redhat.com/archives/cluster-devel/2010-July/msg00021.html
http://www.redhat.com/archives/cluster-devel/2010-July/msg00022.html
http://www.redhat.com/archives/cluster-devel/2010-July/msg00023.html

which reminded me of the problem. So this might not be so easy to
resolve...

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
