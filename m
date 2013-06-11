Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id AB5696B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 12:43:44 -0400 (EDT)
Date: Tue, 11 Jun 2013 12:43:36 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] slab: prevent warnings when allocating with __GFP_NOWARN
Message-ID: <20130611164336.GA17241@redhat.com>
References: <51B67553.6020205@oracle.com>
 <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com>
 <51B72323.8040207@oracle.com>
 <0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com>
 <51B73F38.6040802@kernel.org>
 <0000013f33d58923-88767793-2187-476d-b500-dba3c22607aa-000000@email.amazonses.com>
 <51B745F9.9080609@oracle.com>
 <1370967193.3252.47.camel@edumazet-glaptop>
 <51B74E28.4070906@oracle.com>
 <1370968655.3252.49.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370968655.3252.49.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 11, 2013 at 09:37:35AM -0700, Eric Dumazet wrote:
 > On Tue, 2013-06-11 at 12:19 -0400, Sasha Levin wrote:
 > 
 > > It might be, but you need CAP_SYS_RESOURCE to go into the dangerous
 > > zone (>pipe_max_size).
 > > 
 > > So if root (or someone with that cap) wants to go there, as Rusty says:
 > > "Root asked, we do."
 > 
 > Yes and no : adding a test to select vmalloc()/vfree() instead of
 > kmalloc()/kfree() will slow down regular users asking 32 pages in their
 > pipe.
 > 
 > If there is no _sensible_ use for large pipes even for root, please do
 > not bloat the code just because we can.

It's not even that this is the only place that this happens.
I've reported similar traces from the ieee802.154 code for some time.

I wouldn't be surprised to find that there are other similar cases where
a user can ask the kernel to do some incredibly huge allocation.

For my fuzz testing runs, I ended up with the patch below to stop the page allocator warnings.

	Dave

--- /home/davej/src/kernel/git-trees/linux/net/ieee802154/af_ieee802154.c	2013-01-04 18:57:17.677270225 -0500
+++ linux-dj/net/ieee802154/af_ieee802154.c	2013-05-06 20:34:30.702926471 -0400
@@ -108,6 +108,12 @@ static int ieee802154_sock_sendmsg(struc
 {
 	struct sock *sk = sock->sk;
 
+	if (len > MAX_ORDER_NR_PAGES * PAGE_SIZE) {
+		printk_once("Massive alloc in %s!: %d > %d\n", __func__,
+			(unsigned int) len, (unsigned int) (MAX_ORDER_NR_PAGES * PAGE_SIZE));
+		return -EINVAL;
+	}
+
 	return sk->sk_prot->sendmsg(iocb, sk, msg, len);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
