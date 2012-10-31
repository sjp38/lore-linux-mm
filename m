Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9613B6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 18:56:26 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so2421798obc.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 15:56:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org> <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 31 Oct 2012 18:56:05 -0400
Message-ID: <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com>
Subject: Re: [RFC v2] Support volatile range for anon vma
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

>> > Allocator should call madvise(MADV_NOVOLATILE) before reusing for
>> > allocating that area to user. Otherwise, accessing of volatile range
>> > will meet SIGBUS error.
>>
>> Well, why?  It would be easy enough for the fault handler to give
>> userspace a new, zeroed page at that address.
>
> Note: MADV_DONTNEED already has this (nice) property.

I don't think I strictly understand this patch. but maybe I can answer why
userland and malloc folks don't like MADV_DONTNEED.

glibc malloc discard freed memory by using MADV_DONTNEED
as tcmalloc. and it is often a source of large performance decrease.
because of MADV_DONTNEED discard memory immediately and
right after malloc() call fall into page fault and pagesize memset() path.
then, using DONTNEED increased zero fill and cache miss rate.

At called free() time, malloc don't have a knowledge when next big malloc()
is called. then, immediate discarding may or may not get good performance
gain. (Ah, ok, the rate is not 5:5. then usually it is worth. but not everytime)


In past, several developers tryied to avoid such situation, likes

- making zero page daemon and avoid pagesize zero fill at page fault
- making new vma or page flags and mark as discardable w/o swap and
  vmscan treat it. (like this and/or MADV_FREE)
- making new process option and avoid page zero fill from page fault path.
  (yes, it is big incompatibility and insecure. but some embedded folks thought
   they are acceptable downside)
- etc


btw, I'm not sure this patch is better for malloc because current MADV_DONTNEED
don't need mmap_sem and works very effectively when a lot of threads case.
taking mmap_sem might bring worse performance than DONTNEED. dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
