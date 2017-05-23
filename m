Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9F383292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 17:40:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i206so114505191ita.10
        for <linux-mm@kvack.org>; Tue, 23 May 2017 14:40:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 76si3514157itx.37.2017.05.23.14.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 14:40:12 -0700 (PDT)
From: Qing Huang <qing.huang@oracle.com>
Subject: Re: [PATCH] ib/core: not to set page dirty bit if it's already set.
References: <20170518233353.14370-1-qing.huang@oracle.com>
 <20170519130541.GA8017@infradead.org>
 <9f4a4f90-a7b1-b1dc-6e7a-042f26254681@oracle.com>
 <20170523074234.GE29525@infradead.org>
Message-ID: <045c8fb5-fa64-c0e0-c5e4-2734f849a66a@oracle.com>
Date: Tue, 23 May 2017 14:39:38 -0700
MIME-Version: 1.0
In-Reply-To: <20170523074234.GE29525@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, dledford@redhat.com, sean.hefty@intel.com, artemyko@mellanox.com, linux-mm@kvack.org



On 5/23/2017 12:42 AM, Christoph Hellwig wrote:
> On Mon, May 22, 2017 at 04:43:57PM -0700, Qing Huang wrote:
>> On 5/19/2017 6:05 AM, Christoph Hellwig wrote:
>>> On Thu, May 18, 2017 at 04:33:53PM -0700, Qing Huang wrote:
>>>> This change will optimize kernel memory deregistration operations.
>>>> __ib_umem_release() used to call set_page_dirty_lock() against every
>>>> writable page in its memory region. Its purpose is to keep data
>>>> synced between CPU and DMA device when swapping happens after mem
>>>> deregistration ops. Now we choose not to set page dirty bit if it's
>>>> already set by kernel prior to calling __ib_umem_release(). This
>>>> reduces memory deregistration time by half or even more when we ran
>>>> application simulation test program.
>>> As far as I can tell this code doesn't even need set_page_dirty_lock
>>> and could just use set_page_dirty
>> It seems that set_page_dirty_lock has been used here for more than 10 years.
>> Don't know the original purpose. Maybe it was used to prevent races between
>> setting dirty bits and swapping out pages?
> I suspect copy & paste.  Or maybe I don't actually understand the
> explanation of set_page_dirty vs set_page_dirty_lock enough.  But
> I'd rather not hack around the problem.
> --
I think there are two parts here. First part is that we don't need to 
set the dirty bit if it's already set. Second part is whether we use 
set_page_dirty or set_page_dirty_lock to set dirty bits.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
