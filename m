Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 968346B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 13:34:46 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 15so2514249oip.7
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 10:34:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d37sor258622otb.174.2018.02.08.10.34.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 10:34:45 -0800 (PST)
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <f8be3fc9-a96d-bf37-4da0-43220014caed@redhat.com>
 <20180208181800.GA9524@bombadil.infradead.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <d7314317-f3d6-a38d-326a-7a27e05a5e67@redhat.com>
Date: Thu, 8 Feb 2018 10:34:42 -0800
MIME-Version: 1.0
In-Reply-To: <20180208181800.GA9524@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 02/08/2018 10:18 AM, Matthew Wilcox wrote:
> On Thu, Feb 08, 2018 at 09:56:42AM -0800, Laura Abbott wrote:
>>> +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
>>> @@ -77,7 +77,7 @@ static struct scatterlist *videobuf_vmalloc_to_sg(unsigned char *virt,
>>>    		pg = vmalloc_to_page(virt);
>>>    		if (NULL == pg)
>>>    			goto err;
>>> -		BUG_ON(PageHighMem(pg));
>>> +		BUG_ON(page_to_pfn(pg) >= (1 << (32 - PAGE_SHIFT)));
>>>    		sg_set_page(&sglist[i], pg, PAGE_SIZE, 0);
>>>    	}
>>>    	return sglist;
>>>
>>
>> the vzalloc in this function needs to be switched to vmalloc32 if it
>> actually wants to guarantee 32-bit memory.
> 
> Whoops, you got confused between the sglist allocation and the allocation
> of the pages which will be mapped ...
> 

Ah yeah, clearly need more coffee this morning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
