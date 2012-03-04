Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0A7096B004D
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 02:43:45 -0500 (EST)
Received: by bkwq16 with SMTP id q16so3361151bkw.14
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 23:43:44 -0800 (PST)
Message-ID: <4F531D2C.7090105@openvz.org>
Date: Sun, 04 Mar 2012 11:43:40 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3.3] memcg: fix GPF when cgroup removal races with last
 exit
References: <alpine.LSU.2.00.1203021030140.2094@eggly.anvils> <4F51E4B1.4010607@openvz.org>
In-Reply-To: <4F51E4B1.4010607@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
>>
>> Konstantin, I've not yet looked into how this patch affects your
>> patchsets; but I do know that this surreptitious-switch-to-root
>> behaviour seemed nightmarish when I was doing per-memcg per-zone
>> locking (particularly inside something like __activate_page(), where
>> we del and add under a single lock), and unnecessary once you and I
>> secure the memcg differently.  So you may just want to revert this in
>> patches for linux-next; but I've a suspicion that now we understand
>> it better, this technique might still be usable, and more efficient.
>
> Yes, something like that. But, I  must fix my "isolated-pages" counters first,
> otherwise I just reintroduce this bug again.
>

I have thought little more and invented better approach: we can keep isolated pages
counted in lruvec->lru_size[] and vmstat counters. Thus isolated pages will prevent
removing it's memory cgroup. This method is more complicated than your tricky pushing
pages to root lruvec, but it more generic and does not adds new page-counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
