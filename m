Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0748F6B0260
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:31:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r83so2286714pfj.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:31:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si932660pfh.448.2017.09.28.01.31.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Sep 2017 01:31:03 -0700 (PDT)
From: Luis Henriques <lhenriques@suse.com>
Subject: Re: [PATCH 2/2] percpu: fix iteration to prevent skipping over block
References: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
	<1506548100-31247-3-git-send-email-dennisszhou@gmail.com>
	<20170927215125.GB15129@devbig577.frc2.facebook.com>
Date: Thu, 28 Sep 2017 09:31:00 +0100
In-Reply-To: <20170927215125.GB15129@devbig577.frc2.facebook.com> (Tejun Heo's
	message of "Wed, 27 Sep 2017 14:51:25 -0700")
Message-ID: <87lgkzkywr.fsf@hermes>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dennis Zhou <dennisszhou@gmail.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> On Wed, Sep 27, 2017 at 04:35:00PM -0500, Dennis Zhou wrote:
>> The iterator functions pcpu_next_md_free_region and
>> pcpu_next_fit_region use the block offset to determine if they have
>> checked the area in the prior iteration. However, this causes an issue
>> when the block offset is greater than subsequent block contig hints. If
>> within the iterator it moves to check subsequent blocks, it may fail in
>> the second predicate due to the block offset not being cleared. Thus,
>> this causes the allocator to skip over blocks leading to false failures
>> when allocating from the reserved chunk. While this happens in the
>> general case as well, it will only fail if it cannot allocate a new
>> chunk.
>> 
>> This patch resets the block offset to 0 to pass the second predicate
>> when checking subseqent blocks within the iterator function.
>> 
>> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
>> Reported-by: Luis Henriques <lhenriques@suse.com>
>
> Luis, can you please verify that this fixes the allocaiton failure you
> were seeing?

I can confirm that I'm no longer seeing the allocation failure after
applying these patches.  Feel free to add my:

Tested-by: Luis Henriques <lhenriques@suse.com>

Cheers,
-- 
Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
