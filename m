Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 87C2A6B006C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 06:01:57 -0400 (EDT)
Received: by lajy8 with SMTP id y8so8685959laj.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 03:01:57 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id ka5si8902773lbc.119.2015.03.31.03.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 03:01:55 -0700 (PDT)
Received: by lbbug6 with SMTP id ug6so8496993lbb.3
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 03:01:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1503281705040.13543@eggly.anvils>
References: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com>
 <20150224001228.GA11456@amt.cnet> <CABYiri_U7oB==4-cxegjVQJ_dX62d0tX=D0cUAPTpV_xjCukEw@mail.gmail.com>
 <alpine.LSU.2.11.1503281705040.13543@eggly.anvils>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Tue, 31 Mar 2015 13:01:34 +0300
Message-ID: <CABYiri9W5qM3PRyNua3pNO+eP=nz--TbYzTQ0Z8WseKTygz8HA@mail.gmail.com>
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, Luis Henriques <luis.henriques@canonical.com>, Marcelo Tosatti <mtosatti@redhat.com>, stable@vger.kernel.org, linux-mm@kvack.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, wanpeng.li@linux.intel.com, jipan yang <jipan.yang@gmail.com>

On Sun, Mar 29, 2015 at 3:25 AM, Hugh Dickins <hughd@google.com> wrote:
> On Sat, 28 Mar 2015, Andrey Korolyov wrote:
>> On Tue, Feb 24, 2015 at 3:12 AM, Marcelo Tosatti <mtosatti@redhat.com> wrote:
>> > On Wed, Feb 04, 2015 at 08:34:04PM +0400, Andrey Korolyov wrote:
>> >> >Hi,
>> >> >
>> >> >I've seen the problem quite a few times.  Before spending more time on
>> >> >it, I'd like to have a quick check here to see if anyone ever saw the
>> >> >same problem?  Hope it is a relevant question with this mail list.
>> >> >
>> >> >
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.078623] BUG: unable to handle
>> >> >kernel NULL pointer dereference at 0000000000000008
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.078916] IP: [<ffffffff8118d0fa>]
>> >> >copy_huge_page+0x8a/0x2a0
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.079128] PGD 0
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.079198] Oops: 0000 [#1] SMP
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.079319] Modules linked in:
>> >> >ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
>> >> >iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>> >> >xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle xt_tcpudp
>> >> >iptable_filter ip_tables x_tables kvm_intel kvm bridge stp llc ast ttm
>> >> >drm_kms_helper drm sysimgblt sysfillrect syscopyarea lp mei_me ioatdma
>> >> >ext2 parport mei shpchp dcdbas joydev mac_hid lpc_ich acpi_pad wmi
>> >> >hid_generic usbhid hid ixgbe igb dca i2c_algo_bit ahci ptp libahci
>> >> >mdio pps_core
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.081090] CPU: 19 PID: 3494 Comm:
>> >> >qemu-system-x86 Not tainted 3.11.0-15-generic #25~precise1-Ubuntu
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.081424] Hardware name: Dell Inc.
>> >> >PowerEdge C6220 II/09N44V, BIOS 2.0.3 07/03/2013
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.081705] task: ffff881026750000
>> >> >ti: ffff881026056000 task.ti: ffff881026056000
>> >> >Jul  2 11:08:21 arno-3 kernel: [ 2165.081973] RIP:
>> >> >0010:[<ffffffff8118d0fa>]  [<ffffffff8118d0fa>]
>> >> >copy_huge_page+0x8a/0x2a0
>> >>
>> >>
>> >> Hello,
>> >>
>> >> sorry for possible top-posting, the same issue appears on at least
>> >> 3.10 LTS series. The original thread is at
>> >> http://marc.info/?l=kvm&m=14043742300901.
>> >
>> > Andrey,
>> >
>> > I am unable to access the URL above?
>> >
>> >> The necessary components for failure to reappear are a single running
>> >> kvm guest and mounted large thp: hugepagesz=1G (seemingly the same as
>> >> in initial report). With default 2M pages everything is working well,
>> >> the same for 3.18 with 1G THP. Are there any obvious clues for the
>> >> issue?
>> >>
>> >> Thanks!
>> >
>> >
>>
>> Hello,
>>
>> Marcelo, sorry, I`ve missed your reply in time. The working link, for
>> example is http://www.spinics.net/lists/linux-mm/msg75658.html. The
>> reproducer is a very simple, you need 1G THP and mounted hugetlbfs.
>> What is interesting, if guest is backed by THP like '-object
>> memory-backend-file,id=mem,size=1G,mem-path=/hugepages,share=on' the
>> failure is less likely to occur.
>
> I think you're mistaken when you write of "1G THP": although hugetlbfs
> can support 1G hugepages, we don't support that size with Transparent
> Huge Pages.
>
> But you are very appositely mistaken: copy_huge_page() used to make
> the same mistake, and Dave Hansen fixed it back in v3.13, but the fix
> never went to the stable trees.
>
> Your report was on an Ubuntu "3.11.0-15" kernel: I think Ubuntu have
> discontinued their 3.11-stable kernel series, but 3.10-longterm and
> 3.12-longterm would benefit from including this fix.  I haven't tried
> patching and  building and testing it there, but it looks reasonable.
>
> Hugh
>
> commit 30b0a105d9f7141e4cbf72ae5511832457d89788
> Author: Dave Hansen <dave.hansen@linux.intel.com>
> Date:   Thu Nov 21 14:31:58 2013 -0800
>
>     mm: thp: give transparent hugepage code a separate copy_page
>
>     Right now, the migration code in migrate_page_copy() uses copy_huge_page()
>     for hugetlbfs and thp pages:
>
>            if (PageHuge(page) || PageTransHuge(page))
>                     copy_huge_page(newpage, page);
>
>     So, yay for code reuse.  But:
>
>       void copy_huge_page(struct page *dst, struct page *src)
>       {
>             struct hstate *h = page_hstate(src);
>
>     and a non-hugetlbfs page has no page_hstate().  This works 99% of the
>     time because page_hstate() determines the hstate from the page order
>     alone.  Since the page order of a THP page matches the default hugetlbfs
>     page order, it works.
>
>     But, if you change the default huge page size on the boot command-line
>     (say default_hugepagesz=1G), then we might not even *have* a 2MB hstate
>     so page_hstate() returns null and copy_huge_page() oopses pretty fast
>     since copy_huge_page() dereferences the hstate:
>
>       void copy_huge_page(struct page *dst, struct page *src)
>       {
>             struct hstate *h = page_hstate(src);
>             if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
>       ...
>
>     Mel noticed that the migration code is really the only user of these
>     functions.  This moves all the copy code over to migrate.c and makes
>     copy_huge_page() work for THP by checking for it explicitly.
>
>     I believe the bug was introduced in commit b32967ff101a ("mm: numa: Add
>     THP migration for the NUMA working set scanning fault case")
>
>     [akpm@linux-foundation.org: fix coding-style and comment text, per Naoya Horiguchi]
>     Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>     Acked-by: Mel Gorman <mgorman@suse.de>
>     Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>     Cc: Hillf Danton <dhillf@gmail.com>
>     Cc: Andrea Arcangeli <aarcange@redhat.com>
>     Tested-by: Dave Jiang <dave.jiang@intel.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index acd2010328f3..85e0c58bdfdf 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -69,7 +69,6 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
>  bool is_hugepage_active(struct page *page);
> -void copy_huge_page(struct page *dst, struct page *src);
>
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
> @@ -140,9 +139,6 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  #define isolate_huge_page(p, l) false
>  #define putback_active_hugepage(p)     do {} while (0)
>  #define is_hugepage_active(x)  false
> -static inline void copy_huge_page(struct page *dst, struct page *src)
> -{
> -}
>
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>                 unsigned long address, unsigned long end, pgprot_t newprot)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7d57af21f49e..2130365d387d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -476,40 +476,6 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
>         return 0;
>  }
>
> -static void copy_gigantic_page(struct page *dst, struct page *src)
> -{
> -       int i;
> -       struct hstate *h = page_hstate(src);
> -       struct page *dst_base = dst;
> -       struct page *src_base = src;
> -
> -       for (i = 0; i < pages_per_huge_page(h); ) {
> -               cond_resched();
> -               copy_highpage(dst, src);
> -
> -               i++;
> -               dst = mem_map_next(dst, dst_base, i);
> -               src = mem_map_next(src, src_base, i);
> -       }
> -}
> -
> -void copy_huge_page(struct page *dst, struct page *src)
> -{
> -       int i;
> -       struct hstate *h = page_hstate(src);
> -
> -       if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> -               copy_gigantic_page(dst, src);
> -               return;
> -       }
> -
> -       might_sleep();
> -       for (i = 0; i < pages_per_huge_page(h); i++) {
> -               cond_resched();
> -               copy_highpage(dst + i, src + i);
> -       }
> -}
> -
>  static void enqueue_huge_page(struct hstate *h, struct page *page)
>  {
>         int nid = page_to_nid(page);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 316e720a2023..bb940045fe85 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -442,6 +442,54 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  }
>
>  /*
> + * Gigantic pages are so large that we do not guarantee that page++ pointer
> + * arithmetic will work across the entire page.  We need something more
> + * specialized.
> + */
> +static void __copy_gigantic_page(struct page *dst, struct page *src,
> +                               int nr_pages)
> +{
> +       int i;
> +       struct page *dst_base = dst;
> +       struct page *src_base = src;
> +
> +       for (i = 0; i < nr_pages; ) {
> +               cond_resched();
> +               copy_highpage(dst, src);
> +
> +               i++;
> +               dst = mem_map_next(dst, dst_base, i);
> +               src = mem_map_next(src, src_base, i);
> +       }
> +}
> +
> +static void copy_huge_page(struct page *dst, struct page *src)
> +{
> +       int i;
> +       int nr_pages;
> +
> +       if (PageHuge(src)) {
> +               /* hugetlbfs page */
> +               struct hstate *h = page_hstate(src);
> +               nr_pages = pages_per_huge_page(h);
> +
> +               if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
> +                       __copy_gigantic_page(dst, src, nr_pages);
> +                       return;
> +               }
> +       } else {
> +               /* thp page */
> +               BUG_ON(!PageTransHuge(src));
> +               nr_pages = hpage_nr_pages(src);
> +       }
> +
> +       for (i = 0; i < nr_pages; i++) {
> +               cond_resched();
> +               copy_highpage(dst + i, src + i);
> +       }
> +}
> +
> +/*
>   * Copy the page to its new location
>   */
>  void migrate_page_copy(struct page *newpage, struct page *page)

Thanks, the issue is fixed on 3.10 with trivial patch modification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
