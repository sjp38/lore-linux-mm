Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 436B36B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:49:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 124so53666194itl.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 23:49:21 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id d64si3955408iof.82.2016.09.29.23.49.02
        for <linux-mm@kvack.org>;
        Thu, 29 Sep 2016 23:49:03 -0700 (PDT)
Date: Fri, 30 Sep 2016 16:48:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/12] re-enable DAX PMD support
Message-ID: <20160930064858.GJ27872@dastard>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160929234345.GG27872@dastard>
 <20160930030343.GA12464@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160930030343.GA12464@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Sep 29, 2016 at 09:03:43PM -0600, Ross Zwisler wrote:
> On Fri, Sep 30, 2016 at 09:43:45AM +1000, Dave Chinner wrote:
> > Finally: none of the patches in your tree have reviewed-by tags.
> > That says to me that none of this code has been reviewed yet.
> > Reviewed-by tags are non-negotiable requirement for anything going
> > through my trees. I don't have time right now to review this code,
> > so you're going to need to chase up other reviewers before merging.
> > 
> > And, really, this is getting very late in the cycle to be merging
> > new code - we're less than one working day away from the merge
> > window opening and we've missed the last linux-next build. I'd
> > suggest that we'd might be best served by slipping this to the PMD
> > support code to the next cycle when there's no time pressure for
> > review and we can get a decent linux-next soak on the code.
> 
> I absolutely support your policy of only sending code to Linux that has passed
> peer review.
> 
> However, I do feel compelled to point out that this is not new code.  I didn't
> just spring it on everyone in the hours before the v4.8 merge window.  I
> posted the first version of this patch set on August 15th, *seven weeks ago*:
> 
> https://lkml.org/lkml/2016/8/15/613
>
> This was the day after v4.7-rc2 was released.

I understand, Ross. We've all been there - welcome to the club. :/

The problem is there are lots of people writing code and very few
people who spent time reviewing it. And for many of those reviewers,
they also have to spend time on other code bases, whether it be the
distro's they maintain, the userspace that the kernel code needs to
function, or even the test code needed to make this all work
properly.

Stuff that spans multiple subsystems such as DAX (i.e. vm,
filesystems and block devices) are particularly troublesome in this
respect because there are very few people with expertise in all
three aspects and hence able to review a change that spans all three
subsystems. Those people also tend to be the busiest and have to
prioritise what they do.

Consider the XFS side of review in recent times: in the past 4
months, there's been ~30,000 lines of code change between kernel and
userspace.  And there's already another 15,000+ lines of code in the
backlog for the next 2-3 months.  That review load is falling on 3-4
people, who all have other work to do as well. This is for work that
was started well over a year ago, and that picked up from work that
was originally done 3 years ago. We're swamped on pure XFS review
right now, let alone all the other infratructure stuff we need to
get reviewed at the same time...

Having someone say "lets get sorted after the merge window" is far
better than having your patches ignored - it tells you someone wants
your code and is actually planning to review it in the near term!
Have patience. Keep the patches up to date, keep building what you
need to build on top of them. Missing a merge window is not the end
of the world.

> Since then I have responded promptly to the little review feedback that I've
> received.  I've also reviewed and tested other DAX changes, like the struct
> iomap changes from Christoph.

And I'm grateful for your doing that - it sped the process up a lot
because they then weren't blocked waiting for me to get to them. As
a result, I owe you some review time in return but unfortunately I
can't fully return the favour immediately. If more people treated
review as a selfless act that should be returned in kind, then we
wouldn't have a review bottleneck like we do...

> Those changes were first posted to the mailing
> list on September 9th, four weeks after mine.  Nevertheless, I was happy to
> rebase my changes on top of his, which meant a full rewrite of the DAX PMD
> fault handler so it would be based on struct iomap.  His changes are going to
> be merged for v4.9, and mine are not.

Yes, this can happen, too - core infrastructure changes can appear
suddenly and be implemented very quickly, but that does not mean
there hasn't been a lot of background work and effort put into the
code. The iomap code goes way back. Back to early 2010, in fact:

http://lkml.iu.edu/hypermail/linux/kernel/1005.1/02720.html

At that time I implemented a working multipage write IO path for
XFS, and Christoph integrated that int various OEM products shortly
afterwards. Yes, there have been iomap based XFS implementations out
there in production for over 5 years now, but that code was not
clean enough to even consider merging.

Another reference in 2013, when someone proposed a hack for embedded
systems to optimise the write path:

https://lkml.org/lkml/2013/7/23/809

Then Christoph introduced the struct iomap for pNFS and the XFS
block layout driver in late 2013, and when DAX first came along I
really wanted iomaps to be used up front rather than buffer heads
for block mapping.

Now we've finally got iomaps in the IO path and that's rapidly
cascading through all the XFS IO interfaces and into other
filesystems. This is exactly what we first talked about 6 years ago.

So while it might look like the iomap infrastructure has come out of
nowhere, it's really been a long, long road to get to this point. We
work to a different time scale over here - it's not uncommon to be
planning 5 years ahead for new XFS features. We know how long it
takes to develop, test, review and stabilise significant new
features, so while it might look like something appears and is
committed quickly, that's because you haven't seen the work that has
been done leading up to patches being presented for review and
merge.

Hopefully this will give you some more perspective on why I think
slipping a single release isn't something to get worried about. :)

> Please, help me understand what I can do to get my code reviewed.  Do I need
> to more aggressively ping my patch series, asking people by name for reviews?

On the XFS and fstests lists, if nobody has responded within a few
days (usually a week) then it's OK to ping it and see if anyone has
time to review it. In general, a single ping is enough if the
patchset is in good shape. Fix it all, repost, ping in a week if
there's no followup. Repeat until merge.

> Do we need to rework our code flow to Linus so that the DAX changes go through
> a filesystem tree like XFS or ext4, and ask the developers of that filesystem
> to help with reviews?  Something else?

The question we have to ask here is whether a lack of development
support from a filesystem stop us from driving the DAX
implementation forward?  I've said it before, and I'll say it again:
I'm happy to drive DAX on XFS forwards at the rate at which we can
sustain review via the XFS tree and I don't care if we break support
on ext2 or ext4. If we keep having to wait for ext4 to fix stuff to
catch up with what we want/need to do then progress will continue to
be sporadic and frustrating.  Perhaps it's time to stop waiting for
ext4 to play catchup every time we take a step forwards....

> I'm honestly very frustrated by this because I've done my best to be open to
> constructive criticism and I've tried to respond promptly to the feedback that
> I've received.  In the end, though, a system where it's a requirement that all
> upstreamed code be peer reviewed but in which I can't get any feedback is
> essentially a system where I'm not allowed to contribute.

There's always been a review bottleneck, and everyone ends up on the
end of that frustration from time to time. Delays will happen - it's
just part of the process we all need to deal with. I used to get
frustrated, too, but now I just accept it, roll with it and we've
made it an acceptible part of the process to ping patches when it
looks like they have been forgotten...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
