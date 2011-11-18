Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B06E16B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 01:43:10 -0500 (EST)
Received: by faas10 with SMTP id s10so5355131faa.14
        for <linux-mm@kvack.org>; Thu, 17 Nov 2011 22:43:08 -0800 (PST)
Message-ID: <4EC5FE6A.3080003@openvz.org>
Date: Fri, 18 Nov 2011 10:42:50 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: account reaped page cache on inode cache pruning
References: <20111116134713.8933.34389.stgit@zurg> <20111117162322.1c3e3d05.akpm@linux-foundation.org>
In-Reply-To: <20111117162322.1c3e3d05.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>

Andrew Morton wrote:
> On Wed, 16 Nov 2011 17:47:13 +0300
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Inode cache pruning indirectly reclaims page-cache by invalidating mapping pages.
>> Let's account them into reclaim-state to notice this progress in memory reclaimer.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> ---
>>   fs/inode.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/inode.c b/fs/inode.c
>> index ee4e66b..1f6c48d 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -692,6 +692,8 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
>>   	else
>>   		__count_vm_events(PGINODESTEAL, reap);
>>   	spin_unlock(&sb->s_inode_lru_lock);
>> +	if (current->reclaim_state)
>> +		current->reclaim_state->reclaimed_slab += reap;
>>
>>   	dispose_list(&freeable);
>>   }
>
> hm, yes, I suppose we should.
>
> It seems to be cheating to use the "reclaimed_slab" field for this.
> Perhaps it would be cleaner to add an additional field to reclaim_state
> for non-slab pages which were also reclaimed.  That's a cosmetic thing
> and I guess we don't need to go that far, not sure...

Do we really need separate on-stack reclaim_state structure with single field?
Maybe replace it with single long (or even unsigned int) .reclaimed_pages field on task_struct
and account reclaimed pages unconditionally.

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
