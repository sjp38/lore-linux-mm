Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0166B06C1
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:42:18 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x11-v6so845800pgp.20
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:42:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y1-v6si7362461pli.131.2018.11.09.01.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 01:42:17 -0800 (PST)
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
Date: Fri, 9 Nov 2018 18:41:53 +0900
MIME-Version: 1.0
In-Reply-To: <20181109084353.GA5321@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Kyungtae Kim <kt0755@gmail.com>
Cc: akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 2018/11/09 17:43, Michal Hocko wrote:
> @@ -4364,6 +4353,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>  	struct alloc_context ac = { };
>  
> +	/*
> +	 * In the slowpath, we sanity check order to avoid ever trying to

Please keep the comment up to dated.
I don't like that comments in OOM code is outdated.

> +	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> +	 * be using allocators in order of preference for an area that is
> +	 * too large.
> +	 */
> +	if (order >= MAX_ORDER) {

Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?

> +		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> +		return NULL;
> +	}
> +
>  	gfp_mask &= gfp_allowed_mask;
>  	alloc_mask = gfp_mask;
>  	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
> 
