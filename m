Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE5936B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:47:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so219066536pgq.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:47:37 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e4si9711537plj.170.2016.12.16.14.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 14:47:36 -0800 (PST)
Subject: Re: OOM: Better, but still there on 4.9
References: <20161215225702.GA27944@boerne.fritz.box>
 <20161216073941.GA26976@dhcp22.suse.cz>
 <1da4691d-d0da-a620-020c-c2e968c2a5ec@fb.com>
 <20161216221420.GF7645@dhcp22.suse.cz>
From: Chris Mason <clm@fb.com>
Message-ID: <4e87e963-154a-df2c-80a4-ecc6d898f9a8@fb.com>
Date: Fri, 16 Dec 2016 17:47:25 -0500
MIME-Version: 1.0
In-Reply-To: <20161216221420.GF7645@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On 12/16/2016 05:14 PM, Michal Hocko wrote:
> On Fri 16-12-16 13:15:18, Chris Mason wrote:
>> On 12/16/2016 02:39 AM, Michal Hocko wrote:
> [...]
>>> I believe the right way to go around this is to pursue what I've started
>>> in [1]. I will try to prepare something for testing today for you. Stay
>>> tuned. But I would be really happy if somebody from the btrfs camp could
>>> check the NOFS aspect of this allocation. We have already seen
>>> allocation stalls from this path quite recently
>>
>> Just double checking, are you asking why we're using GFP_NOFS to avoid going
>> into btrfs from the btrfs writepages call, or are you asking why we aren't
>> allowing highmem?
>
> I am more interested in the NOFS part. Why cannot this be a full
> GFP_KERNEL context? What kind of locks we would lock up when recursing
> to the fs via slab shrinkers?
>

Since this is our writepages call, any jump into direct reclaim would go 
to writepage, which would end up calling the same set of code to read 
metadata blocks, which would do a GFP_KERNEL allocation and end up back 
in writepage again.

We'd also have issues with blowing through transaction reservations 
since the writepage recursion would have to nest into the running 
transaction.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
