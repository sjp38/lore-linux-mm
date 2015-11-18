Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id A38FC6B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:05:37 -0500 (EST)
Received: by igl9 with SMTP id 9so109929004igl.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 12:05:37 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id k78si7108698iod.9.2015.11.18.12.05.36
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 12:05:37 -0800 (PST)
Subject: Re: [PATCH] mempolicy: convert the shared_policy lock to a rwlock
References: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
 <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
 <564C820D.1060105@suse.cz>
From: Nathan Zimmer <nzimmer@sgi.com>
Message-ID: <564CDA0F.40801@sgi.com>
Date: Wed, 18 Nov 2015 14:05:35 -0600
MIME-Version: 1.0
In-Reply-To: <564C820D.1060105@suse.cz>
Content-Type: text/plain; charset="iso-8859-2"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 11/18/2015 07:50 AM, Vlastimil Babka wrote:
> On 11/17/2015 05:17 PM, Nathan Zimmer wrote:
>> When running the SPECint_rate gcc on some very large boxes it was noticed
>> that the system was spending lots of time in mpol_shared_policy_lookup.
>> The gamess benchmark can also show it and is what I mostly used to chase
>> down the issue since the setup for that I found a easier.
>>
>> To be clear the binaries were on tmpfs because of disk I/O reqruirements.
>> We then used text replication to avoid icache misses and having all the
>> copies banging on the memory where the instruction code resides.
>> This results in us hitting a bottle neck in mpol_shared_policy_lookup
>> since lookup is serialised by the shared_policy lock.
>>
>> I have only reproduced this on very large (3k+ cores) boxes.  The problem
>> starts showing up at just a few hundred ranks getting worse until it
>> threatens to livelock once it gets large enough.
>> For example on the gamess benchmark at 128 ranks this area consumes only
>> ~1% of time, at 512 ranks it consumes nearly 13%, and at 2k ranks it is
>> over 90%.
>>
>> To alleviate the contention on this area I converted the spinslock to a
>> rwlock.  This allows the large number of lookups to happen simultaneously.
>> The results were quite good reducing this to consumtion at max ranks to
>> around 2%.
> At first glance it seems that RCU would be a good fit here and achieve even
> better lookup scalability, have you considered it?
>

Originally that was my plan but when I saw how good the results were
with the rwlock, I chickened out and took the less prone to mistakes way.

I should also note that the 2% time left in system is not from this lookup
but another area.

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
