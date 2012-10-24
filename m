Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B27736B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 04:19:18 -0400 (EDT)
Message-ID: <50881500.9030604@parallels.com>
Date: Wed, 24 Oct 2012 20:19:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 04/18] slab: don't preemptively remove element from
 list in cache destroy
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-5-git-send-email-glommer@parallels.com> <0000013a7a84cb28-334eab12-33c4-4a92-bd9c-e5ad938f83d0-000000@email.amazonses.com> <5085068E.5080304@parallels.com> <CAOJsxLFxQuC9mRb=ZMoqdxS6fyLHCg1LxyfF9wAR1hiOL5i93g@mail.gmail.com>
In-Reply-To: <CAOJsxLFxQuC9mRb=ZMoqdxS6fyLHCg1LxyfF9wAR1hiOL5i93g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, devel@openvz.org, Suleiman Souhlal <suleiman@google.com>

On 10/24/2012 10:54 AM, Pekka Enberg wrote:
> On Mon, Oct 22, 2012 at 11:40 AM, Glauber Costa <glommer@parallels.com> wrote:
>> On 10/19/2012 11:34 PM, Christoph Lameter wrote:
>>> On Fri, 19 Oct 2012, Glauber Costa wrote:
>>>
>>>> I, however, see no reason why we need to do so, since we are now locked
>>>> during the whole deletion (which wasn't necessarily true before).  I
>>>> propose a simplification in which we delete it only when there is no
>>>> more going back, so we don't need to add it again.
>>>
>>> Ok lets hope that holding the lock does not cause issues.
>>>
>>> Acked-by: Christoph Lameter <cl@linux.com>
>>>
>> BTW: One of the good things about this set, is that we are naturally
>> exercising cache destruction a lot more than we did before. So if there
>> is any problem, either with this or anything related to cache
>> destruction, it should at least show up a lot more frequently. So far,
>> this does not seem to cause any problems.
> 
> We no longer hold the mutex the whole time after. See commit 210ed9d
> ("mm, slab: release slab_mutex earlier in kmem_cache_destroy()") for
> details.
> 
I will resubmit then.

It doesn't really change the spirit of the patch. I took a look at that
fix, and what it does, is it releases the mutex right after
kmem_cache_shutdown() succeeds. Removing from the list in there would do
the trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
