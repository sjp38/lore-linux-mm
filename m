Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8B766B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 23:48:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s17-v6so3869500pgq.23
        for <linux-mm@kvack.org>; Sun, 20 May 2018 20:48:25 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id g1-v6si13044739pld.11.2018.05.20.20.48.24
        for <linux-mm@kvack.org>;
        Sun, 20 May 2018 20:48:24 -0700 (PDT)
Subject: Re: [PATCH v2 3/7] memcg: use compound_order rather than
 hpage_nr_pages
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
 <262267fe-d98c-0b25-9013-3dafb52e8679@ascade.co.jp>
 <87wow0zwja.fsf@e105922-lin.cambridge.arm.com>
 <87sh6ozwc4.fsf@e105922-lin.cambridge.arm.com>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <2053ac36-74df-b05e-d1ce-36f69dde2a47@ascade.co.jp>
Date: Mon, 21 May 2018 12:48:22 +0900
MIME-Version: 1.0
In-Reply-To: <87sh6ozwc4.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 2018/05/19 2:51, Punit Agrawal wrote:
> Punit Agrawal <punit.agrawal@arm.com> writes:
> 
>> Tsukada-san,
>>
>> I am not familiar with memcg so can't comment about whether the patchset
>> is the right way to solve the problem outlined in the cover letter but
>> had a couple of comments about this patch.
>>
>> TSUKADA Koutaro <tsukada@ascade.co.jp> writes:
>>
>>> The current memcg implementation assumes that the compound page is THP.
>>> In order to be able to charge surplus hugepage, we use compound_order.
>>>
>>> Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
>>
>> Please move this before Patch 1/7. This is to prevent wrong accounting
>> of pages to memcg for size != PMD_SIZE.
> 
> I just noticed that the default state is off so the change isn't enabled
> until the sysfs node is exposed in the next patch. Please ignore this
> comment.
> 
> One below still applies.
> 
>>
>>> ---
>>>   memcontrol.c |   10 +++++-----
>>>   1 file changed, 5 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 2bd3df3..a8f1ff8 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -4483,7 +4483,7 @@ static int mem_cgroup_move_account(struct page *page,
>>>   				   struct mem_cgroup *to)
>>>   {
>>>   	unsigned long flags;
>>> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
>>> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>>
>> Instead of replacing calls to hpage_nr_pages(), is it possible to modify
>> it to do the calculation?

Thank you for review my code and please just call me Tsukada.

I think it is possible to modify the inside of itself rather than
replacing the call to hpage_nr_pages().

Inferring from the processing that hpage_nr_pages() desires, I thought
that the definition of hpage_nr_pages() could be moved outside the
CONFIG_TRANSPARENT_HUGEPAGE. It seems that THP and HugeTLBfs can be
handled correctly because compound_order() is judged by seeing whether it
is PageHead or not.

Also, I would like to use compound_order() inside hpage_nr_pages(), but
since huge_mm.h is included before mm.h where compound_order() is defined,
move hpage_nr_pages to mm.h.

Instead of patch 3/7, are the following patches implementing what you
intended?

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a1262..1186ab7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -204,12 +204,6 @@ static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
  	else
  		return NULL;
  }
-static inline int hpage_nr_pages(struct page *page)
-{
-	if (unlikely(PageTransHuge(page)))
-		return HPAGE_PMD_NR;
-	return 1;
-}

  struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
  		pmd_t *pmd, int flags);
@@ -254,8 +248,6 @@ static inline bool thp_migration_supported(void)
  #define HPAGE_PUD_MASK ({ BUILD_BUG(); 0; })
  #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })

-#define hpage_nr_pages(x) 1
-
  static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
  {
  	return false;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06..082f2ee 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -673,6 +673,12 @@ static inline unsigned int compound_order(struct page *page)
  	return page[1].compound_order;
  }

+static inline int hpage_nr_pages(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	return (1 << compound_order(page));
+}
+
  static inline void set_compound_order(struct page *page, unsigned int order)
  {
  	page[1].compound_order = order;

-- 
Thanks,
Tsukada
