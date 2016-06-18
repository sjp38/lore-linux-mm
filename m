Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31E906B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 21:12:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so191457380pfb.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 18:12:14 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id o3si15553704pfg.243.2016.06.17.18.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 18:12:13 -0700 (PDT)
From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH] sysctl: Handle error writing UINT_MAX to u32 fields
Date: Fri, 17 Jun 2016 19:12:00 -0600
Message-Id: <1466212320-25994-1-git-send-email-subashab@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>, Heinrich Schuchardt <xypron.glpk@gmx.de>

We have scripts which write to certain fields on 3.18 kernels but
this seems to be failing on 4.4 kernels. An entry which we write
to here is xfrm_aevent_rseqth which is u32.

echo 4294967295  > /proc/sys/net/core/xfrm_aevent_rseqth

Commit 230633d109e35b0a24277498e773edeb79b4a331 ("kernel/sysctl.c:
detect overflows when converting to int") prevented writing to
sysctl entries when integer overflow occurs.
However, this does not apply to unsigned integers.

Heinrich suggested that we introduce a new option to handle 64 bit
limits and set min as 0 and max as UINT_MAX. This might not work
as it leads to issues similar to __do_proc_doulongvec_minmax.

static int __do_proc_doulongvec_minmax(void *data, struct ctl_table
{
	i = (unsigned long *) data;   //This cast is causing to
read beyond the size of data (u32)
	vleft = table->maxlen / sizeof(unsigned long); //vleft is 0
because maxlen is sizeof(u32) which is lesser than sizeof(unsigned
long) on x86_64.

Introduce a new proc handler proc_douintvec. Sample output when
changing the proc_handler of xfrm_aevent_rseqth

dev0# cat /proc/sys/net/core/xfrm_aevent_rseqth
2
dev0# echo 4294967295  > /proc/sys/net/core/xfrm_aevent_rseqth
dev0# cat /proc/sys/net/core/xfrm_aevent_rseqth
4294967295
dev0#
dev0# echo -1  > /proc/sys/net/core/xfrm_aevent_rseqth
bash: echo: write error: Invalid argument

Cc: Heinrich Schuchardt <xypron.glpk@gmx.de>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/linux/sysctl.h |  2 ++
 kernel/sysctl.c        | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index fa7bc29..ef17db6c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -41,6 +41,8 @@ extern int proc_dostring(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
+extern int proc_douintvec(struct ctl_table *, int,
+			 void __user *, size_t *, loff_t *);
 extern int proc_dointvec_minmax(struct ctl_table *, int,
 				void __user *, size_t *, loff_t *);
 extern int proc_dointvec_jiffies(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 87b2fc3..72b0248 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2122,6 +2122,21 @@ static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
 	return 0;
 }
 
+static int do_proc_douintvec_conv(bool *negp, unsigned long *lvalp,
+				 int *valp,
+				 int write, void *data)
+{
+	if (write) {
+		if (*negp)
+			return -EINVAL;
+		*valp = *lvalp;
+	} else {
+		unsigned int val = *valp;
+		*lvalp = (unsigned long)val;
+	}
+	return 0;
+}
+
 static const char proc_wspace_sep[] = { ' ', '\t', '\n' };
 
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
@@ -2245,6 +2260,16 @@ int proc_dointvec(struct ctl_table *table, int write,
 		    	    NULL,NULL);
 }
 
+/**
+ * proc_douintvec - read a vector of unsigned integers
+ */
+int proc_douintvec(struct ctl_table *table, int write,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+    return do_proc_dointvec(table,write,buffer,lenp,ppos,
+			    do_proc_douintvec_conv, NULL);
+}
+
 /*
  * Taint values can only be increased
  * This means we can safely use a temporary.
@@ -2840,6 +2865,12 @@ int proc_dointvec(struct ctl_table *table, int write,
 	return -ENOSYS;
 }
 
+int proc_douintvec(struct ctl_table *table, int write,
+		  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
 int proc_dointvec_minmax(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2885,6 +2916,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
  * exception granted :-)
  */
 EXPORT_SYMBOL(proc_dointvec);
+EXPORT_SYMBOL(proc_douintvec);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
 EXPORT_SYMBOL(proc_dointvec_minmax);
 EXPORT_SYMBOL(proc_dointvec_userhz_jiffies);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
