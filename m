Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5B28F828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 08:17:54 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so96890377wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 05:17:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 194si19793359wmo.35.2016.01.07.05.17.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 05:17:53 -0800 (PST)
Subject: Re: [PATCH v3 12/14] mm, page_owner: track and print last migrate
 reason
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
 <1450429406-7081-13-git-send-email-vbabka@suse.cz>
 <20160107105404.GJ27868@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568E657B.9040306@suse.cz>
Date: Thu, 7 Jan 2016 14:17:47 +0100
MIME-Version: 1.0
In-Reply-To: <20160107105404.GJ27868@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 01/07/2016 11:54 AM, Michal Hocko wrote:
> On Fri 18-12-15 10:03:24, Vlastimil Babka wrote:
>> During migration, page_owner info is now copied with the rest of the page, so
>> the stacktrace leading to free page allocation during migration is overwritten.
>> For debugging purposes, it might be however useful to know that the page has
>> been migrated since its initial allocation. This might happen many times during
>> the lifetime for different reasons and fully tracking this, especially with
>> stacktraces would incur extra memory costs. As a compromise, store and print
>> the migrate_reason of the last migration that occurred to the page. This is
>> enough to distinguish compaction, numa balancing etc.
>
> So you know that the page has been migrated because of compaction the
> last time. You do not know anything about the previous migrations
> though. How would you use that information during debugging? Wouldn't it

The assumption is that if a migration does something bad, chances are it 
will manifest before another migration happens. I.e. the last migration 
is probably more related to the bug (e.g. catched by VM_BUG_ON_PAGE()) 
than the previous ones. Statistically if trinity sees more errors 
implying compaction than numa balancing, we should look for bugs in 
compaction, etc.

> be sufficient to know that the page has been migrated (or count how many
> times) instead? That would lead to less code and it might be sufficient
> for practical use.

Yeah it's hard to predict how useful/sufficient this patch would be. The 
fact that migration happened should be definitely noted. How many times 
is not that useful IMHO. Migrate reason seemed appropriate and useful 
enough and we already distinguish them for tracepoints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
