Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A24EB6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:09:44 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id n3so53782562wmn.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:09:44 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id a194si9144110wma.76.2016.04.06.02.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 02:09:43 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so64226429wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:09:43 -0700 (PDT)
Date: Wed, 6 Apr 2016 11:09:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, hugetlb_cgroup: round limit_in_bytes down to
 hugepage size
Message-ID: <20160406090941.GC24272@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1604051824320.32718@chino.kir.corp.google.com>
 <5704BA37.2080508@kyup.com>
 <5704BBBF.8040302@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5704BBBF.8040302@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 06-04-16 10:33:19, Nikolay Borisov wrote:
> 
> 
> On 04/06/2016 10:26 AM, Nikolay Borisov wrote:
> > 
> > 
> > On 04/06/2016 04:25 AM, David Rientjes wrote:
> >> The page_counter rounds limits down to page size values.  This makes
> >> sense, except in the case of hugetlb_cgroup where it's not possible to
> >> charge partial hugepages.
> >>
> >> Round the hugetlb_cgroup limit down to hugepage size.
> >>
> >> Signed-off-by: David Rientjes <rientjes@google.com>
> >> ---
> >>  mm/hugetlb_cgroup.c | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> >> --- a/mm/hugetlb_cgroup.c
> >> +++ b/mm/hugetlb_cgroup.c
> >> @@ -288,6 +288,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
> >>  
> >>  	switch (MEMFILE_ATTR(of_cft(of)->private)) {
> >>  	case RES_LIMIT:
> >> +		nr_pages &= ~((1 << huge_page_order(&hstates[idx])) - 1);
> > 
> > Why not:
> > 
> > nr_pages = round_down(nr_pages, huge_page_order(&hstates[idx]));
> 
> Oops, that should be:
> 
> round_down(nr_pages, 1 << huge_page_order(&hstates[idx]));

round_down is a bit nicer.

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
