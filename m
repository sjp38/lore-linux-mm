Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A709E6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:18:38 -0500 (EST)
Subject: Re: [PATCH 10/13] writeback: make reasonable gap between the
 dirty/background thresholds
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042850.482907860@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.482907860@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 12:18:18 +0100
Message-ID: <1290597498.2072.458.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> plain text document attachment
> (writeback-fix-oversize-background-thresh.patch)
> The change is virtually a no-op for the majority users that use the
> default 10/20 background/dirty ratios. For others don't know why they
> are setting background ratio close enough to dirty ratio. Someone must
> set background ratio equal to dirty ratio, but no one seems to notice or
> complain that it's then silently halved under the hood..
>=20
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |   11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
>=20
> --- linux-next.orig/mm/page-writeback.c	2010-11-15 13:12:50.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c	2010-11-15 13:13:42.000000000 +0800
> @@ -403,8 +403,15 @@ void global_dirty_limits(unsigned long *
>  	else
>  		background =3D (dirty_background_ratio * available_memory) / 100;
> =20
> -	if (background >=3D dirty)
> -		background =3D dirty / 2;
> +	/*
> +	 * Ensure at least 1/4 gap between background and dirty thresholds, so
> +	 * that when dirty throttling starts at (background + dirty)/2, it's at
> +	 * the entrance of bdi soft throttle threshold, so as to avoid being
> +	 * hard throttled.
> +	 */
> +	if (background > dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT)
> +		background =3D dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT;
> +
>  	tsk =3D current;
>  	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
>  		background +=3D background / 4;


Hrm,.. the alternative is to return -ERANGE or somesuch when people try
to write nonsensical values.

I'm not sure what's best, guessing at what the user did mean to do or
forcing him to actually think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
