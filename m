Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E08426B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:19:38 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so7926131pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 15:19:38 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z72si7143944pgd.233.2017.01.11.15.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 15:19:38 -0800 (PST)
Date: Wed, 11 Jan 2017 15:19:37 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v5 3/9] mm/swap: Split swap cache into 64MB trunks
Message-ID: <20170111231937.GH8388@tassilo.jf.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <735bab895e64c930581ffb0a05b661e01da82bc5.1484082593.git.tim.c.chen@linux.intel.com>
 <20170111150940.25d951a121a62e1b7eff6f8d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111150940.25d951a121a62e1b7eff6f8d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> Switching from a single radix-tree to an array of radix-trees to reduce
> contention seems a bit hacky.  That we can do this and have everything
> continue to work tells me that we're simply using an inappropriate data
> structure to hold this info.

What would you use instead?

A tree with fine grained locking?

FWIW too fine grained locking (e.g. on every node) is usually a bad idea: 

it slows down the single thread performance and it causes much more overhead
when there is actual contention because too much time is spent bouncing cache
lines around.

So I actually like the "a little bit more fine grained, but not too much"
approach.

Or a hash table? 

Not sure if this would work here.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
