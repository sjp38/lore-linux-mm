Message-Id: <6.0.0.20.2.20081016112735.04a68e70@172.19.0.2>
Date: Thu, 16 Oct 2008 11:44:39 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: Re: [PATCH] vmscan: set try_to_release_page's gfp_mask to 0
In-Reply-To: <20081015153641.afcc94e5.akpm@linux-foundation.org>
References: <6.0.0.20.2.20080813111835.03d345b0@172.19.0.2>
 <20080812202127.b88e8250.akpm@linux-foundation.org>
 <6.0.0.20.2.20080813150454.03b13e30@172.19.0.2>
 <20081015153641.afcc94e5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi Andrew.

>Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp> wrote:
>
>> At 12:21 08/08/13, Andrew Morton wrote:
>> >On Wed, 13 Aug 2008 11:21:16 +0900 Hisashi Hifumi 
>> ><hifumi.hisashi@oss.ntt.co.jp> wrote:

>> >> Signed-off-by: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
>> >> 
>> >> diff -Nrup linux-2.6.27-rc2.org/mm/vmscan.c 
>linux-2.6.27-rc2.vmscan/mm/vmscan.c
>> >> --- linux-2.6.27-rc2.org/mm/vmscan.c	2008-08-11 14:33:24.000000000 +0900
>> >> +++ linux-2.6.27-rc2.vmscan/mm/vmscan.c	2008-08-12 18:57:05.000000000 +0900
>> >> @@ -614,7 +614,7 @@ static unsigned long shrink_page_list(st
>> >>  		* Otherwise, leave the page on the LRU so it is swappable.
>> >>  		*/
>> >>  		if (PagePrivate(page)) {
>> >> -			if (!try_to_release_page(page, sc->gfp_mask))
>> >> +			if (!try_to_release_page(page, 0))
>> >>  				goto activate_locked;
>> >>  			if (!mapping && page_count(page) == 1) {
>> >>  				unlock_page(page);
>> >
>> >I think the change makes sense.
>> >
>> >Has this change been shown to improve any workloads?  If so, please
>> >provide full information for the changelog.  If not, please mention
>> >this and explain why benefits were not demonstrable.  This information
>> >should _always_ be present in a "performance" patch's changelog!
>> 
>> Sorry, I do not have performance number yet. I'll try this.
>> 
>

Unfortunately, I did not succeed to get good performance number that
prove this patch had some benefit.

>This patch remains in a stalled state...
>
>And then there's this:
>

>: 
>: Really, I think what this patch tells us is that 3f31fddf ("jbd: fix
>: race between free buffer and commit transaction") was an unpleasant
>: hack which had undesirable and unexpected side-effects.  I think - that
>: depends upon your as-yet-undisclosed testing results?
>: 
>: Perhaps we should revert 3f31fddf and have another think about how to
>: fix the direct-io -EIO problem.  One option would be to hold our noses
>: and add a new gfp_t flag for this specific purpose?
>:

direct-io -EIO problem was already fixed by following patch.

commit 6ccfa806a9cfbbf1cd43d5b6aa47ef2c0eb518fd
Author: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Date:   Tue Sep 2 14:35:40 2008 -0700

    VFS: fix dio write returning EIO when try_to_release_page fails

Dio falls back to buffered write when dio write gets EIO due to failure of try_to_release_page
by above patch. So I think just reverting the patch 3f31fddf ("jbd: fix race between 
free buffer and commit transaction") is good approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
