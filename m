Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DAD0C8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:47:19 -0500 (EST)
Date: Thu, 17 Feb 2011 14:46:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
Message-Id: <20110217144643.0d60bef4.akpm@linux-foundation.org>
In-Reply-To: <4D5C7ED1.2070601@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com>
	<4D5C7ED1.2070601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?Q?=E7=BC=AA_=E5=8B=B0?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Thu, 17 Feb 2011 09:50:09 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> +/*
> + * In functions that can't propogate errno to users, to avoid declaring a
> + * nodemask_t variable, and avoid using NODEMASK_ALLOC that can return
> + * -ENOMEM, we use this global cpuset_mems.
> + *
> + * It should be used with cgroup_lock held.

I'll do s/should/must/ - that would be a nasty bug.

I'd be more comfortable about the maintainability of this optimisation
if we had

	WARN_ON(!cgroup_is_locked());

at each site.

> + */
> +static nodemask_t cpuset_mems;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
