Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3B5266B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 05:32:47 -0400 (EDT)
Message-ID: <503354FF.1070809@parallels.com>
Date: Tue, 21 Aug 2012 13:29:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
References: <1343942658-13307-1-git-send-email-yinghan@google.com> <20120803152234.GE8434@dhcp22.suse.cz> <501BF952.7070202@redhat.com> <CALWz4iw6Q500k5qGWaubwLi-3V3qziPuQ98Et9Ay=LS0-PB0dQ@mail.gmail.com> <20120806133324.GD6150@dhcp22.suse.cz> <CALWz4iw2NqQw3FgjM9k6nbMb7k8Gy2khdyL_9NpGM6T7Ma5t3g@mail.gmail.com> <5031EF4C.6070204@parallels.com> <CALWz4izy1zK5ZNZOK+82x-YPa-WdQnJu1Gq=70SDJmOVVrpPwQ@mail.gmail.com>
In-Reply-To: <CALWz4izy1zK5ZNZOK+82x-YPa-WdQnJu1Gq=70SDJmOVVrpPwQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/20/2012 10:30 PM, Ying Han wrote:
> Not exactly. Here reclaiming from root is mainly for "reclaiming from
> root's exclusive lru", which links the page includes:
> 1. processes running under root
> 2. reparented pages from rmdir memcg under root
> 3. bypassed pages
> 
> Setting root cgroup's softlimit = 0 has the implication of putting
> those pages to likely to reclaim, which works fine. The question is
> that if no other memcg is above its softlimit, would it be a problem
> to adding a bit extra pressure to root which always is eligible for
> softlimit reclaim ( usage is always greater than softlimit).
> 
> As an example, it works fine in our environment since we don't
> explicitly put any process under root. Most of  the pages linked in
> root lru would be reparented pages which should be reclaimed prior to
> others.

Keep in mind that not all environments will be specialized to the point
of having root memcg empty. This basically treats root memcg as a trash
bin, and can be very detrimental to use cases where actual memory is
present in there.

It would maybe be better to have all this garbage to go to a separate
place, like a shadow garbage memcg, which is invisible to the
filesystem, and is always the first to be reclaimed from, in any
circumstance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
