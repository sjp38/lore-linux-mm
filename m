Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 3700F6B00BA
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 20:52:24 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id cr7so838711qab.10
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 17:52:23 -0800 (PST)
Message-ID: <512037D1.2010907@gmail.com>
Date: Sun, 17 Feb 2013 09:52:17 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: zram /proc/swaps accounting weirdness
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default> <20121211062601.GD22698@blaptop> <d4ab3d29-f29d-4236-bbba-d93b633a18e7@default> <9c96c9e7-4f6e-4e78-a207-009293c37b89@default>
In-Reply-To: <9c96c9e7-4f6e-4e78-a207-009293c37b89@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

On 12/12/2012 09:12 AM, Dan Magenheimer wrote:
>> From: Dan Magenheimer
>> Subject: RE: zram /proc/swaps accounting weirdness
>>
>>>> Can you explain how this could happen if num_writes never
>>>> exceeded 1863?  This may be harmless in the case where
>>> Odd.
>>> I tried to reproduce it with zram and real swap device without
>>> zcache but failed. Does the problem happen only if enabling zcache
>>> together?
>> I also cannot reproduce it with only zram, without zcache.
>> I can only reproduce with zcache+zram.  Since zcache will
>> only "fall through" to zram when the frontswap_store() call
>> in swap_writepage() fails, I wonder if in both cases swap_writepage()
>> is being called in large (e.g. SWAPFILE_CLUSTER-sized) blocks
>> of pages?  When zram-only, the entire block of pages always gets
>> sent to zram, but with zcache only a small randomly-positioned
>> fraction fail frontswap_store(), but the SWAPFILE_CLUSTER-sized
>> blocks have already been pre-reserved on the swap device and
>> become only partially-filled?
> Urk.  Never mind.  My bad.  When a swap page is compressed in
> zcache, it gets accounted in the swap subsystem as an "inuse"

Could you point out to me where add this count to swap subsystem?

> page for the backing swap device.  (Frontswap provides a
> page-by-page "fronting store" for the swap device.)  That explains
> why Used is so high for the "zram swap device" even though
> zram has only compressed a fraction of the pages... the
> remaining (much larger) number of pages have been compressed
> by/in zcache.
>
> Move along, there are no droids here. :-(
>
> Dan
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
