Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D74FF6B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 23:46:22 -0400 (EDT)
Message-ID: <502F100A.1080401@redhat.com>
Date: Fri, 17 Aug 2012 23:46:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Repeated fork() causes SLAB to grow without bound
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu>
In-Reply-To: <20120818000312.GA4262@evergreen.ssec.wisc.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

On 08/17/2012 08:03 PM, Daniel Forrest wrote:

> Based on your comments, I came up with the following patch.  It boots
> and the anon_vma/anon_vma_chain SLAB usage is stable, but I don't know
> if I've overlooked something.  I'm not a kernel hacker.

The patch looks reasonable to me.  There is one spot left
for optimization, which I have pointed out below.

Of course, that leaves the big question: do we want the
overhead of having the atomic addition and decrement for
every anonymous memory page, or is it easier to fix this
issue in userspace?

Given that malicious userspace could potentially run the
system out of memory, without needing special privileges,
and the OOM killer may not be able to reclaim it due to
internal slab fragmentation, I guess this issue could be
classified as a low impact denial of service vulnerability.

Furthermore, there is already a fair amount of bookkeeping
being done in the rmap code, so this patch is not likely
to add a whole lot - some testing might be useful, though.

> @@ -262,7 +264,10 @@ int anon_vma_clone(struct vm_area_struct
>   		}
>   		anon_vma = pavc->anon_vma;
>   		root = lock_anon_vma_root(root, anon_vma);
> -		anon_vma_chain_link(dst, avc, anon_vma);
> +		if (!atomic_read(&anon_vma->pagecount))
> +			anon_vma_chain_free(avc);
> +		else
> +			anon_vma_chain_link(dst, avc, anon_vma);
>   	}
>   	unlock_anon_vma_root(root);
>   	return 0;

In this function, you can do the test before the code block
where we try to allocate an anon_vma chain.

In other words:

	list_for_each_entry_reverse(.....
	struct anon_vma *anon_vma;

+	if (!atomic_read(&anon_vma->pagecount))
+		continue;
+
	avc = anon_vma_chain_alloc(...
	if (unlikely(!avc)) {

The rest looks good.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
