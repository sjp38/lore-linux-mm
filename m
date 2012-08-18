Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 94AD86B0069
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 00:10:17 -0400 (EDT)
Message-ID: <502F15A6.5060902@redhat.com>
Date: Sat, 18 Aug 2012 00:10:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Repeated fork() causes SLAB to grow without bound
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu> <502F100A.1080401@redhat.com> <20120818040747.GA22793@evergreen.ssec.wisc.edu>
In-Reply-To: <20120818040747.GA22793@evergreen.ssec.wisc.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

On 08/18/2012 12:07 AM, Daniel Forrest wrote:

> I was being careful since I wasn't certain about the locking.  Does
> the test need to be protected by "lock_anon_vma_root"?  That's why I
> chose the overhead of the possible wasted "anon_vma_chain_alloc".

The function anon_vma_clone is being called from fork().

When running fork(), the kernel holds the mm->mmap_sem for
write, which prevents page faults by the parent process.
This means if the anon_vma in question belongs to the parent
process, no new pages will be added to it in this time.

Likewise, if the anon_vma belonged to a grandparent process,
any new pages instantiated in it will not be visible to the
parent process, or to the newly created process. This means
it is safe to skip the anon_vma.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
