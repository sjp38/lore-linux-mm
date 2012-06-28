Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id B2F6C6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:48:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 344853EE0BB
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:48:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B4ED45DE5C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:48:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFBE845DE54
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:48:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE62AE38004
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:48:12 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 684FD1DB804A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:48:12 +0900 (JST)
Message-ID: <4FEC19C9.4090708@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 17:46:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
References: <1340725634-9017-1-git-send-email-glommer@parallels.com> <1340725634-9017-3-git-send-email-glommer@parallels.com> <20120626180451.GP3869@google.com> <20120626220809.GA4653@tiehlicka.suse.cz> <20120626221452.GA15811@google.com> <20120627125119.GE5683@tiehlicka.suse.cz> <20120627173336.GJ15811@google.com>
In-Reply-To: <20120627173336.GJ15811@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

(2012/06/28 2:33), Tejun Heo wrote:
> Hello, Michal.
>
> On Wed, Jun 27, 2012 at 02:51:19PM +0200, Michal Hocko wrote:
>>> Yeah, this is something I'm seriously considering doing from cgroup
>>> core.  ie. generating a warning message if the user nests cgroups w/
>>> controllers which don't support full hierarchy.
>>
>> This is a good idea.
>
> And I want each controller either to do proper hierarchy or not at all
> and disallow switching the behavior while mounted - at least disallow
> switching off hierarchy support dynamically.
>
>>> Just disallow clearing .use_hierarchy if it was mounted with the
>>> option?
>>
>> Dunno, mount option just doesn't feel right. We do not offer other
>> attributes to be set by them so it would be just confusing. Besides that
>> it would require an integration into existing tools like cgconfig which
>> is yet another pain just because of something that we never promissed to
>> keep a certain way. There are many people who don't work with mount&fs
>> cgroups directly but rather use libcgroup for that...
>
> If the default behavior has to be switched without extra input from
> userland, that should be noisy like hell and slow.  e.g. generate
> warning messages whenever userland does something which is to be
> deprecated - nesting when .use_hierarchy == 0, mixing .use_hierarchy
> == 0 / 1, and maybe later on, using .use_hierarchy == 0 at all.
>
> Hmm.... we need to switch other controllers over to hierarchical
> behavior too.  We may as well just do it from cgroup core.  Once we
> rule out all users of pseudo hierarchy - nesting with controllers
> which don't support hierarchy - switching on hierarchy support
> per-controller shouldn't cause much problem.
>
> How about the following then?
>
> * I'll add a way for controllers to tell cgroup core that full
>    hierarchy support is supported and a cgroup mount option to enable
>    hierarchy (cgroup core itself already uses a number of mount options
>    and libgroup or whatever should be able to deal with it).
>
>    cgroup will refuse to mount if the hierarchy option is specified
>    with a controller which doesn't support hierarchy and it will also
>    whine like crazy if the userland tries to nest without the mount
>    option specified.
>
>    Each controller must enforce hierarchy once so directed by cgroup
>    mount option.
>
> * While doing that, all applicable controllers will be updated to
>    support hierarchy.
>
> * After sufficient time has passed, nesting without the mount option
>    specified will be failed by cgroup core.
>
> As for memcg's .use_hierarchy, make it RO 1 if the cgroup indicates
> that hierarchy should be used.  Otherwise, I don't know but make sure
> it gets phased out out use somehow.
>


  The reason for use_hierarchy file was just _performance_, it _was_ terrible.
  Now it's not very good but not terrible.


You all may think this as crazy idea. How about versioning ?

Creating 'memory2'(memory cgroup v2) cgroup and mark 'memory' cgroup as deprecated,
and put it to feature-removal-list.

Of course, memory2 cgroup doesn't have use_hierarchy file and have kmem accounting.
We should disallow to use memory and memory2 at the same time.

Or, add version file to cgroup subsys ? select v2 as default...user can choose v1
with mount option if necessary, but it will not be maintained.
Is it too difficult or messy ?

To keep user experience, versioning is a way. And we can see how the changes
affects users.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
