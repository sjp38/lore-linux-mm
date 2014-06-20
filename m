Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 892AB6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 09:51:35 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so3283413ieb.20
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 06:51:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z5si15069509icm.36.2014.06.20.06.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 06:51:34 -0700 (PDT)
Message-ID: <53A43C54.3090402@oracle.com>
Date: Fri, 20 Jun 2014 21:51:16 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
References: <53A0EB84.7030308@oracle.com>	<alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com>	<alpine.DEB.2.11.1406190939030.2785@gentwo.org> <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org>
In-Reply-To: <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org


On 06/20/2014 04:32 AM, Andrew Morton wrote:
> On Thu, 19 Jun 2014 09:39:54 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:
> 
>> On Wed, 18 Jun 2014, David Rientjes wrote:
>>
>>> Why?  kset_create_and_add() can fail for a few other reasons other than
>>> memory constraints and given that this is only done at bootstrap, it
>>> actually seems like a duplicate name would be a bigger concern than low on
>>> memory if another init call actually registered it.
>>
>> Greg said that the only reason for failure would be out of memory.
> 
> The kset_create_and_add interface is busted - it should return an
> ERR_PTR on error, not NULL.  This seems to be a common gregkh failing :(
> 
> It's plausible that out-of-memory is the most common reason for
> kset_create_and_add() failure, dunno.
> 
> Jeff, the changelog wasn't a good one - it failed to describe the
> reasons for the change.  What was wrong with ENOSYS and why is ENOMEM
> more appropriate?  If Greg told us that out-of-memory is the only
> possible reason for the failure then it would be useful to capture the
> reasoning behind this within this changelog.
> 
> Also let's describe the effects of this patch.  It looks like it's just
> cosmetic - if kset_create_and_add() fails, the kernel behavior will be
> the same either way.

I admit that the current changelog is indistinct :)

At that time, I thought it would be ENOMEM because I was review another patch
for adding sysfs support to XFS where we return ENOMEM in this case:
http://www.spinics.net/lists/xfs/msg28343.html

This drives to me to think why it should be ENOMEM rather than ERR_PTR since
it seems most likely kset_create_and_add() would fails due to other reasons.
Hence I looked through kernel sources and figured out most subsystems are return
ENOMEM, maybe those subsystems are refers to the kset example code at:
samples/kobject/kset-example.c

So my original motivation is just to make the slub sysfs init error handling in
accordance to other subsystems(nitpick) and it does not affect the kernel behaviour.

Combine with Greg's comments, as such, maybe the changelog would looks like
the following?

GregKH: the only reason for failure would be out of memory on kset_create_and_add().
return -ENOMEM than -ENOSYS if the call is failed which is consistent with other
subsystems in this situation.


Cheers,
-Jeff





  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
