Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5A2D86B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:23:40 -0500 (EST)
Date: Tue, 9 Nov 2010 23:22:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 66] disable lumpy when compaction is enabled
Message-ID: <20101109222240.GH6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <ca2fea6527833aad8adc.1288798056@v2.random>
 <20101109121318.BC51.A69D9226@jp.fujitsu.com>
 <20101109213049.GC6809@random.random>
 <20101109213855.GM32723@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109213855.GM32723@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Nov 09, 2010 at 09:38:55PM +0000, Mel Gorman wrote:
> Specifically, I measured that lumpy in combination with compaction is
> more reliable and lower latency but that's not the same as deleting it.

Thanks for the clarification. Well no doubt that using both could only
increase the success rate. So the thing with hugetlbfs you may want to
run both, but with THP we want to stop at compaction. So this would
then require a __GFP_LUMPY if we want hugetlbfs to fallback on lumpy
whenever compaction isn't successful. We can't just nuke and ignore
young bits in pte if compaction fails. Trying later in khugepaged once
every 10 seconds is a lot better.

> That said, lumpy does hurt the system a lot.  I'm prototyping a series at the
> moment that pushes lumpy reclaim to the side and for the majority of cases
> replaces it with "lumpy compaction". I'd hoping this will be sufficient for
> THP and alleviate the need to delete it entirely - at least until we are 100%
> sure that compaction can replace it in all cases.
> 
> Unfortunately, in the process of testing it today I also found out that
> 2.6.37-rc1 had regressed severely in terms of huge page allocations so I'm
> side-tracked trying to chase that down. My initial theories for the regression
> have shown up nothing so I'm currently preparing to do a bisection. This
> will take a long time though because the test is very slow :(

On my side (unrelated) I also found 37-rc1 broke my mic by changing
soundcard type (luckily csipsimple and skype on my cellphone are now
working better than laptop for making voip calls so it was easy to
workaround) and my backlight goes blank forever after a "xset dpms
force standby" (so I'm stuck in presentation mode to workaround it,
suspend to ram was successful to avoid having to reboot too as the
bios restarts the backlight during boot).

> I can still post the series as an RFC if you like to show what direction
> I'm thinking of but at the moment, I'm unable to test it until I pin the
> regression down.

Sure feel free to post it, if it's already worth testing it, I can
keep at the end of the patchset considering it's new code while what I
posted had lots of testing.

With THP we have khugepaged in the background, nothing is mandatory at
allocation time. I don't want a super aggressive thing at allocation
time, and lumpy by ignoring all young bits is too aggressive and
generates swap storms for every single allocation. We need to fail
order 9 allocation quick even if compaction fails (like if more than
90% of the ram is asked in hugepages so having to use ram in the
unmovable page blocks selected by anti-frag) to avoid hanging the
system during allocations. Looking my stats things seem to be working
ok with compaction in 37-rc1, so maybe it's just the lumpy changes
that introduced your regression?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
