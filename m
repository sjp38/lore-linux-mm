Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BC5BB6B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:32:52 -0400 (EDT)
Message-ID: <50811E3B.3060503@parallels.com>
Date: Fri, 19 Oct 2012 13:32:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] slab: Ignore internal flags in cache creation
References: <1350473811-16264-1-git-send-email-glommer@parallels.com> <20121018154203.4b3a1179.akpm@linux-foundation.org>
In-Reply-To: <20121018154203.4b3a1179.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 10/19/2012 02:42 AM, Andrew Morton wrote:
> On Wed, 17 Oct 2012 15:36:51 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> Some flags are used internally by the allocators for management
>> purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
>> to mark that the metadata for that cache is stored outside of the slab.
>>
>> No cache should ever pass those as a creation flags. We can just ignore
>> this bit if it happens to be passed (such as when duplicating a cache in
>> the kmem memcg patches).
> 
> I may be minunderstanding this, but...
> 
> If some caller to kmem_cache_create() is passing in bogus flags then
> that's a bug, and it is undesirable to hide such a bug in this fashion?
> 

Not necessarily.

This part is part of the kmemcg-slab series. In that use case, I copy
the flags from the original kmem cache, and create a duplicate. That
duplicate need to have the same flags, but only the creation flags.

We had many attempts to mask it out in different places, and after some
discussion, it seemed best to independently do it from common code in
slab_common.c at creation time. It gets quite independent from the
kmemcg-slab this way, and so I posted independently to reduce my churn



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
