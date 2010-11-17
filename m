Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 868176B012B
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:45:51 -0500 (EST)
Subject: Re: [PATCH/RFC 0/8] numa - Migrate-on-Fault
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20101116134644.BF21.A69D9226@jp.fujitsu.com>
References: <20101114152440.E02E.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1011150809030.19175@router.home>
	 <20101116134644.BF21.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 17 Nov 2010 09:45:23 -0500
Message-ID: <1290005123.3786.26.camel@zaphod>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-16 at 13:54 +0900, KOSAKI Motohiro wrote:
> > On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> > 
> > > Nice!
> > 
> > Lets not get overenthused. There has been no conclusive proof that the
> > overhead introduced by automatic migration schemes is consistently less
> > than the benefit obtained by moving the data. Quite to the contrary. We
> > have over a decades worth of research and attempts on this issue and there
> > was no general improvement to be had that way.
> > 
> > The reason that the manual placement interfaces exist is because there was
> > no generally beneficial migration scheme available. The manual interfaces
> > allow the writing of various automatic migrations schemes in user space.
> > 
> > If wecan come up with something that is an improvement then lets go
> > this way but I am skeptical.
> 
> Ah, I thought this series only has manua migration (i.e. MPOL_MF_LAZY),
> but it also has automatic migration if a page is not mapped. So my standpoint
> is, manual lazy migration has certinally usecase. but I have no opinion against
> automatic one.
> 

Hello, Kosaki-san:

Yes the focus of the series is adding the lazy [on fault] + automatic
[on internode migration] migration.  The kernel has had "manual
migration" via the migrate_pages() and move_pages() sys calls and
inter-cpuset migration.  The idea here is to let the scheduler have its
way, load balancing without much consideration of numa footprint, and
try to restore locality after an internode migration by fetching just
the [anon] pages that the task actually references while executing on a
given node.  I added the per task /proc/<pid>/migrate control to force a
task to simulate internode migration and perform a direct migration or
[default] unmap to allow lazy migration of anonymous pages controlled by
local mempolicy.

You can use/test the "manual" migrate control without enabling the
automigration feature.  You'll need to enable migrate_on_fault in the
cpuset that contains the task[s] to be tested or the task will unmap
[replace ptes with swap/migration cache ptes] and remap [replace cache
ptes with real ptes] without migration.  Or, you could disable
'automigrate_lazy' and use direct migration.  Of course, you can enable
and test automigration as well :).

However, unfortunately, you'll need to use the mainline version plus the
mmotm used in patches.  I recently rebased to the 1109 mmotm on 37-rc1
and the very first lazy migration fault pulls a null pointer in
swap_cgroup_record().  This is how it has gone with these patches over
the past couple of years.  Seems to have some bad interaction with
memory cgroups in every other mmotm.  Sometimes I need to adjust my
code, other times I just wait and it gets fixed in mainline.  I'll
probably just wait a couple of mmotms this time.

More in response to Andrea's mail...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
