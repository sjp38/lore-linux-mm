Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A538E6B0399
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 18:29:29 -0400 (EDT)
Message-ID: <4FE8E5A8.6020106@parallels.com>
Date: Tue, 26 Jun 2012 02:26:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix bad behavior in use_hierarchy file
References: <1340616061-1955-1-git-send-email-glommer@parallels.com> <20120625204908.GL3869@google.com>
In-Reply-To: <20120625204908.GL3869@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org, Dhaval Giani <dhaval.giani@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 06/26/2012 12:49 AM, Tejun Heo wrote:
> On Mon, Jun 25, 2012 at 01:21:01PM +0400, Glauber Costa wrote:
>> I have an application that does the following:
>>
>> * copy the state of all controllers attached to a hierarchy
>> * replicate it as a child of the current level.
>>
>> I would expect writes to the files to mostly succeed, since they
>> are inheriting sane values from parents.
>>
>> But that is not the case for use_hierarchy. If it is set to 0, we
>> succeed ok. If we're set to 1, the value of the file is automatically
>> set to 1 in the children, but if userspace tries to write the
>> very same 1, it will fail. That same situation happens if we
>> set use_hierarchy, create a child, and then try to write 1 again.
>>
>> Now, there is no reason whatsoever for failing to write a value
>> that is already there. It doesn't even match the comments, that
>> states:
>>
>>   /* If parent's use_hierarchy is set, we can't make any modifications
>>    * in the child subtrees...
>>
>> since we are not changing anything.
>>
>> The following patch tests the new value against the one we're storing,
>> and automatically return 0 if we're not proposing a change.
>
> A bit of delta but is there any chance we can either deprecate
> .use_hierarhcy or at least make it global toggle instead of subtree
> thing?  This seems needlessly complicated. :(
>

I am for deprecating. If this is a long term goal, a two-phase process 
making it per-tree seems unnecessary and even more confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
