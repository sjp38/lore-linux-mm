Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 633B36B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 10:09:38 -0400 (EDT)
Message-ID: <50169593.5020506@parallels.com>
Date: Mon, 30 Jul 2012 18:09:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] memcg: skip memcg kmem allocations in specified
 code regions
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <1343227101-14217-5-git-send-email-glommer@parallels.com> <20120730125004.GA27293@shutemov.name>
In-Reply-To: <20120730125004.GA27293@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Frederic Weisbecker <fweisbec@gmail.com>, devel@openvz.org, cgroups@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>

On 07/30/2012 04:50 PM, Kirill A. Shutemov wrote:
> On Wed, Jul 25, 2012 at 06:38:15PM +0400, Glauber Costa wrote:
>> This patch creates a mechanism that skip memcg allocations during
>> certain pieces of our core code. It basically works in the same way
>> as preempt_disable()/preempt_enable(): By marking a region under
>> which all allocations will be accounted to the root memcg.
>>
>> We need this to prevent races in early cache creation, when we
>> allocate data using caches that are not necessarily created already.
> 
> Why not a GFP_* flag?
> 

The main reason for this is to prevent nested calls of
kmem_cache_create(), since they could create (and in my tests, do
create) funny circular dependencies with each other. So the cache
creation itself would proceed without involving memcg.

At first, it is a bit weird to have cache creation itself depending on a
allocation flag test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
