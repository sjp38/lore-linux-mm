Date: Thu, 08 May 2003 10:21:55 -0700 (PDT)
Message-Id: <20030508.102155.132908119.davem@redhat.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030508013854.GW8931@holomorphy.com>
References: <20030507.064010.42794250.davem@redhat.com>
	<20030507215430.GA1109@hh.idb.hist.no>
	<20030508013854.GW8931@holomorphy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

   
   Can you try one kernel with the netfilter cset backed out, and another
   with the re-slabification patch backed out? (But not with both backed
   out simultaneously).

Not needed, this should cure the problem:

--- net/ipv4/netfilter/ip_nat_core.c.~1~	Thu May  8 11:23:22 2003
+++ net/ipv4/netfilter/ip_nat_core.c	Thu May  8 11:25:56 2003
@@ -861,6 +861,7 @@
 	} *inside;
 	unsigned int i;
 	struct ip_nat_info *info = &conntrack->nat.info;
+	int hdrlen;
 
 	if (!skb_ip_make_writable(pskb,(*pskb)->nh.iph->ihl*4+sizeof(*inside)))
 		return 0;
@@ -868,10 +869,12 @@
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY
-	    && (u16)csum_fold(skb_checksum(*pskb, (*pskb)->nh.iph->ihl*4,
-					   (*pskb)->len, 0)))
-		return 0;
+	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
+		hdrlen = (*pskb)->nh.iph->ihl * 4;
+		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
+						(*pskb)->len - hdrlen, 0)))
+			return 0;
+	}
 
 	/* Must be RELATED */
 	IP_NF_ASSERT((*pskb)->nfct
@@ -948,10 +951,12 @@
 	}
 	READ_UNLOCK(&ip_nat_lock);
 
+	hdrlen = (*pskb)->nh.iph->ihl * 4;
+
 	inside->icmp.checksum = 0;
-	inside->icmp.checksum = csum_fold(skb_checksum(*pskb,
-						       (*pskb)->nh.iph->ihl*4,
-						       (*pskb)->len, 0));
+	inside->icmp.checksum = csum_fold(skb_checksum(*pskb, hdrlen,
+						       (*pskb)->len - hdrlen,
+						       0));
 	return 1;
 
  unlock_fail:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
