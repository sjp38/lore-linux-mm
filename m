Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3D7BA6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 21:16:04 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so1929229iak.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 18:16:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org> <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
 <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com>
From: Paul Turner <pjt@google.com>
Date: Wed, 31 Oct 2012 18:15:33 -0700
Message-ID: <CAPM31RJwrM2f8fg0--Xcea+tHYcB2C_khXy3k-h=O2x4MMfwmw@mail.gmail.com>
Subject: Re: [RFC v2] Support volatile range for anon vma
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

On Wed, Oct 31, 2012 at 3:56 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>>> > Allocator should call madvise(MADV_NOVOLATILE) before reusing for
>>> > allocating that area to user. Otherwise, accessing of volatile range
>>> > will meet SIGBUS error.
>>>
>>> Well, why?  It would be easy enough for the fault handler to give
>>> userspace a new, zeroed page at that address.
>>
>> Note: MADV_DONTNEED already has this (nice) property.
>
> I don't think I strictly understand this patch. but maybe I can answer why
> userland and malloc folks don't like MADV_DONTNEED.
>
> glibc malloc discard freed memory by using MADV_DONTNEED
> as tcmalloc. and it is often a source of large performance decrease.
> because of MADV_DONTNEED discard memory immediately and
> right after malloc() call fall into page fault and pagesize memset() path.
> then, using DONTNEED increased zero fill and cache miss rate.
>
> At called free() time, malloc don't have a knowledge when next big malloc()
> is called. then, immediate discarding may or may not get good performance
> gain. (Ah, ok, the rate is not 5:5. then usually it is worth. but not everytime)
>

Ah; In tcmalloc allocations (and their associated free-lists) are
binned into separate lists as a function of object-size which helps to
mitigate this.

I'd make a separate more general argument here:
If I'm allocating a large (multi-kilobyte object) the cost of what I'm
about to do with that object is likely fairly large -- The fault/zero
cost a probably fairly small proportional cost, which limits the
optimization value.

>
> In past, several developers tryied to avoid such situation, likes
>
> - making zero page daemon and avoid pagesize zero fill at page fault
> - making new vma or page flags and mark as discardable w/o swap and
>   vmscan treat it. (like this and/or MADV_FREE)
> - making new process option and avoid page zero fill from page fault path.
>   (yes, it is big incompatibility and insecure. but some embedded folks thought
>    they are acceptable downside)
> - etc
>
>
> btw, I'm not sure this patch is better for malloc because current MADV_DONTNEED
> don't need mmap_sem and works very effectively when a lot of threads case.
> taking mmap_sem might bring worse performance than DONTNEED. dunno.

MADV_VOLATILE also seems to end up looking quite similar to a
user-visible (range-based) cleancache.

A second popular use-case for such semantics is the case of
discardable cache elements (e.g. web browser).  I suspect we'd want to
at least mention these in the changelog.  (Alternatively, what does a
cleancache-backed-fs exposing these semantics look like?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
