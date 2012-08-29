Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E6B946B0068
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 11:56:55 -0400 (EDT)
Date: Wed, 29 Aug 2012 08:56:46 -0700
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] kmemleak: avoid buffer overrun: NUL-terminate
 strncpy-copied command
Message-ID: <20120829154209.GA20836@mwanda>
References: <1345481724-30108-1-git-send-email-jim@meyering.net>
 <1345481724-30108-4-git-send-email-jim@meyering.net>
 <20120824102725.GH7585@arm.com>
 <876288o7ny.fsf@rho.meyering.net>
 <20120828202459.GA13638@mwanda>
 <874nnm6wkg.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874nnm6wkg.fsf@rho.meyering.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Meyering <jim@meyering.net>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Aug 29, 2012 at 08:28:47AM +0200, Jim Meyering wrote:
> Dan Carpenter wrote:
> > On Fri, Aug 24, 2012 at 01:23:29PM +0200, Jim Meyering wrote:
> >> In that case, what would you think of a patch to use strcpy instead?
> >>
> >>   -		strncpy(object->comm, current->comm, sizeof(object->comm));
> >>   +		strcpy(object->comm, current->comm);
> >
> > Another option would be to use strlcpy().  It's slightly neater than
> > the strncpy() followed by a NUL assignment.
> >
> >> Is there a preferred method of adding a static_assert-like statement?
> >> I see compile_time_assert and a few similar macros, but I haven't
> >> spotted anything that is used project-wide.
> >
> > BUILD_BUG_ON().
> 
> Hi Dan,
> 
> Thanks for the feedback and tip.  How about this patch?
> 

I'm not someone who can approve kmemleak patches, but that's
horrible.  I'm not sure we need a BUILD_BUG_ON(), I was just telling
you the standard way to do a build time assert.  If we did put the
assert in then it should only be in one place in the header file
where the data is decared instead of repeated over and over.

I like strlcpy().  Both strcpy() and strlcpy() will silence your
static checker tool.  strcpy() may be better, but strlcpy() feels
very safe so that might be preferred.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
