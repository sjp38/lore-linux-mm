Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 524576B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:30:24 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id c200so50647723wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:30:24 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id a10si628836wmc.91.2016.02.25.15.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:30:23 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id b205so51882802wmb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:30:23 -0800 (PST)
Date: Fri, 26 Feb 2016 01:30:17 +0200
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
Message-ID: <20160225233017.GA14587@debian>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
 <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
 <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
 <1456439750.15821.97.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1456439750.15821.97.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, hughd@google.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

in Thu, Feb 25, 2016 at 05:35:50PM -0500, Rik van Riel wrote:
> On Wed, 2016-02-24 at 23:36 -0800, Hugh Dickins wrote:
> > 
> > Doesn't this imply that __collapse_huge_page_swapin() will initiate
> > all
> > the necessary swapins for a THP, then (given the
> > FAULT_FLAG_ALLOW_RETRY)
> > not wait for them to complete, so khugepaged will give up on that
> > extent
> > and move on to another; then after another full circuit of all the
> > mms
> > it needs to examine, it will arrive back at this extent and build a
> > THP
> > from the swapins it arranged last time.
> > 
> > Which may work well when a system transitions from busy+swappingout
> > to idle+swappingin, but isn't that rather a special case?  It feels
> > (meaning, I've not measured at all) as if the inbetween busyish case
> > will waste a lot of I/O and memory on swapins that have to be
> > discarded
> > again before khugepaged has made its sedate way back to slotting them
> > in.
> > 
> 
> There may be a fairly simple way to prevent
> that from becoming an issue.
> 
> When khugepaged wakes up, it can check the
> PGSWPOUT or even the PGSTEAL_* stats for
> the system, and skip swapin readahead if
> there was swapout activity (or any page
> reclaim activity?) since the time it last
> ran.
> 
> That way the swapin readahead will do
> its thing when transitioning from
> busy + swapout to idle + swapin, but not
> while the system is under permanent memory
> pressure.
> 
The idea make sense for me.
> Am I forgetting anything obvious?
> 
> Is this too aggressive?
> 
> Not aggressive enough?
> 
> Could PGPGOUT + PGSWPOUT be a useful
> in-between between just PGSWPOUT or
> PGSTEAL_*?
> 
> -- 
> All rights reversed


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
