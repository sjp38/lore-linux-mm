Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9999F6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:46:37 -0400 (EDT)
Date: Tue, 4 Sep 2012 16:46:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix potential anon_vma locking issue in mprotect()
Message-Id: <20120904164636.158d8012.akpm@linux-foundation.org>
In-Reply-To: <1346801989-18274-1-git-send-email-walken@google.com>
References: <1346801989-18274-1-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com

On Tue,  4 Sep 2012 16:39:49 -0700
Michel Lespinasse <walken@google.com> wrote:

> This change fixes an anon_vma locking issue in the following situation:
> - vma has no anon_vma
> - next has an anon_vma
> - vma is being shrunk / next is being expanded, due to an mprotect call
> 
> We need to take next's anon_vma lock to avoid races with rmap users
> (such as page migration) while next is being expanded.
>
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -578,8 +578,12 @@ again:			remove_next = 1 + (end > next->vm_end);
>  	 */
>  	if (vma->anon_vma && (importer || start != vma->vm_start)) {
>  		anon_vma = vma->anon_vma;
> +		VM_BUG_ON(adjust_next && next->anon_vma &&
> +			  anon_vma != next->anon_vma);
> +	} else if (adjust_next && next->anon_vma)
> +		anon_vma = next->anon_vma;
> +	if (anon_vma)
>  		anon_vma_lock(anon_vma);
> -	}
>  
>  	if (root) {
>  		flush_dcache_mmap_lock(mapping);

hm, OK.  How serious was that bug?  I'm suspecting "only needed in
3.7".

If we want to fix this in 3.6 and perhaps -stable, I'm a bit worried
about that new VM_BUG_ON().  Not that I don't trust you or anything,
but these things tend to go bang when people least expected it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
