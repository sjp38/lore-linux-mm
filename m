Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id CB67F6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:09:43 -0400 (EDT)
Message-ID: <515940E4.8050704@parallels.com>
Date: Mon, 1 Apr 2013 12:10:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-3-git-send-email-glommer@parallels.com> <515936B5.8070501@jp.fujitsu.com>
In-Reply-To: <515936B5.8070501@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg
 Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

Hi Kame,

> Doesn't this break
> 
> ==
>                 /*
>                  * copy the current shrinker scan count into a local variable
>                  * and zero it so that other concurrent shrinker invocations
>                  * don't also do this scanning work.
>                  */
>                 nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
> ==
> 
> This xchg magic ?
> 
> Thnks,
> -Kame

This is done before the actual reclaim attempt, and all it does is to
indicate to other concurrent shrinkers that "I've got it", and others
should not attempt to shrink.

Even before I touch this, this quantity represents the number of
entities we will try to shrink. Not necessarily we will succeed. What my
patch does, is to try at least once if the number is too small.

Before it, we will try to shrink 512 objects and succeed at 0 (because
batch is 1024). After this, we will try to free 512 objects and succeed
at an undefined quantity between 0 and 512.

In both cases, we will zero out nr_in_batch in the shrinker structure to
notify other shrinkers that we are the ones shrinking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
