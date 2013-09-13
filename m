Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 5DC706B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 22:25:04 -0400 (EDT)
Message-ID: <5232773E.8090007@asianux.com>
Date: Fri, 13 Sep 2013 10:23:58 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com>
In-Reply-To: <523205A0.1000102@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/13/2013 02:19 AM, KOSAKI Motohiro wrote:
>> BTW: in my opinion, within mpol_to_str(), the VM_BUG_ON() need be
>> replaced by returning -EINVAL.
> 
> Nope. mpol_to_str() is not carefully designed since it was born. It
> doesn't have a way to get proper buffer size. That said, the function
> assume all caller know proper buffer size. So, just adding EINVAL
> doesn't solve anything. we need to add a way to get proper buffer length
> at least if we take your way. However it is overengineering because
> current all caller doesn't need it.
> 


That sounds reasonable.

Hmm... but I still believe there must be a fixing way to satisfy us all.

Please check the patch below whether can satisfy us all, thanks.


-------------------------------patch begin-----------------------------

mm/shmem.c: use VM_BUG_ON() for mpol_to_str() when it fails.

  mpol_to_str() is an extern function which may return a failure. But in
  our case, it should not,

  If it really return a failure, that means current kernel is continuing
  blindly (e.g. some kernel structures are corrupted), should be stopped
  as soon as possible.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/shmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8612a95..3f81120 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -890,7 +890,7 @@ static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 	if (!mpol || mpol->mode == MPOL_DEFAULT)
 		return;		/* show nothing */
 
-	mpol_to_str(buffer, sizeof(buffer), mpol);
+	VM_BUG_ON(mpol_to_str(buffer, sizeof(buffer), mpol) < 0);
 
 	seq_printf(seq, ",mpol=%s", buffer);
 }
-- 
1.7.7.6

-------------------------------patch end-------------------------------


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
