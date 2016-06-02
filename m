Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9F2A6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 07:44:48 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so22964155lbb.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 04:44:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si167287wjt.204.2016.06.02.04.44.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 04:44:47 -0700 (PDT)
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <574EEC96.8050805@suse.cz> <20160602002519.GB1736@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8ebf6c9e-043d-0e70-7b6e-193771ead68d@suse.cz>
Date: Thu, 2 Jun 2016 13:44:45 +0200
MIME-Version: 1.0
In-Reply-To: <20160602002519.GB1736@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On 06/02/2016 02:25 AM, Minchan Kim wrote:
> On Wed, Jun 01, 2016 at 04:09:26PM +0200, Vlastimil Babka wrote:
>> On 06/01/2016 01:21 AM, Minchan Kim wrote:
>>> +	reset_page(page);
>>> +	put_page(page);
>>> +	page = newpage;
>>> +
>>> +	ret = 0;
>>> +unpin_objects:
>>> +	for (addr = s_addr + offset; addr < s_addr + pos;
>>> +						addr += class->size) {
>>> +		head = obj_to_head(page, addr);
>>> +		if (head & OBJ_ALLOCATED_TAG) {
>>> +			handle = head & ~OBJ_ALLOCATED_TAG;
>>> +			if (!testpin_tag(handle))
>>> +				BUG();
>>> +			unpin_tag(handle);
>>> +		}
>>> +	}
>>> +	kunmap_atomic(s_addr);
>>
>> The above seems suspicious to me. In the success case, page points to
>> newpage, but s_addr is still the original one?
>
> s_addr is virtual adress of old page by kmap_atomic so page pointer of
> new page doesn't matter.

Hmm, I see. The value (head address/handle) it reads from the old page 
should be the same as the one in the newpage. And this value doesn't get 
changed in the process. So it works, it's just subtle :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
