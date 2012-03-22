Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4182A6B0092
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:07:33 -0400 (EDT)
Message-ID: <4F6B787B.4050109@redhat.com>
Date: Thu, 22 Mar 2012 15:07:39 -0400
From: KOSAKI Motohiro <mkosaki@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home>
In-Reply-To: <alpine.DEB.2.00.1203221348470.25011@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, lwoodman@redhat.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

(3/22/12 2:51 PM), Christoph Lameter wrote:
> On Thu, 22 Mar 2012, KOSAKI Motohiro wrote:
>
>> CC to Christoph.
>>
>>> While moving tasks between cpusets I noticed some strange behavior.
>>> Specifically if the nodes of the destination
>>> cpuset are a subset of the nodes of the source cpuset do_migrate_pages()
>>> will move pages that are already on a node
>>> in the destination cpuset. The reason for this is do_migrate_pages() does
>>> not check whether each node in the source
>>> nodemask is in the destination nodemask before calling migrate_to_node(). If
>>> we simply do this check and skip them
>>> when the source is in the destination moving we wont move nodes that dont
>>> need to be moved.
>>>
>>> Adding a little debug printk to migrate_to_node():
>>>
>>> Without this change migrating tasks from a cpuset containing nodes 0-7 to a
>>> cpuset containing nodes 3-4, we migrate
>>> from ALL the nodes even if they are in the both the source and destination
>>> nodesets:
>>>
>>> Migrating 7 to 4
>>> Migrating 6 to 3
>>> Migrating 5 to 4
>>> Migrating 4 to 3
>>> Migrating 1 to 4
>>> Migrating 3 to 4
>>> Migrating 0 to 3
>>> Migrating 2 to 3
>>
>> Wait.
>>
>> This may be non-optimal for cpusets, but maybe optimal migrate_pages,
>> especially
>> the usecase is HPC. I guess this is intended behavior. I think we need to hear
>> Christoph's intention.
>>
>> But, I'm not against this if he has no objection.
>
> The use case for this is if you have an app running on nodes 3,4,5 on your
> machine and now you want to shift it to 4,5,6. The expectation is that the
> location of the pages relative to the first node stay the same.
> Application may manage their locality given a range of nodes and each of
> the x .. x+n nodes has their particular purpose.
>
> If you justd copy 3 to 6 then the app may get confused when doing
> additional allocations since different types of information is now stored
> on the "first" node (which is now 4).

MPOL_INTERLEAVE is more simple situaltion. applications naturally assume the
memory is mapped intealeaving and application threads optimize for it. if we
broke intereaving, the applications may slow down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
