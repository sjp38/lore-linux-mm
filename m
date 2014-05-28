Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id D5FE76B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 18:00:12 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so13247320veb.16
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:00:12 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id j10si11791276vdf.97.2014.05.28.15.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 15:00:12 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so13120827vcb.38
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:00:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53862f6c.91148c0a.5fb0.2d0cSMTPIN_ADDED_BROKEN@mx.google.com>
References: <cover.1400607328.git.tony.luck@intel.com>
	<eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
	<20140523033438.GC16945@gchen.bj.intel.com>
	<CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
	<20140527161613.GC4108@mcs.anl.gov>
	<5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com>
	<CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com>
	<53852abb.867ce00a.3cef.3c7eSMTPIN_ADDED_BROKEN@mx.google.com>
	<FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com>
	<53862f6c.91148c0a.5fb0.2d0cSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Wed, 28 May 2014 15:00:11 -0700
Message-ID: <CA+8MBbKdKy+sbov-f+1xNnj=syEM5FWR1BV85AgRJ9S+qPbWEg@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure.c: support dedicated thread to handle
 SIGBUS(BUS_MCEERR_AO) thread
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Kamil Iskra <iskra@mcs.anl.gov>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

On Wed, May 28, 2014 at 11:47 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Could you take a look?

It looks good - and should be a workable API for
application writers to use.

> @@ -84,6 +84,11 @@ PR_MCE_KILL
>                 PR_MCE_KILL_EARLY: Early kill
>                 PR_MCE_KILL_LATE:  Late kill
>                 PR_MCE_KILL_DEFAULT: Use system global default
> +       Note that if you want to have a dedicated thread which handles
> +       the SIGBUS(BUS_MCEERR_AO) on behalf of the process, you should
> +       call prctl() on the thread. Otherwise, the SIGBUS is sent to
> +       the main thread.

Perhaps be more explicit here that the user should call
prctl(PR_MCE_KILL_EARLY) on the designated thread
to get this behavior?  The user could also mark more than
one thread in this way - in which case the kernel will pick
the first one it sees (is that oldest, or newest?) that is marked.
Not sure if this would ever be useful unless you want to pass
responsibility around in an application that is dynamically
creating and removing threads.

> +               if (t->flags & PF_MCE_PROCESS && t->flags & PF_MCE_EARLY)

This is correct - but made me twitch to add extra brackets:

                  if ((t->flags & PF_MCE_PROCESS) && (t->flags & PF_MCE_EARLY))

or
                  if ((t->flags & (PF_MCE_PROCESS|PF_MCE_EARLY)) ==
PF_MCE_PROCESS|PF_MCE_EARLY)

[oops, no ... that's too long and no clearer]

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
