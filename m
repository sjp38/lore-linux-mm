Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBB98299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 19:08:40 -0400 (EDT)
Received: by igjz20 with SMTP id z20so265461igj.4
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:08:40 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id l19si3706454icg.13.2015.03.13.16.08.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 16:08:39 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so130965485iec.2
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:08:39 -0700 (PDT)
Date: Fri, 13 Mar 2015 16:08:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mremap should return -ENOMEM when __vm_enough_memory
 fail
In-Reply-To: <1426238498-21127-1-git-send-email-crquan@ymail.com>
Message-ID: <alpine.DEB.2.10.1503131606100.7827@chino.kir.corp.google.com>
References: <1426238498-21127-1-git-send-email-crquan@ymail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Derek <crquan@ymail.com>
Cc: linux-mm@kvack.org

On Fri, 13 Mar 2015, Derek wrote:

> Recently I straced bash behavior in this dd zero pipe to read test,
> in part of testing under vm.overcommit_memory=2 (OVERCOMMIT_NEVER mode):
>     # dd if=/dev/zero | read x
> 
> The bash sub shell is calling mremap to reallocate more and more memory
> untill it finally failed -ENOMEM (I expect), or to be killed by system
> OOM killer (which should not happen under OVERCOMMIT_NEVER mode);
> But the mremap system call actually failed of -EFAULT, which is a surprise
> to me, I think it's supposed to be -ENOMEM? then I wrote this piece
> of C code testing confirmed it:
> https://gist.github.com/crquan/326bde37e1ddda8effe5
> 
> The -EFAULT comes from the branch of security_vm_enough_memory_mm failure,
> underlyingly it calls __vm_enough_memory which returns only 0 for success
> or -ENOMEM; So why vma_to_resize needs to return -EFAULT in this case?
> it sounds like a mistake to me.
> 
> Some more digging into git history:
> 1) Before commit 119f657c7 in May 1 2005 (pre 2.6.12 days) it was returning
>    -ENOMEM for this failure;
> 2) but commit 119f657c7 changed it accidentally, to what ever is preserved
>    in local ret, which happened to be -EFAULT, in a previous assignment;
> 3) then in commit 54f5de709 code refactoring, it's explicitly returning
>    -EFAULT, should be wrong.
> 
> Signed-off-by: Derek Che <crquan@ymail.com>

Acked-by: David Rientjes <rientjes@google.com>

vma_to_resize() could certainly be cleaned up to just return ERR_PTR() and 
avoiding the "goto"s since there is no other cleanup needed as suggested 
by Kirill if you have time for a cleanup patch on top of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
