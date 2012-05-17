Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id C84A36B0082
	for <linux-mm@kvack.org>; Wed, 16 May 2012 20:03:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D22C63EE0B6
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:03:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB89445DE8D
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:03:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4DE445DE8A
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:03:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98B351DB803E
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:03:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 481F41DB8038
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:03:33 +0900 (JST)
Message-ID: <4FB43FDB.6050300@jp.fujitsu.com>
Date: Thu, 17 May 2012 09:01:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 6/6] mm: memcg: print statistics from live counters
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org> <1337018451-27359-7-git-send-email-hannes@cmpxchg.org> <20120516160131.fecb5ddf.akpm@linux-foundation.org>
In-Reply-To: <20120516160131.fecb5ddf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/17 8:01), Andrew Morton wrote:

> On Mon, 14 May 2012 20:00:51 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
>> Directly print statistics and event counters instead of going through
>> an intermediate accumulation stage into a separate array, which used
>> to require defining statistic items in more than one place.
>>
>> ...
>>
>> -static const char *memcg_stat_strings[NR_MCS_STAT] = {
>> -	"cache",
>> -	"rss",
>> -	"mapped_file",
> 
> Bah humbug, who went and called this mapped_file?
> 
> This stat is derived from MEM_CGROUP_STAT_FILE_MAPPED.  But if we
> rename MEM_CGROUP_STAT_FILE_MAPPED to MEM_CGROUP_STAT_MAPPED_FILE then
> we also need to rename the non-memcg NR_FILE_MAPPED.  And we can't
> change the text to "file_mapped" because it's ABI.
> 


Sorry..

>> -	"mlock",
>> -	"swap",
> 
> And "swap" is derived from MEM_CGROUP_STAT_SWAPOUT.  We could rename
> that to MEM_CGROUP_STAT_SWAP without trouble.
> 

Yes.

> But both are poor names.  There are two concepts here: a) swapout
> events (ie: swap writeout initiation) and b) swapspace usage.  Type a)
> only ever counts up, whereas type b) counts up and down.
> 
> MEM_CGROUP_STAT_SWAPOUT is actually of type b), but "swapout" is a
> misleading term, because it refers to type a) events.
> 

I'll prepare a patch.

> And the human-displayed "swap" is useless because it can refer to
> either type a) or type b) events.  These should be called "swapped" and
> MEM_CGROUP_STAT_SWAPPED.  But we can't change the userspace interface.
> 
> argh, I hate you all!
> 

Hm...sorry. I(fujitsu) am now considering to add meminfo for memcg...,

add an option to override /proc/meminfo if a task is in container or
meminfo file somewhere.
(Now, we cannot trust /usr/bin/free, /usr/bin/top etc...in a container.)

so...I think usual user experience will be better because of the same format
with meminfo.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
