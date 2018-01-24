Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCAF800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:43:54 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q18so5670357ioh.4
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 15:43:54 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v62si1042255iof.253.2018.01.24.15.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 15:43:52 -0800 (PST)
Date: Wed, 24 Jan 2018 15:43:47 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] Patch Submission process and Handling Internal
 Conflict
Message-ID: <20180124234347.GA11926@magnolia>
References: <1516820744.3073.30.camel@HansenPartnership.com>
 <c4598a9a-6995-d67a-dd1c-8e946470eeb4@oracle.com>
 <1516829760.3073.43.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1516829760.3073.43.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Wed, Jan 24, 2018 at 01:36:00PM -0800, James Bottomley wrote:
> On Wed, 2018-01-24 at 11:20 -0800, Mike Kravetz wrote:
> > On 01/24/2018 11:05 AM, James Bottomley wrote:
> > > 
> > > I've got two community style topics, which should probably be
> > > discussed
> > > in the plenary
> > > 
> > > 1. Patch Submission Process
> > > 
> > > Today we don't have a uniform patch submission process across
> > > Storage, Filesystems and MM.  The question is should we (or at
> > > least should we adhere to some minimal standards).  The standard
> > > we've been trying to hold to in SCSI is one review per accepted
> > > non-trivial patch.  For us, it's useful because it encourages
> > > driver writers to review each other's patches rather than just
> > > posting and then complaining their patch hasn't gone in.  I can
> > > certainly think of a couple of bugs I've had to chase in mm where
> > > the underlying patches would have benefited from review, so I'd
> > > like to discuss making the one review per non-trival patch our base
> > > minimum standard across the whole of LSF/MM; it would certainly
> > > serve to improve our Reviewed-by statistics.
> > 
> > Well, the mm track at least has some discussion of this last year:
> > https://lwn.net/Articles/718212/
> 
> The pushback in your session was mandating reviews would mean slowing
> patch acceptance or possibly causing the dropping of patches that
> couldn't get reviewed.  Michal did say that XFS didn't have the
> problem, however there not being XFS people in the room, discussion
> stopped there.

I actually /was/ lurking in the session, but a year later I have more
thoughts:

Now that I've been maintainer for more than a year I feel more confident
in actually talking about our review processes, though I can only speak
about my own experiences and hope the other xfs developers chime in if
they choose.

In xfs we are fortunate enough that most of the codebase is at least
one software layer up from the raw hardware, which means that anybody
can build xfs with all kconfig options enabled and use it to try to
create all possible metadata structures, which means that the ability to
review a given patch and try it out isn't restricted to the subset of
people with a particular hardware device.  This means that there aren't
any patches that cannot be reviewed, which is not something I'm so sure
of for the mm layer.

Requiring review on the vast majority of non-maintainer patches that
goes into xfs (and xfsprogs) doesn't has the effect of increasing the
time to upstream acceptance, since the fact that it was committed at all
implies that the maintainer probably looked at it.

The dangerous part of course is when the maintainer commits non-trivial
code without a review -- did they look at it, or just commit whatever
made the symptoms go away?  So that's argument #1 for creating a group
norm that yes, everyone should be involved in review on a semi regular
basis.  Certainly if they're also *submitting* patches.

Argument #2 is that encouraging review of everything most likely reduces
the overall time it takes for a feature to mature because that means
that at least one of the regular participants in the group have taken
the time to read and understand how the patches mesh with the existing
systems and will ask questions when they see ill-fitting pieces.  It
definitely reduces code churn from not having to walk back bad patches
and rushed microcode updates.  That said, I've no data to back up this
assertion, merely my observations of the past decade.

My third argument is that the most time consuming part of
maintainership isn't gluing patches onto a git tree and running tests,
it's reviewing the patches.  It's a big help to know that other people
who are more familiar with various subcomponents of xfs review patches
regularly, so I don't feel as much pressure to know all things at all
times, and I worry less about blind spots because we work as a group of
people who don't see every xfs component in exactly the same way.

(Granted it helps that Dave Chinner is a fountain of historical context
indexing...)

That said, I also get reeeeally itchy to commit my own patches at times,
especially things that look like trivial one-liners.  However, I find
that nothing in xfs is simple, and moreover the reviewers are
knowledgeable enough that even trivial patches can get reviewed quickly.

For bigger things like new features or large refactorings, there's a
strong need for updating documentation like the disk format
specification, developing a test plan, and integrating new tests into
xfstests.  That's where review is most useful, because it is the
submitter's opportunity to increase everyone's knowledge levels.  It is
also the reviewers' chance to anticipate design problems when it is
easy/cheap to fix them, and for everyone to build confidence about the
code that's going in.

The challenge for everyone, then, is to get together to decide on a
reasonable target for the amount and the levels on which review happen;
and to figure out how to make that reviewing a group norm to avoid
regression to 'building hacks on other hacks'.  My uneducated guess as
to a good starting point is to start by trying to build a rough
consensus about how the memory manager actually works, after which you
can then review the high level design of these large patchsets that come
in.

Unfortunately, I'm not sufficiently familiar with the mm community to
know if I've just asked for the moon.  That's where LSFMM comes in. :)

> Having this as a plenary would allow people outside mm
> to describe their experiences and for us to look at process based
> solutions using our shared experience.

I'd show up, so long as this wasn't scheduled against something else.
(IOWs, yes please.)

--D

> James
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
