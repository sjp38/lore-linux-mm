Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i73HJrgM197604
	for <linux-mm@kvack.org>; Tue, 3 Aug 2004 13:19:53 -0400
Received: from nighthawk.sr71.net (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i73HJo8b085074
	for <linux-mm@kvack.org>; Tue, 3 Aug 2004 11:19:51 -0600
Received: from localhost (dave@nighthawk [127.0.0.1])
	by nighthawk.sr71.net (8.12.11/8.12.11/Debian-1) with ESMTP id i73HJl8d031828
	for <linux-mm@kvack.org>; Tue, 3 Aug 2004 10:19:48 -0700
Subject: return type for __get_free_pages()
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-ERTJMTkHxLbMvnp0bI48"
Message-Id: <1091553587.27397.5279.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 03 Aug 2004 10:19:47 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-ERTJMTkHxLbMvnp0bI48
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Several page allocator functions (__get_free_pages(), get_zeroed_page(),
etc...) return 'unsigned long's for the virtual address of pages that
have been allocated, not the 'struct page'.  I have the feeling this was
to differentiate them from things like __alloc_pages() that _do_ return
a 'struct page *' and keep a hapless author from doing this:

	struct page *foo = get_zeroed_page();
	struct my_struct *bar = page_to_virt(foo);

and getting some senseless goo in 'bar' without some kind of compiler
warning.

While I'm sure this is effective at slapping a silly kernel programmer
earlier than at runtime, it has also made users of those functions
*store* those addresses in 'unsigned long's, which gets around doing a
cast when the allocation occurs. (see
net/packet/af_packet.c::packet_opt->pg_vec)

But, they tend to go and do things like virt_to_phys(foo) on their new
page, which is perfectly valid, but also properly generates a compiler
warning if virt_to_phys() takes a 'void *'.

Anyway, has anyone's opinion changed about the return types of those
functions?  Can I convince anyone that we should change them to return
pointers?  In in their structures, authors will use whatever types give
them the fewest casts when they're initially coding, not necessarily
what types they should be using.  

If we keep it the way it is, we pretty much require ourselved to have a
bunch of ugly casts at alloc/free time:

        unsigned char *foo;
        foo = (unsigned char *)__get_free_pages(GFP_KERNEL, order);
        ...
        free_pages((unsigned long)foo, order);

BTW, I've attached a patch to convert af_packet.c from using 'unsigned
long' for its pointers to an actual pointer.  

-- Dave

--=-ERTJMTkHxLbMvnp0bI48
Content-Disposition: attachment; filename=A6-af_packet_to_voidstar.patch
Content-Type: text/x-patch; name=A6-af_packet_to_voidstar.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit




---

 memhotplug-dave/net/packet/af_packet.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff -puN net/packet/af_packet.c~A6-af_packet_to_voidstar net/packet/af_packet.c
--- memhotplug/net/packet/af_packet.c~A6-af_packet_to_voidstar	Tue Aug  3 09:50:36 2004
+++ memhotplug-dave/net/packet/af_packet.c	Tue Aug  3 10:05:36 2004
@@ -173,7 +173,7 @@ struct packet_opt
 {
 	struct tpacket_stats	stats;
 #ifdef CONFIG_PACKET_MMAP
-	unsigned long		*pg_vec;
+	unsigned char *		*pg_vec;
 	unsigned int		head;
 	unsigned int            frames_per_block;
 	unsigned int		frame_size;
@@ -198,15 +198,15 @@ struct packet_opt
 
 #ifdef CONFIG_PACKET_MMAP
 
-static inline unsigned long packet_lookup_frame(struct packet_opt *po, unsigned int position)
+static inline unsigned char *packet_lookup_frame(struct packet_opt *po, unsigned int position)
 {
 	unsigned int pg_vec_pos, frame_offset;
-	unsigned long frame;
+	unsigned char *frame;
 
 	pg_vec_pos = position / po->frames_per_block;
 	frame_offset = position % po->frames_per_block;
 
-	frame = (unsigned long) (po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size));
+	frame = po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size);
 	
 	return frame;
 }
@@ -1549,7 +1549,12 @@ static struct vm_operations_struct packe
 	.close =packet_mm_close,
 };
 
-static void free_pg_vec(unsigned long *pg_vec, unsigned order, unsigned len)
+static inline struct page *pg_vec_endpage(unsigned char *one_pg_vec, unsigned int order)
+{
+	return virt_to_page(one_pg_vec + (PAGE_SIZE << order) - 1);
+}
+
+static void free_pg_vec(unsigned char **pg_vec, unsigned order, unsigned len)
 {
 	int i;
 
@@ -1557,10 +1562,10 @@ static void free_pg_vec(unsigned long *p
 		if (pg_vec[i]) {
 			struct page *page, *pend;
 
-			pend = virt_to_page(pg_vec[i] + (PAGE_SIZE << order) - 1);
+			pend = pg_vec_endpage(pg_vec[i], order);
 			for (page = virt_to_page(pg_vec[i]); page <= pend; page++)
 				ClearPageReserved(page);
-			free_pages(pg_vec[i], order);
+			free_pages((unsigned long)pg_vec[i], order);
 		}
 	}
 	kfree(pg_vec);
@@ -1569,7 +1574,7 @@ static void free_pg_vec(unsigned long *p
 
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing)
 {
-	unsigned long *pg_vec = NULL;
+	unsigned char **pg_vec = NULL;
 	struct packet_opt *po = pkt_sk(sk);
 	int was_running, num, order = 0;
 	int err = 0;
@@ -1604,18 +1609,18 @@ static int packet_set_ring(struct sock *
 
 		err = -ENOMEM;
 
-		pg_vec = kmalloc(req->tp_block_nr*sizeof(unsigned long*), GFP_KERNEL);
+		pg_vec = kmalloc(req->tp_block_nr*sizeof(unsigned char *), GFP_KERNEL);
 		if (pg_vec == NULL)
 			goto out;
-		memset(pg_vec, 0, req->tp_block_nr*sizeof(unsigned long*));
+		memset(pg_vec, 0, req->tp_block_nr*sizeof(unsigned char *));
 
 		for (i=0; i<req->tp_block_nr; i++) {
 			struct page *page, *pend;
-			pg_vec[i] = __get_free_pages(GFP_KERNEL, order);
+			pg_vec[i] = (unsigned char *)__get_free_pages(GFP_KERNEL, order);
 			if (!pg_vec[i])
 				goto out_free_pgvec;
 
-			pend = virt_to_page(pg_vec[i] + (PAGE_SIZE << order) - 1);
+			pend = pg_vec_endpage(pg_vec[i], order);
 			for (page = virt_to_page(pg_vec[i]); page <= pend; page++)
 				SetPageReserved(page);
 		}
@@ -1623,7 +1628,7 @@ static int packet_set_ring(struct sock *
 
 		l = 0;
 		for (i=0; i<req->tp_block_nr; i++) {
-			unsigned long ptr = pg_vec[i];
+			unsigned char *ptr = pg_vec[i];
 			struct tpacket_hdr *header;
 			int k;
 

_

--=-ERTJMTkHxLbMvnp0bI48--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
