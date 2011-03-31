Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8088D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 23:05:58 -0400 (EDT)
Date: Wed, 30 Mar 2011 20:06:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: improve scalability for updating vm_committed_as
Message-Id: <20110330200650.d93a1aec.akpm@linux-foundation.org>
In-Reply-To: <1301540239.3981.80.camel@sli10-conroe>
References: <1301447847.3981.49.camel@sli10-conroe>
	<20110330155114.fa47dd9d.akpm@linux-foundation.org>
	<1301533003.3981.75.camel@sli10-conroe>
	<20110330193404.9525b4e9.akpm@linux-foundation.org>
	<1301540239.3981.80.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, 31 Mar 2011 10:57:19 +0800 Shaohua Li <shaohua.li@intel.com> wrote:

> On Thu, 2011-03-31 at 10:34 +0800, Andrew Morton wrote:
> > On Thu, 31 Mar 2011 08:56:43 +0800 Shaohua Li <shaohua.li@intel.com> wrote:
> > 
> > > > This is a big change, and it wasn't even changelogged.  It's
> > > > potentially a tremendous increase in the expense of a read from
> > > > /proc/meminfo, which is a file that lots of tools will be polling. 
> > > > Many of those tools we don't even know about or have access to.
> > > Assume we don't read /proc/meminfo too often.
> > 
> > That's a poor assumption.  top(1) and vmstat(8) read it, for a start. 
> > There will be zillions of locally-developed monitoring tools which read
> > meminfo.
> > 
> > Now, it could be that something under meminfo reads _already_ does a
> > massive walk across all CPUs.  If so then we'll have already trained
> > people to avoid reading /proc/meminfo and this change might be
> > acceptable.
> > 
> > But if this isn't the case then it's quite likely that this change will
> > hurt some people quite a lot.  And, unfortunately, the sort of people
> > who we will hurt tend to be people who don't run our stuff until a long
> > time (years) after we wrote it.  By which time it's going to be quite
> > expensive to get a fix down the chain and into their hands.
> Just looked at the code. nr_blockdev_pages() of si_meminfo iterate all
> block devices. For people who care about the time, their system must
> have more block devices than CPUs.

How can we be sure of that?

> so this isn't a big issue?

Well it might be.  Experience tells us that some people are likely to
get bitten by this.

It's far safer and saner to find a solution which doesn't have big fat
failure modes!

Also, we don't (yet) know what we're *gaining* for this big fat failure
mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
