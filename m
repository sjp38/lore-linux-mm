Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id E686D6B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:51:27 -0400 (EDT)
Received: by lbon3 with SMTP id n3so2285224lbo.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:51:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502DD54F.3010800@parallels.com>
References: <1345150459-31170-1-git-send-email-yinghan@google.com>
	<502DD54F.3010800@parallels.com>
Date: Thu, 16 Aug 2012 22:51:25 -0700
Message-ID: <CALWz4ix-fv+m6ohLT8Kn6oJk8duBV4RKU--Gx8GV93vR6Nfq-w@mail.gmail.com>
Subject: Re: [RFC PATCH 6/6] memcg: shrink slab during memcg reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 10:23 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 08/17/2012 12:54 AM, Ying Han wrote:
>> This patch makes target reclaim shrinks slabs in addition to userpages.
>>
>> Slab shrinkers determine the amount of pressure to put on slabs based on how
>> many pages are on lru (inversely proportional relationship). Calculate the
>> lru_pages correctly based on memcg lru lists instead of global lru lists.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> This seems fine from where I stand.
>
> So imagining for an instant we apply this patch, and this patch only.
> The behavior we get is that when memcg gets pressure, it will shrink
> globally, but it will at least shrink anything.
>
> It is needless to say this is not enough. But I wonder if this isn't
> better than no shrinking at all ? Maybe this could be put ontop of the
> slab series and be the temporary default while we sort out the whole
> shrinkers problem?

It is a balance between breaking isolation or risking the memcg to
OOM. Today there is no shrink_slab under target reclaim, and I think
that is
bad after your slab accounting patch. But I do worry about the
isolation bit where you might end up throwing memcg B's pages for
memcg A's pressure. Not only for slab pages but also user pages, like
the example I listed on the first patch.

--Ying

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
