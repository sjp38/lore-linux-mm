Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 62F6B6B00D4
	for <linux-mm@kvack.org>; Tue,  7 May 2013 09:35:28 -0400 (EDT)
Message-ID: <51890336.2080509@parallels.com>
Date: Tue, 7 May 2013 17:35:50 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 02/31] vmscan: take at least one pass with shrinkers
References: <1367018367-11278-1-git-send-email-glommer@openvz.org> <1367018367-11278-3-git-send-email-glommer@openvz.org> <20130430132239.GB6415@suse.de> <517FC7B4.5030101@parallels.com> <20130430153707.GD11497@suse.de>
In-Reply-To: <20130430153707.GD11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On 04/30/2013 07:37 PM, Mel Gorman wrote:
> On Tue, Apr 30, 2013 at 05:31:32PM +0400, Glauber Costa wrote:
>> On 04/30/2013 05:22 PM, Mel Gorman wrote:
>>> On Sat, Apr 27, 2013 at 03:18:58AM +0400, Glauber Costa wrote:
>>>> In very low free kernel memory situations, it may be the case that we
>>>> have less objects to free than our initial batch size. If this is the
>>>> case, it is better to shrink those, and open space for the new workload
>>>> then to keep them and fail the new allocations.
>>>>
>>>> More specifically, this happens because we encode this in a loop with
>>>> the condition: "while (total_scan >= batch_size)". So if we are in such
>>>> a case, we'll not even enter the loop.
>>>>
>>>> This patch modifies turns it into a do () while {} loop, that will
>>>> guarantee that we scan it at least once, while keeping the behaviour
>>>> exactly the same for the cases in which total_scan > batch_size.
>>>>
>>>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>>>> Reviewed-by: Dave Chinner <david@fromorbit.com>
>>>> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
>>>> CC: "Theodore Ts'o" <tytso@mit.edu>
>>>> CC: Al Viro <viro@zeniv.linux.org.uk>
>>>
>>> There are two cases where this *might* cause a problem and worth keeping
>>> an eye out for.
>>>
>>
>> Any test case that you envision that could help bringing those issues
>> forward should they exist ? (aside from getting it into upstream trees
>> early?)
>>
> 
> hmm.
> 
> fsmark multi-threaded in a small-memory machine with a small number of
> very large files greater than the size of physical memory might trigger
> it. There should be a small number of inodes active so less than the 128
> that would have been ignored before the patch. As the files are larger
> than memory, kswapd will be awake and calling shrinkers so if the
> shrinker is really discarding active inodes then the performance will
> degrade.
> 
FYI: The weird behavior you found on benchmarks is due to this patch.
The problem is twofold:

first, by always scanning we fail to differentiate from the 0 condition,
which means skip it. We should have at least 1 object in the counter to
scan.

second, nr_to_scan continues being a batch. So when count returns, say,
3 objects, the shrinker will still try to free, say, 128 objects. And in
some situations, it might very well succeed.

I have already fixed this, and as soon as I finish merging all your
suggestions I will send an updated version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
