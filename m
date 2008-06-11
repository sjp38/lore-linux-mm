Message-ID: <4850070F.6060305@gmail.com>
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152948.15001.39361.sendpatchset@localhost.localdomain>
In-Reply-To: <20080521152948.15001.39361.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Jun 2008 19:10:40 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> +static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> +{
> +	*tmp = memparse(buf, &buf);
> +	if (*buf != '\0')
> +		return -EINVAL;
> +
> +	*tmp = PAGE_ALIGN(*tmp);
> +	return 0;
> +}

We shouldn't use PAGE_ALIGN() here, otherwise we limit the address space
to 4GB on 32-bit architectures (that could be reasonable, because this
is a per-cgroup limit and not per-process).

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 mm/memrlimitcgroup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/memrlimitcgroup.c b/mm/memrlimitcgroup.c
index 9a03d7d..2d42ff3 100644
--- a/mm/memrlimitcgroup.c
+++ b/mm/memrlimitcgroup.c
@@ -29,6 +29,8 @@
 #include <linux/res_counter.h>
 #include <linux/memrlimitcgroup.h>
 
+#define PAGE_ALIGN64(addr) (((((addr)+PAGE_SIZE-1))>>PAGE_SHIFT)<<PAGE_SHIFT)
+
 struct cgroup_subsys memrlimit_cgroup_subsys;
 
 struct memrlimit_cgroup {
@@ -124,7 +126,7 @@ static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 	if (*buf != '\0')
 		return -EINVAL;
 
-	*tmp = PAGE_ALIGN(*tmp);
+	*tmp = PAGE_ALIGN64(*tmp);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
