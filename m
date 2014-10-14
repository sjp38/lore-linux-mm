Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 708876B006E
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 11:31:49 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so11182960wgg.25
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 08:31:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id de9si21640921wjb.109.2014.10.14.08.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 08:31:47 -0700 (PDT)
Message-ID: <543D41B9.1040401@redhat.com>
Date: Tue, 14 Oct 2014 11:31:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
References: <20141008191050.GK3778@sgi.com> <20141014114828.GA6524@node.dhcp.inet.fi> <20141014145435.GA7369@worktop.fdxtended.com>
In-Reply-To: <20141014145435.GA7369@worktop.fdxtended.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On 10/14/2014 10:54 AM, Peter Zijlstra wrote:
> On Tue, Oct 14, 2014 at 02:48:28PM +0300, Kirill A. Shutemov wrote:
>
>> Why whould you want to pin khugpeaged? Is there a valid use-case?
>> Looks like userspace shoots to its leg.
>
> Its just bad design to put so much work in another context. But the
> use-case is isolating other cpus.
>
>> Is there a reason why we should respect cpuset limitation for kernel
>> threads?
>
> Yes, because we want to allow isolating CPUs from 'random' activity.
>
>> Should we bypass cpuset for PF_KTHREAD completely?
>
> No. That'll break stuff.

Agreed on the above.

I suspect the sane thing to do is allow a cpuset
limited task to still allocate pages elsewhere,
if it explicitly asks for it.

Ask for something potentially stupid? Get it :)

In many of the cases where something asks for memory
in a specific location, it has a good reason to do
so, and there's no reason to deny it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
