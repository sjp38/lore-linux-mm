Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EA8906B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 00:36:46 -0400 (EDT)
Date: Wed, 19 Jun 2013 13:36:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 8/8] vrange: Send SIGBUS when user try to access purged
 page
Message-ID: <20130619043650.GB10961@bbox>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
 <1371010971-15647-9-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371010971-15647-9-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 11, 2013 at 09:22:51PM -0700, John Stultz wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> By vrange(2) semantic, user should see SIGBUG if he try to access
> purged page without vrange(...VRANGE_NOVOLATILE).
> 
> This patch implements it.
> 
> XXX: I reused PSE bit for quick prototype without enough considering
> so need time to see what's empty bit and I am surely missing
> many places to handle vrange pte bit. I should investigate all of
> pte handling places, especially pte_none case.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Righi <andrea@betterlinux.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Dhaval Giani <dgiani@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> [jstultz: Extended to work with file pages]
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  arch/x86/include/asm/pgtable_types.h |  2 ++
>  include/asm-generic/pgtable.h        | 11 +++++++++++
>  include/linux/vrange.h               |  2 ++
>  mm/memory.c                          | 23 +++++++++++++++++++++--
>  mm/vrange.c                          | 35 ++++++++++++++++++++++++++++++++++-
>  5 files changed, 70 insertions(+), 3 deletions(-)
> 

This patch fixes the problem Dhaval reported.
