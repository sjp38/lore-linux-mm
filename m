Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 850096B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:33:28 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 4so83289513pfd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:33:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i22si17849884pfj.249.2016.03.31.19.33.27
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 19:33:27 -0700 (PDT)
Date: Fri, 1 Apr 2016 11:35:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC][PATCH] mm/slub: Skip CPU slab activation when debugging
Message-ID: <20160401023533.GB13179@js1304-P5Q-DELUXE>
References: <1459205581-4605-1-git-send-email-labbott@fedoraproject.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459205581-4605-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Mon, Mar 28, 2016 at 03:53:01PM -0700, Laura Abbott wrote:
> The per-cpu slab is designed to be the primary path for allocation in SLUB
> since it assumed allocations will go through the fast path if possible.
> When debugging is enabled, the fast path is disabled and per-cpu
> allocations are not used. The current debugging code path still activates
> the cpu slab for allocations and then immediately deactivates it. This
> is useless work. When a slab is enabled for debugging, skip cpu
> activation.
> 
> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
> ---
> This is a follow on to the optimization of the debug paths for poisoning
> With this I get ~2 second drop on hackbench -g 20 -l 1000 with slub_debug=P
> and no noticable change with slub_debug=- .

I'd like to know the performance difference between slub_debug=P and
slub_debug=- with this change.

Although this patch increases hackbench performance, I'm not sure it's
sufficient for the production system. Concurrent slab allocation request
will contend the node lock in every allocation attempt. So, there would be
other ues-cases that performance drop due to slub_debug=P cannot be
accepted even if it is security feature.

How about allowing cpu partial list for debug cases?
It will not hurt fast path and will make less contention on the node
lock.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
