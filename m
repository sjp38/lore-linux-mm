Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E403F6B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 05:14:57 -0400 (EDT)
Message-ID: <4FEC1FF1.4020300@parallels.com>
Date: Thu, 28 Jun 2012 13:12:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
References: <1340725634-9017-1-git-send-email-glommer@parallels.com> <1340725634-9017-3-git-send-email-glommer@parallels.com> <20120626180451.GP3869@google.com> <20120626220809.GA4653@tiehlicka.suse.cz> <20120626221452.GA15811@google.com> <20120627125119.GE5683@tiehlicka.suse.cz> <20120627173336.GJ15811@google.com> <4FEC19C9.4090708@jp.fujitsu.com>
In-Reply-To: <4FEC19C9.4090708@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, David
 Rientjes <rientjes@google.com>

On 06/28/2012 12:46 PM, Kamezawa Hiroyuki wrote:
> (2012/06/28 2:33), Tejun Heo wrote:
>> Hello, Michal.
>>
>> On Wed, Jun 27, 2012 at 02:51:19PM +0200, Michal Hocko wrote:
>>>> Yeah, this is something I'm seriously considering doing from cgroup
>>>> core.  ie. generating a warning message if the user nests cgroups w/
>>>> controllers which don't support full hierarchy.
>>>
>>> This is a good idea.
>>
>> And I want each controller either to do proper hierarchy or not at all
>> and disallow switching the behavior while mounted - at least disallow
>> switching off hierarchy support dynamically.
>>
>>>> Just disallow clearing .use_hierarchy if it was mounted with the
>>>> option?
>>>
>>> Dunno, mount option just doesn't feel right. We do not offer other
>>> attributes to be set by them so it would be just confusing. Besides that
>>> it would require an integration into existing tools like cgconfig which
>>> is yet another pain just because of something that we never promissed to
>>> keep a certain way. There are many people who don't work with mount&fs
>>> cgroups directly but rather use libcgroup for that...
>>
>> If the default behavior has to be switched without extra input from
>> userland, that should be noisy like hell and slow.  e.g. generate
>> warning messages whenever userland does something which is to be
>> deprecated - nesting when .use_hierarchy == 0, mixing .use_hierarchy
>> == 0 / 1, and maybe later on, using .use_hierarchy == 0 at all.
>>
>> Hmm.... we need to switch other controllers over to hierarchical
>> behavior too.  We may as well just do it from cgroup core.  Once we
>> rule out all users of pseudo hierarchy - nesting with controllers
>> which don't support hierarchy - switching on hierarchy support
>> per-controller shouldn't cause much problem.
>>
>> How about the following then?
>>
>> * I'll add a way for controllers to tell cgroup core that full
>>    hierarchy support is supported and a cgroup mount option to enable
>>    hierarchy (cgroup core itself already uses a number of mount options
>>    and libgroup or whatever should be able to deal with it).
>>
>>    cgroup will refuse to mount if the hierarchy option is specified
>>    with a controller which doesn't support hierarchy and it will also
>>    whine like crazy if the userland tries to nest without the mount
>>    option specified.
>>
>>    Each controller must enforce hierarchy once so directed by cgroup
>>    mount option.
>>
>> * While doing that, all applicable controllers will be updated to
>>    support hierarchy.
>>
>> * After sufficient time has passed, nesting without the mount option
>>    specified will be failed by cgroup core.
>>
>> As for memcg's .use_hierarchy, make it RO 1 if the cgroup indicates
>> that hierarchy should be used.  Otherwise, I don't know but make sure
>> it gets phased out out use somehow.
>>
> 
> 
>  The reason for use_hierarchy file was just _performance_, it _was_
> terrible.
>  Now it's not very good but not terrible.
> 
> 
> You all may think this as crazy idea. How about versioning ?
> 
> Creating 'memory2'(memory cgroup v2) cgroup and mark 'memory' cgroup as
> deprecated,
> and put it to feature-removal-list.
> 
> Of course, memory2 cgroup doesn't have use_hierarchy file and have kmem
> accounting.
> We should disallow to use memory and memory2 at the same time.
> 
> Or, add version file to cgroup subsys ? select v2 as default...user can
> choose v1
> with mount option if necessary, but it will not be maintained.
> Is it too difficult or messy ?
> 
> To keep user experience, versioning is a way. And we can see how the
> changes
> affects users.
> 

I think it needs more consideration.

Let's consider the following points:

* We are having a hard time getting rid of a file we know we hurt us.
* We can identify at least a bazillion other points in which we suck.
  Some of them may be user visible, and we'll have an equally hard time
  fixing it
* People like Michal and David are raising points on the lines of
  "I have this setup working, everything we add or remove may break it"
  I agree with it sometimes, disagree at others(*).
* I really doubt memcg as it is now - even considered kmem in, is
  "finished". This means more additions are likely to follow, and
  waiting for it to ever be "finished" would be waiting forever.

I don't necessarily agree with versioning. Mainly, because we have no
one in the other end negotiating the features. Versioning makes more
sense in those environments, where you can actually adapt your
application to whatever you see in the version field, and conversely
request a version you are safe with.

But the point I want to make here is that whatever we agree on, we
should work towards something that will allow us to more freely change
and fix memcg in the future, without going through this discussion every
single time.



(*) Please note that I am not saying it is okay to break setups!!! I am
only saying that I disagree that some actions will break setups that are
used within reasonability.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
