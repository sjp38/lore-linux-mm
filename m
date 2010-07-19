Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0C8DB6B02A8
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 02:48:06 -0400 (EDT)
Received: by pwi8 with SMTP id 8so1852935pwi.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 23:48:05 -0700 (PDT)
Message-ID: <4C43F541.7070902@vflare.org>
Date: Mon, 19 Jul 2010 12:18:33 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Use xvmalloc to store compressed chunks
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>	<1279283870-18549-8-git-send-email-ngupta@vflare.org>	<4C42B2E4.4040504@cs.helsinki.fi>	<4C42B98E.4020208@vflare.org> <AANLkTinjJLaDVenwNcxgN7ycr97XLN_DVi1ckXBZetZm@mail.gmail.com>
In-Reply-To: <AANLkTinjJLaDVenwNcxgN7ycr97XLN_DVi1ckXBZetZm@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 07/19/2010 10:06 AM, Minchan Kim wrote:
> Hi Nitin,
> 
> On Sun, Jul 18, 2010 at 5:21 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>> On 07/18/2010 01:23 PM, Pekka Enberg wrote:
>>> Nitin Gupta wrote:
>>>> @@ -528,17 +581,32 @@ static int zcache_store_page(struct zcache_inode_rb *znode,
>>>>          goto out;
>>>>      }
>>>>
>>>> -    dest_data = kmap_atomic(zpage, KM_USER0);
>>>> +    local_irq_save(flags);
>>>
>>> Does xv_malloc() required interrupts to be disabled? If so, why doesn't the function do it by itself?
>>>
>>
>>
>> xvmalloc itself doesn't require disabling interrupts but zcache needs that since
>> otherwise, we can have deadlock between xvmalloc pool lock and mapping->tree_lock
>> which zcache_put_page() is called. OTOH, zram does not require this disabling of
>> interrupts. So, interrupts are disable separately for zcache case.
> 
> cleancache_put_page always is called with spin_lock_irq.
> Couldn't we replace spin_lock_irq_save with spin_lock?
> 

I was missing this point regarding cleancache_put(). So, we can now:
 - take plain (non-irq) spin_lock in zcache_put_page()
 - take non-irq rwlock  in zcache_inode_create() which is called only by
zcache_put_page().
 - Same applies to zcache_store_page(). So, we can also get rid of unnecessary
preempt_disable()/enable() in this function.

I will put up a comment for all these functions and make these changes.

Thanks,
Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
