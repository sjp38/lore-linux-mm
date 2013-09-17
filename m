Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1A5E96B0037
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:29:00 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-9-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379330740-5602-9-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCHv2 8/9] mm: implement split page table lock for PMD level
Content-Transfer-Encoding: 7bit
Message-Id: <20130917142851.5D332E0090@blue.fi.intel.com>
Date: Tue, 17 Sep 2013 17:28:51 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index b17a909..94206cb 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -24,6 +24,9 @@
>  struct address_space;
>  
>  #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
> +/* hugetlb hasn't converted to split locking yet */
> +#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
> +		CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK && !CONFIG_HUGETLB_PAGE)
>  

I forgot to commit local changes. It should be like this:

#define USE_SPLIT_PMD_PTLOCKS  (USE_SPLIT_PTE_PTLOCKS && \
               IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK) && \
               !IS_ENABLED(CONFIG_HUGETLB_PAGE))

Updated patch is below.
