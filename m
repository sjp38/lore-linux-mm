Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 531376B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 11:03:56 -0400 (EDT)
Message-ID: <4FBCFBE0.2080803@parallels.com>
Date: Wed, 23 May 2012 19:01:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab+slob: dup name string
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com> <alpine.DEB.2.00.1205220855470.17600@router.home> <4FBBAE95.6080608@parallels.com> <alpine.DEB.2.00.1205221216050.17721@router.home> <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com> <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com> <4FBCD328.6060406@parallels.com> <1337775878.3013.16.camel@dabdike.int.hansenpartnership.com> <alpine.DEB.2.00.1205230947490.30940@router.home>
In-Reply-To: <alpine.DEB.2.00.1205230947490.30940@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/23/2012 06:48 PM, Christoph Lameter wrote:
> On Wed, 23 May 2012, James Bottomley wrote:
>
>>>> So, why not simply patch slab to rely on the string lifetime being the
>>>> cache lifetime (or beyond) and therefore not having it take a copy?
>
> Well thats they way it was for a long time. There must be some reason that
> someone started to add this copying business....  Pekka?
>

 From git:

commit 84c1cf62465e2fb0a692620dcfeb52323ab03d48
Author: Pekka Enberg <penberg@kernel.org>
Date:   Tue Sep 14 23:21:12 2010 +0300

SLUB: Fix merged slab cache names

As explained by Linus "I'm Proud to be an American" Torvalds:

Looking at the merging code, I actually think it's totally
buggy. If you have something like this:

  - load module A: create slab cache A

  - load module B: create slab cache B that can merge with A

  - unload module A

  - "cat /proc/slabinfo": BOOM. Oops.

exactly because the name is not handled correctly, and you'll have
module B holding open a slab cache that has a name pointer that points
to module A that no longer exists.

So if I understand it correctly, this is mostly because the name string 
outlives the cache in the slub case, because of merging ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
