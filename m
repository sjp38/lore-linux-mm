Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 24FD16B005D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 15:12:58 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Thu, 9 Aug 2012 15:12:55 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 10ED2C90050
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 15:12:25 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q79JCO1g110706
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 15:12:24 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q79JBxlr027389
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 13:12:02 -0600
Message-ID: <50240B77.2060204@linaro.org>
Date: Thu, 09 Aug 2012 12:11:51 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] [RFC] Add volatile range management code
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org> <1343447832-7182-2-git-send-email-john.stultz@linaro.org> <CANN689HWYO5DD_p7yY39ethcFu_JO9hudMcDHd=K8FUfhpHZOg@mail.gmail.com>
In-Reply-To: <CANN689HWYO5DD_p7yY39ethcFu_JO9hudMcDHd=K8FUfhpHZOg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/09/2012 02:46 AM, Michel Lespinasse wrote:
> On Fri, Jul 27, 2012 at 8:57 PM, John Stultz <john.stultz@linaro.org> wrote:
>> v5:
>> * Drop intervaltree for prio_tree usage per Michel &
>>    Dmitry's suggestions.
> Actually, I believe the ranges you need to track are non-overlapping, correct ?
Correct.  Any overlapping range is coalesced.

> If that is the case, a simple rbtree, sorted by start-of-range
> address, would work best.
> (I am trying to remove prio_tree users... :)

Sigh.  Sure.  Although I've blown with the wind on a number of different 
approaches for storing the ranges. I'm not particularly passionate about 
it, but the continual conflicting suggestions are a slight frustration.  :)


>> +       /* First, find any existing intervals that overlap */
>> +       prio_tree_iter_init(&iter, root, start, end);
> Note that prio tree iterations take intervals as [start; last] not [start; end[
> So if you want to stick with prio trees, you would have to use end-1 here.
Thanks!  I think I hit this off-by-one issue in my testing, but fixed it 
on the backend  w/ :

     modify_range(&inode->i_data, start, end-1, &mark_nonvolatile_page);

Clearly fixing it at the start instead of papering over it is better.


>> +       node = prio_tree_next(&iter);
>> +       while (node) {
> I'm confused, I don't think you ever expect more than one range to
> match, do you ???

So yea.  If you already have two ranges (0-5),(10-15) and then add range 
(0-20) we need to coalesce the two existing ranges into the new one.


> This is far from a complete code review, but I just wanted to point
> out a couple details that jumped to me first. I am afraid I am missing
> some of the background about how the feature is to be used to really
> dig into the rest of the changes at this point :/

Well, I really appreciate any feedback here.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
