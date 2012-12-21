Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B6C216B0070
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 17:00:03 -0500 (EST)
Message-ID: <50D4DBC8.2020008@oracle.com>
Date: Fri, 21 Dec 2012 16:59:36 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm,ksm: use new hashtable implementation
References: <1356112012-24584-1-git-send-email-sasha.levin@oracle.com> <20121221133610.bb516813.akpm@linux-foundation.org>
In-Reply-To: <20121221133610.bb516813.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

On 12/21/2012 04:36 PM, Andrew Morton wrote:
> On Fri, 21 Dec 2012 12:46:50 -0500
> Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> Switch ksm to use the new hashtable implementation. This reduces the amount of
>> generic unrelated code in the ksm module.
> 
> hm, include/linux/hashtable.h:hash_min() is rather dangerous - it
> returns different values depending on the size of the first argument. 
> So if the calling code mixes up its ints and longs (and boy we do that
> a lot), the result will work on 32-bit and fail on 64-bit.

The reason for doing so is because hashing 32 bits is much faster than
hashing 64 bits.

I'd really prefer to fix the code the mixes up ints and longs instead
of removing optimizations. Not only because of the optimizations themselves
but because these mixups will be rather obvious with the hashtable as
opposed to all the other places that just misbehave silently.

> Also, is there ever likely to be a situation where the first arg to
> hash_min() is *not* a pointer?  Perhaps it would be better to concede
> to reality: rename `key' to `ptr' and remove all those typcasts you
> just added.

There actually are several. This is the reason for hash_min really - several
places that used 32bit keys would have been slowed down by switch to
hash_long(), which is why hash_min() was introduced.

The first places that come to mind are userns, 9p and tracepoints, I guess
there are a few more which I don't remember.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
