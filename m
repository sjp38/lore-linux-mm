Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 69C1E6B0071
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 12:10:08 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so3281615wes.6
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:10:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si5099383wja.141.2014.07.17.09.10.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 09:10:07 -0700 (PDT)
Message-ID: <53C7F55B.8030307@suse.cz>
Date: Thu, 17 Jul 2014 18:10:03 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/15/2014 12:28 PM, Hugh Dickins wrote:
> In the end I decided that we had better look at it as two problems,
> the trinity faulting starvation, and the indefinite punching loop,
> so 1/2 and 2/2 present both solutions: belt and braces.

I tested that with my reproducer and it was OK, but as I already said, 
it's not trinity so I didn't observe the new problems in the first place.

> Which may be the best for fixing, but the worst for ease of backporting.
> Vlastimil, I have prepared (and lightly tested) a 3.2.61-based version
> of the combination of f00cdc6df7d7 and 1/2 and 2/2 (basically, I moved
> vmtruncate_range from mm/truncate.c to mm/shmem.c, since nothing but
> shmem ever implemented the truncate_range method).  It should give a

I don't know how much stable kernel updates are supposed to care about 
out-of-tree modules, but doesn't the change mean that an out-of-tree FS 
supporting truncate_range (if such thing exists) would effectively stop 
supporting madvise(MADV_REMOVE) after this change? But hey it's still 
madvise so maybe we don't need to care. And I suppose kernels where 
FALLOC_FL_PUNCH_HOLE is supported, can be backported normally.

> good hint for backports earlier and later: I'll send it privately to
> you now, but keep in mind that it may need to be revised if today's
> patches for 3.16 get revised again (I'll send it to Ben Hutchings
> only when that's settled).
>
> Thanks,
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
