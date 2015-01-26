Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id E9E766B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 17:38:28 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so11752115wes.10
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:38:28 -0800 (PST)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id n9si6374509wiy.82.2015.01.26.14.38.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 14:38:26 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id x12so11636446wgg.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:38:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150126120043.GB25833@node.dhcp.inet.fi>
References: <20150120001643.7D15AA8@black.fi.intel.com>
	<20150120114555.GA11502@n2100.arm.linux.org.uk>
	<20150120140546.DDCB8D4@black.fi.intel.com>
	<20150123172736.GA15392@kahuna>
	<CANMBJr7w2jZBwRDEsVNvL3XrDZ2ttwFz7qBf4zySAMMmcgAxiw@mail.gmail.com>
	<20150123183706.GA15791@kahuna>
	<20150123202229.GA9038@node.dhcp.inet.fi>
	<CANMBJr4YOcHj2G7w-gwfoZjQQd=h0Mj59QNBo3ei_=ejYRcdnw@mail.gmail.com>
	<20150124011311.GB9038@node.dhcp.inet.fi>
	<20150124043746.GA22262@kahuna>
	<20150126120043.GB25833@node.dhcp.inet.fi>
Date: Mon, 26 Jan 2015 14:38:26 -0800
Message-ID: <CANMBJr74kCw23SQUPo+6dgpN=MJEmmwPiS5A2bax1+dou5-GDA@mail.gmail.com>
Subject: Re: [next-20150119]regression (mm)?
From: Tyler Baker <tyler.baker@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Nishanth Menon <nm@ti.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, James Hogan <james.hogan@imgtec.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>

