Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 69DAE6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 11:16:43 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so1050385bkc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:16:41 -0700 (PDT)
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20121022180655.50a50401@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	 <20121019233632.26cf96d8@sacrilege>
	 <CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	 <20121020204958.4bc8e293@sacrilege> <20121021044540.12e8f4b7@sacrilege>
	 <20121021062402.7c4c4cb8@sacrilege>
	 <1350826183.13333.2243.camel@edumazet-glaptop>
	 <20121021195701.7a5872e7@sacrilege> <20121022004332.7e3f3f29@sacrilege>
	 <20121022015134.4de457b9@sacrilege>
	 <1350856053.8609.217.camel@edumazet-glaptop>
	 <20121022045850.788df346@sacrilege>
	 <1350893743.8609.424.camel@edumazet-glaptop>
	 <20121022180655.50a50401@sacrilege>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Oct 2012 17:16:37 +0200
Message-ID: <1350918997.8609.858.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kazantsev <mk.fraggod@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-10-22 at 18:06 +0600, Mike Kazantsev wrote:
> On Mon, 22 Oct 2012 10:15:43 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2012-10-22 at 04:58 +0600, Mike Kazantsev wrote:
> > 
> > > I've grepped for "/org/free" specifically and sure enough, same scraps
> > > of data seem to be in some of the (varied) dumps there.
> > 
> > Content is not meaningful, as we dont initialize it.
> > So you see previous content.
> > 
> > Could you try the following :
> > 
> ...
> 
> With this patch on top of v3.7-rc2 (w/o patches from your previous
> mail), leak seem to be still present.

OK, I believe I found the bug in IPv4 defrag / IPv6 reasm

Please test the following patch.

Thanks !

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 448e685..0a52771 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -48,6 +48,7 @@
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
+#include <net/xfrm.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -634,6 +635,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 
+		secpath_reset(fp);
 		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
 			kfree_skb_partial(fp, headstolen);
 		} else {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index da8a4e3..4fcc463 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -55,6 +55,7 @@
 #include <net/ndisc.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <net/xfrm.h>
 
 struct ip6frag_skb_cb
 {
@@ -456,6 +457,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 
+		secpath_reset(fp);
 		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
 			kfree_skb_partial(fp, headstolen);
 		} else {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
