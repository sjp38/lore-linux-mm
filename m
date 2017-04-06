Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC8E36B03D7
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 20:47:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 81so20613779pgh.3
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 17:47:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b13si6358469pge.309.2017.04.05.17.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 17:47:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2] mm, swap: Sort swap entries before free
References: <20170405071041.24469-1-ying.huang@intel.com>
	<1491403231.16856.11.camel@redhat.com>
Date: Thu, 06 Apr 2017 08:47:30 +0800
In-Reply-To: <1491403231.16856.11.camel@redhat.com> (Rik van Riel's message of
	"Wed, 5 Apr 2017 10:40:31 -0400")
Message-ID: <87k26ye50d.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

Rik van Riel <riel@redhat.com> writes:

> On Wed, 2017-04-05 at 15:10 +0800, Huang, Ying wrote:
>> To solve the issue, the per-CPU buffer is sorted according to the
>> swap
>> device before freeing the swap entries.A A Test shows that the time
>> spent by swapcache_free_entries() could be reduced after the patch.
>
> That makes a lot of sense.
>
>> @@ -1075,6 +1083,8 @@ void swapcache_free_entries(swp_entry_t
>> *entries, int n)
>> A 
>> A 	prev = NULL;
>> A 	p = NULL;
>> +	if (nr_swapfiles > 1)
>> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp,
>> NULL);
>
> But it really wants a comment in the code, so people
> reading the code a few years from now can see why
> we are sorting things we are about to free.
>
> Maybe something like:
> A  A  A  A  /* Sort swap entries by swap device, so each lock is only taken
> once. */

Good suggestion!  I will add it in the next version.

Best Regards,
Huang, Ying

>> A 	for (i = 0; i < n; ++i) {
>> A 		p = swap_info_get_cont(entries[i], prev);
>> A 		if (p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
