Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8FE6B0488
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:47:12 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o1so43902298ito.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:47:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s74si3472425ita.89.2016.11.18.14.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 14:47:11 -0800 (PST)
Subject: Re: [PATCH v3 (re-send)] xen/gntdev: Use mempolicy instead of VM_IO
 flag to avoid NUMA balancing
References: <1479413404-27332-1-git-send-email-boris.ostrovsky@oracle.com>
 <alpine.LSU.2.11.1611181335560.9605@eggly.anvils>
 <2bf041f3-8918-3c6f-8afb-c9edcc03dcd9@oracle.com>
 <alpine.LSU.2.11.1611181421470.10145@eggly.anvils>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <05c24d23-0298-5b58-d0e8-095ba64cdf9b@oracle.com>
Date: Fri, 18 Nov 2016 17:49:41 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611181421470.10145@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, david.vrabel@citrix.com, jgross@suse.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, olaf@aepfle.de

On 11/18/2016 05:27 PM, Hugh Dickins wrote:
> On Fri, 18 Nov 2016, Boris Ostrovsky wrote:
>> On 11/18/2016 04:51 PM, Hugh Dickins wrote:
>>> Hmm, sorry, but this seems overcomplicated to me: ingenious, but an
>>> unusual use of the ->get_policy method, which is a little worrying,
>>> since it has only been used for shmem (+ shm and kernfs) until now.
>>>
>>> Maybe I'm wrong, but wouldn't substituting VM_MIXEDMAP for VM_IO
>>> solve the problem more simply?
>> It would indeed. I didn't want to use it because it has specific meani=
ng
>> ("Can contain "struct page" and pure PFN pages") and that didn't seem
>> like the right flag to describe this vma.
> It is okay if it contains 0 pure PFN pages; and no worse than VM_IO was=
=2E
> A comment on why VM_MIXEDMAP is being used there would certainly be goo=
d.
> But I do find its use preferable to enlisting an unusual ->get_policy.

OK, I'll set VM_MIXEDMAP then.

I am still curious though why you feel get_policy is not appropriate
here (beside the fact that so far it had limited use). It is essentially
trying to say that the only policy to be consulted (in vma_policy_mof())
is of the vma itself and not of the task.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
