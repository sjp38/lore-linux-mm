Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC4806B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:16:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so10783520pfb.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 16:16:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p15si7266907pgg.270.2017.01.11.16.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 16:16:49 -0800 (PST)
Date: Wed, 11 Jan 2017 16:16:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2] mm, thp: add new defer+madvise defrag option
Message-Id: <20170111161647.306e511a2478132ac9a3969e@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
	<20170105101330.bvhuglbbeudubgqb@techsingularity.net>
	<fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
	<alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
	<558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
	<alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
	<baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
	<alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1701101614330.41805@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Jan 2017 16:15:27 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
> to do direct compaction and reclaim while all other thp allocations simply 
> trigger kswapd and kcompactd in the background and fail immediately.
> 
> The "defer" setting simply triggers background reclaim and compaction for 
> all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
> userspace where MADV_HUGEPAGE is being used to indicate the application is 
> willing to wait for work for thp memory to be available.
> 
> The "madvise" setting will do direct compaction and reclaim for these
> MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
> background for anybody else.
> 
> For reasonable usage, there needs to be a mesh between the two options.  
> This patch introduces a fifth mode, "defer+madvise", that will do direct 
> reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
> reclaim and compaction for everybody else so that hugepages may be 
> available in the near future.
> 
> A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
> regions as part of the "defer" mode, making it a very powerful setting and 
> avoids breaking userspace, was offered: 
> http://marc.info/?t=148236612700003.  This additional mode is a 
> compromise.
> 
> A second proposal to allow both "defer" and "madvise" to be selected at
> the same time was also offered: http://marc.info/?t=148357345300001.
> This is possible, but there was a concern that it might break existing
> userspaces the parse the output of the defrag mode, so the fifth option
> was introduced instead.
> 
> This patch also cleans up the helper function for storing to "enabled" 
> and "defrag" since the former supports three modes while the latter 
> supports five and triple_flag_store() was getting unnecessarily messy.
> 
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -110,6 +110,7 @@ MADV_HUGEPAGE region.
>  
>  echo always >/sys/kernel/mm/transparent_hugepage/defrag
>  echo defer >/sys/kernel/mm/transparent_hugepage/defrag
> +echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
>  echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
>  echo never >/sys/kernel/mm/transparent_hugepage/defrag
>  
> @@ -120,10 +121,15 @@ that benefit heavily from THP use and are willing to delay the VM start
>  to utilise them.
>  
>  "defer" means that an application will wake kswapd in the background
> -to reclaim pages and wake kcompact to compact memory so that THP is
> +to reclaim pages and wake kcompactd to compact memory so that THP is
>  available in the near future. It's the responsibility of khugepaged
>  to then install the THP pages later.
>  
> +"defer+madvise" will enter direct reclaim and compaction like "always", but
> +only for regions that have used madvise(MADV_HUGEPAGE); all other regions
> +will wake kswapd in the background to reclaim pages and wake kcompactd to
> +compact memory so that THP is available in the near future.
> +

It would be helpful if this text were to tell the reader why they may
choose to use this option: runtime effects, advantages, when-to-use,
when-not-to-use, etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
