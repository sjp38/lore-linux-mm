Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 131C16007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:21:07 -0400 (EDT)
Received: by pwi8 with SMTP id 8so1591395pwi.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 01:21:06 -0700 (PDT)
Message-ID: <4C42B98E.4020208@vflare.org>
Date: Sun, 18 Jul 2010 13:51:34 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Use xvmalloc to store compressed chunks
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-8-git-send-email-ngupta@vflare.org> <4C42B2E4.4040504@cs.helsinki.fi>
In-Reply-To: <4C42B2E4.4040504@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 07/18/2010 01:23 PM, Pekka Enberg wrote:
> Nitin Gupta wrote:
>> @@ -528,17 +581,32 @@ static int zcache_store_page(struct zcache_inode_rb *znode,
>>          goto out;
>>      }
>>  
>> -    dest_data = kmap_atomic(zpage, KM_USER0);
>> +    local_irq_save(flags);
> 
> Does xv_malloc() required interrupts to be disabled? If so, why doesn't the function do it by itself?
> 


xvmalloc itself doesn't require disabling interrupts but zcache needs that since
otherwise, we can have deadlock between xvmalloc pool lock and mapping->tree_lock
which zcache_put_page() is called. OTOH, zram does not require this disabling of
interrupts. So, interrupts are disable separately for zcache case.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
