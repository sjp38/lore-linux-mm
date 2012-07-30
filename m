Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 9D6A76B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 16:49:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
Date: Mon, 30 Jul 2012 13:48:29 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
In-Reply-To: <5016DE4E.5050300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> Dan,
>=20
> I started writing inline responses to each concern but that
> was adding more confusion than clarity.  I would like to
> focus the discussion.
>   :
> Let's have this discussion.  If there are specific issues
> that need to be addressed to get this ready for mainline
> let's take them one-by-one and line-by-line with patches.

Hi Seth --

Thanks for your response and for your passion.

The first discussion I think is about whether zsmalloc is
a suitable allocator for zcache.  In its current state
in staging, zcache uses zbud for ephemeral (cleancache)
zpages and zsmalloc for persistent (frontswap) zpages.
I have proposed concerns on-list that the capabilities
provided by zsmalloc are not suitable for supporting zcache
in an enterprise distro.  The author of zsmalloc concurred
and has (at least so far) not been available to enhance
zsmalloc, and you have taken a strong position that zsmalloc
needed to be "generic" (i.e. will never deliver the functionality
IMHO is necessary for zcache).  So I have rewritten zbud to
handle both kinds of zpages and, at the same time, to
resolve my stated issues.  This is the bulk of my
major rewrite... I don't think constructing and reviewing
a long series of one-by-one and line-by-line patches is
of much value here, especially since the current code is
in staging.  We either (1) use the now rewritten zbud (2) wait
until someone rewrites zsmalloc (3) accept the deficiencies
of zcache in its current form.

The second discussion is whether ramster, as a "user" of
zcache, is relevant.  As you know, ramster is built on
top of zcache but requires a fair number of significant
changes that, due to gregkh's restriction, could not be
made directly to zcache while in staging.  In my rewrite,
I've taken a great deal of care that the "new" zcache
cleanly supports both.  While some couldn't care less about
ramster, the next step of ramster may be of more interest
to a broader part of the community.  So I am eager to
ensure that the core zcache code in zcache and ramster
doesn't need to "fork" again.  The zcache-main.c in staging/ramster
is farther along than the zcache-main.c in staging/zcache, but
IMHO my rewrite is better and cleaner than either.

Most of the rest of the cleanup, such as converting to debugfs
instead of sysfs, could be done as a sequence of one-by-one
and line-by-line patches.  I think we agree that zcache will
not be promoted unless this change is made, but IMHO constructing
and reviewing patches individually is not of much value since
the above zbud and ramster changes already result in a major
rewrite.  I think the community would benefit most from a new
solid code foundation for zcache and reviewers time (and your
time and mine) would best be spent grokking the new code than
from reviewing a very long sequence of cleanup patches.

> The purpose of this patchset is to discuss the inclusion of
> zcache into mainline during the 3.7 merge window.  zcache
> has been a staging since v2.6.39 and has been maturing with
> contributions from 15 developers (5 with multiple commits)
> working on improvements and bug fixes.
>
> I want good code in the kernel, so if there are particular
> areas that need attention before it's of acceptable quality
> for mainline we need that discussion.  I am eager to have
> customers using memory compression with zcache but before
> that I want to see zcache in mainline.

I think we are all eager to achieve the end result: real users
using zcache in real production systems.  IMHO your suggested
path will not achieve that, certainly not in the 3.7 timeframe.
The current code (IMHO) is neither suitable for promotion, nor
functionally capable of taking the beating of an enterprise distro.

> We agree with Konrad that zcache should be promoted before
> additional features are included.  Greg has also expressed
> that he would like promotion before attempting to add
> additional features [1].  Including new features now, while
> in the staging tree, adds to the complexity and difficultly
> of reverifying zcache and getting it accepted into mainline.
>=20
> [1] https://lkml.org/lkml/2012/3/16/472still in staging.

Zcache as submitted to staging in 2.6.39 was (and is) a working
proof-of-concept.  As you know, Greg's position created a
"catch 22"... zcache in its current state isn't good enough
to be promoted, but we can't change it substantially to resolve
its deficiencies while it is still in staging.  (Minchan
recently stated that he doesn't think it is in good enough
shape to be approved by Andrew, and I agree.)  That's why I
embarked on the rewrite.

Lastly, I'm not so much "adding new features" as ensuring the
new zcache foundation will be sufficient to support enterprise
users.  But I do now agree with Minchan (and I think with you)
that I need to post where I'm at, even if I am not 100% ready or
satisfied.  I'll try to do that by the end of the week.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
