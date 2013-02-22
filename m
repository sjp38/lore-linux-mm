Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 64B076B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 10:08:41 -0500 (EST)
Message-ID: <51278A12.4000504@parallels.com>
Date: Fri, 22 Feb 2013 19:09:06 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: correctly bootstrap boot caches
References: <1361529030-17462-1-git-send-email-glommer@parallels.com> <0000013d026b4e5f-1b3deecb-7e37-4476-a27b-3a7db8c1f0a8-000000@email.amazonses.com>
In-Reply-To: <0000013d026b4e5f-1b3deecb-7e37-4476-a27b-3a7db8c1f0a8-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 02/22/2013 07:00 PM, Christoph Lameter wrote:
> On Fri, 22 Feb 2013, Glauber Costa wrote:
> 
>> Although not verified in practice, I also point out that it is not safe to scan
>> the full list only when debugging is on in this case. As unlikely as it is, it
>> is theoretically possible for the pages to be full. If they are, they will
>> become unreachable. Aside from scanning the full list, we also need to make
>> sure that the pages indeed sit in there: the easiest way to do it is to make
>> sure the boot caches have the SLAB_STORE_USER debug flag set.
> 
> SLAB_STORE_USER typically increases the size of the managed object. It is
> not available when slab debugging is not compiled in. There is no list of
> full slab objects that is maintained in the non debug case and if the
> allocator is compiled without debug support also the code to manage full
> lists will not be present.
> 
> Only one or two kmem_cache item is allocated in the bootstrap code and so
> far the size of the objects was signficantly smaller than page size. So
> the slab pages will be on the partial lists. Why are your slab management
> structures so large that a page can no longer contain multiple objects?
> 
They are not.

As I've mentioned in the description, the real bug is from partial slabs
being temporarily in the cpu_slab during a recent allocation and
therefore unreachable through the partial list.

I've just read the code, and it seemed to me that theoretically that
could happen. I agree with you that this is an unlikely scenario and if
you prefer I can resend the patch without that part.

Would that be preferable ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
