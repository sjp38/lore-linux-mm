Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 25FEE6B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:32:38 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 17 Aug 2012 18:32:37 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9A00C6E803C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:32:34 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7HMWYE3112308
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:32:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7HMWYHL025131
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 19:32:34 -0300
Message-ID: <502EC67F.4070603@linux.vnet.ibm.com>
Date: Fri, 17 Aug 2012 17:32:31 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] staging: zcache+ramster: move to new code base and
 re-merge
References: <1345156293-18852-1-git-send-email-dan.magenheimer@oracle.com> <20120816224814.GA18737@kroah.com> <9f2da295-4164-4e95-bbe8-bd234307b83c@default> <20120816230817.GA14757@kroah.com>
In-Reply-To: <20120816230817.GA14757@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org

On 08/16/2012 06:08 PM, Greg KH wrote:
> On a larger note, I _really_ don't want a set of 'delete and then add it
> back' set of patches.  That destroys all of the work that people had
> done up until now on the code base.
> 
> I understand your need, and want, to start fresh, but you still need to
> abide with the "evolve over time" model here.  Surely there is some path
> from the old to the new codebase that you can find?

I very much agree that this is the wrong way to do this.

I can't possibly inspect the code changes in this format, so
I'll just comment on some high level changes and mention
some performance results.

I like frontswap reclaiming memory from cleancache.  I think
that would work better than having the pages go back to the
kernel-wide page pool using the shrinker interface.

That being said, I can't test the impact of this alone
because all these changes are being submitted together.

I also like the sysfs->debugfs cleanup and zbud being moved
into its own file.

I do _not_ support replacing zsmalloc with zbud:
https://lkml.org/lkml/2012/8/14/347

I do not support the integration of ramster mixed in with
all the rest of these changes.  I have no way to see or
measure the impact of the ramster code.

I ran my kernel building benchmark twice on an unmodified
v3.5 kernel with zcache and then with these changes.  On
none-low memory pressure, <16 threads, they worked roughly
the same with low swap volume.  However, in mid-high
pressure, >20 threads, these changes degraded zcache runtime
and I/O savings by 30-80%.

I would suspect the low-density storage of zbud as the
culprit; however I can't confirm this because, again, it all
one huge change.

Some smaller issues:

1. This patchset breaks the build when CONFIG_SWAP in not
set.  FRONTSWAP depends on SWAP, but ZCACHE _selects_
FRONTSWAP.  If ZCACHE is selected and FRONTSWAP can't be
selected because SWAP isn't selected, then there is a break.

2. I get about 8 unsued/uninit'ed variable warnings at
compile time.

So I can't support this patchset, citing the performance
degradation and the fact that this submission is
unreviewable due to it being one huge monolithic patchset on
top of an existing codebase.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
