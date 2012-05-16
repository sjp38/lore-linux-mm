Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 586366B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 19:01:33 -0400 (EDT)
Date: Wed, 16 May 2012 16:01:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 6/6] mm: memcg: print statistics from live counters
Message-Id: <20120516160131.fecb5ddf.akpm@linux-foundation.org>
In-Reply-To: <1337018451-27359-7-git-send-email-hannes@cmpxchg.org>
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
	<1337018451-27359-7-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 May 2012 20:00:51 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Directly print statistics and event counters instead of going through
> an intermediate accumulation stage into a separate array, which used
> to require defining statistic items in more than one place.
> 
> ...
>
> -static const char *memcg_stat_strings[NR_MCS_STAT] = {
> -	"cache",
> -	"rss",
> -	"mapped_file",

Bah humbug, who went and called this mapped_file?

This stat is derived from MEM_CGROUP_STAT_FILE_MAPPED.  But if we
rename MEM_CGROUP_STAT_FILE_MAPPED to MEM_CGROUP_STAT_MAPPED_FILE then
we also need to rename the non-memcg NR_FILE_MAPPED.  And we can't
change the text to "file_mapped" because it's ABI.

> -	"mlock",
> -	"swap",

And "swap" is derived from MEM_CGROUP_STAT_SWAPOUT.  We could rename
that to MEM_CGROUP_STAT_SWAP without trouble.

But both are poor names.  There are two concepts here: a) swapout
events (ie: swap writeout initiation) and b) swapspace usage.  Type a)
only ever counts up, whereas type b) counts up and down.

MEM_CGROUP_STAT_SWAPOUT is actually of type b), but "swapout" is a
misleading term, because it refers to type a) events.

And the human-displayed "swap" is useless because it can refer to
either type a) or type b) events.  These should be called "swapped" and
MEM_CGROUP_STAT_SWAPPED.  But we can't change the userspace interface.

argh, I hate you all!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
