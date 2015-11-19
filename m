Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7946D6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:04:58 -0500 (EST)
Received: by wmww144 with SMTP id w144so109085885wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 02:04:57 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id v65si23856925wmg.77.2015.11.19.02.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 02:04:57 -0800 (PST)
Received: by wmdw130 with SMTP id w130so233270607wmd.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 02:04:57 -0800 (PST)
Date: Thu, 19 Nov 2015 11:04:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 3/6] mm, proc: reduce cost of /proc/pid/smaps for
 shmem mappings
Message-ID: <20151119100455.GB8494@dhcp22.suse.cz>
References: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
 <1447838976-17607-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447838976-17607-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Wed 18-11-15 10:29:33, Vlastimil Babka wrote:
> The previous patch has improved swap accounting for shmem mapping, which
> however made /proc/pid/smaps more expensive for shmem mappings, as we consult
> the radix tree for each pte_none entry, so the overal complexity is
> O(n*log(n)).
> 
> We can reduce this significantly for mappings that cannot contain COWed pages,
> because then we can either use the statistics tha shmem object itself tracks
> (if the mapping contains the whole object, or the swap usage of the whole
> object is zero), or use the radix tree iterator, which is much more effective
> than repeated find_get_entry() calls.
> 
> This patch therefore introduces a function shmem_swap_usage(vma) and makes
> /proc/pid/smaps use it when possible. Only for writable private mappings of
> shmem objects (i.e. tmpfs files) with the shmem object itself (partially)
> swapped outwe have to resort to the find_get_entry() approach. Hopefully
> such mappings are relatively uncommon.
> 
> To demonstrate the diference, I have measured this on a process that creates
> a 2GB mapping and dirties single pages with a stride of 2MB, and time how long
> does it take to cat /proc/pid/smaps of this process 100 times.
> 
> Private writable mapping of a /dev/shm/file (the most complex case):
> 
> real    0m3.831s
> user    0m0.180s
> sys     0m3.212s
> 
> Shared mapping of an almost full mapping of a partially swapped /dev/shm/file
> (which needs to employ the radix tree iterator).
> 
> real    0m1.351s
> user    0m0.096s
> sys     0m0.768s
> 
> Same, but with /dev/shm/file not swapped (so no radix tree walk needed)
> 
> real    0m0.935s
> user    0m0.128s
> sys     0m0.344s
> 
> Private anonymous mapping:
> 
> real    0m0.949s
> user    0m0.116s
> sys     0m0.348s
> 
> The cost is now much closer to the private anonymous mapping case, unless the
> shmem mapping is private and writable.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Looks good to me
Acked-by: Michal Hocko <mhocko@suse.com>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
