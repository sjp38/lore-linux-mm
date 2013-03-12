Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 44C2A6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 15:00:37 -0400 (EDT)
Message-ID: <513F7B55.60805@tilera.com>
Date: Tue, 12 Mar 2013 15:00:37 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm/hugetlb: add more arch-defined huge_pte_xxx functions
References: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com> <1363114106-30251-2-git-send-email-gerald.schaefer@de.ibm.com>
In-Reply-To: <1363114106-30251-2-git-send-email-gerald.schaefer@de.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 3/12/2013 2:48 PM, Gerald Schaefer wrote:
> Commit abf09bed3c "s390/mm: implement software dirty bits" introduced
> another difference in the pte layout vs. the pmd layout on s390,
> thoroughly breaking the s390 support for hugetlbfs. This requires
> replacing some more pte_xxx functions in mm/hugetlbfs.c with a
> huge_pte_xxx version.
>
> This patch introduces those huge_pte_xxx functions and their
> implementation on all architectures supporting hugetlbfs. This change
> will be a no-op for all architectures other than s390.
>
> [...]
>  
> +static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
> +{
> +	return mk_pte(page, pgprot);
> +}

Does it make sense to merge this new per-arch function with the existing per-arch arch_make_huge_pte() function?  Certainly in the tile case, we could set up our "super" bit in the initial mk_huge_pte() call, and then set "young" and "huge" after that in the platform-independent caller (make_huge_pte).  This would allow your change to eliminate some code as well as just introducing code :-)

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
