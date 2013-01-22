Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 76F866B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 18:54:41 -0500 (EST)
Date: Wed, 23 Jan 2013 00:54:38 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
Message-ID: <20130122235438.GB7497@quack.suse.cz>
References: <201301200002.r0K02Atl031280@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301200002.r0K02Atl031280@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

On Sun 20-01-13 11:02:10, paul.szabo@sydney.edu.au wrote:
> In bdi_position_ratio(), get difference (setpoint-dirty) right even when
> negative. Both setpoint and dirty are unsigned long, the difference was
> zero-padded thus wrongly sign-extended to s64. This issue affects all
> 32-bit architectures, does not affect 64-bit architectures where long
> and s64 are equivalent.
> 
> In this function, dirty is between freerun and limit, the pseudo-float x
> is between [-1,1], expected to be negative about half the time. With
> zero-padding, instead of a small negative x we obtained a large positive
> one so bdi_position_ratio() returned garbage.
> 
> Casting the difference to s64 also prevents overflow with left-shift;
> though normally these numbers are small and I never observed a 32-bit
> overflow there.
> 
> (This patch does not solve the PAE OOM issue.)
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> 
> Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
> Reference: http://bugs.debian.org/695182
> Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>
  Ah, good catch. Thanks for the patch. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

  I've also added CC to writeback maintainer.

								Honza

> 
> --- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
> +++ mm/page-writeback.c	2013-01-20 07:47:55.000000000 +1100
> @@ -559,7 +559,7 @@ static unsigned long bdi_position_ratio(
>  	 *     => fast response on large errors; small oscillation near setpoint
>  	 */
>  	setpoint = (freerun + limit) / 2;
> -	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
> +	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>  		    limit - setpoint + 1);
>  	pos_ratio = x;
>  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
