Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6786B431F
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 13:35:34 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u20so17344002qtk.6
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:35:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o87sor607283qko.109.2018.11.26.10.35.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 10:35:33 -0800 (PST)
Subject: Re: [PATCH v2] mm: prototype: rid swapoff of quadratic complexity
References: <20181126165521.19777-1-vpillai@digitalocean.com>
 <20181126172255.GK3065@bombadil.infradead.org>
From: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Message-ID: <21acdf55-dbcb-1c8f-4783-9bb496dcbca3@digitalocean.com>
Date: Mon, 26 Nov 2018 13:35:30 -0500
MIME-Version: 1.0
In-Reply-To: <20181126172255.GK3065@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

Hi Mathew,


Thanks for your response!

On 11/26/18 12:22 PM, Matthew Wilcox wrote:
> On Mon, Nov 26, 2018 at 04:55:21PM +0000, Vineeth Remanan Pillai wrote:
>> +	do {
>> +		XA_STATE(xas, &mapping->i_pages, start);
>> +		int i;
>> +		int entries = 0;
>> +		struct page *page;
>> +		pgoff_t indices[PAGEVEC_SIZE];
>> +		unsigned long end = start + PAGEVEC_SIZE;
>>   
>> +		rcu_read_lock();
>> +		xas_for_each(&xas, page, end) {
> I think this is a mistake.  You should probably specify ULONG_MAX for the
> end.  Otherwise if there are no swap entries in the first 60kB of the file,
> you'll just exit.  That does mean you'll need to check 'entries' for
> hitting PAGEVEC_SIZE.

Thanks for pointing this out. I shall fix this in the next version.

> This seems terribly complicated.  You run through i_pages, record the
> indices of the swap entries, then go back and look them up again by
> calling shmem_getpage() which calls the incredibly complex 300 line
> shmem_getpage_gfp().
>
> Can we refactor shmem_getpage_gfp() to skip some of the checks which
> aren't necessary when called from this path, and turn this into a nice
> simple xas_for_each() loop which works one entry at a time?

I shall investigate this and make this simpler as you suggested.

>> +	list_for_each_safe(p, next, &shmem_swaplist) {
>> +		info = list_entry(p, struct shmem_inode_info, swaplist);
> This could use list_for_each_entry_safe(), right?

Yes, you are right. Will fix.


Thanks,

Vineeth

>
