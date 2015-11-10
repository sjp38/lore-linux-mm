Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 975136B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 20:34:15 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so217107563pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 17:34:15 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id sr1si1319015pbc.79.2015.11.09.17.34.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 17:34:14 -0800 (PST)
Received: by pasz6 with SMTP id z6so223547219pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 17:34:14 -0800 (PST)
Subject: Re: [PATCHv4] mm: Don't offset memmap for flatmem
References: <1444253335-5811-1-git-send-email-labbott@fedoraproject.org>
 <CA+8MBbLGdYfQRPnVmT=te1y3C7PhCcXqbDGXb7LtqvCWTA+vDQ@mail.gmail.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <56414993.8070709@labbott.name>
Date: Mon, 9 Nov 2015 17:34:11 -0800
MIME-Version: 1.0
In-Reply-To: <CA+8MBbLGdYfQRPnVmT=te1y3C7PhCcXqbDGXb7LtqvCWTA+vDQ@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>, Laura Abbott <labbott@fedoraproject.org>
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Bjorn Andersson <bjorn.andersson@sonymobile.com>, Santosh Shilimkar <ssantosh@kernel.org>, Russell King <rmk@arm.linux.org.uk>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, Andy Gross <agross@codeaurora.org>, Mel Gorman <mgorman@suse.de>, Steven Rostedt <rostedt@goodmis.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/9/15 3:20 PM, Tony Luck wrote:
>> @@ -4984,9 +4987,9 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>>           */
>>          if (pgdat == NODE_DATA(0)) {
>>                  mem_map = NODE_DATA(0)->node_mem_map;
>> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>> +#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>>                  if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
>> -                       mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
>> +                       mem_map -= offset;
>>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>          }
>>   #endif
>
> This piece breaks ia64.  See the comment earlier in the function
> that "ia64 gets its own node_mem_map" ... so we skip the initialization
> of offset ... and arrive down here and just subtract "0" from mem_map.
>
> Attached patch fixes ia64 ... does ARM still work if this is applied?
>
> -Tony
>

Yes, this still fixes the problem for me. I see the pfn <-> page
translation working as expected.

Tested-by: Laura Abbott <laura@labbott.name>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
