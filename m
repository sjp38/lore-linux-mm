Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D06546B007B
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 23:29:08 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so11085lbj.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 20:29:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE0C514.4040807@jp.fujitsu.com>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
	<1340038051-29502-4-git-send-email-yinghan@google.com>
	<4FE0C514.4040807@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 20:29:06 -0700
Message-ID: <CALWz4izWXKBbU8CB=Z_2j1rupZwU4hystNgSf4kuZqrbSFgQrg@mail.gmail.com>
Subject: Re: [PATCH V5 4/5] mm, vmscan: fix do_try_to_free_pages() livelock
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, dhillf@gmail.com, hughd@google.com, dan.magenheimer@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Jun 19, 2012 at 11:29 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> On 6/18/2012 12:47 PM, Ying Han wrote:
>> Currently, do_try_to_free_pages() can enter livelock. Because of,
>> now vmscan has two conflicted policies.
>>
>> 1) kswapd sleep when it couldn't reclaim any page even though
>> =A0 =A0reach priority 0. This is because to avoid kswapd() infinite
>> =A0 =A0loop. That said, kswapd assume direct reclaim makes enough
>> =A0 =A0free pages either regular page reclaim or oom-killer.
>> =A0 =A0This logic makes kswapd -> direct-reclaim dependency.
>> 2) direct reclaim continue to reclaim without oom-killer until
>> =A0 =A0kswapd turn on zone->all_unreclaimble. This is because
>> =A0 =A0to avoid too early oom-kill.
>> =A0 =A0This logic makes direct-reclaim -> kswapd dependency.
>>
>> In worst case, direct-reclaim may continue to page reclaim forever
>> when kswapd is slept and any other thread don't wakeup kswapd.
>>
>> We can't turn on zone->all_unreclaimable because this is racy.
>> direct reclaim path don't take any lock. Thus this patch removes
>> zone->all_unreclaimable field completely and recalculates every
>> time.
>>
>> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
>> directly and kswapd continue to use zone->all_unreclaimable. Because,
>> it is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
>> zone->all_unreclaimable as a name) describes the detail.
>>
>> Reported-by: Aaditya Kumar <aaditya.kumar.30@gmail.com>
>> Reported-by: Ying Han <yinghan@google.com>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>
> Please drop this. I've got some review comment about this patch and
> i need respin. but thank you for paying attention this.

Thanks for the heads up. Are you working on the new version of it,
since I included this patch in my softlimit reclaim patchset as a
replacement of one patch i had.

--Ying
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
