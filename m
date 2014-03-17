Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6976B0093
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 07:00:32 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so1937219wib.2
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 04:00:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ep15si9410512wjd.3.2014.03.17.04.00.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 04:00:30 -0700 (PDT)
Date: Mon, 17 Mar 2014 12:00:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: non-atomic rss_stat modifications
Message-ID: <20140317110029.GB4777@dhcp22.suse.cz>
References: <20140314021745.GA4894@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140314021745.GA4894@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org

On Thu 13-03-14 22:17:45, Dave Jones wrote:
> I've been trying to make sense of this message which I keep seeing..
> 
> BUG: Bad rss-counter state mm:ffff88018bb78000 idx:0 val:1
> 
> Looking at the FILEPAGES counter accesses...
> 
> $ rgrep FILEPAGES mm
> mm/filemap_xip.c:			dec_mm_counter(mm, MM_FILEPAGES);
> mm/oom_kill.c:		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> mm/fremap.c:			dec_mm_counter(mm, MM_FILEPAGES);
> mm/memory.c:					rss[MM_FILEPAGES]++;
> mm/memory.c:			rss[MM_FILEPAGES]++;
> mm/memory.c:				rss[MM_FILEPAGES]--;
> mm/memory.c:					rss[MM_FILEPAGES]--;
> mm/memory.c:	inc_mm_counter_fast(mm, MM_FILEPAGES);
> mm/memory.c:				dec_mm_counter_fast(mm, MM_FILEPAGES);
> mm/memory.c:			inc_mm_counter_fast(mm, MM_FILEPAGES);
> mm/rmap.c:				dec_mm_counter(mm, MM_FILEPAGES);
> mm/rmap.c:		dec_mm_counter(mm, MM_FILEPAGES);
> mm/rmap.c:		dec_mm_counter(mm, MM_FILEPAGES);
> 
> 
> How come we sometimes use the atomic accessors, but in copy_one_pte() and
> zap_pte_range() we don't ?  Is that safe ?

Those two use a local counter which is then added to the global one. See
copy_pte_range (resp. zap_pte_range) and add_mm_rss_vec they use.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
