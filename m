From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Thu, 17 Aug 2000 08:58:21 +1000 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14747.7309.941683.168466@notabene.cse.unsw.edu.au>
Subject: Re: 2.4.0-test7-pre4 oops in generic_make_request()
In-Reply-To: message from Tigran Aivazian on Wednesday August 16
References: <Pine.LNX.4.21.0008162201590.1028-100000@saturn.homenet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday August 16, tigran@veritas.com wrote:
> Hi guys,
> 
> linux-kernel is dead so I am posting this oops here. This is
> 2.4.0-test7-pre4 slightly patched by
> 
> http://www.moses.uklinux.net/patches/linux-vxfs-2.4.0-test7-pre4.patch
> 
> (the patch is irrelevant to the oops but I list for completeness)
> 
> I was mkfs'ing a new filesystem on a 61G disk partition. Oops is
> interesting (the fact that mkfs is actually mkfs.vxfs is totally
> irrelevant - think of it as "some app" which writes some stuff to
> /dev/hdd1).
> 
> Regards,
> Tigran

This was my fault.  Patch has already been sent to Linus and
linux-kernel, but pre5 seems to be a while coming.

But it looks like you are doing IO on a raw (drivers/char/raw.c)
device, rather than /dev/hdd1.  Is that right?

NeilBrown




--- fs/buffer.c	2000/08/14 23:05:44	1.2
+++ fs/buffer.c	2000/08/14 23:10:30
@@ -1837,6 +1837,7 @@
 	int		pageind;
 	int		bhind;
 	int		offset;
+	int		sectors = size>>9;
 	unsigned long	blocknr;
 	struct kiobuf *	iobuf = NULL;
 	struct page *	map;
@@ -1888,9 +1889,10 @@
 				tmp->b_this_page = tmp;
 
 				init_buffer(tmp, end_buffer_io_kiobuf, iobuf);
-				tmp->b_dev = dev;
+				tmp->b_rdev = tmp->b_dev = dev;
 				tmp->b_blocknr = blocknr;
-				tmp->b_state = 1 << BH_Mapped;
+				tmp->b_rsector = blocknr*sectors;
+				tmp->b_state = (1 << BH_Mapped) | (1 << BH_Lock) | (1 << BH_Req);
 
 				if (rw == WRITE) {
 					set_bit(BH_Uptodate, &tmp->b_state);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
