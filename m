Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C454900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:32:29 -0400 (EDT)
Date: Wed, 13 Apr 2011 12:31:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-Id: <20110413123122.1adceba6.akpm@linux-foundation.org>
In-Reply-To: <1300772711.26693.473.camel@localhost>
References: <1300772711.26693.473.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, 22 Mar 2011 05:45:11 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

>  static ssize_t single_flag_store(struct kobject *kobj,
>  				 struct kobj_attribute *attr,
>  				 const char *buf, size_t count,
>  				 enum transparent_hugepage_flag flag)
>  {
> -	if (!memcmp("yes", buf,
> -		    min(sizeof("yes")-1, count))) {
> +	unsigned long value;
> +	char *endp;
> +
> +	value = simple_strtoul(buf, &endp, 0);

What the heck is this doing using simple_strtoul()?  checkpatch has
been telling us to use strict_strtoul() for ages, and lately it tells us
to use kstrtoul().

Please review and test asap:

--- a/mm/huge_memory.c~mm-thp-use-conventional-format-for-boolean-attributes-fix
+++ a/mm/huge_memory.c
@@ -247,16 +247,19 @@ static ssize_t single_flag_show(struct k
 	return sprintf(buf, "%d\n",
 		       test_bit(flag, &transparent_hugepage_flags));
 }
+
 static ssize_t single_flag_store(struct kobject *kobj,
 				 struct kobj_attribute *attr,
 				 const char *buf, size_t count,
 				 enum transparent_hugepage_flag flag)
 {
 	unsigned long value;
-	char *endp;
+	int ret;
 
-	value = simple_strtoul(buf, &endp, 0);
-	if (endp == buf || value > 1)
+	ret = kstrtoul(buf, 10, &value);
+	if (ret < 0)
+		return ret;
+	if (value > 1)
 		return -EINVAL;
 
 	if (value)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
