Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 558B46B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 15:06:59 -0400 (EDT)
Message-ID: <502015C9.2@redhat.com>
Date: Mon, 06 Aug 2012 15:06:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
References: <cover.1344259054.git.aquini@redhat.com> <212b5297df32cb4e3f60d5b76a8cb0629d328a4e.1344259054.git.aquini@redhat.com> <50200F1F.7060605@redhat.com> <20120806190053.GA3968@t510.redhat.com>
In-Reply-To: <20120806190053.GA3968@t510.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On 08/06/2012 03:00 PM, Rafael Aquini wrote:
> On Mon, Aug 06, 2012 at 02:38:23PM -0400, Rik van Riel wrote:
>> On 08/06/2012 09:56 AM, Rafael Aquini wrote:
>>
>>> @@ -846,6 +861,21 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>>>   			goto out;
>>>
>>>   	rc = __unmap_and_move(page, newpage, force, offlining, mode);
>>> +
>>> +	if (unlikely(is_balloon_page(newpage)&&
>>> +		     balloon_compaction_enabled())) {
>>
>> Could that be collapsed into one movable_balloon_page(newpage) function
>> call?
>>
> Keeping is_balloon_page() as is, and itroducing this new movable_balloon_page()
> function call, or just doing a plain rename, as Andrew has first suggested?

Just a plain rename would work.

> +static inline bool is_balloon_page(struct page *page)
> +{
> +	return (page->mapping && page->mapping == balloon_mapping);
> +}

As an aside, since you are only comparing page->mapping and
not dereferencing it, it can be simplified to just:

	return (page->mapping == balloon_mapping);



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
