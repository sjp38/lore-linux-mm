Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id D8F5E6B0031
	for <linux-mm@kvack.org>; Sat, 21 Jun 2014 04:49:50 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id 131so3388813ykp.25
        for <linux-mm@kvack.org>; Sat, 21 Jun 2014 01:49:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b79si17736380yhi.32.2014.06.21.01.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Jun 2014 01:49:50 -0700 (PDT)
Message-ID: <53A5471E.50503@oracle.com>
Date: Sat, 21 Jun 2014 16:49:34 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
References: <53A0EB84.7030308@oracle.com> <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com> <alpine.DEB.2.11.1406190939030.2785@gentwo.org> <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org> <53A43C54.3090402@oracle.com> <alpine.DEB.2.02.1406201526190.16090@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406201526190.16090@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org, Greg KH <gregkh@linuxfoundation.org>


On 06/21/2014 06:30 AM, David Rientjes wrote:
> On Fri, 20 Jun 2014, Jeff Liu wrote:
> 
>> At that time, I thought it would be ENOMEM because I was review another patch
>> for adding sysfs support to XFS where we return ENOMEM in this case:
>> http://www.spinics.net/lists/xfs/msg28343.html
>>
>> This drives to me to think why it should be ENOMEM rather than ERR_PTR since
>> it seems most likely kset_create_and_add() would fails due to other reasons.
>> Hence I looked through kernel sources and figured out most subsystems are return
>> ENOMEM, maybe those subsystems are refers to the kset example code at:
>> samples/kobject/kset-example.c
>>
> 
> If you're going to ignore other emails in this thread, then you're not 
> going to make a very strong argument.

No, I was not intended to ignore your comments, instead, I appreciate your
review since it took up your time and time is valuable to everybody.
But the time zone is too late to me yesterday, and I need to refresh my
head to read through the whole call chains in kset_create_and_add().

> 
> kset_create_and_add() can return NULL for reasons OTHER than just ENOMEM.  
> It can also be returned for EEXIST because something registered the 
> kobject with the same name.  During init, which is what you're modifying 
> here, the liklihood is higher that it will return EEXIST rather than 
> ENOMEM otherwise there are much bigger problems than return value.

Agree, now it's clear EEXIST is returned if we trying to create a new kobject
with the same name and with the same parent_kobj, i.e,

kset_create_and_add()
  kset_register()
    kset_register()
      kobject_add_internal()
        create_dir()
          sysfs_create_dir_ns()->sysfs_warn_dup()...

And also, the likelihood is higher to some extent, indeed.

> 
>> So my original motivation is just to make the slub sysfs init error handling in
>> accordance to other subsystems(nitpick) and it does not affect the kernel behaviour.
>>
> 
> Why should slub match the other incorrect behavior?
> 
> What you're never addressing is WHY you are even making this change or
> even care about the return value.  Show userspace breakage that depends on 
> this.

For the consistency with other subsystems, but now I don't think it's right
due to above reason.

>> Combine with Greg's comments, as such, maybe the changelog would looks like
>> the following?
>>
>> GregKH: the only reason for failure would be out of memory on kset_create_and_add().
>> return -ENOMEM than -ENOSYS if the call is failed which is consistent with other
>> subsystems in this situation.
>>
> 
> Bullshit.  Read the above.
  ^^^^^^^
I assume that you spoke like that because I have not reply to you in time, I can
understand if so.  Otherwise, don't talk to me like that no matter who you are!

> 
> If you want to return PTR_ERR() when this fails and fixup all the callers, 
> then propose that patch.  Until then, it's a pretty simple rule: if you 
> don't have an errno, don't assume the reason for failure.

As I mentioned previously, Greg don't like to fixup kobjects API via PTR_ERR().
For me, I neither want to propose PTR_ERR to kobject nor try to push the current
slub fix, because it's make no sense to slub with either errno.


Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
