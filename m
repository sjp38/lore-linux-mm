Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C02286B1B35
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:39:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o42so16151607edc.13
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:39:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2-v6si1512288eju.193.2018.11.19.08.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:39:15 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181115083055.GD23831@dhcp22.suse.cz>
 <20181115131211.GP2653@MiWiFi-R3L-srv>
 <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
Date: Mon, 19 Nov 2018 17:36:21 +0100
MIME-Version: 1.0
In-Reply-To: <20181119141016.GO22247@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Baoquan He <bhe@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 11/19/18 3:10 PM, Michal Hocko wrote:
> On Mon 19-11-18 13:51:21, Michal Hocko wrote:
>> On Mon 19-11-18 13:40:33, Michal Hocko wrote:
>>> How are
>>> we supposed to converge when the swapin code waits for the migration to
>>> finish with the reference count elevated?

Indeed this looks wrong. How comes we only found this out now? I guess
the race window where refcounts matter is only a part of the whole
migration, where we update the mapping (migrate_page_move_mapping()).
That's before copying contents, flags etc.

>> Just to clarify. This is not only about swapin obviously. Any caller of
>> __migration_entry_wait is affected the same way AFAICS.
> 
> In other words. Why cannot we do the following?
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..7ccab29bcf9a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -324,19 +324,9 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
>  		goto out;
>  
>  	page = migration_entry_to_page(entry);
> -
> -	/*
> -	 * Once page cache replacement of page migration started, page_count
> -	 * *must* be zero. And, we don't want to call wait_on_page_locked()
> -	 * against a page without get_page().
> -	 * So, we use get_page_unless_zero(), here. Even failed, page fault
> -	 * will occur again.
> -	 */
> -	if (!get_page_unless_zero(page))
> -		goto out;
>  	pte_unmap_unlock(ptep, ptl);
> -	wait_on_page_locked(page);
> -	put_page(page);
> +	page_lock(page);
> +	page_unlock(page);

So what protects us from locking a page whose refcount dropped to zero?
and is being freed? The checks in freeing path won't be happy about a
stray lock.

I suspect it's not that simple to fix this. Perhaps migration code could
set some flag/bit in the page during the part where it stabilizes
refcounts, and __migration_entry_wait() would just spin until the bit is
cleared, and only then proceed with the current get_page+wait? Or we
could maybe wait on the pte itself and not page?

>  	return;
>  out:
>  	pte_unmap_unlock(ptep, ptl);
> 
