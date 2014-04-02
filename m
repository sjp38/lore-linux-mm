Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A63E06B006C
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 00:12:49 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so10868843pab.18
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 21:12:49 -0700 (PDT)
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
        by mx.google.com with ESMTPS id pm5si387623pbc.441.2014.04.01.21.12.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 21:12:48 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so10559869pdi.30
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 21:12:48 -0700 (PDT)
Message-ID: <533B8E3C.3090606@linaro.org>
Date: Tue, 01 Apr 2014 21:12:44 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B313E.5000403@zytor.com> <533B4555.3000608@sr71.net>
In-Reply-To: <533B4555.3000608@sr71.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/01/2014 04:01 PM, Dave Hansen wrote:
> On 04/01/2014 02:35 PM, H. Peter Anvin wrote:
>> On 04/01/2014 02:21 PM, Johannes Weiner wrote:
>>> Either way, optimistic volatile pointers are nowhere near as
>>> transparent to the application as the above description suggests,
>>> which makes this usecase not very interesting, IMO.
>> ... however, I think you're still derating the value way too much.  The
>> case of user space doing elastic memory management is more and more
>> common, and for a lot of those applications it is perfectly reasonable
>> to either not do system calls or to have to devolatilize first.
> The SIGBUS is only in cases where the memory is set as volatile and
> _then_ accessed, right?
Not just set volatile and then accessed, but when a volatile page has
been purged and then accessed without being made non-volatile.


> John, this was something that the Mozilla guys asked for, right?  Any
> idea why this isn't ever a problem for them?
So one of their use cases for it is for library text. Basically they
want to decompress a compressed library file into memory. Then they plan
to mark the uncompressed pages volatile, and then be able to call into
it. Ideally for them, the kernel would only purge cold pages, leaving
the hot pages in memory. When they traverse a purged page, they handle
the SIGBUS and patch the page up.

Now.. this is not what I'd consider a normal use case, but was hoping to
illustrate some of the more interesting uses and demonstrate the
interfaces flexibility.

Also it provided a clear example of benefits to doing LRU based
cold-page purging rather then full object purging. Though I think the
same could be demonstrated in a simpler case of a large cache of objects
that the applications wants to mark volatile in one pass, unmarking
sub-objects as it needs.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
