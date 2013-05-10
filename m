Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 65CFC6B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 10:12:15 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id ep20so4035303lab.38
        for <linux-mm@kvack.org>; Fri, 10 May 2013 07:12:13 -0700 (PDT)
Message-ID: <518D0039.6070006@openvz.org>
Date: Fri, 10 May 2013 18:12:09 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
References: <20130430110214.22179.26139.stgit@zurg> <20130510102809.GA31738@suse.de>
In-Reply-To: <20130510102809.GA31738@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

Mel Gorman wrote:
> On Tue, Apr 30, 2013 at 03:02:14PM +0400, Konstantin Khlebnikov wrote:
>> +static inline bool
>> +is_lru_milestone(struct lruvec *lruvec, struct list_head *list)
>> +{
>> +	return unlikely(list>=&lruvec->milestones[0][0].lru&&
>> +			list<   &lruvec->milestones[NR_EVICTABLE_LRU_LISTS]
>> +						   [NR_LRU_MILESTONES].lru);
>> +}
>> +
>
> Not reviewing properly yet, just taking a quick look out of interest but
> this check may be delicate.  32-bit x86 machines start the kernel direct
> mapping at 0xC0000000 so milestones[0][0].lru will have some value betewen
> 0xC0000000 and 0xFFFFFFFF. HZ=250 on my distro config so after 0xC0000000
> jiffies or a bit over 149 days of uptime, it looks like there will be a
> window where LRU entries look like milestones. If I'm right, that is
> bound to cause problems.
>

Nope. There is no such dangerous magic. This function compares only pointers.
List heads in page LRU list can be either &page->lru or &lru_milestone->lru.
Since milestones are embedded into struct lruvec we can separate them in this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
