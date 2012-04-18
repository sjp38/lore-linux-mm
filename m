Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3CC946B00E7
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 02:16:59 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 18 Apr 2012 11:46:54 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3I6Gpjm4448264
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:46:51 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3IBkZWD031763
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 21:46:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 10/14] hugetlbfs: Add memcg control files for hugetlbfs
In-Reply-To: <20120416161354.b967790c.akpm@linux-foundation.org>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1334573091-18602-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120416161354.b967790c.akpm@linux-foundation.org>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 18 Apr 2012 11:46:37 +0530
Message-ID: <87d375womy.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 16 Apr 2012 16:14:47 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
>> +static char *mem_fmt(char *buf, unsigned long n)
>> +{
>> +	if (n >= (1UL << 30))
>> +		sprintf(buf, "%luGB", n >> 30);
>> +	else if (n >= (1UL << 20))
>> +		sprintf(buf, "%luMB", n >> 20);
>> +	else
>> +		sprintf(buf, "%luKB", n >> 10);
>> +	return buf;
>> +}
>> +
>> +int __init mem_cgroup_hugetlb_file_init(int idx)
>> +{
>> +	char buf[32];
>> +	struct cftype *cft;
>> +	struct hstate *h = &hstates[idx];
>> +
>> +	/* format the size */
>> +	mem_fmt(buf, huge_page_size(h));
>
> The sprintf() into a fixed-sized buffer is a bit ugly.  I didn't check
> it for possible overflows because 32 looks like "enough".  Actually too
> much.
>
> Oh well, it's hard to avoid.  But using scnprintf() would prevent nasty
> accidents.
>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 519d370..0ccf934 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5269,14 +5269,14 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 }
 
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
-static char *mem_fmt(char *buf, unsigned long n)
+static char *mem_fmt(char *buf, int size, unsigned long hsize)
 {
-	if (n >= (1UL << 30))
-		sprintf(buf, "%luGB", n >> 30);
-	else if (n >= (1UL << 20))
-		sprintf(buf, "%luMB", n >> 20);
+	if (hsize >= (1UL << 30))
+		scnprintf(buf, size, "%luGB", hsize >> 30);
+	else if (hsize >= (1UL << 20))
+		scnprintf(buf, size, "%luMB", hsize >> 20);
 	else
-		sprintf(buf, "%luKB", n >> 10);
+		scnprintf(buf, size, "%luKB", hsize >> 10);
 	return buf;
 }
 
@@ -5287,7 +5287,7 @@ int __init mem_cgroup_hugetlb_file_init(int idx)
 	struct hstate *h = &hstates[idx];
 
 	/* format the size */
-	mem_fmt(buf, huge_page_size(h));
+	mem_fmt(buf, 32, huge_page_size(h));
 
 	/* Add the limit file */
 	cft = &h->mem_cgroup_files[0];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
