Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1986B0253
	for <linux-mm@kvack.org>; Sat,  6 Aug 2016 18:15:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so37993472wmz.2
        for <linux-mm@kvack.org>; Sat, 06 Aug 2016 15:15:14 -0700 (PDT)
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net. [217.70.183.194])
        by mx.google.com with ESMTPS id x65si14261872wmf.38.2016.08.06.15.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Aug 2016 15:15:13 -0700 (PDT)
Subject: Re: Dirty/Writeback fields in /proc/meminfo affected by 20d74bf29c
References: <80b21fe4-ee8b-314c-ee3e-c09386bf368d@pgaddict.com>
 <20160804135533.153ecbdc199e03f359c98e75@linux-foundation.org>
From: Tomas Vondra <tomas@pgaddict.com>
Message-ID: <d3da059b-9930-38d4-76f8-79f66f8713e4@pgaddict.com>
Date: Sun, 7 Aug 2016 00:15:08 +0200
MIME-Version: 1.0
In-Reply-To: <20160804135533.153ecbdc199e03f359c98e75@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-scsi@vger.kernel.org


On 08/04/2016 10:55 PM, Andrew Morton wrote:
> On Mon, 1 Aug 2016 04:36:28 +0200 Tomas Vondra <tomas@pgaddict.com> wrote:
>
>> Hi,
>>
>> While investigating a strange OOM issue on the 3.18.x branch (which
>> turned out to be already fixed by 52c84a95), I've noticed a strange
>> difference in Dirty/Writeback fields in /proc/meminfo depending on
>> kernel version. I'm wondering whether this is expected ...
>>
>> I've bisected the change to 20d74bf29c, added in 3.18.22 (upstream
>> commit 4f258a46):
>>
>>      sd: Fix maximum I/O size for BLOCK_PC requests
>>
>> With /etc/sysctl.conf containing
>>
>>      vm.dirty_background_bytes = 67108864
>>      vm.dirty_bytes = 1073741824
>>
>> a simple "dd" example writing 10GB file
>>
>>      dd if=/dev/zero of=ssd.test.file bs=1M count=10240
>>
>> results in about this on 3.18.21:
>>
>>      Dirty:            740856 kB
>>      Writeback:         12400 kB
>>
>> but on 3.18.22:
>>
>>      Dirty:             49244 kB
>>      Writeback:        656396 kB
>>
>> I.e. it seems to revert the relationship. I haven't identified any
>> performance impact, and apparently for random writes the behavior did
>> not change at all (or at least I haven't managed to reproduce it).
>>
>> But it's unclear to me why setting a maximum I/O size should affect
>> this, and perhaps it has impact that I don't see.
>
> So what appears to be happening here is that background writeback is
> cutting in earlier - the amount of pending writeback ("Dirty") is
> reduced while the amount of active writeback ("Writeback") is
> correspondingly increased.
>
> 4f258a46 had the effect of permitting larger requests into the
> request queue. It's unclear to me why larger requests would cause
> background writeback to cut in earlier - the writeback code doesn't
> even care about individual request sizes, it only cares about
> aggregate pagecache state.
>

Right. Not a kernel expert here, but that's mostly my thinking.

> Less Dirty and more Writeback isn't necessarily a bad thing at all,
> but I don't like mysteries. cc linux-mm to see if anyone else can
> spot-the-difference.
>

I'm not sure if the change has positive or negative impact (or perhaps 
no actual impact), but as a database guy (PostgreSQL) I'm interested in 
this, as the interaction between the database write activity and kernel 
matters to us a lot. So I'm wondering if this change might trigger the 
writeback sooner, etc.

regards
Tomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
