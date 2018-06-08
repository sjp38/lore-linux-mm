Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4DE6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 13:05:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e39-v6so428181plb.10
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 10:05:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y124-v6si24861169pgb.61.2018.06.08.10.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Jun 2018 10:05:08 -0700 (PDT)
Date: Fri, 8 Jun 2018 10:05:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-ID: <20180608170503.GA29260@bombadil.infradead.org>
References: <201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp>
 <20180418144401.7c9311079914803c9076d209@linux-foundation.org>
 <201804190154.w3J1sieH011800@www262.sakura.ne.jp>
 <20180418193254.2db529eeca5d0dc5b82f6b3e@linux-foundation.org>
 <20180607150546.1c7db21f70221008e14b8bb8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180607150546.1c7db21f70221008e14b8bb8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com

On Thu, Jun 07, 2018 at 03:05:46PM -0700, Andrew Morton wrote:
> [akpm@linux-foundation.org: add comment]

Can I fix the comment?  ;-)

> @@ -440,6 +440,14 @@ static __latent_entropy int dup_mmap(str
>  			continue;
>  		}
>  		charge = 0;
> +		/*
> +		 * Don't duplicate many vmas if we've been oom-killed (for
> +		 * example)
> +		 */

		/*
		 * No point in continuing if we're just going to die at
		 * the end of the fork.  This may happen due to being OOM.
		 */

> +		if (fatal_signal_pending(current)) {
> +			retval = -EINTR;
> +			goto out;
> +		}

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
