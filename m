Date: Sat, 6 Nov 2004 08:19:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
In-Reply-To: <204290000.1099754257@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0411060812390.25369@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>  <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com>
 <418AD329.3000609@yahoo.com.au>  <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com>
 <418AE0F0.5050908@yahoo.com.au>  <418AE9BB.1000602@yahoo.com.au><1099622957.29587.101.camel@gaston>
 <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
 <204290000.1099754257@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Martin J. Bligh wrote:

> > So I removed all uses of mm->rss and anon_rss from the kernel and
> > introduced a bean counter count_vm() that is only run when the
> > corresponding /proc file is used. count_vm then runs throught the vm
> > and counts all the page types. This could also add additional page types to our
> > statistics and solve some of the consistency issues.
>
> I would've thought SGI would be more worried about this kind of thing
> than anyone else ... what's going to happen when you type 'ps' on a large
> box, and it does this for 10,000 processes?

Yes but I think this is preferable because of the generally faster
operations of the vm without having to continually update statistics. And
these statistics seem to be quite difficult to properly generate (why else
introduce anon_rss). Without the counters other optimizations are easier
to do.

Doing a ps is not a frequent event. Of course this may cause
significant load if one does regularly access /proc entities then. Are
there any threads from the past with some numbers of what the impact was
when we calculated rss via proc?

> If you want to make it quicker, how about doing per-cpu stats, and totalling
> them at runtime, which'd be lockless, instead of all the atomic ops?

That has its own complications and would require lots of memory with
systems that already have up to 10k cpus.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
