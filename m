Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 385A66B048C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 18:27:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so276089763pgc.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:27:19 -0800 (PST)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id c68si10301933pfj.98.2016.11.18.15.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 15:27:18 -0800 (PST)
Received: by mail-pg0-x230.google.com with SMTP id x23so104783192pgx.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:27:18 -0800 (PST)
Date: Fri, 18 Nov 2016 15:27:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 (re-send)] xen/gntdev: Use mempolicy instead of VM_IO
 flag to avoid NUMA balancing
In-Reply-To: <05c24d23-0298-5b58-d0e8-095ba64cdf9b@oracle.com>
Message-ID: <alpine.LSU.2.11.1611181456280.10597@eggly.anvils>
References: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com> <alpine.LSU.2.11.1611181335560.9605@eggly.anvils> <2bf041f3-8918-3c6f-8afb-c9edcc03dcd9@oracle.com> <alpine.LSU.2.11.1611181421470.10145@eggly.anvils>
 <05c24d23-0298-5b58-d0e8-095ba64cdf9b@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, david.vrabel@citrix.com, jgross@suse.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, olaf@aepfle.de

On Fri, 18 Nov 2016, Boris Ostrovsky wrote:
> On 11/18/2016 05:27 PM, Hugh Dickins wrote:
> > On Fri, 18 Nov 2016, Boris Ostrovsky wrote:
> >> On 11/18/2016 04:51 PM, Hugh Dickins wrote:
> >>> Hmm, sorry, but this seems overcomplicated to me: ingenious, but an
> >>> unusual use of the ->get_policy method, which is a little worrying,
> >>> since it has only been used for shmem (+ shm and kernfs) until now.
> >>>
> >>> Maybe I'm wrong, but wouldn't substituting VM_MIXEDMAP for VM_IO
> >>> solve the problem more simply?
> >> It would indeed. I didn't want to use it because it has specific meaning
> >> ("Can contain "struct page" and pure PFN pages") and that didn't seem
> >> like the right flag to describe this vma.
> > It is okay if it contains 0 pure PFN pages; and no worse than VM_IO was.
> > A comment on why VM_MIXEDMAP is being used there would certainly be good.
> > But I do find its use preferable to enlisting an unusual ->get_policy.
> 
> OK, I'll set VM_MIXEDMAP then.

Thanks, if it accomplishes what you need, then please do use it.

> 
> I am still curious though why you feel get_policy is not appropriate
> here (beside the fact that so far it had limited use). It is essentially
> trying to say that the only policy to be consulted (in vma_policy_mof())
> is of the vma itself and not of the task.

I agree that get_policy is explicitly about NUMA, and so relevant to the
matter of (discouraging) NUMA balancing, without any apology needed.

But there are no other examples of its use that way, it's been something
private to shmem (hence shm and kernfs) up until now: the complement of
set_policy, which implements the mbind() syscall on shmem objects.

Introduce an exceptional new usage, and we're likely to introduce bugs
(not to mention the long history of bugs in mpol_dup() that you also use).
Perhaps I'd find one already if I took the time to study your patch.

Full disclosure: I'm also contemplating a change to its interface,
to handle a possible NUMA interleave issue, so I do need to keep
an eye on all its callers.

If we have to choose between two less-than-ideal solutions,
please let's choose the simplest.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
