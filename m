Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BBD186B0062
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 19:00:10 -0500 (EST)
Date: Tue, 4 Dec 2012 09:00:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121204000042.GB20395@bbox>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <50AD739A.30804@linaro.org>
 <50B6E1F9.5010301@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B6E1F9.5010301@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Nov 28, 2012 at 08:18:01PM -0800, John Stultz wrote:
> On 11/21/2012 04:36 PM, John Stultz wrote:
> >2) Being able to use this with tmpfs files. I'm currently trying
> >to better understand the rmap code, looking to see if there's a
> >way to have try_to_unmap_file() work similarly to
> >try_to_unmap_anon(), to allow allow users to madvise() on mmapped
> >tmpfs files. This would provide a very similar interface as to
> >what I've been proposing with fadvise/fallocate, but just using
> >process virtual addresses instead of (fd, offset) pairs.   The
> >benefit with (fd,offset) pairs for Android is that its easier to
> >manage shared volatile ranges between two processes that are
> >sharing data via an mmapped tmpfs file (although this actual use
> >case may be fairly rare).  I believe we should still be able to
> >rework the ashmem internals to use madvise (which would provide
> >legacy support for existing android apps), so then its just a
> >question of if we could then eventually convince Android apps to
> >use the madvise interface directly, rather then the ashmem unpin
> >ioctl.
> 
> Hey Minchan,
>     I've been playing around with your patch trying to better
> understand your approach and to extend it to support tmpfs files. In
> doing so I've found a few bugs, and have some rough fixes I wanted
> to share. There's still a few edge cases I need to deal with (the
> vma-purged flag isn't being properly handled through vma merge/split
> operations), but its starting to come along.

Hmm, my patch doesn't allow to merge volatile with another one by
inserting VM_VOLATILE into VM_SPECIAL so I guess merge isn't problem.
In case of split, __split_vma copy old vma to new vma like this

        *new = *vma;

So the problem shouldn't happen, I guess.
Did you see the real problem about that?

> 
> Anyway, take a look at the tree here and let me know what you think.
> http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/minchan-anonvol
> 
> I'm sure much is wrong with the tree, but with it I can now mark
> tmpfs file pages as volatile/nonvolatile and see them purged under
> pressure. Unfortunately its not limited to tmpfs, so persistent
> files will also work, but the state of the underlying files on purge
> is undefined. Hopefully I can find a way to limit it to
> non-persistent filesystems for now, and if needed find a way to
> extend it to persistent filesystems in a sane way later.

I will take a look.
Thanks.

> 
> thanks
> -john
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
