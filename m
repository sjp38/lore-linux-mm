Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 093096B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 09:13:51 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id f198so605698wme.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 06:13:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2si11730646wje.67.2016.03.31.06.13.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 06:13:50 -0700 (PDT)
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com>
 <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
 <56FA7DC8.4000902@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FD2285.4080600@suse.cz>
Date: Thu, 31 Mar 2016 15:13:41 +0200
MIME-Version: 1.0
In-Reply-To: <56FA7DC8.4000902@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/29/2016 03:06 PM, Vlastimil Babka wrote:
> On 03/25/2016 08:22 PM, Andrew Morton wrote:
>> Also, mm/mempolicy.c:offset_il_node() worries me:
>>
>> 	do {
>> 		nid = next_node(nid, pol->v.nodes);
>> 		c++;
>> 	} while (c <= target);
>>
>> Can't `nid' hit MAX_NUMNODES?
>
> AFAICS it can. interleave_nid() uses this and the nid is then used e.g.
> in node_zonelist() where it's used for NODE_DATA(nid). That's quite
> scary. It also predates git. Why don't we see crashes or KASAN finding this?

Ah, I see. In offset_il_node(), nid is initialized to -1, and the number 
of do-while iterations calling next_node() is up to the number of bits 
set in the pol->v.nodes bitmap, so it can't reach past the last set bit 
and return MAX_NUMNODES.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
