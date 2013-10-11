Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1608D6B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 10:13:02 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so4468969pab.4
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 07:13:01 -0700 (PDT)
Received: from [92.224.46.200] ([92.224.46.200]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0MBIAz-1Veq3o0n1Z-00ABAe for <linux-mm@kvack.org>;
 Fri, 11 Oct 2013 16:12:58 +0200
Message-ID: <52580767.6090604@gmx.de>
Date: Fri, 11 Oct 2013 16:12:55 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
References: <CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com> <5251CF94.5040101@gmx.de> <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com> <525591AD.4060401@gmx.de> <5255A3E6.6020100@nod.at> <20131009214733.GB25608@quack.suse.cz> <5255D9A6.3010208@nod.at> <5256DA9A.5060904@gmx.de> <20131011011649.GA11191@localhost> <5257B9EB.7080503@gmx.de> <20131011085701.GA27382@localhost>
In-Reply-To: <20131011085701.GA27382@localhost>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Richard Weinberger <richard@nod.at>, Jan Kara <jack@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>

On 10/11/2013 10:57 AM, Fengguang Wu wrote:
> On Fri, Oct 11, 2013 at 10:42:19AM +0200, Toralf FA?rster wrote:
>> yeah, now the picture becomes more clear
>> ...
>> net.core.warnings = 0                                                                         [ ok ]
>> ick: pause : -717
>>                  ick : min_pause : -177
>>                                    ick : max_pause : -717
>>                                                      ick: pages_dirtied : 14
>>                                                                             ick: task_ratelimit: 0
> 
> Great and thanks! So it's the max pause calculation went wrong.
> Would help you try the below patch?
> 
Definitely.
I'm running now the test case since 6 hours w/o any issues.
before that usually after 15 - 30 min the bug occurred.

>>From 5420b9bbe42dd0a366d7615e9f3d3724cee725c4 Mon Sep 17 00:00:00 2001
> From: Fengguang Wu <fengguang.wu@intel.com>
> Date: Fri, 11 Oct 2013 16:53:26 +0800
> Subject: [PATCH] fix bdi max pause calculation
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3f0c895..241a746 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1104,11 +1104,11 @@ static unsigned long dirty_poll_interval(unsigned long dirty,
>  	return 1;
>  }
>  
> -static long bdi_max_pause(struct backing_dev_info *bdi,
> -			  unsigned long bdi_dirty)
> +static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
> +				   unsigned long bdi_dirty)
>  {
> -	long bw = bdi->avg_write_bandwidth;
> -	long t;
> +	unsigned long bw = bdi->avg_write_bandwidth;
> +	unsigned long t;
>  
>  	/*
>  	 * Limit pause time for small memory systems. If sleeping for too long
> @@ -1120,7 +1120,7 @@ static long bdi_max_pause(struct backing_dev_info *bdi,
>  	t = bdi_dirty / (1 + bw / roundup_pow_of_two(1 + HZ / 8));
>  	t++;
>  
> -	return min_t(long, t, MAX_PAUSE);
> +	return min_t(unsigned long, t, MAX_PAUSE);
>  }
>  
>  static long bdi_min_pause(struct backing_dev_info *bdi,
> 


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
