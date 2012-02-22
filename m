Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1F6B16B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:52:51 -0500 (EST)
Message-ID: <4F4500D2.9040207@parallels.com>
Date: Wed, 22 Feb 2012 18:50:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] chained slab caches: move pages to a different cache
 when a cache is destroyed.
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <1329824079-14449-5-git-send-email-glommer@parallels.com> <CABCjUKBQZZ1fjKMAt5LdxzkVEhj3Ro9nxySH2rM8=N8Hk=OQzQ@mail.gmail.com>
In-Reply-To: <CABCjUKBQZZ1fjKMAt5LdxzkVEhj3Ro9nxySH2rM8=N8Hk=OQzQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul
 Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka
 Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 02/22/2012 03:40 AM, Suleiman Souhlal wrote:
> On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa<glommer@parallels.com>  wrote:
>> In the context of tracking kernel memory objects to a cgroup, the
>> following problem appears: we may need to destroy a cgroup, but
>> this does not guarantee that all objects inside the cache are dead.
>> This can't be guaranteed even if we shrink the cache beforehand.
>>
>> The simple option is to simply leave the cache around. However,
>> intensive workloads may have generated a lot of objects and thus
>> the dead cache will live in memory for a long while.
>
> Why is this a problem?
>
> Leaving the cache around while there are still active objects in it
> would certainly be a lot simpler to understand and implement.
>

Yeah, I agree on the simplicity. The chained stuff was probably the 
hardest one in the patchset to get working alright. However, my 
assumptions are as follow:

1) If we bother to be tracking kernel memory, it is because we believe 
its usage can skyrocket under certain circumstances. In those scenarios, 
we'll have a lot of objects around. If we just let them flowing, it's 
just wasted memory that was created from the memcg, but can't be 
reclaimed on its behalf.

2) We can reclaim that, if we have, as a policy, to always start 
shrinking from those when global pressure kicks in. But then, we move 
the complication from one part to another.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
