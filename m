Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D9C5A6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 18:07:40 -0500 (EST)
Received: by qcsd16 with SMTP id d16so2848180qcs.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 15:07:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4CD731.60908@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-8-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD731.60908@parallels.com>
Date: Tue, 28 Feb 2012 15:07:39 -0800
Message-ID: <CABCjUKCaJVGShRKRkvBMrz_XNVGNrcguQ1uTP8Am1fQ1Te6PWA@mail.gmail.com>
Subject: Re: [PATCH 07/10] memcg: Stop res_counter underflows.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 5:31 AM, Glauber Costa <glommer@parallels.com> wrote:
> I don't fully understand this.
> To me, the whole purpose of having a cache tied to a memcg, is that we know
> all allocations from that particular cache should be billed to a specific
> memcg. So after a cache is created, and has an assigned memcg,
> what's the point in bypassing it to root?
>
> It smells like you're just using this to circumvent something...

In the vast majority of the cases, we will be able to account to the cgroup.
However, there are cases when __mem_cgroup_try_charge() is not able to
do so, like when the task is being killed.
When this happens, the allocation will not get accounted to the
cgroup, but the slab accounting code will still think the page belongs
to the memcg's kmem_cache.
So, when we go to free the page, we assume that the page belongs to
the memcg and uncharge it, even though it was never charged to us in
the first place.

This is the situation this patch is trying to address, by keeping a
counter of how much memory has been bypassed like this, and uncharging
from the root if we have any outstanding bypassed memory.

Does that make sense?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
