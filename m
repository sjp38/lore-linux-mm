Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B46906B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 09:22:58 -0400 (EDT)
Date: Fri, 5 Jun 2009 22:22:45 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [PATCH mmotm] memcg: add interface to reset limits
Message-Id: <20090605222245.6920061a.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090603144347.81ec2ce1.nishimura@mxp.nes.nec.co.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
	<4A26072B.8040207@cn.fujitsu.com>
	<20090603144347.81ec2ce1.nishimura@mxp.nes.nec.co.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > > We don't have interface to reset mem.limit or memsw.limit now,
> > > so let's reset the mem.limit or memsw.limit to default(unlimited)
> > > when they are being set to 0.
> > > 
> > 
> > The idea of having a way to set the limit to unlimited is good,
> > but how about allow this by writing -1 to mem.limit?
> > 
> O.K.
> I'll try it.
> 
This is the updated version.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

We don't have interface to reset mem.limit or memsw.limit now.

This patch allows to reset mem.limit or memsw.limit when they are
being set to -1.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/memory.txt |    1 +
 include/linux/res_counter.h      |    2 ++
 kernel/res_counter.c             |   12 +++++++++++-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 1a60887..1631690 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -204,6 +204,7 @@ We can alter the memory limit:
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
 mega or gigabytes.
+NOTE: We can write "-1" to reset the *.limit_in_bytes(unlimited).
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 4c5bcf6..511f42f 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -49,6 +49,8 @@ struct res_counter {
 	struct res_counter *parent;
 };
 
+#define RESOURCE_MAX (unsigned long long)LLONG_MAX
+
 /**
  * Helpers to interact with userspace
  * res_counter_read_u64() - returns the value of the specified member.
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index bf8e753..e1338f0 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,7 @@
 void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
-	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
@@ -133,6 +133,16 @@ int res_counter_memparse_write_strategy(const char *buf,
 					unsigned long long *res)
 {
 	char *end;
+
+	/* return RESOURCE_MAX(unlimited) if "-1" is specified */
+	if (*buf == '-') {
+		*res = simple_strtoull(buf + 1, &end, 10);
+		if (*res != 1 || *end != '\0')
+			return -EINVAL;
+		*res = RESOURCE_MAX;
+		return 0;
+	}
+
 	/* FIXME - make memparse() take const char* args */
 	*res = memparse((char *)buf, &end);
 	if (*end != '\0')

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
