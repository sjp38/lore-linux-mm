Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCA0280256
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 13:13:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so30349542wmf.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:13:53 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 20si11669477wmk.33.2016.09.21.10.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 10:13:51 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w84so9732409wmg.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:13:51 -0700 (PDT)
Date: Wed, 21 Sep 2016 19:13:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160921171348.GF24210@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160906135258.18335-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 06-09-16 15:52:56, Vlastimil Babka wrote:
[...]
> @@ -3204,6 +3199,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	if (compaction_retries <= max_retries)
>  		return true;
>  
> +	/*
> +	 * Make sure there is at least one attempt at the highest priority
> +	 * if we exhausted all retries at the lower priorities
> +	 */
> +check_priority:
> +	if (*compact_priority > MIN_COMPACT_PRIORITY) {
> +		(*compact_priority)--;
> +		return true;

Don't we want to reset compaction_retries here? Otherwise we can consume
all retries on the lower priorities.

Other than that it looks good to me. With that you can add
Acked-by: Michal Hocko <mhocko@suse.com>

> +	}
>  	return false;
>  }
>  #else
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
