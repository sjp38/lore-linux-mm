Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E021B6B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 18:30:49 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so1238891igq.0
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 15:30:49 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id u7si17546792ics.13.2014.06.20.15.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 15:30:49 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so1238874igq.0
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 15:30:49 -0700 (PDT)
Date: Fri, 20 Jun 2014 15:30:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
In-Reply-To: <53A43C54.3090402@oracle.com>
Message-ID: <alpine.DEB.2.02.1406201526190.16090@chino.kir.corp.google.com>
References: <53A0EB84.7030308@oracle.com> <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com> <alpine.DEB.2.11.1406190939030.2785@gentwo.org> <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org> <53A43C54.3090402@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org

On Fri, 20 Jun 2014, Jeff Liu wrote:

> At that time, I thought it would be ENOMEM because I was review another patch
> for adding sysfs support to XFS where we return ENOMEM in this case:
> http://www.spinics.net/lists/xfs/msg28343.html
> 
> This drives to me to think why it should be ENOMEM rather than ERR_PTR since
> it seems most likely kset_create_and_add() would fails due to other reasons.
> Hence I looked through kernel sources and figured out most subsystems are return
> ENOMEM, maybe those subsystems are refers to the kset example code at:
> samples/kobject/kset-example.c
> 

If you're going to ignore other emails in this thread, then you're not 
going to make a very strong argument.

kset_create_and_add() can return NULL for reasons OTHER than just ENOMEM.  
It can also be returned for EEXIST because something registered the 
kobject with the same name.  During init, which is what you're modifying 
here, the liklihood is higher that it will return EEXIST rather than 
ENOMEM otherwise there are much bigger problems than return value.

> So my original motivation is just to make the slub sysfs init error handling in
> accordance to other subsystems(nitpick) and it does not affect the kernel behaviour.
> 

Why should slub match the other incorrect behavior?

What you're never addressing is WHY you are even making this change or 
even care about the return value.  Show userspace breakage that depends on 
this.

> Combine with Greg's comments, as such, maybe the changelog would looks like
> the following?
> 
> GregKH: the only reason for failure would be out of memory on kset_create_and_add().
> return -ENOMEM than -ENOSYS if the call is failed which is consistent with other
> subsystems in this situation.
> 

Bullshit.  Read the above.

If you want to return PTR_ERR() when this fails and fixup all the callers, 
then propose that patch.  Until then, it's a pretty simple rule: if you 
don't have an errno, don't assume the reason for failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
