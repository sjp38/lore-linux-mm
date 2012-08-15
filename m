Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 649DB6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 09:51:51 -0400 (EDT)
Message-ID: <502BA96C.8070602@parallels.com>
Date: Wed, 15 Aug 2012 17:51:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 07/11] mm: Allocate kernel pages to the right memcg
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-8-git-send-email-glommer@parallels.com> <20120814151616.GO4177@suse.de> <502B66F8.30909@parallels.com> <20120815132244.GQ4177@suse.de>
In-Reply-To: <20120815132244.GQ4177@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 08/15/2012 05:22 PM, Mel Gorman wrote:
>> I believe it
>> > to be a better and less complicated approach then letting a page appear
>> > and then charging it. Besides being consistent with the rest of memcg,
>> > it won't create unnecessary disturbance in the page allocator
>> > when the allocation is to fail.
>> > 
> I still don't get why you did not just return a mem_cgroup instead of a
> handle.
> 

Forgot this one, sorry:

The reason is to keep the semantics simple.

What should we return if the code is not compiled in? If we return NULL
for failure, the test becomes

memcg = memcg_kmem_charge_page(gfp, order);
if (!memcg)
  exit;

If we're not compiled in, we'd either return positive garbage or we need
to wrap it inside an ifdef

I personally believe to be a lot more clear to standardize on true
to mean "allocation can proceed".

the compiled out case becomes:

if (!true)
   exit;

which is easily compiled away altogether. Now of course, using struct
mem_cgroup makes sense, and I have already changed that here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
