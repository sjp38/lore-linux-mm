Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id A7D8F900017
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 08:13:22 -0400 (EDT)
Received: by wetk59 with SMTP id k59so20459970wet.3
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 05:13:22 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id wv4si12032361wjb.165.2015.03.15.05.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Mar 2015 05:13:20 -0700 (PDT)
Received: by wibg7 with SMTP id g7so15572203wib.1
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 05:13:20 -0700 (PDT)
Date: Sun, 15 Mar 2015 13:13:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm: Allow small allocations to fail
Message-ID: <20150315121317.GA30685@dhcp22.suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 15-03-15 14:43:37, Tetsuo Handa wrote:
[...]
> If you want to count only those retries which involved OOM killer, you need
> to do like
> 
> -			nr_retries++;
> +			if (gfp_mask & __GFP_FS)
> +				nr_retries++;
> 
> in this patch.

No, we shouldn't create another type of hidden NOFAIL allocation like
this. I understand that the wording of the changelog might be confusing,
though.

It says: "This implementation counts only those retries which involved
OOM killer because we do not want to be too eager to fail the request."

Would it be more clear if I changed that to?
"This implemetnation counts only those retries when the system is
considered OOM because all previous reclaim attempts have resulted
in no progress because we do not want to be too eager to fail the
request."

We definitely _want_ to fail GFP_NOFS allocations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
