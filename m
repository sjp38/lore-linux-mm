Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A66E46B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 19:40:12 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so2878745qcq.0
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:40:11 -0800 (PST)
Message-ID: <51241B66.7080004@gmail.com>
Date: Wed, 20 Feb 2013 08:40:06 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Should a swapped out page be deleted from swap cache?
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils> <512338A6.1030602@gmail.com> <alpine.LNX.2.00.1302191050330.2248@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302191050330.2248@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Li Haifeng <omycle@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Hi Hugh,

On 02/20/2013 02:56 AM, Hugh Dickins wrote:
> On Tue, 19 Feb 2013, Ric Mason wrote:
>> There is a call of try_to_free_swap in function swap_writepage, if
>> swap_writepage is call from shrink_page_list path, PageSwapCache(page) ==
>> trure, PageWriteback(page) maybe false, page_swapcount(page) == 0, then will
>> delete the page from swap cache and free swap slot, where I miss?
> That's correct.  PageWriteback is sure to be false there.  page_swapcount
> usually won't be 0 there, but sometimes it will be, and in that case we
> do want to delete from swap cache and free the swap slot.

1) If PageSwapCache(page)  == true, PageWriteback(page) == false, 
page_swapcount(page) == 0  in swap_writepage(shrink_page_list path), 
then will delete the page from swap cache and free swap slot, in 
function swap_writepage:

if (try_to_free_swap(page)) {
     unlock_page(page);
     goto out;
}
writeback will not execute, that's wrong. Where I miss?

2) In the function pageout, page will be set PG_Reclaim flag, since this 
flag is set, end_swap_bio_write->end_page_writeback:
if (TestClearPageReclaim(page))
      rotate_reclaimable_page(page);
it means that page will be add to the tail of lru list, page is clean 
anonymous page this time and will be reclaim to buddy system soon, correct?
If is correct, what is the meaning of rotate here?

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
