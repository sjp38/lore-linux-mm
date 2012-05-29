Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id AD8876B007B
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:15:51 -0400 (EDT)
Message-ID: <4FC4F5A8.9060506@parallels.com>
Date: Tue, 29 May 2012 20:13:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 19/28] slab: per-memcg accounting of slab caches
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-20-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290951520.4666@router.home> <4FC4F42D.6060601@parallels.com>
In-Reply-To: <4FC4F42D.6060601@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/29/2012 08:07 PM, Glauber Costa wrote:
> On 05/29/2012 06:52 PM, Christoph Lameter wrote:
>> On Fri, 25 May 2012, Glauber Costa wrote:
>>
>>> > This patch charges allocation of a slab object to a particular
>>> > memcg.
>> Ok so a requirement is to support tracking of individual slab
>> objects to cgroups? That is going to be quite expensive since it will
>> touch the hotpaths.
>>
>
> No, we track pages. But all the objects in the page belong to the same
> cgroup.
>

Also, please note the following:

The code that relays us to the right cache, is wrapped inside a static 
branch. Whoever is not using more than the root cgroup, will not suffer 
a single bit.

If you are, but your process is in the right cgroup, you will 
unfortunately pay function call penalty(*), but the code will make and 
effort to detect that as early as possible and resume.


(*) Not even then if you fall in the following categories, that are 
resolved inline:

+       if (!current->mm)
+               return cachep;
+       if (in_interrupt())
+               return cachep;
+       if (gfp & __GFP_NOFAIL)
+               return cachep;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
