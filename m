Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE246B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 16:17:15 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id l18so12857926wgh.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 13:17:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si353569wjf.70.2015.02.12.13.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 13:17:12 -0800 (PST)
Message-ID: <54DD16BD.4000201@redhat.com>
Date: Thu, 12 Feb 2015 16:10:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 04/24] rmap: add argument to charge compound page
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:

> +++ b/include/linux/rmap.h @@ -168,16 +168,24 @@ static inline void
> anon_vma_merge(struct vm_area_struct *vma,
> 
> struct anon_vma *page_get_anon_vma(struct page *page);
> 
> +/* flags for do_page_add_anon_rmap() */ +enum { +	RMAP_EXCLUSIVE =
> 1, +	RMAP_COMPOUND = 2, +};

Always a good idea to name things. However, "exclusive" is
not that clear to me. Given that the argument is supposed
to indicate whether we map a single or a compound page,
maybe the names in the enum could just be SINGLE and COMPOUND?

Naming the enum should make it clear enough what it does:

 enum rmap_page {
      SINGLE = 0,
      COMPOUND
 }

> +++ b/kernel/events/uprobes.c @@ -183,7 +183,7 @@ static int
> __replace_page(struct vm_area_struct *vma, unsigned long addr, goto
> unlock;
> 
> get_page(kpage); -	page_add_new_anon_rmap(kpage, vma, addr); +
> page_add_new_anon_rmap(kpage, vma, addr, false); 
> mem_cgroup_commit_charge(kpage, memcg, false); 
> lru_cache_add_active_or_unevictable(kpage, vma);

Would it make sense to use the name in the argument to that function,
too?

I often find it a lot easier to see what things do if they use symbolic
names, rather than by trying to remember what each boolean argument to
a function does.

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU3Ra9AAoJEM553pKExN6D4UcH/10GlcYBB813KE7dR2r23MDx
WlrcC096IRoEjD/aaBHikLcKSu5mZDzf3ic1ZHzMPzz7oMdsFkmnY/k2zMdcqc83
7scvd7VB3acI4STKWcbkaCsIHIpHPFmfdcLv9Rabi0P2MBb8SALQCwxDUJqvXojC
JdJivfuagDoSUEamHwZrCvFylC7J7M4zPLD5aUpc93E4I4lhG9VHD7FmnYP3rxb8
kX4DOZFZ7aTN3K9IweCZPN2HWZe2qcSKc/AmIfHfokdjJLTuqbMv5UGSwLHmmeDf
DO4Uru/BMgPg2Ds7uKZosf7icAnOzT08b/Woh34JT83ua9XpFMam+hx6g+lA78E=
=Kzss
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
