Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46FE46B0570
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:37:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so4291145plp.8
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:37:47 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id f2-v6si7286619pli.569.2018.05.17.21.37.46
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:37:46 -0700 (PDT)
Subject: [PATCH v2 5/7] hugetlb: add charge_surplus_hugepages attribute
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <2e8b5907-36e1-094b-ec87-149e1f0b7f69@ascade.co.jp>
Date: Fri, 18 May 2018 13:37:37 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

Add an entry for charge_surplus_hugepages to sysfs.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 hugetlb.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9a9549c..2f9bdbc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2662,6 +2662,30 @@ static ssize_t surplus_hugepages_show(struct kobject *kobj,
 }
 HSTATE_ATTR_RO(surplus_hugepages);

+static ssize_t charge_surplus_hugepages_show(struct kobject *kobj,
+					struct kobj_attribute *attr, char *buf)
+{
+	struct hstate *h = kobj_to_hstate(kobj, NULL);
+	return sprintf(buf, "%d\n", h->charge_surplus_huge_pages);
+}
+
+static ssize_t charge_surplus_hugepages_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t len)
+{
+	int err;
+	unsigned long input;
+	struct hstate *h = kobj_to_hstate(kobj, NULL);
+
+	err = kstrtoul(buf, 10, &input);
+	if (err)
+		return err;
+
+	h->charge_surplus_huge_pages = input ? true : false;
+
+	return len;
+}
+HSTATE_ATTR(charge_surplus_hugepages);
+
 static struct attribute *hstate_attrs[] = {
 	&nr_hugepages_attr.attr,
 	&nr_overcommit_hugepages_attr.attr,
@@ -2671,6 +2695,7 @@ static ssize_t surplus_hugepages_show(struct kobject *kobj,
 #ifdef CONFIG_NUMA
 	&nr_hugepages_mempolicy_attr.attr,
 #endif
+	&charge_surplus_hugepages_attr.attr,
 	NULL,
 };

-- 
Tsukada
