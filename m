Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 165D96B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 10:25:22 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so8555477pad.41
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 07:25:21 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wm3si25026030pab.339.2014.02.04.07.25.19
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 07:25:19 -0800 (PST)
Message-ID: <52F1065B.8040305@intel.com>
Date: Tue, 04 Feb 2014 07:25:15 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
References: <20140204013151.GB3481@bbox> <CF1584DE.149CA%je@fb.com> <20140204045821.GE3481@bbox>
In-Reply-To: <20140204045821.GE3481@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Jason Evans <je@fb.com>
Cc: John Stultz <john.stultz@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, "pliard@google.com" <pliard@google.com>

On 02/03/2014 08:58 PM, Minchan Kim wrote:
> Of course, every thread could do madvise(MADV_FREE) in parallel because
> VM in Linux doesn't need write-side semaphore but read-side semaphore.
> Additionally, page faulting also needs read-side semaphore so
> page faulting, madvise(MADV_FREE) in threads could be done in parallel
> without any scalability issue if they don't overlap same virtual addresses
> within 4M range because they need a page table lock but it's very
> unlikely in allocator, IMO.

In practice, things holding mmap_sem for read don't scale well, either,
especially when their hold times are short.  It's _better_ than if they
took it for write, but still doesn't scale well.  Check out the red
(threads) line in "Anonymous memory page fault" for instance:

> https://www.sr71.net/~dave/intel/willitscale/systems/bigbox/3.13.0-slub-08988-gd891ea2-dirty/foo.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
