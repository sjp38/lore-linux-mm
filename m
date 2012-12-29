Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2EBC08D0001
	for <linux-mm@kvack.org>; Sat, 29 Dec 2012 03:45:29 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id o22so5867438qcr.33
        for <linux-mm@kvack.org>; Sat, 29 Dec 2012 00:45:28 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <50DD0106.7040001@iskon.hr>
References: <50D24AF3.1050809@iskon.hr>
	<20121220111208.GD10819@suse.de>
	<20121220125802.23e9b22d.akpm@linux-foundation.org>
	<50D601C9.9060803@iskon.hr>
	<50D71166.6030608@iskon.hr>
	<50DB129E.7010000@iskon.hr>
	<50DD0106.7040001@iskon.hr>
Date: Sat, 29 Dec 2012 09:45:27 +0100
Message-ID: <CA+icZUV1kOPogpd6cuwUUFy=MK8AqArVW+XgAPDLpAKyWLUShg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix null pointer dereference in wait_iff_congested()
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhouping Liu <zliu@redhat.com>

Just FYI:

This patch landed upstream [1].
Thanks for all involved people.

- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=ecccd1248d6e6986130ffcc3b0d003cb46a485c0

On Fri, Dec 28, 2012 at 3:16 AM, Zlatko Calusic <zlatko.calusic@iskon.hr> wrote:
> From: Zlatko Calusic <zlatko.calusic@iskon.hr>
>
> The unintended consequence of commit 4ae0a48b is that
> wait_iff_congested() can now be called with NULL struct zone*
> producing kernel oops like this:
>
> BUG: unable to handle kernel NULL pointer dereference
> IP: [<ffffffff811542d9>] wait_iff_congested+0x59/0x140
>
> This trivial patch fixes it.
>
> Reported-by: Zhouping Liu <zliu@redhat.com>
> Reported-and-tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 02bcfa3..e55ce55 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2782,7 +2782,7 @@ loop_again:
>                 if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
>                         if (has_under_min_watermark_zone)
>                                 count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
> -                       else
> +                       else if (unbalanced_zone)
>                                 wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
>                 }
>
> --
> 1.8.1.rc3
>
> --
> Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
