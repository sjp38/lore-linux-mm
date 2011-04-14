Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFC0900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 15:10:55 -0400 (EDT)
Date: Thu, 14 Apr 2011 12:09:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
Message-Id: <20110414120920.1e6c04ff.akpm@linux-foundation.org>
In-Reply-To: <20110414144807.19ec5f69@notabene.brown>
References: <1300772711.26693.473.camel@localhost>
	<alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
	<20110414144807.19ec5f69@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: David Rientjes <rientjes@google.com>, Ben Hutchings <ben@decadent.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, 14 Apr 2011 14:48:07 +1000
NeilBrown <neilb@suse.de> wrote:

> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -244,24 +244,25 @@ static ssize_t single_flag_show(struct kobject *kobj,
> > >  				struct kobj_attribute *attr, char *buf,
> > >  				enum transparent_hugepage_flag flag)
> > >  {
> > > -	if (test_bit(flag, &transparent_hugepage_flags))
> > > -		return sprintf(buf, "[yes] no\n");
> > > -	else
> > > -		return sprintf(buf, "yes [no]\n");
> > > +	return sprintf(buf, "%d\n",
> > > +		       test_bit(flag, &transparent_hugepage_flags));
> 
> It test bit guaranteed to return 0 or 1?
> 
> I think the x86 version returns 0 or -1 (that is from reading the code and
> using google to check what 'sbb' does).

Thanks for catching that.  One wonders how well-tested the patch was!

Speaking of which...

Here's the current status.  Ben, can you please test this soon?

From: Ben Hutchings <ben@decadent.org.uk>

The conventional format for boolean attributes in sysfs is numeric ("0" or
"1" followed by new-line).  Any boolean attribute can then be read and
written using a generic function.  Using the strings "yes [no]", "[yes]
no" (read), "yes" and "no" (write) will frustrate this.

[akpm@linux-foundation.org: use kstrtoul()]
[akpm@linux-foundation.org: test_bit() doesn't return 1/0, per Neil]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <jweiner@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: NeilBrown <neilb@suse.de>
Cc: <stable@kernel.org> 	[2.6.38.x]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/huge_memory.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff -puN mm/huge_memory.c~mm-thp-use-conventional-format-for-boolean-attributes mm/huge_memory.c
--- a/mm/huge_memory.c~mm-thp-use-conventional-format-for-boolean-attributes
+++ a/mm/huge_memory.c
@@ -244,24 +244,28 @@ static ssize_t single_flag_show(struct k
 				struct kobj_attribute *attr, char *buf,
 				enum transparent_hugepage_flag flag)
 {
-	if (test_bit(flag, &transparent_hugepage_flags))
-		return sprintf(buf, "[yes] no\n");
-	else
-		return sprintf(buf, "yes [no]\n");
+	return sprintf(buf, "%d\n",
+		       !!test_bit(flag, &transparent_hugepage_flags));
 }
+
 static ssize_t single_flag_store(struct kobject *kobj,
 				 struct kobj_attribute *attr,
 				 const char *buf, size_t count,
 				 enum transparent_hugepage_flag flag)
 {
-	if (!memcmp("yes", buf,
-		    min(sizeof("yes")-1, count))) {
+	unsigned long value;
+	int ret;
+
+	ret = kstrtoul(buf, 10, &value);
+	if (ret < 0)
+		return ret;
+	if (value > 1)
+		return -EINVAL;
+
+	if (value)
 		set_bit(flag, &transparent_hugepage_flags);
-	} else if (!memcmp("no", buf,
-			   min(sizeof("no")-1, count))) {
+	else
 		clear_bit(flag, &transparent_hugepage_flags);
-	} else
-		return -EINVAL;
 
 	return count;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
