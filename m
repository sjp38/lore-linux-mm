Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8C82D6B0068
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:35:54 -0400 (EDT)
Date: Fri, 12 Oct 2012 13:35:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 23/33] autonuma: retain page last_nid information in
 khugepaged
Message-ID: <20121012123550.GT3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-24-git-send-email-aarcange@redhat.com>
 <20121011184453.GG3317@csn.ul.ie>
 <5078010E.8020100@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5078010E.8020100@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, Oct 12, 2012 at 07:37:50AM -0400, Rik van Riel wrote:
> On 10/11/2012 02:44 PM, Mel Gorman wrote:
> >On Thu, Oct 04, 2012 at 01:51:05AM +0200, Andrea Arcangeli wrote:
> >>When pages are collapsed try to keep the last_nid information from one
> >>of the original pages.
> >>
> >
> >If two pages within a THP disagree on the node, should the collapsing be
> >aborted? I would expect that the code of a remote access exceeds the
> >gain from reduced TLB overhead.
> 
> Hard to predict.  The gains from THP seem to be on the same
> order as the gains from NUMA locality, both between 5-15%
> typically.
> 

Usually yes, but in this case you know that at least 50% of those accesses
are going to be remote and as autonuma will be attempting to get hints on
the PMD level there is going to be a struggle between THP collapsing the
page and autonuma splitting it for NUMA migration. It feels to me that
the best decision in this case is to leave the page split and NUMA
hinting take place on the PTE level.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
