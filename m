Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4BF440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:49:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u20so597731pgb.10
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:49:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l23si3186479pgu.76.2017.08.24.10.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 10:49:19 -0700 (PDT)
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
 <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
 <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <85fb2a78-cbb7-dceb-12e8-7d18519c30a0@linux.intel.com>
Date: Thu, 24 Aug 2017 10:49:18 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 08/23/2017 04:30 PM, Linus Torvalds wrote:
> On Wed, Aug 23, 2017 at 11:17 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Wed, Aug 23, 2017 at 8:58 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>>
>>> Will you still consider the original patch as a fail safe mechanism?
>>
>> I don't think we have much choice, although I would *really* want to
>> get this root-caused rather than just papering over the symptoms.
> 
> Oh well. Apparently we're not making progress on that, so I looked at
> the patch again.
> 
> Can we fix it up a bit? In particular, the "bookmark_wake_function()"
> thing added no value, and definitely shouldn't have been exported.
> Just use NULL instead.
> 
> And the WAITQUEUE_WALK_BREAK_CNT thing should be internal to
> __wake_up_common(), not in some common header file. Again, there's no
> value in exporting it to anybody else.
> 
> And doing
> 
>                 if (curr->flags & WQ_FLAG_BOOKMARK)
> 
> looks odd, when we just did
> 
>                 unsigned flags = curr->flags;
> 
> one line earlier, so that can be just simplified.
> 
> So can you test that simplified version of the patch? I'm attaching my
> suggested edited patch, but you may just want to do those changes
> directly to your tree instead.

These changes look fine.  We are testing them now.
Does the second patch in the series look okay to you?

Thanks.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
