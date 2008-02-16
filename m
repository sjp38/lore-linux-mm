Date: Sat, 16 Feb 2008 02:58:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-Id: <20080216025803.40d8ccbc.akpm@linux-foundation.org>
In-Reply-To: <47B6BDDF.90502@inria.fr>
References: <20080215064859.384203497@sgi.com>
	<20080215064932.371510599@sgi.com>
	<20080215193719.262c03a1.akpm@linux-foundation.org>
	<47B6BDDF.90502@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008 11:41:35 +0100 Brice Goglin <Brice.Goglin@inria.fr> wrote:

> Andrew Morton wrote:
> > What is the status of getting infiniband to use this facility?
> >
> > How important is this feature to KVM?
> >
> > To xpmem?
> >
> > Which other potential clients have been identified and how important it it
> > to those?
> >   
> 
> As I said when Andrea posted the first patch series, I used something
> very similar for non-RDMA-based HPC about 4 years ago. I haven't had
> time yet to look in depth and try the latest proposed API but my feeling
> is that it looks good.
> 

"looks good" maybe.  But it's in the details where I fear this will come
unstuck.  The likelihood that some callbacks really will want to be able to
block in places where this interface doesn't permit that - either to wait
for IO to complete or to wait for other threads to clear critical regions.

>From that POV it doesn't look like a sufficiently general and useful
design.  Looks like it was grafted onto the current VM implementation in a
way which just about suits two particular clients if they try hard enough.

Which is all perfectly understandable - it would be hard to rework core MM
to be able to make this interface more general.  But I do think it's
half-baked and there is a decent risk that future (or present) code which
_could_ use something like this won't be able to use this one, and will
continue to futz with mlock, page-pinning, etc.

Not that I know what the fix to that is..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
