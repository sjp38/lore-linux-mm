Message-Id: <200111160730.AAA18774@puffin.external.hp.com>
Subject: parisc scatterlist doesn't want page/offset
Date: Fri, 16 Nov 2001 00:30:32 -0700
From: Grant Grundler <grundler@puffin.external.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

Hi all,
Could someone point me to any discussion about adding
page/offset to struct scatterlist?

To me, it looks like a half-assed step to support DMA to HIGHMEM
on 32-bit arches.  TBH, I'd like to see page/offset replace
address in the pci_map* interfaces and struct scatterlist.
But then replace it across the board so the DMA mapping code
doesn't have to decide which field to use (KISS). This really
belongs in 2.5 kernel.

parisc has just merged up to 2.4.14 and picked up the following
macros from arch/sparc:
/* No highmem on parisc, plus we have an IOMMU, so mapping pages is easy. */
#define pci_map_page(dev, page, off, size, dir) \
        pci_map_single(dev, (page_address(page) + (off)), size, dir) 
#define pci_unmap_page(dev,addr,sz,dir) pci_unmap_single(dev,addr,sz,dir)

afaict, parisc doesn't need page/offset in struct scatterlist.
As an interim solution, I've appended a patch that I'm hoping
is acceptable (or at least a starting point).
Thoughts?

thanks,
grant

ps. I'm trying to be constructive - it's a bit difficult after
  putting up with davem ranting about how the DMA mapping interface
  in 2.4 was frozen.

Index: drivers/scsi/scsi_merge.c
===================================================================
RCS file: /var/cvs/linux/drivers/scsi/scsi_merge.c,v
retrieving revision 1.10
diff -u -p -r1.10 scsi_merge.c
--- drivers/scsi/scsi_merge.c	2001/11/09 23:36:24	1.10
+++ drivers/scsi/scsi_merge.c	2001/11/16 07:26:36
@@ -943,7 +943,9 @@ __inline static int __init_io(Scsi_Cmnd 
 		}
 		count++;
 		sgpnt[count - 1].address = bh->b_data;
+#ifdef CONFIG_HIGHMEM
 		sgpnt[count - 1].page = NULL;
+#endif
 		sgpnt[count - 1].length += bh->b_size;
 		if (!dma_host) {
 			SCpnt->request_bufflen += bh->b_size;
Index: drivers/scsi/sg.c
===================================================================
RCS file: /var/cvs/linux/drivers/scsi/sg.c,v
retrieving revision 1.12
diff -u -p -r1.12 sg.c
--- drivers/scsi/sg.c	2001/11/09 23:36:24	1.12
+++ drivers/scsi/sg.c	2001/11/16 07:26:37
@@ -1544,7 +1544,9 @@ static int sg_build_dir(Sg_request * srp
 	num = (rem_sz > (PAGE_SIZE - offset)) ? (PAGE_SIZE - offset) :
 						rem_sz;
 	sclp->address = page_address(kp->maplist[k]) + offset;
+#ifdef CONFIG_HIGHMEM
 	sclp->page = NULL;
+#endif
 	sclp->length = num;
 	mem_src_arr[k] = SG_USER_MEM;
 	rem_sz -= num;
@@ -1631,7 +1633,9 @@ static int sg_build_indi(Sg_scatter_hold
                     break;
             }
             sclp->address = p;
+#ifdef CONFIG_HIGHMEM
 	    sclp->page = NULL;
+#endif
             sclp->length = ret_sz;
 	    mem_src_arr[k] = mem_src;
 
@@ -1789,7 +1793,9 @@ static void sg_remove_scat(Sg_scatter_ho
                        k, sclp->address, sclp->length, mem_src));
             sg_free(sclp->address, sclp->length, mem_src);
             sclp->address = NULL;
+#ifdef CONFIG_HIGHMEM
 	    sclp->page = NULL;
+#endif
             sclp->length = 0;
         }
 	sg_free(schp->buffer, schp->sglist_len, schp->buffer_mem_src);
Index: drivers/scsi/st.c
===================================================================
RCS file: /var/cvs/linux/drivers/scsi/st.c,v
retrieving revision 1.10
diff -u -p -r1.10 st.c
--- drivers/scsi/st.c	2001/11/09 23:36:24	1.10
+++ drivers/scsi/st.c	2001/11/16 07:26:39
@@ -3233,7 +3233,9 @@ static ST_buffer *
 				break;
 			}
 		}
+#ifdef CONFIG_HIGHMEM
 		tb->sg[0].page = NULL;
+#endif
 		if (tb->sg[segs].address == NULL) {
 			kfree(tb);
 			tb = NULL;
@@ -3265,7 +3267,9 @@ static ST_buffer *
 					tb = NULL;
 					break;
 				}
+#ifdef CONFIG_HIGHMEM
 				tb->sg[segs].page = NULL;
+#endif
 				tb->sg[segs].length = b_size;
 				got += b_size;
 				segs++;
@@ -3339,7 +3343,9 @@ static int enlarge_buffer(ST_buffer * ST
 			normalize_buffer(STbuffer);
 			return FALSE;
 		}
+#ifdef CONFIG_HIGHMEM
 		STbuffer->sg[segs].page = NULL;
+#endif
 		STbuffer->sg[segs].length = b_size;
 		STbuffer->sg_segs += 1;
 		got += b_size;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