On 26 January 2015 at 04:00, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Fri, Jan 23, 2015 at 10:37:46PM -0600, Nishanth Menon wrote:
>> On 03:13-20150124, Kirill A. Shutemov wrote:
>> > > >> On 09:39-20150123, Tyler Baker wrote:
>> [...]
>> > > >> > I just reviewed the boot logs for next-20150123 and there still seems
>> > > >> > to be a related issue. I've been boot testing
>> > > >> > multi_v7_defconfig+CONFIG_ARM_LPAE=y kernel configurations which still
>> > > >> > seem broken.
>> [...]
>> > Okay, proof of concept patch is below. It's going to break every other
>> > architecture with FIRST_USER_ADDRESS != 0, but I think it's cleaner way to
>> > go.
>>
>> Testing on my end:
>>
>> just ran through this set (+ logs similar to Tyler's from my side):
>>
>> next-20150123 (multi_v7_defconfig == !LPAE)
>>  1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2219449
>>  2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219450
>>  3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219451
>>  4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2219452
>> TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0
>>
>> next-20150123-LPAE-Logging enabled[1] (multi_v7_defconfig +LPAE)
>>  1:    BeagleBoard-X15(am57xx-evm): BOOT: FAIL: http://paste.ubuntu.org.cn/2220938
>>  2:                     dra72x-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220943
>>  3:                     dra7xx-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220947
>>  4:                      omap5-evm: BOOT: FAIL: http://paste.ubuntu.org.cn/2220955
>> TOTAL = 4 boards, Booted Boards = 0, No Boot boards = 4
>>
>> next-20150123-LPAE-new-patch [2] (multi_v7_defconfig + LPAE)
>>  1:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221047
>>  2:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221065
>>  3:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221069
>>  4:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221070
>> TOTAL = 4 boards, Booted Boards = 4, No Boot boards = 0
>>
>> next-20150123-new-patch[2] (multi_v7_defconfig == !LPAE)
>>  1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221277
>>  2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221278
>>  3:                      am437x-sk: BOOT: FAIL: http://paste.ubuntu.org.cn/2221279 (unrelated)
>>  4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221280
>>  5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221281
>>  6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221282
>>  7:                 BeagleBoard-XM: BOOT: FAIL: http://paste.ubuntu.org.cn/2221283 (unrelated)
>>  8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221284
>>  9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221285
>> 10:                     beaglebone: BOOT: FAIL: http://paste.ubuntu.org.cn/2221286 (unrelated)
>> 11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221287
>> 12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221288
>> 13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221289
>> 14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221290
>> 15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221291
>> 16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221292
>> TOTAL = 16 boards, Booted Boards = 13, No Boot boards = 3
>>
>> next-20150123-new-patch[2] (omap2plus_defconfig)
>>  1:                     am335x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221653
>>  2:                      am335x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221654
>>  3:                      am437x-sk: BOOT: PASS: http://paste.ubuntu.org.cn/2221656
>>  4:                    am43xx-epos: BOOT: PASS: http://paste.ubuntu.org.cn/2221659
>>  5:                   am43xx-gpevm: BOOT: PASS: http://paste.ubuntu.org.cn/2221660
>>  6:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: http://paste.ubuntu.org.cn/2221661
>>  7:                 BeagleBoard-XM: BOOT: PASS: http://paste.ubuntu.org.cn/2221670
>>  8:            beagleboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221676
>>  9:               beaglebone-black: BOOT: PASS: http://paste.ubuntu.org.cn/2221683
>> 10:                     beaglebone: BOOT: PASS: http://paste.ubuntu.org.cn/2221690
>> 11:                     dra72x-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221692
>> 12:                     dra7xx-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221695
>> 13:                      omap5-evm: BOOT: PASS: http://paste.ubuntu.org.cn/2221700
>> 14:                  pandaboard-es: BOOT: PASS: http://paste.ubuntu.org.cn/2221704
>> 15:             pandaboard-vanilla: BOOT: PASS: http://paste.ubuntu.org.cn/2221707
>> 16:                        sdp4430: BOOT: PASS: http://paste.ubuntu.org.cn/2221713
>> TOTAL = 16 boards, Booted Boards = 16, No Boot boards = 0
>
> Okay thanks. Here's proper patch.
>
> From 8f9845ab8d972164b700ff3e3ce53484cceb942b Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 26 Jan 2015 12:07:54 +0200
> Subject: [PATCH 1/2] mm: fix false-positive warning on exit due mm_nr_pmds(mm)
>
> The problem is that we check nr_ptes/nr_pmds in exit_mmap() which happens
> *before* pgd_free(). And if an arch does pte/pmd allocation in pgd_alloc()
> and frees them in pgd_free() we see offset in counters by the time of the
> checks.
>
> We tried to workaround this by offsetting expected counter value
> according to FIRST_USER_ADDRESS for both nr_pte and nr_pmd in
> exit_mmap(). But it doesn't work in some cases:
>
> 1. ARM with LPAE enabled also has non-zero USER_PGTABLES_CEILING, but
>    upper addresses occupied with huge pmd entries, so the trick with
>    offsetting expected counter value will get really ugly: we will have
>    to apply it nr_pmds, but not nr_ptes.
>
> 2. Metag has non-zero FIRST_USER_ADDRESS, but doesn't do allocation
>    pte/pmd page tables allocation in pgd_alloc(), just setup a pgd entry
>    which is allocated at boot and shared accross all processes.
>
> The proposal is to move the check to check_mm() which happens *after*
> pgd_free() and do proper accounting during pgd_alloc() and pgd_free()
> which would bring counters to zero if nothing leaked.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I've tested this patch on top of linux-next [1] on a various array of
arm, arm64 and x86 hardware. I can confirm the issue with
CONFIG_ARM_LPAE=y has been resolved with no additional regressions
detected. The results can be found here [2].

Feel free to add:

Tested-by: Tyler Baker <tyler.baker@linaro.org>

> Reported-by: Tyler Baker <tyler.baker@linaro.org>
> Tested-by: Nishanth Menon <nm@ti.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: James Hogan <james.hogan@imgtec.com>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> ---
>  arch/arm/mm/pgd.c       | 4 ++++
>  arch/unicore32/mm/pgd.c | 3 +++
>  kernel/fork.c           | 8 ++++++++
>  mm/mmap.c               | 5 -----
>  4 files changed, 15 insertions(+), 5 deletions(-)
>
> diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
> index 249379535be2..a3681f11dd9f 100644
> --- a/arch/arm/mm/pgd.c
> +++ b/arch/arm/mm/pgd.c
> @@ -97,6 +97,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
>
>  no_pte:
>         pmd_free(mm, new_pmd);
> +       mm_dec_nr_pmds(mm);
>  no_pmd:
>         pud_free(mm, new_pud);
>  no_pud:
> @@ -130,9 +131,11 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd_base)
>         pte = pmd_pgtable(*pmd);
>         pmd_clear(pmd);
>         pte_free(mm, pte);
> +       atomic_long_dec(&mm->nr_ptes);
>  no_pmd:
>         pud_clear(pud);
>         pmd_free(mm, pmd);
> +       mm_dec_nr_pmds(mm);
>  no_pud:
>         pgd_clear(pgd);
>         pud_free(mm, pud);
> @@ -152,6 +155,7 @@ no_pgd:
>                 pmd = pmd_offset(pud, 0);
>                 pud_clear(pud);
>                 pmd_free(mm, pmd);
> +               mm_dec_nr_pmds(mm);
>                 pgd_clear(pgd);
>                 pud_free(mm, pud);
>         }
> diff --git a/arch/unicore32/mm/pgd.c b/arch/unicore32/mm/pgd.c
> index 08b8d4295e70..1bc00d0305d4 100644
> --- a/arch/unicore32/mm/pgd.c
> +++ b/arch/unicore32/mm/pgd.c
> @@ -69,6 +69,7 @@ pgd_t *get_pgd_slow(struct mm_struct *mm)
>
>  no_pte:
>         pmd_free(mm, new_pmd);
> +       mm_dec_nr_pmds(mm);
>  no_pmd:
>         free_pages((unsigned long)new_pgd, 0);
>  no_pgd:
> @@ -96,7 +97,9 @@ void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd)
>         pte = pmd_pgtable(*pmd);
>         pmd_clear(pmd);
>         pte_free(mm, pte);
> +       atomic_long_dec(&mm->nr_ptes);
>         pmd_free(mm, pmd);
> +       mm_dec_nr_pmds(mm)
>  free:
>         free_pages((unsigned long) pgd, 0);
>  }
> diff --git a/kernel/fork.c b/kernel/fork.c
> index c99098c52641..76d6f292274c 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -606,6 +606,14 @@ static void check_mm(struct mm_struct *mm)
>                         printk(KERN_ALERT "BUG: Bad rss-counter state "
>                                           "mm:%p idx:%d val:%ld\n", mm, i, x);
>         }
> +
> +       if (atomic_long_read(&mm->nr_ptes))
> +               pr_alert("BUG: non-zero nr_ptes on freeing mm: %ld",
> +                               atomic_long_read(&mm->nr_ptes));
> +       if (mm_nr_pmds(mm))
> +               pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld",
> +                               mm_nr_pmds(mm));
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>         VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
>  #endif
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6a7d36d133fb..c5f44682c0d1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2851,11 +2851,6 @@ void exit_mmap(struct mm_struct *mm)
>                 vma = remove_vma(vma);
>         }
>         vm_unacct_memory(nr_accounted);
> -
> -       WARN_ON(atomic_long_read(&mm->nr_ptes) >
> -                       round_up(FIRST_USER_ADDRESS, PMD_SIZE) >> PMD_SHIFT);
> -       WARN_ON(mm_nr_pmds(mm) >
> -                       round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);
>  }
>
>  /* Insert vm structure into process list sorted by address
> --
>  Kirill A. Shutemov

[1] https://git.linaro.org/people/tyler.baker/linux-next.git/shortlog/refs/heads/next-testing
[2] http://kernelci.org/boot/all/job/tbaker/kernel/v3.19-rc5-5174-g384ba8a33c70/

Thanks,

Tyler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
