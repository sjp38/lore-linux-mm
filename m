Date: Thu, 08 May 2003 14:53:37 -0700 (PDT)
Message-Id: <20030508.145337.44959912.davem@redhat.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200305081734.54621.tomlins@cam.org>
References: <20030508013854.GW8931@holomorphy.com>
	<20030508.102155.132908119.davem@redhat.com>
	<200305081734.54621.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tomlins@cam.org
Cc: wli@holomorphy.com, helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

   Since I have not noticed anyone posting one, here is the opps that
   kills -mm3

Oh yeah, thats a seperate problem.  This should fix it:

--- ./net/ipv4/netfilter/ip_fw_compat_masq.c.~1~	Thu May  8 14:38:01 2003
+++ ./net/ipv4/netfilter/ip_fw_compat_masq.c	Thu May  8 14:49:19 2003
@@ -103,19 +103,19 @@ do_masquerade(struct sk_buff **pskb, con
 }
 
 void
-check_for_masq_error(struct sk_buff *skb)
+check_for_masq_error(struct sk_buff **pskb)
 {
 	enum ip_conntrack_info ctinfo;
 	struct ip_conntrack *ct;
 
-	ct = ip_conntrack_get(skb, &ctinfo);
+	ct = ip_conntrack_get(*pskb, &ctinfo);
 	/* Wouldn't be here if not tracked already => masq'ed ICMP
            ping or error related to masq'd connection */
 	IP_NF_ASSERT(ct);
 	if (ctinfo == IP_CT_RELATED) {
-		icmp_reply_translation(skb, ct, NF_IP_PRE_ROUTING,
+		icmp_reply_translation(pskb, ct, NF_IP_PRE_ROUTING,
 				       CTINFO2DIR(ctinfo));
-		icmp_reply_translation(skb, ct, NF_IP_POST_ROUTING,
+		icmp_reply_translation(pskb, ct, NF_IP_POST_ROUTING,
 				       CTINFO2DIR(ctinfo));
 	}
 }
@@ -152,10 +152,10 @@ check_for_demasq(struct sk_buff **pskb)
 				    && skb_linearize(*pskb, GFP_ATOMIC) != 0)
 					return NF_DROP;
 
-				icmp_reply_translation(*pskb, ct,
+				icmp_reply_translation(pskb, ct,
 						       NF_IP_PRE_ROUTING,
 						       CTINFO2DIR(ctinfo));
-				icmp_reply_translation(*pskb, ct,
+				icmp_reply_translation(pskb, ct,
 						       NF_IP_POST_ROUTING,
 						       CTINFO2DIR(ctinfo));
 			}
--- ./net/ipv4/netfilter/ip_fw_compat.c.~1~	Thu May  8 14:39:58 2003
+++ ./net/ipv4/netfilter/ip_fw_compat.c	Thu May  8 14:40:08 2003
@@ -35,7 +35,7 @@ extern unsigned int
 do_masquerade(struct sk_buff **pskb, const struct net_device *dev);
 
 extern unsigned int
-check_for_masq_error(struct sk_buff *pskb);
+check_for_masq_error(struct sk_buff **pskb);
 
 extern unsigned int
 check_for_demasq(struct sk_buff **pskb);
@@ -167,7 +167,7 @@ fw_in(unsigned int hooknum,
 			/* Handle ICMP errors from client here */
 			if ((*pskb)->nh.iph->protocol == IPPROTO_ICMP
 			    && (*pskb)->nfct)
-				check_for_masq_error(*pskb);
+				check_for_masq_error(pskb);
 		}
 		return NF_ACCEPT;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
