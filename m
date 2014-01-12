Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0926B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 06:00:11 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id n12so2037665wgh.24
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 03:00:10 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ut3si7555827wjc.140.2014.01.12.03.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 03:00:09 -0800 (PST)
Date: Sun, 12 Jan 2014 10:59:59 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
Message-ID: <20140112105958.GA9791@n2100.arm.linux.org.uk>
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com> <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org> <20131210005454.GX4360@n2100.arm.linux.org.uk> <52A66826.7060204@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A66826.7060204@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-arm-kernel@lists.infradead.org

On Mon, Dec 09, 2013 at 08:02:30PM -0500, Santosh Shilimkar wrote:
> On Monday 09 December 2013 07:54 PM, Russell King - ARM Linux wrote:
> > The underlying reason is that - as I've already explained - ARM's __ffs()
> > differs from other architectures in that it ends up being an int, whereas
> > almost everyone else is unsigned long.
> > 
> > The fix is to fix ARMs __ffs() to conform to other architectures.
> > 
> I was just about to cross-post your reply here. Obviously I didn't think
> this far when I made  $subject fix.
> 
> So lets ignore the $subject patch which is not correct. Sorry for noise

Well, here we are, a month on, and this still remains unfixed despite
my comments pointing to what the problem is.  So, here's a patch to fix
this problem the correct way.  I took the time to add some comments to
these functions as I find that I wonder about their return values, and
these comments make the patch a little larger than it otherwise would be.

This patch makes their types match exactly with x86's definitions of
the same, which is the basic problem: on ARM, they all took "int" values
and returned "int"s, which leads to min() in nobootmem.c complaining.

 arch/arm/include/asm/bitops.h | 54 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 44 insertions(+), 10 deletions(-)

diff --git a/arch/arm/include/asm/bitops.h b/arch/arm/include/asm/bitops.h
index e691ec91e4d3..b2e298a90d76 100644
--- a/arch/arm/include/asm/bitops.h
+++ b/arch/arm/include/asm/bitops.h
@@ -254,25 +254,59 @@ static inline int constant_fls(int x)
 }
 
 /*
- * On ARMv5 and above those functions can be implemented around
- * the clz instruction for much better code efficiency.
+ * On ARMv5 and above those functions can be implemented around the
+ * clz instruction for much better code efficiency.  __clz returns
+ * the number of leading zeros, zero input will return 32, and
+ * 0x80000000 will return 0.
  */
+static inline unsigned int __clz(unsigned int x)
+{
+	unsigned int ret;
+
+	asm("clz\t%0, %1" : "=r" (ret) : "r" (x));
 
+	return ret;
+}
+
+/*
+ * fls() returns zero if the input is zero, otherwise returns the bit
+ * position of the last set bit, where the LSB is 1 and MSB is 32.
+ */
 static inline int fls(int x)
 {
-	int ret;
-
 	if (__builtin_constant_p(x))
 	       return constant_fls(x);
 
-	asm("clz\t%0, %1" : "=r" (ret) : "r" (x));
-       	ret = 32 - ret;
-	return ret;
+	return 32 - __clz(x);
+}
+
+/*
+ * __fls() returns the bit position of the last bit set, where the
+ * LSB is 0 and MSB is 31.  Zero input is undefined.
+ */
+static inline unsigned long __fls(unsigned long x)
+{
+	return fls(x) - 1;
+}
+
+/*
+ * ffs() returns zero if the input was zero, otherwise returns the bit
+ * position of the first set bit, where the LSB is 1 and MSB is 32.
+ */
+static inline int ffs(int x)
+{
+	return fls(x & -x);
+}
+
+/*
+ * __ffs() returns the bit position of the first bit set, where the
+ * LSB is 0 and MSB is 31.  Zero input is undefined.
+ */
+static inline unsigned long __ffs(unsigned long x)
+{
+	return ffs(x) - 1;
 }
 
-#define __fls(x) (fls(x) - 1)
-#define ffs(x) ({ unsigned long __t = (x); fls(__t & -__t); })
-#define __ffs(x) (ffs(x) - 1)
 #define ffz(x) __ffs( ~(x) )
 
 #endif


-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
