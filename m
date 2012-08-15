Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 517EE6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 15:25:47 -0400 (EDT)
Message-ID: <502BF6FA.6050602@parallels.com>
Date: Wed, 15 Aug 2012 23:22:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz> <000001392ac15404-43a3fd2c-a6d3-4985-b173-74bb586ad47c-000000@email.amazonses.com> <502BBC35.809@parallels.com> <000001392aec1926-72b3a631-1fb1-460c-803d-38c4405151e1-000000@email.amazonses.com> <CALWz4ixv8wfOqQ34CBLQ1jVdWoQc4-hQRkeRTb6U5x93gxjZZw@mail.gmail.com> <000001392b881bf0-4cf7cb93-c142-4ddb-960a-b35390caca0f-000000@email.amazonses.com>
In-Reply-To: <000001392b881bf0-4cf7cb93-c142-4ddb-960a-b35390caca0f-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On 08/15/2012 10:25 PM, Christoph Lameter wrote:
> On Wed, 15 Aug 2012, Ying Han wrote:
> 
>>> How can you figure out which objects belong to which memcg? The ownerships
>>> of dentries and inodes is a dubious concept already.
>>
>> I figured it out based on the kernel slab accounting.
>> obj->page->kmem_cache->memcg
> 
> Well that is only the memcg which allocated it. It may be in use heavily
> by other processes.
> 

Yes, but a lot of the use cases for cgroups/containers are pretty local.
That is why we have been able to get away with a first-touch mechanism
even in user pages memcg. In those cases - which we expect to be the
majority of them - this will perform well.

Now, this is not of course representative of the whole range of possible
use cases, and others are valid. There are people like Greg
and Ying Han herself that want a more fine grained control on which
memcg gets the accounting. That is one of the topics for the summit.

But even then: regardless of what mechanism is in place, one cgroup is
to be accounted (or not accounted at all, meaning it belongs to a
non-accounted cgroup). And then we can just grab whichever memcg it was
allocated from and shrink it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
