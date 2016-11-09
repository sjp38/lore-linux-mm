Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5276B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 21:32:13 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n85so86596778pfi.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 18:32:13 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id qg4si32969619pac.339.2016.11.08.18.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 18:32:11 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y68so21693827pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 18:32:11 -0800 (PST)
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ee20300d-0367-5b2c-71f2-f86bce3d6b90@gmail.com>
Date: Wed, 9 Nov 2016 13:32:04 +1100
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 08/11/16 10:31, Naoya Horiguchi wrote:
> Hi everyone,
> 
> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> with feedbacks for ver.1.
> 
> General description (no change since ver.1)
> ===========================================
> 
> This patchset enhances page migration functionality to handle thp migration
> for various page migration's callers:
>  - mbind(2)
>  - move_pages(2)
>  - migrate_pages(2)
>  - cgroup/cpuset migration
>  - memory hotremove
>  - soft offline
> 
> The main benefit is that we can avoid unnecessary thp splits, which helps us
> avoid performance decrease when your applications handles NUMA optimization on
> their own.
> 
> The implementation is similar to that of normal page migration, the key point
> is that we modify a pmd to a pmd migration entry in swap-entry like format.
> 
> Changes / Notes
> ===============
> 
> - pmd_present() in x86 checks _PAGE_PRESENT, _PAGE_PROTNONE and _PAGE_PSE
>   bits together, which makes implementing thp migration a bit hard because
>   _PAGE_PSE bit is currently used by soft-dirty in swap-entry format.
>   I was advised to dropping _PAGE_PSE in pmd_present(), but I don't think
>   of the justification, so I keep it in this version. Instead, my approach
>   is to move _PAGE_SWP_SOFT_DIRTY to bit 6 (unused) and reserve bit 7 for
>   pmd non-present cases.

Thanks, IIRC

pmd_present = _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE

AutoNUMA balancing would change it to

pmd_present = _PAGE_PROTNONE | _PAGE_PSE

and PMD_SWP_SOFT_DIRTY would make it

pmd_present = _PAGE_PSE

What you seem to be suggesting in your comment is that

pmd_present should be _PAGE_PRESENT | _PAGE_PROTNONE

Isn't that good enough?

For THP migration I guess we use

_PAGE_PRESENT | _PAGE_PROTNONE | is_migration_entry(pmd)


> 
> - this patchset still covers only x86_64. Zi Yan posted a patch for ppc64
>   and I think it's favorably received so that's fine. But there's unsolved
>   minor suggestion by Aneesh, so I don't include it in this set, expecting
>   that it will be updated/reposted.
> 
> - pte-mapped thp and doubly-mapped thp were not supported in ver.1, but
>   this version should work for such kinds of thp.
> 
> - thp page cache is not tested yet, and it's at the head of my todo list
>   for future version.
> 
> Any comments or advices are welcomed.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
