Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE9606B0260
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:08:38 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so20008975lfa.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:08:38 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id el5si4255427wjd.31.2016.06.16.02.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:08:37 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id 187so7824266wmz.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:08:37 -0700 (PDT)
Date: Thu, 16 Jun 2016 12:08:20 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC PATCH 2/3] mm, thp: convert from optimistic to conservative
Message-ID: <20160616090819.GA18977@gezgin>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
 <1465672561-29608-3-git-send-email-ebru.akagunduz@gmail.com>
 <20160615064053.GH17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615064053.GH17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, mhocko@suse.cz, linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Wed, Jun 15, 2016 at 03:40:53PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Sat, Jun 11, 2016 at 10:16:00PM +0300, Ebru Akagunduz wrote:
> > Currently, khugepaged collapses pages saying only
> > a referenced page enough to create a THP.
> > 
> > This patch changes the design from optimistic to conservative.
> > It gives a default threshold which is half of HPAGE_PMD_NR
> > for referenced pages, also introduces a new sysfs knob.
> 
> Strictly speaking, It's not what I suggested.
> 
> I didn't mean that let's change threshold for deciding whether we should
> collapse or not(although just *a* reference page seems be too
> optimistic) and export the knob to the user. In fact, I cannot judge
> whether it's worth or not because I never have an experience with THP
> workload in practice although I believe it does make sense.
> 
> What I suggested is that a swapin operation would be much heavier than
> a THP cost to collapse populated anon page so it should be more
> conservative than THP collasping decision, at least. Given that thought,
> decision point for collasping a THP is *a* reference page now so *half*
> reference of populated pages for reading swapped-out page is more
> conservative.
>
Then passing referenced parameter from khugepaged_scan_pmd to
collapse_huge_page_swapin seems okay. A referenced is enough to
create THP, if needs to swapin, we check the value that should
be higher than 256 and so that, we don't need a new sysfs knob.
 
> > 
> > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > ---

> > +static unsigned int khugepaged_min_ptes_young __read_mostly;
> 
> We should set it to 1 to preserve old behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
