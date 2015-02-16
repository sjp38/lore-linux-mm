Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1E87E6B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 10:39:46 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id b13so30154785wgh.0
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 07:39:45 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id hc4si22935746wjc.99.2015.02.16.07.39.43
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 07:39:44 -0800 (PST)
Date: Mon, 16 Feb 2015 17:20:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 04/24] rmap: add argument to charge compound page
Message-ID: <20150216152056.GC3270@node.dhcp.inet.fi>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com>
 <54DD16BD.4000201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54DD16BD.4000201@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 12, 2015 at 04:10:21PM -0500, Rik van Riel wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
> 
> > +++ b/include/linux/rmap.h @@ -168,16 +168,24 @@ static inline void
> > anon_vma_merge(struct vm_area_struct *vma,
> > 
> > struct anon_vma *page_get_anon_vma(struct page *page);
> > 
> > +/* flags for do_page_add_anon_rmap() */ +enum { +	RMAP_EXCLUSIVE =
> > 1, +	RMAP_COMPOUND = 2, +};
> 
> Always a good idea to name things. However, "exclusive" is
> not that clear to me. Given that the argument is supposed
> to indicate whether we map a single or a compound page,
> maybe the names in the enum could just be SINGLE and COMPOUND?
> 
> Naming the enum should make it clear enough what it does:
> 
>  enum rmap_page {
>       SINGLE = 0,
>       COMPOUND
>  }

Okay, this is probably confusing: do_page_add_anon_rmap() already had one
of arguments called 'exclusive'. It indicates if the page is exclusively
owned by the current process. And I needed also to indicate if we need to
handle the page as a compound or not. I've reused the same argument and
converted it to set bit-flags: bit 0 is exclusive, bit 1 - compound.

> 
> > +++ b/kernel/events/uprobes.c @@ -183,7 +183,7 @@ static int
> > __replace_page(struct vm_area_struct *vma, unsigned long addr, goto
> > unlock;
> > 
> > get_page(kpage); -	page_add_new_anon_rmap(kpage, vma, addr); +
> > page_add_new_anon_rmap(kpage, vma, addr, false); 
> > mem_cgroup_commit_charge(kpage, memcg, false); 
> > lru_cache_add_active_or_unevictable(kpage, vma);
> 
> Would it make sense to use the name in the argument to that function,
> too?
> 
> I often find it a lot easier to see what things do if they use symbolic
> names, rather than by trying to remember what each boolean argument to
> a function does.

I can convert these compound booleans to enums if you want. I'm personally
not sure that if will bring much value.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
