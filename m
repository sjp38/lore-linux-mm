Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 204D26B057A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:49:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t11-v6so2447371pgn.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:49:52 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id j20-v6si6475901pll.223.2018.05.17.21.36.19
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:36:19 -0700 (PDT)
Subject: [PATCH v2 4/7] mm, sysctl: make charging surplus hugepages
 controllable
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <d87cac0d-e395-a528-4c25-226399a09121@ascade.co.jp>
Date: Fri, 18 May 2018 13:36:11 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

Make the default hugetlb surplus hugepage controlable by
/proc/sys/vm/charge_surplus_hugepages.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 include/linux/hugetlb.h |    2 ++
 kernel/sysctl.c         |    7 +++++++
 mm/hugetlb.c            |   21 +++++++++++++++++++++
 3 files changed, 30 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 33fe5be..9314b07 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -80,6 +80,8 @@ struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long max_hpages,
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_charge_surplus_handler(struct ctl_table *, int, void __user *,
+					size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);

 #ifdef CONFIG_NUMA
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6a78cf7..d562d64 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1394,6 +1394,13 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.mode		= 0644,
 		.proc_handler	= hugetlb_overcommit_handler,
 	},
+	{
+		.procname	= "charge_surplus_hugepages",
+		.data		= NULL,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= hugetlb_charge_surplus_handler,
+	},
 #endif
 	{
 		.procname	= "lowmem_reserve_ratio",
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2e7b543..9a9549c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3069,6 +3069,27 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 	return ret;
 }

+int hugetlb_charge_surplus_handler(struct ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos)
+{
+	struct hstate *h = &default_hstate;
+	int tmp, ret;
+
+	if (!hugepages_supported())
+		return -EOPNOTSUPP;
+
+	tmp = h->charge_surplus_huge_pages ? 1 : 0;
+	table->data = &tmp;
+	table->maxlen = sizeof(int);
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		goto out;
+
+	if (write)
+		h->charge_surplus_huge_pages = tmp ? true : false;
+out:
+	return ret;
+}
 #endif /* CONFIG_SYSCTL */

 void hugetlb_report_meminfo(struct seq_file *m)

--
Tsukada
