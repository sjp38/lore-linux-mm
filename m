Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 980EA6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:19:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x77so253962wmd.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:19:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z132si8338435wmg.108.2018.02.15.06.19.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 06:19:20 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] memory allocation scope
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
 <87po56q578.fsf@notabene.neil.brown.name>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <a6dfc5fe-56c5-731e-701b-93cd41cf547b@suse.de>
Date: Thu, 15 Feb 2018 08:19:16 -0600
MIME-Version: 1.0
In-Reply-To: <87po56q578.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, lsf-pc@lists.linux-foundation.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org



On 02/14/2018 09:53 PM, NeilBrown wrote:
> On Wed, Feb 14 2018, Goldwyn Rodrigues wrote:
> 
>> Discussion with the memory folks towards scope based allocation
>> I am working on converting some of the GFP_NOFS memory allocation calls
>> to new scope API [1]. While other allocation types (noio, nofs,
>> noreclaim) are covered. Are there plans for identifying scope of
>> GFP_ATOMIC allocations? This should cover most (if not all) of the
>> allocation scope.
>>
>> Transient Errors with direct I/O
>> In a large enough direct I/O, bios are split. If any of these bios get
>> an error, the whole I/O is marked as erroneous. What this means at the
>> application level is that part of your direct I/O data may be written
>> while part may not be. In the end, you can have an inconsistent write
>> with some parts of it written and some not. Currently the applications
>> need to overwrite the whole write() again.
> 
> So?
> If that is a problem for the application, maybe it should use smaller
> writes.  If smaller writes cause higher latency, then use aio to submit
> them.
> 
> I doubt that splitting bios is the only thing that can cause a write
> that reported as EIO to have partially completed.  An application should
> *always* assume that EIO from a write means that the data on the device
> is indistinguishable from garbage - shouldn't it?
> 

Yes, and that is what I got from others as well. The scenario is not
deterministic of the contents of the file in case of overwriting a file.
And no, splitting bios is not the only reason you can have partial
write. This is different from what buffered I/O would result in, where a
partial write may not be an error and returns the bytes written.

Perhaps this needs to be documented in the man pages. I will put in one
shortly.

-- 
Goldwyn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
