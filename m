Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id 3039D6B0062
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:40 -0400 (EDT)
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet14.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q6VG8gxT007122
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 16:08:42 GMT
Date: Tue, 31 Jul 2012 11:58:43 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120731155843.GP4789@phenom.dumpdata.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jul 30, 2012 at 01:48:29PM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: [PATCH 0/4] promote zcache from staging
> > 
> > Dan,
> > 
> > I started writing inline responses to each concern but that
> > was adding more confusion than clarity.  I would like to
> > focus the discussion.
> >   :
> > Let's have this discussion.  If there are specific issues
> > that need to be addressed to get this ready for mainline
> > let's take them one-by-one and line-by-line with patches.
> 
> Hi Seth --
> 
> Thanks for your response and for your passion.
> 
> The first discussion I think is about whether zsmalloc is
> a suitable allocator for zcache.  In its current state
> in staging, zcache uses zbud for ephemeral (cleancache)
> zpages and zsmalloc for persistent (frontswap) zpages.

OK, but - unstaging 'zsmalloc' is a different patchset.

> I have proposed concerns on-list that the capabilities
> provided by zsmalloc are not suitable for supporting zcache
> in an enterprise distro.  The author of zsmalloc concurred

The goal is to support _both_ enterprise and embedded.

But what you are saying sounds like it does not work in enterprise
environment - which is not my experience? If you are saying that
the code should not be integrated before it works in both classes
perfectly - well, then a lot of other code in the Linux should not
have been accepted - and I would call those insufficienies "bugs".
And bugs are .. natural, albeit pesky.

I think what you are saing by "enterprise" is that you want
it to be enabled by default (or at least be confident that it
can be done so) for everybody and that it work quite well under
99% workload. While right now it covers only 98% (or some
other number) of workload.

> and has (at least so far) not been available to enhance
> zsmalloc, and you have taken a strong position that zsmalloc
> needed to be "generic" (i.e. will never deliver the functionality
> IMHO is necessary for zcache).  So I have rewritten zbud to
> handle both kinds of zpages and, at the same time, to
> resolve my stated issues.  This is the bulk of my

Ok, so zbud rewrite is to remove the need for zsmalloc
and use zbud2 for both persistent and ephemeral pages.

> major rewrite... I don't think constructing and reviewing
> a long series of one-by-one and line-by-line patches is
> of much value here, especially since the current code is
> in staging.  We either (1) use the now rewritten zbud (2) wait
> until someone rewrites zsmalloc (3) accept the deficiencies
> of zcache in its current form.

This sounds like a Catch-22 :-) Greg would like to have the
TODO list finished - and it seems that one of the todo's
is to have one instead of two engines for dealing with pages.
But at the same time not adding in new features.

> 
> The second discussion is whether ramster, as a "user" of
> zcache, is relevant.  As you know, ramster is built on
> top of zcache but requires a fair number of significant
> changes that, due to gregkh's restriction, could not be
> made directly to zcache while in staging.  In my rewrite,
> I've taken a great deal of care that the "new" zcache
> cleanly supports both.  While some couldn't care less about
> ramster, the next step of ramster may be of more interest
> to a broader part of the community.  So I am eager to
> ensure that the core zcache code in zcache and ramster
> doesn't need to "fork" again.  The zcache-main.c in staging/ramster
> is farther along than the zcache-main.c in staging/zcache, but
> IMHO my rewrite is better and cleaner than either.

So in short you made zcache more modular?

> 
> Most of the rest of the cleanup, such as converting to debugfs
> instead of sysfs, could be done as a sequence of one-by-one
> and line-by-line patches.  I think we agree that zcache will

Sure. Thought you could do it more wholesale: sysfs->debugfs patch.

> not be promoted unless this change is made, but IMHO constructing
> and reviewing patches individually is not of much value since
> the above zbud and ramster changes already result in a major
> rewrite.  I think the community would benefit most from a new
> solid code foundation for zcache and reviewers time (and your
> time and mine) would best be spent grokking the new code than
> from reviewing a very long sequence of cleanup patches.

You are ignoring the goodness of the testing and performance
numbers that zcache has gotten so far. With a new code those
numbers are invalidated. That is throwing away some good data.
Reviewing code based on the old code (and knowing how the
old code works) I think is easier than trying to understand new
code from scratch - at least one has a baseline to undertand it.
But that might be just my opinion - either way I am OK
looking at brand new code or old code - but I would end up
looking at the old code to answer those : "Huh. I wonder how
we did that previously." - at which point it might make sense
just to have the patches broken up in small segments.

> 
> > The purpose of this patchset is to discuss the inclusion of
> > zcache into mainline during the 3.7 merge window.  zcache
> > has been a staging since v2.6.39 and has been maturing with
> > contributions from 15 developers (5 with multiple commits)
> > working on improvements and bug fixes.
> >
> > I want good code in the kernel, so if there are particular
> > areas that need attention before it's of acceptable quality
> > for mainline we need that discussion.  I am eager to have
> > customers using memory compression with zcache but before
> > that I want to see zcache in mainline.
> 
> I think we are all eager to achieve the end result: real users
> using zcache in real production systems.  IMHO your suggested
> path will not achieve that, certainly not in the 3.7 timeframe.
> The current code (IMHO) is neither suitable for promotion, nor
> functionally capable of taking the beating of an enterprise distro.

So we agree that it must be fixed, but disagree on how to fix it :-)

However there are real folks in the embedded env that use it (with
some modifications) - please don't call them "unreal users".

> 
> > We agree with Konrad that zcache should be promoted before
> > additional features are included.  Greg has also expressed
> > that he would like promotion before attempting to add
> > additional features [1].  Including new features now, while
> > in the staging tree, adds to the complexity and difficultly
> > of reverifying zcache and getting it accepted into mainline.
> > 
> > [1] https://lkml.org/lkml/2012/3/16/472still in staging.
> 
> Zcache as submitted to staging in 2.6.39 was (and is) a working
> proof-of-concept.  As you know, Greg's position created a
> "catch 22"... zcache in its current state isn't good enough
> to be promoted, but we can't change it substantially to resolve
> its deficiencies while it is still in staging.  (Minchan
> recently stated that he doesn't think it is in good enough
> shape to be approved by Andrew, and I agree.)  That's why I
> embarked on the rewrite.
> 
> Lastly, I'm not so much "adding new features" as ensuring the
> new zcache foundation will be sufficient to support enterprise
> users.  But I do now agree with Minchan (and I think with you)
> that I need to post where I'm at, even if I am not 100% ready or
> satisfied.  I'll try to do that by the end of the week.

So in my head I feel that it is Ok to:
1) address the concerns that zcache has before it is unstaged
2) rip out the two-engine system with a one-engine system
   (and see how well it behaves)
3) sysfs->debugfs as needed
4) other things as needed

I think we are getting hung-up what Greg said about adding features
and the two-engine->one engine could be understood as that.
While I think that is part of a staging effort to clean up the
existing issues. Lets see what Greg thinks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
