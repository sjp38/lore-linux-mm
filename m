Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0T1puNZ003081
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 17:51:57 -0800 (PST)
Message-ID: <41FAED57.DFCF1D22@akamai.com>
Date: Fri, 28 Jan 2005 17:56:39 -0800
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: [patch] ext2: Apply Jack's ext3 speedups
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org>
Content-Type: multipart/mixed;
 boundary="------------F1A4EE1C9D1A30DA1F53B6A4"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: akpm@osdl.org, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------F1A4EE1C9D1A30DA1F53B6A4
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Theodore Ts'o wrote:

> On Wed, Jan 26, 2005 at 11:22:39PM -0800, pmeda@akamai.com wrote:
> >
> > Apply ext3 speedups added by Jan Kara to ext2.
> > Reference: http://linus.bkbits.net:8080/linux-2.5/gnupatch@41f127f2jwYahmKm0eWTJNpYcSyhPw
> >
>
> This patch isn't right, as it causes ext2_sparse_group(1) to return 0
> instead of 1.  Block groups number 0 and 1 must always contain a
> superblock.
>
> >  static int ext2_group_sparse(int group)
> >  {
> > +     if (group <= 0)
> > +             return 1;
>
> Change this to be:
>
> +       if (group <= 1)
> +               return 1;
>
> and it should fix the patch (as well as be similar to the ext3
> mainline).  With this change,
>
> Acked-by: "Theodore Ts'o" <tytso@mit.edu>

 Thanks for correction!  I made one more attempt to improve it.
 Please look at the attached patch.

  - Folded all three root checkings for 3,  5 and 7 into one loop.
  -  Short cut the loop with 3**n < 5 **n < 7**n logic.
  -  Even numbers can be ruled out.

  Tested with  user space programs.


Thanks,
Prasanna.


--------------F1A4EE1C9D1A30DA1F53B6A4
Content-Type: text/plain; charset=us-ascii;
 name="ext3_test_root_loops_folding.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ext3_test_root_loops_folding.patch"



Two changes in test_root algorithm, so that number of multiplications
and loops will become less.
 - Fold the root checking for 3, 5, 7 into a single loop.
 - Exploit the concepts 3**n < 5**n < 7**n, and odd**n is odd number.

Logic: On the whole, folded(new) should perfrom better than unfolded(old).
The advantage with new method is, log7 n is lesser than log3 n.

When a is even number, old: log3 n + log5 n + log7 n, multiplications in new: 0
When a is odd number, and
 When a is exact power of 3, old: log3 n, new: log3 n + log5 n + log7 n.
 When a is exact power of 5, old: log3 n + log5 n, new: 2 * log5 n + log7 n.
 When a is exact power of 7, old: log3 n + log5 n + log7 n, new: 3 * log7 n.
 When it is not exact power, old: log3 n + log5 n + log7 n,
 and the new one is also: log3 n + log5 n + log7 n, I see slight impovement here
 too(did not expect), perhaps because of the result of the loop coding.
 Number of such nonexact numbers in n numbers is n - log3 n - log5 n - log7 n,
 so it is good.

An attempt to summarise the observed results:
 When a is small power of 3, unfolded is 50% better, but when
 a is bigger power of 3, it is around 25% better(log3 n and code dominates
 log7 n). When a is power of 5 or 7, folded is 30 to 60% better.
 When a is not power of 3, 5 or 7, folded is 10 to 30% better.


Signed-off-by: Prasanna Meda <pmeda@akamai.com>


--- a/fs/ext3/balloc.c	Fri Jan 28 12:21:45 2005
+++ b/fs/ext3/balloc.c	Fri Jan 28 14:46:32 2005
@@ -1438,21 +1438,43 @@
 			 EXT3_BLOCKS_PER_GROUP(sb), map);
 }
 
-static inline int test_root(int a, int b)
+/*
+ * Checks power(3,n) == a, or power(5,n) == a or power(7,n) == a for some +ve n.
+ * Hints: power(3,n) < power(5,n) < power(7,n), and power can not be even.
+ */
+static inline int test_root(int a)
 {
-	int num = b;
+	int power3 = 3, power5 = 5, power7 = 7;
 
-	while (a > num)
-		num *= b;
-	return num == a;
+	if  (!(a & 1))
+		return 0;
+
+	if  (power5 == a || power7 == a)
+		return 1;
+
+	while (a > power3) {
+		power3 *= 3;
+
+		if (a < power5)
+			continue;
+		power5 *= 5;
+		if (power5 == a)
+			return 1;
+
+		if (a < power7)
+			continue;
+		power7 *= 7;
+		if (power7 == a)
+			return 1;
+	}
+	return (power3 == a);
 }
 
 static int ext3_group_sparse(int group)
 {
 	if (group <= 1)
 		return 1;
-	return (test_root(group, 3) || test_root(group, 5) ||
-		test_root(group, 7));
+	return (test_root(group));
 }
 
 /**

--------------F1A4EE1C9D1A30DA1F53B6A4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
