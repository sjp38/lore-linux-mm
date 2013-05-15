Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B15716B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 10:11:01 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Date: Wed, 15 May 2013 16:10:57 +0200
Subject: Re: [RFC PATCH 0/2] return value from shrinkers
Message-ID: <20130515141057.GA24072@caracas.corpusers.net>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
 <5192523B.7030805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5192523B.7030805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Lekanovic, Radovan" <Radovan.Lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

On 17:03 Tue 14 May     , Glauber Costa wrote:
> On 05/13/2013 06:16 PM, Oskar Andero wrote:
> > Hi,
> > 
> > In a previous discussion on lkml it was noted that the shrinkers use the
> > magic value "-1" to signal that something went wrong.
> > 
> > This patch-set implements the suggestion of instead using errno.h values
> > to return something more meaningful.
> > 
> > The first patch simply changes the check from -1 to any negative value and
> > updates the comment accordingly.
> > 
> > The second patch updates the shrinkers to return an errno.h value instead
> > of -1. Since this one spans over many different areas I need input on what is
> > a meaningful return value. Right now I used -EBUSY on everything for consitency.
> > 
> > What do you say? Is this a good idea or does it make no sense at all?
> > 
> > Thanks!
> > 
> 
> Right now me and Dave are completely reworking the way shrinkers
> operate. I suggest, first of all, that you take a look at that cautiously.

Sounds good. Where can one find the code for that?

> On the specifics of what you are doing here, what would be the benefit
> of returning something other than -1 ? Is there anything we would do
> differently for a return value lesser than 1?

Firstly, what bugs me is the magic and unintuitiveness of using -1 rather than a
more descriptive error code. IMO, even a #define SHRINK_ERROR -1 in some header
file would be better.

Expanding the test to <0 will open up for more granular error checks,
like -EAGAIN, -EBUSY and so on. Currently, they would all be treated the same,
but maybe in the future we would like to handle them differently?

Finally, looking at the code:
                        if (shrink_ret == -1)
                                break;
                        if (shrink_ret < nr_before)
                                ret += nr_before - shrink_ret;

This piece of code will only function if shrink_ret is either greater than zero
or -1. If shrink_ret is -2 this will lead to undefined behaviour.

> So far, shrink_slab behaves the same, you are just expanding the test.
> If you really want to push this through, I would suggest coming up with
> a more concrete reason for why this is wanted.

I don't know how well this patch is aligned with your current rework, but
based on my comments above, I don't see a reason for not taking it.

-Oskar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
