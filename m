Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 51ADD6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:44:45 -0400 (EDT)
Received: by lbon3 with SMTP id n3so2282502lbo.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:44:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502DD663.2020504@parallels.com>
References: <1345150430-30910-1-git-send-email-yinghan@google.com>
	<502DD663.2020504@parallels.com>
Date: Thu, 16 Aug 2012 22:44:42 -0700
Message-ID: <CALWz4iy=NR=yo5+-jj2nVqUiZtS+3866QiecUv3VGr2bkQONaQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/6] memcg: pass priority to prune_icache_sb()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 10:28 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 08/17/2012 12:53 AM, Ying Han wrote:
>> The same patch posted two years ago at:
>> http://permalink.gmane.org/gmane.linux.kernel.mm/55467
>>
>> No change since then and re-post it now mainly because it is part of the
>> patchset I have internally. Also, the issue that the patch addresses would
>> be more problematic after the patchset.
>>
>> Two changes included:
>> 1. only remove inode with pages in its mapping when reclaim priority hits 0.
>>
>> It helps the situation when shrink_slab() is being too agressive, it ends up
>> removing the inode as well as all the pages associated with the inode.
>> Especially when single inode has lots of pages points to it.
>>
>> The problem was observed on a production workload we run, where it has small
>> number of large files. Page reclaim won't blow away the inode which is pinned
>> by dentry which in turn is pinned by open file descriptor. But if the
>> application is openning and closing the fds, it has the chance to trigger
>> the issue. The application will experience performance hit when that happens.
>>
>> After the whole patchset, the code will call the shrinker more often by adding
>> shrink_slab() into target reclaim. So the performance hit will be more likely
>> to be observed.
>>
>> 2. avoid wrapping up when scanning inode lru.
>>
>> The target_scan_count is calculated based on the userpage lru activity,
>> which could be bigger than the inode lru size. avoid scanning the same
>> inode twice by remembering the starting point for each scan.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> I don't doubt the problem, but having a field in sc that is used for
> only one shrinker, and specifically to address a corner case, sounds
> like a bit of a hack.

Hmm, i don't see adding a extra field into shrink_control could be a big problem
here. and I would argue it is a corner case as well :)

This could happen anytime depending on the workload, and  it could be
even possible
to have all the inode in that state.

>
> Wouldn't it be possible to make sure that such inodes are in the end of
> the shrinkable list, so they are effectively left for last without
> messing with priorities?

You mean rotate them to the end of the list? Thought that is what the
patch end up doing.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
