From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/5] mm: hugetlb: Introduce huge_pte_{page,present,young}
Date: Mon, 03 Mar 2014 13:07:07 -0500
Message-ID: <24881.2788785019$1393870093@news.gmane.org>
References: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
 <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
To: steve.capper@linaro.org
Cc: linux@arm.linux.org.uk, arnd@arndb.de, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, dsaxena@linaro.org, linux-arm-kernel@lists.infradead.org
List-Id: linux-mm.kvack.org

Hi Steve,

On Tue, Feb 18, 2014 at 03:27:11PM +0000, Steve Capper wrote:
> Introduce huge pte versions of pte_page, pte_present and pte_young.
> This allows ARM (without LPAE) to use alternative pte processing logic
> for huge ptes.
> 
> Where these functions are not defined by architectural code they
> fallback to the standard functions.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  include/linux/hugetlb.h | 12 ++++++++++++
>  mm/hugetlb.c            | 22 +++++++++++-----------
>  2 files changed, 23 insertions(+), 11 deletions(-)

How about replacing other archs' arch-dependent code with new functions?

  [~/dev]$ find arch/ -name "hugetlbpage.c" | xargs grep pte_page
  arch/s390/mm/hugetlbpage.c:             pmd_val(pmd) |= pte_page(pte)[1].index;
  arch/powerpc/mm/hugetlbpage.c:  page = pte_page(*ptep);
  arch/powerpc/mm/hugetlbpage.c:  head = pte_page(pte);
  arch/x86/mm/hugetlbpage.c:      page = &pte_page(*pte)[vpfn % (HPAGE_SIZE/PAGE_SIZE)];
  arch/ia64/mm/hugetlbpage.c:     page = pte_page(*ptep);
  arch/mips/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pmd);
  arch/tile/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pmd);
  arch/tile/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pud);
  [~/dev]$ find arch/ -name "hugetlbpage.c" | xargs grep pte_present
  arch/s390/mm/hugetlbpage.c:     if (pte_present(pte)) {
  arch/sparc/mm/hugetlbpage.c:    if (!pte_present(*ptep) && pte_present(entry))
  arch/sparc/mm/hugetlbpage.c:    if (pte_present(entry))
  arch/tile/mm/hugetlbpage.c:     if (!pte_present(*ptep) && huge_shift[level] != 0) {
  arch/tile/mm/hugetlbpage.c:             if (pte_present(pte) && pte_super(pte))
  arch/tile/mm/hugetlbpage.c:     if (!pte_present(*pte))

Thanks,
Naoya Horiguchi
