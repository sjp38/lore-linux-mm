Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iB2GQh6S025365
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 11:26:43 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB2GQhhV286382
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 11:26:43 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iB2GQgtN011963
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 11:26:42 -0500
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance tests 
In-reply-to: Your message of Wed, 01 Dec 2004 23:02:17 PST.
             <20041201230217.1d2071a8.akpm@osdl.org>
Date: Thu, 02 Dec 2004 08:24:04 -0800
Message-Id: <E1CZtkS-0002ft-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, clameter@sgi.com, hugh@veritas.com, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 01 Dec 2004 23:02:17 PST, Andrew Morton wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> >
> > Andrew Morton wrote:
> > > We need to be be achieving higher-quality major releases than we did in
> > > 2.6.8 and 2.6.9.  Really the only tool we have to ensure this is longer
> > > stabilisation periods.
> > 
> > 
> > I'm still hoping that distros (like my employer) and orgs like OSDL will 
> > step up, and hook 2.6.x BK snapshots into daily test harnesses.
> 
> I believe that both IBM and OSDL are doing this, or are getting geared up
> to do this.  With both Linus bk and -mm.
> 
> However I have my doubts about how useful it will end up being.  These test
> suites don't seem to pick up many regressions.  I've challenged Gerrit to
> go back through a release cycle's bugfixes and work out how many of those
> bugs would have been detected by the test suite.
> 
> My suspicion is that the answer will be "a very small proportion", and that
> really is the bottom line.
 
Yeah, sort of what Martin said.  LTP, for instance, doesn't find a lot
of what is in our internal bugzilla or the bugme database.  Automated
testing tends not to cover all the range of desktop peripherals and
drivers that make up a large quantity of the code but gets very little
coverage.  Our stress testing is extensive and was finding 3 year old
problems when we first ran it but it is pretty expensive to run those
types of tests (machines, people, data analysis) so we typically run
those tests on distros rather than mainline to help validate distro
quality.

However, that said, the LTP stuff is still *necessary* - it would
catch quite a number of regressions if we were to regress.  The good
thing is that most changes today haven't been leading to regressions.
That could change at any time, and one of the keys is to make sure that
when we do find regressions we get a test into LTP to make sure that
that particular regression never happens again.

I haven't looked at the code coverage for LTP in a while but it is
actually a high line count coverage test for core kernel.  I don't remember
if it was over 80% or not, but usually 85-88% is the point of diminishing
returns for a regression suite.  I think a more important proactive
step here is to understand what regressions we *do* have an whether
or not we can construct a test that in the future will catch that
regression (or better, a class of regressions).

And, maybe we need some kind of filter person or group for lkml that
can see what the key regressions are (e.g. akpm, if you know of a set
of regressions that you are working, maybe periodically sending those
to the ltp mailing list) we could focus on creating tests for those
regressions.

We are also working to set up large ISV applications in a couple of
spots - both inside IBM and there is a similar effort underway at OSDL.
Those ISV applications will catch a class of real world usage models
and also check for regressions.  I don't know if it is possible to set
up a better testing environment for the wild, whacky and weird things
that people do but, yes, Bless them.  ;-)

> We simply get far better coverage testing by releasing code, because of all
> the wild, whacky and weird things which people do with their computers. 
> Bless them.
> 
> > Something like John Cherry's reports to lkml on warnings and errors 
> > would be darned useful.  His reports are IMO an ideal model:  show 
> > day-to-day _changes_ in test results.  Don't just dump a huge list of 
> > testsuite results, results which are often clogged with expected 
> > failures and testsuite bug noise.
> 
> Yes, we need humans between the tests and the developers.  Someone who has
> good experience with the tests and who can say "hey, something changed
> when I do X".  If nothing changed, we don't hear anything.
> 
> It's a developer role, not a testing role.   All testing is, really.

Yep.  However, smart developers continue to write scripts to automate
the rote and mundane tasks that they hate doing.  Towards that end, there
was a recent effort at Bull on the NPTL work which serves as a very
interesting model:

http://nptl.bullopensource.org/Tests/results/run-browse.php

Basically, you can compare results from any test run with any other
and get a summary of differences.  That helps give a quick status
check and helps you focus on the correct issues when tracking down
defects.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
