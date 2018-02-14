Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7909F6B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:12:10 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id d137so11101496itc.0
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:12:10 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o205si6699545itd.161.2018.02.14.10.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:12:09 -0800 (PST)
Subject: Re: [RFC PATCH V2 00/22] Intel(R) Resource Director Technology Cache
 Pseudo-Locking enabling
References: <cover.1518443616.git.reinette.chatre@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e0d59d83-14a1-6059-6f0b-da47b3b7de31@oracle.com>
Date: Wed, 14 Feb 2018 10:12:03 -0800
MIME-Version: 1.0
In-Reply-To: <cover.1518443616.git.reinette.chatre@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reinette Chatre <reinette.chatre@intel.com>, tglx@linutronix.de, fenghua.yu@intel.com, tony.luck@intel.com
Cc: gavin.hindman@intel.com, vikas.shivappa@linux.intel.com, dave.hansen@intel.com, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On 02/13/2018 07:46 AM, Reinette Chatre wrote:
> Adding MM maintainers to v2 to share the new MM change (patch 21/22) that
> enables large contiguous regions that was created to support large Cache
> Pseudo-Locked regions (patch 22/22). This week MM team received another
> proposal to support large contiguous allocations ("[RFC PATCH 0/3]
> Interface for higher order contiguous allocations" at
> http://lkml.kernel.org/r/20180212222056.9735-1-mike.kravetz@oracle.com).
> I have not yet tested with this new proposal but it does seem appropriate
> and I should be able to rework patch 22 from this series on top of that if
> it is accepted instead of what I have in patch 21 of this series.
> 

Well, I certainly would prefer the adoption and use of a more general
purpose interface rather than exposing alloc_gigantic_page().

Both the interface I suggested and alloc_gigantic_page end up calling
alloc_contig_range().  I have not looked at your entire patch series, but
do be aware that in its present form alloc_contig_range will run into
issues if called by two threads simultaneously for the same page range.
Calling alloc_gigantic_page without some form of synchronization will
expose this issue.  Currently this is handled by hugetlb_lock for all
users of alloc_gigantic_page.  If you simply expose alloc_gigantic_page
without any type of synchronization, you may run into issues.  The first
patch in my RFC "mm: make start_isolate_page_range() fail if already
isolated" should handle this situation IF we decide to expose
alloc_gigantic_page (which I do not suggest).

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
