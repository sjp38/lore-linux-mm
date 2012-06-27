Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 4BAE16B0070
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:55:09 -0400 (EDT)
Message-ID: <4FEAC9CB.2010800@parallels.com>
Date: Wed, 27 Jun 2012 12:52:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
References: <1340725634-9017-1-git-send-email-glommer@parallels.com> <1340725634-9017-3-git-send-email-glommer@parallels.com> <20120626180451.GP3869@google.com> <20120626220809.GA4653@tiehlicka.suse.cz> <20120626221452.GA15811@google.com>
In-Reply-To: <20120626221452.GA15811@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On 06/27/2012 02:14 AM, Tejun Heo wrote:
> Hello, Michal.
>
> On Wed, Jun 27, 2012 at 12:08:09AM +0200, Michal Hocko wrote:
>> According to my experience, people usually create deeper subtrees
>> just because they want to have memcg hierarchy together with other
>> controller(s) and the other controller requires a different topology
>> but then they do not care about memory.* attributes in parents.
>> Those cases are not affected by this change because parents are
>> unlimited by default.
>> Deeper subtrees without hierarchy and independent limits are usually
>> mis-configurations, and we would like to hear about those to help to fix
>> them, or they are unfixable usecases which we want to know about as well
>> (because then we have a blocker for the unified cgroup hierarchy, don't
>> we).
>
> Yeah, this is something I'm seriously considering doing from cgroup
> core.  ie. generating a warning message if the user nests cgroups w/
> controllers which don't support full hierarchy.
>
>>>    Note that the default should still be flat hierarchy.
>>>
>>> 2. Mark flat hierarchy deprecated and produce a warning message if
>>>     memcg is mounted w/o hierarchy option for a year or two.
>>
>> I would agree with you on this with many kernel configurables but
>> this one doesn't fall in. There is a trivial fallback (set root to
>> use_hierarchy=0) so the mount option seems like an overkill - yet
>> another API to keep for some time...
>
> Just disallow clearing .use_hierarchy if it was mounted with the
> option?  We can later either make the file RO 1 for compatibility's
> sake or remove it.

How will it buy us anything, if it is clear by default??

>> So in short, I do think we should go the sanity path and end up
>> with hierarchical trees and sooner we start the better.
>
> I do agree with you in principle, but I still don't think we can
> switch the default behavior underneath the users.
>

I think we all agree with that. I can't speak for Johannes here, but I 
risk saying that he agrees with that as well.

The problem is that we may differ in what means "default behavior".

It is very clear in a system call, API, or any documented feature. We 
never made the guarantee, *ever*, that non-hierarchical might be the 
default.

I understand that users may have grown accustomed to it. But users grow 
accustomed to bugs as well! Bugs change behaviors. In fact, in hardware 
emulation - where it matters, because it is harder to change it - we 
have emulator people actually emulating bugs - because that is what 
software expects.

Is this reason for us to keep bugs around, because people grew 
accustomed to it? Hell no. Well, it might be: If we have a proven user 
base that is big and solid on top of that, it may be fair to say: "Well, 
this is unfortunate, but this is how it plays".

Here, we're discussing - or handwaving as Hannes stated, about whether 
or not we have *some* users relying on this behavior. We must certainly 
agree that this is not by far a solid and big usersbase, or anything at 
the like.

Another analogy I believe it is pertinent: I consider this change much 
closer to icon or button placement in the Desktop market: No one *ever* 
said a particular button stays at a particular place. Yet it was there 
for many releases. If you change it, some people will feel it. So what?
People change it anyway. Because that is *not* anything set in stone.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
