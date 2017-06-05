Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 924786B02F3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:38:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so24829179wmc.8
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:38:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v34si32248634wrb.289.2017.06.05.15.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:38:22 -0700 (PDT)
Date: Mon, 5 Jun 2017 15:38:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-Id: <20170605153819.9c86969a73926e4269e77976@linux-foundation.org>
In-Reply-To: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, mike.kravetz@Oracle.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com--dry-run

On Fri,  2 Jun 2017 20:54:13 -0400 "Liam R. Howlett" <Liam.Howlett@Oracle.com> wrote:

> When the user specifies too many hugepages or an invalid
> default_hugepagesz the communication to the user is implicit in the
> allocation message.  This patch adds a warning when the desired page
> count is not allocated and prints an error when the default_hugepagesz
> is invalid on boot.
> 
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -70,6 +70,7 @@ struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
>  
>  /* Forward declaration */
>  static int hugetlb_acct_memory(struct hstate *h, long delta);
> +static char * __init memfmt(char *buf, unsigned long n);

It's better to just move memfmt() to the right place.  After all, you
have revealed that it was in the wrong place, no?

(Am a bit surprised that something as general as memfmt is private to
hugetlb.c)

--- a/mm/hugetlb.c~mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages-fix
+++ a/mm/hugetlb.c
@@ -69,7 +69,17 @@ struct mutex *hugetlb_fault_mutex_table
 
 /* Forward declaration */
 static int hugetlb_acct_memory(struct hstate *h, long delta);
-static char * __init memfmt(char *buf, unsigned long n);
+
+static char * __init memfmt(char *buf, unsigned long n)
+{
+	if (n >= (1UL << 30))
+		sprintf(buf, "%lu GB", n >> 30);
+	else if (n >= (1UL << 20))
+		sprintf(buf, "%lu MB", n >> 20);
+	else
+		sprintf(buf, "%lu KB", n >> 10);
+	return buf;
+}
 
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
@@ -2238,17 +2248,6 @@ static void __init hugetlb_init_hstates(
 	VM_BUG_ON(minimum_order == UINT_MAX);
 }
 
-static char * __init memfmt(char *buf, unsigned long n)
-{
-	if (n >= (1UL << 30))
-		sprintf(buf, "%lu GB", n >> 30);
-	else if (n >= (1UL << 20))
-		sprintf(buf, "%lu MB", n >> 20);
-	else
-		sprintf(buf, "%lu KB", n >> 10);
-	return buf;
-}
-
 static void __init report_hugepages(void)
 {
 	struct hstate *h;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
