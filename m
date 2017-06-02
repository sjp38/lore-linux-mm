Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6356B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:41:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so79350817pfd.11
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:41:41 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0042.outbound.protection.outlook.com. [104.47.36.42])
        by mx.google.com with ESMTPS id u186si22659686pgd.98.2017.06.02.08.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 08:41:40 -0700 (PDT)
Subject: Re: strange PAGE_ALLOC_COSTLY_ORDER usage in xgbe_map_rx_buffer
References: <20170531160422.GW27783@dhcp22.suse.cz>
 <4b894f15-6876-8598-def5-8113df836750@amd.com>
 <20170602144352.GI29840@dhcp22.suse.cz>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <9b41c712-59ee-8457-2741-e913b8498ca7@amd.com>
Date: Fri, 2 Jun 2017 10:41:26 -0500
MIME-Version: 1.0
In-Reply-To: <20170602144352.GI29840@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 6/2/2017 9:43 AM, Michal Hocko wrote:
> On Fri 02-06-17 09:20:54, Tom Lendacky wrote:
>> On 5/31/2017 11:04 AM, Michal Hocko wrote:
>>> Hi Tom,
>>
>> Hi Michal,
>>
>>> I have stumbled over the following construct in xgbe_map_rx_buffer
>>> 	order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
>>> which looks quite suspicious. Why does it PAGE_ALLOC_COSTLY_ORDER - 1?
>>> And why do you depend on PAGE_ALLOC_COSTLY_ORDER at all?
>>>
>>
>> The driver tries to allocate a number of pages to be used as receive
>> buffers.  Based on what I could find in documentation, the value of
>> PAGE_ALLOC_COSTLY_ORDER is the point at which order allocations
>> (could) get expensive.  So I decrease by one the order requested. The
>> max_t test is just to insure that in case PAGE_ALLOC_COSTLY_ORDER ever
>> gets defined as 0, 0 would be used.
> 
> So you have fallen into a carefully prepared trap ;). The thing is that
> orders _larger_ than PAGE_ALLOC_COSTLY_ORDER are costly actually. I can
> completely see how this can be confusing.
> 
> Moreover xgbe_map_rx_buffer does an atomic allocation which doesn't do
> any direct reclaim/compaction attempts so the costly vs. non-costly
> doesn't apply here at all.
> 
> I would be much happier if no code outside of mm used
> PAGE_ALLOC_COSTLY_ORDER directly but that requires a deeper
> consideration. E.g. what would be the largest size that would be
> useful for this path? xgbe_alloc_pages does the order fallback so
> PAGE_ALLOC_COSTLY_ORDER sounds like an artificial limit to me.
> I guess we can at least simplify the xgbe right away though.
> ---
>  From c7d5ca637b889c4e3779f8d2a84ade6448a76ef9 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 2 Jun 2017 16:34:28 +0200
> Subject: [PATCH] amd-xgbe: use PAGE_ALLOC_COSTLY_ORDER in xgbe_map_rx_buffer
> 
> xgbe_map_rx_buffer is rather confused about what PAGE_ALLOC_COSTLY_ORDER
> means. It uses PAGE_ALLOC_COSTLY_ORDER-1 assuming that
> PAGE_ALLOC_COSTLY_ORDER is the first costly order which is not the case
> actually because orders larger than that are costly. And even that
> applies only to sleeping allocations which is not the case here. We
> simply do not perform any costly operations like reclaim or compaction
> for those. Simplify the code by dropping the order calculation and use
> PAGE_ALLOC_COSTLY_ORDER directly.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-desc.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> index b3bc87fe3764..5ded10eba418 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
> @@ -333,9 +333,8 @@ static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
>   	}
>   
>   	if (!ring->rx_buf_pa.pages) {
> -		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
>   		ret = xgbe_alloc_pages(pdata, &ring->rx_buf_pa, GFP_ATOMIC,
> -				       order);
> +				       PAGE_ALLOC_COSTLY_ORDER);

You'll need to also remove the variable definition to avoid an un-used
variable warning.  You should also send this to the netdev mailing list
to send this through the net-next tree (or net tree if you want it fixed
in the current version of the Linux kernel).

Thanks,
Tom

>   		if (ret)
>   			return ret;
>   	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
