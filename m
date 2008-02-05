Date: Tue, 5 Feb 2008 04:17:55 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
Message-Id: <20080205041755.3411b5cc.pj@sgi.com>
In-Reply-To: <1202149243.5028.61.camel@localhost>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080202090914.GA27723@one.firstfloor.org>
	<20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1202149243.5028.61.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, rientjes@google.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Lee wrote:
> I don't know the current state of Paul's rework of cpusets and
> mems_allowed.  That probably resolves this issue, if he still plans on
> allowing a fully populated mask to indicate interleaving over all
> allowed nodes.

It got a bit stalled out for the last month (my employer had other
designs on my time.)  But I'd really like to drive it home.

What happened so far, in December 2007 and earlier, is that a few of us:

  David Rientjes <rientjes@google.com>
  Lee.Schermerhorn@hp.com
  Christoph Lameter <clameter@sgi.com>
  Andi Kleen <ak@suse.de>

had a discussion, motivated in good part by the need to allow a
mempolicy of MPOL_INTERLEAVE over all nodes currently available in
the cpuset, where that interleave policy was robustly preserved if
the cpuset changed (without requiring the application to somehow
"know" its cpuset had changed and reissuing the set_mempolicy call.)

But that discussion touched on some other long standing deficiencies
in the way that I had originally glued cpusets and memory policies
together.  The current mechanism doesn't handle changing cpusets very
well, especially if the number of nodes in the cpuset increases.

Obviously, I can't change the current behaviour, especially of the
mempolicy system calls.  I can only add new options that provide new
alternatives.

The patchset I'd like to drive home addresses these issues with a
couple of additional MPOL_* flags, upward compatible, that alter the
way that nodemasks are mapped into cpusets, and remapped if the cpuset
subsequently changes.

The next two steps I need to take are:
 1) propose this patch, with careful explanation (it's easy to lose
    one's bearings in the mappings and remappings of node numberings)
    to a wider audience, such as linux-mm or linux-kernel, and
 2) carefully test this, especially on each code path I touched in
    mm/mempolicy.c, where the changes were delicate, to ensure I
    didn't break any existing code.

There were also some other, smaller patches proposed, by myself and
others.  I was preferring to address a wider set of the long standing
issues in this area, but the others above mostly preferred the smaller
patches.  This needs to be discussed in a wider forum, and a concensus
reached.

Hopefully this week or next, I will publish this patch proposal.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
