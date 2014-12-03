Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 055C06B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 20:15:27 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so8992954pde.12
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 17:15:26 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id da5si35887377pdb.204.2014.12.02.17.15.24
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 17:15:25 -0800 (PST)
Date: Wed, 3 Dec 2014 10:18:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 1/8] mm/page_ext: resurrect struct page extending code
 for debugging
Message-ID: <20141203011846.GB10084@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416816926-7756-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1416816926-7756-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Nov 24, 2014 at 05:15:19PM +0900, Joonsoo Kim wrote:
> When we debug something, we'd like to insert some information to
> every page. For this purpose, we sometimes modify struct page itself.
> But, this has drawbacks. First, it requires re-compile. This makes us
> hesitate to use the powerful debug feature so development process is
> slowed down. And, second, sometimes it is impossible to rebuild the kernel
> due to third party module dependency. At third, system behaviour would be
> largely different after re-compile, because it changes size of struct
> page greatly and this structure is accessed by every part of kernel.
> Keeping this as it is would be better to reproduce errornous situation.
> 
> This feature is intended to overcome above mentioned problems. This feature
> allocates memory for extended data per page in certain place rather than
> the struct page itself. This memory can be accessed by the accessor
> functions provided by this code. During the boot process, it checks whether
> allocation of huge chunk of memory is needed or not. If not, it avoids
> allocating memory at all. With this advantage, we can include this feature
> into the kernel in default and can avoid rebuild and solve related problems.
> 
> Until now, memcg uses this technique. But, now, memcg decides to embed
> their variable to struct page itself and it's code to extend struct page
> has been removed. I'd like to use this code to develop debug feature,
> so this patch resurrect it.
> 
> To help these things to work well, this patch introduces two callbacks
> for clients. One is the need callback which is mandatory if user wants
> to avoid useless memory allocation at boot-time. The other is optional,
> init callback, which is used to do proper initialization after memory
> is allocated. Detailed explanation about purpose of these functions is
> in code comment. Please refer it.
> 
> Others are completely same with previous extension code in memcg.
> 
> v3:
>  minor fix for readable code
> 
> v2:
>  describe overall design at the top of the page extension code.
>  add more description on commit message.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello, Andrew.

Could you fold following fix into the merged patch?
It fixes the problem on !CONFIG_SPARSEMEM which is reported by
0day kernel testing robot.

https://lkml.org/lkml/2014/11/28/123

Thanks.


------->8----------
