Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 25A3A6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 11:59:48 -0500 (EST)
Date: Mon, 6 Feb 2012 17:59:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] NUMA aware load-balancing
Message-ID: <20120206165945.GM31064@redhat.com>
References: <20120131202836.GF31817@redhat.com>
 <4F2FD25C.7070801@google.com>
 <alpine.DEB.2.00.1202061047450.2799@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202061047450.2799@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Paul Turner <pjt@google.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

Hi,

On Mon, Feb 06, 2012 at 10:48:42AM -0600, Christoph Lameter wrote:
> So this would mean having statistics that show how many pages are
> allocated on each node and take that into consideration for load
> balancing? Which is something that we felt to be desirable for a long
> time.

Correct.

The most difficult part after collecting the per page thread affinity
and per-mm (process) thread affinity, is to compute it and drive both
scheduler and migrate.c in function of it. The algorithm I got seems
to work but it's not easy stuff. But at least it's not intrusive, it's
trivial to proof absolutely zero change of runtime behavior the moment
the core daemon that drives the whole thing stops running (sysfs
disable or not compiled in).

There are still areas where this logic needs improvement (like
migrating unmapped pagecache when node is full etc..).

I'm trying to clean things up so the code will be more readable and
tunable at runtime. I also need to reduce its cost when you boot the
kernel on a not-numa machine (allocating the data on the pgdat instead
of struct page, which is not so easy with all memory models we got
that allocate the pgdat data in different places, and allocate
autonuma structures pointed by mm and task struct). All structures are
embedded static right now (not allocated dynamically) but making it
dynamic is not difficult cleanup even it's not the top priority at the
moment.

The only difficult feature I still miss is native THP migration which
I plan to add after complete sysfs tuning works. (khugepaged is
already capable to recreate THP on destination node, but I don't like
that because the migration right now leads to temporary creation of
sptes instead of sticking to spmds on KVM, not to tell a lot more
vmexits than if we only get one for the spmd). For no-virt probably
it's not so important feature as the hugepages are recreated later and
a page fault costs less than a vmexit.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
