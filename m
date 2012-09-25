Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 70C566B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 04:57:18 -0400 (EDT)
Date: Tue, 25 Sep 2012 10:57:09 +0200
From: Conny Seidel <conny.seidel@amd.com>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120925085707.GB30042@marah.osrc.amd.com>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <20120924142305.GD12264@quack.suse.cz>
 <20120924143609.GH22303@aftab.osrc.amd.com>
 <20120924201650.6574af64.conny.seidel@amd.com>
 <20120924181927.GA25762@aftab.osrc.amd.com>
 <5060AB0E.3070809@linux.vnet.ibm.com>
 <20120924193135.GB25762@aftab.osrc.amd.com>
 <20120924200737.GA30997@quack.suse.cz>
 <20120924201726.GB30997@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20120924201726.GB30997@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Borislav Petkov <bp@amd64.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Conny Seidel <conny.seidel@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Jan Kara <jack@suse.cz>:
>  [...]

The patch works for me. Tested it a couple of times on several machines
without triggering the issue.

Thanks for the fix.

> From 1fd707552a67adf869958e479910d2f70452351b Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Mon, 24 Sep 2012 16:17:16 +0200
> Subject: [PATCH] lib: Fix corruption of denominator in flexible proportions
>
> When racing with CPU hotplug, percpu_counter_sum() can return negative
> values for the number of observed events. This confuses fprop_new_period(),
> which uses unsigned type and as a result number of events is set to big
> *positive* number. From that moment on, things go pear shaped and can result
> e.g. in division by zero as denominator is later truncated to 32-bits.
>
> Fix the issue by using a signed type in fprop_new_period(). That makes us
> bail out from the function without doing anything (mistakenly) thinking
> there are no events to age. That makes aging somewhat inaccurate but getting
> accurate data would be rather hard.
>
> Reported-by: Borislav Petkov <bp@amd64.org>
> Reported-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
Tested-by: Conny Seidel <conny.seidel@amd.com>
> ---
>  lib/flex_proportions.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index c785554..ebf3bac 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -62,7 +62,7 @@ void fprop_global_destroy(struct fprop_global *p)
>   */
>  bool fprop_new_period(struct fprop_global *p, int periods)
>  {
> -	u64 events;
> +	s64 events;
>  	unsigned long flags;
>
>  	local_irq_save(flags);
> --
> 1.7.1
>


--
Kind regards.

Conny Seidel

##################################################################
# Email : conny.seidel@amd.com            GnuPG-Key : 0xA6AB055D #
# Fingerprint: 17C4 5DB2 7C4C C1C7 1452 8148 F139 7C09 A6AB 055D #
##################################################################
# Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach      #
# General Managers: Alberto Bozzo                                #
# Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen #
#               HRB Nr. 43632                                    #
##################################################################

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
