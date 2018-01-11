Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id E96D76B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:06:47 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i35so1229743ote.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 03:06:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o187si1319149oia.533.2018.01.11.03.06.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 03:06:46 -0800 (PST)
Subject: Re: [PATCH v21 2/5 RESEND] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1515501687-7874-1-git-send-email-wei.w.wang@intel.com>
	<201801092342.FCH56215.LJHOMVFFFOOSQt@I-love.SAKURA.ne.jp>
	<5A55EA71.6020309@intel.com>
In-Reply-To: <5A55EA71.6020309@intel.com>
Message-Id: <201801112006.EHD48461.LOtVFFSOJMOFHQ@I-love.SAKURA.ne.jp>
Date: Thu, 11 Jan 2018 20:06:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> Michael, could we merge patch 3-5 first?

No! I'm repeatedly asking you to propose only VIRTIO_BALLOON_F_SG changes.
Please don't ignore me.



Patch 4 depends on patch 2. Thus, back to patch 2.

Your patch is trying to switch tell_host_sgs() and tell_host() based on
VIRTIO_BALLOON_F_SG.

----------------------------------------
+	if (vb->num_pfns) {
+		if (use_sg)
+			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);
+		else
+			tell_host(vb, vb->inflate_vq);
+	}
----------------------------------------

tell_host() uses sg_init_one()/virtqueue_add_outbuf() sequence for
telling to the host

----------------------------------------
static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
{
	struct scatterlist sg;
	unsigned int len;

	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);

	/* We should always be able to add one buffer to an empty queue. */
	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
	virtqueue_kick(vq);

	/* When host has read buffer, this completes via balloon_ack */
	wait_event(vb->acked, virtqueue_get_buf(vq, &len));

}
----------------------------------------

while add_one_sg() from batch_balloon_page_sg() from tell_host_sgs() uses
sg_init_one()/virtqueue_add_inbuf() sequence for telling to the host.
Why the direction becomes opposite (inbuf versus outbuf) ?

----------------------------------------
+static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
+{
+	unsigned int len;
+
+	virtqueue_kick(vq);
+	wait_event(wq_head, virtqueue_get_buf(vq, &len));
+}
+
+static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
+{
+	struct scatterlist sg;
+	unsigned int unused;
+	int err;
+
+	sg_init_table(&sg, 1);
+	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
+	/*
+	 * This is expected to never fail: there is always at least 1 entry
+	 * available on the vq, because when the vq is full the worker thread
+	 * that adds the sg will be put into sleep until at least 1 entry is
+	 * available to use.
+	 */
+	BUG_ON(err);
+}
+
+static void batch_balloon_page_sg(struct virtio_balloon *vb,
+				  struct virtqueue *vq,
+				  unsigned long pfn,
+				  uint32_t len)
+{
+	add_one_sg(vq, pfn, len);
+
+	/* Batch till the vq is full */
+	if (!vq->num_free)
+		kick_and_wait(vq, vb->acked);
+}
+
+/*
+ * Send balloon pages in sgs to host. The balloon pages are recorded in the
+ * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
+ * The page xbitmap is searched for continuous "1" bits, which correspond
+ * to continuous pages, to chunk into sgs.
+ *
+ * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
+ * need to be searched.
+ */
+static void tell_host_sgs(struct virtio_balloon *vb,
+			  struct virtqueue *vq,
+			  unsigned long page_xb_start,
+			  unsigned long page_xb_end)
+{
+	unsigned long pfn_start, pfn_end;
+	uint32_t max_len = round_down(UINT_MAX, PAGE_SIZE);
+	uint64_t len;
+
+	pfn_start = page_xb_start;
+	while (pfn_start < page_xb_end) {
+		if (!xb_find_set(&vb->page_xb, page_xb_end, &pfn_start))
+			break;
+		pfn_end = pfn_start + 1;
+		if (!xb_find_zero(&vb->page_xb, page_xb_end, &pfn_end))
+			pfn_end = page_xb_end + 1;
+		len = (pfn_end - pfn_start) << PAGE_SHIFT;
+		while (len > max_len) {
+			batch_balloon_page_sg(vb, vq, pfn_start, max_len);
+			pfn_start += max_len >> PAGE_SHIFT;
+			len -= max_len;
+		}
+		batch_balloon_page_sg(vb, vq, pfn_start, (uint32_t)len);
+		pfn_start = pfn_end + 1;
+	}
+
+	/*
+	 * The last few sgs may not reach the batch size, but need a kick to
+	 * notify the device to handle them.
+	 */
+	if (vq->num_free != virtqueue_get_vring_size(vq))
+		kick_and_wait(vq, vb->acked);
+
+	xb_zero(&vb->page_xb, page_xb_start, page_xb_end);
+}
----------------------------------------

Where does inefficiency of !VIRTIO_BALLOON_F_SG path come from?
Does it come from the limitation that tell_host() has to call wait_event()
for every 256 pages?

Is the value 256 required by the communication protocol? If no, why can't we use
larger values? If yes, is the sg_init_one()/virtqueue_add_outbuf()/virtqueue_kick(vq)/wait_event()
sequence required by the communication protocol?

If no, why can't we call sg_init_one()/virtqueue_add_outbuf() sequence for N times and
call kick_and_wait() only when vq->num_free == 0 or reached the last page?

Even if the sg_init_one()/virtqueue_add_outbuf()/virtqueue_kick(vq)/wait_event()
sequence is required by the communication protocol, we can consider introducing
(sg_init_one()/virtqueue_add_outbuf()) * N + kick_and_wait() sequence instead of
VIRTIO_BALLOON_F_SG flag. Then, we don't need patch 1 which needs to worry about
memory allocation failure cases.

> The implementation of the previous virtio-balloon is not very efficient,
> because the balloon pages are transferred to the host by one array each
> time. Here is the breakdown of the time in percentage spent on each step
> of the balloon inflating process (inflating 7GB of an 8GB idle guest).
> 
> 1) allocating pages (6.5%)
> 2) sending PFNs to host (68.3%)
> 3) address translation (6.1%)
> 4) madvise (19%)
> 
> It takes about 4126ms for the inflating process to complete. The above
> profiling shows that the bottlenecks are stage 2) and stage 4).
> 
> This patch optimizes step 2) by transferring pages to host in sgs. An sg
> describes a chunk of guest physically continuous pages. With this
> mechanism, step 4) can also be optimized by doing address translation and
> madvise() in chunks rather than page by page.

Who does 4) ? The host's kernel code? The host's hypervisor code (i.e. QEMU)?
The guest's kernel code? The guest's userspace code? If it is not the kernel
code, sorting PFNs in userspace will be very efficient.



Now, proceeding to patch 4.

Your patch is trying to call add_one_sg() for multiple times based on

----------------------------------------
+	/*
+	 * This is expected to never fail: there is always at least 1 entry
+	 * available on the vq, because when the vq is full the worker thread
+	 * that adds the sg will be put into sleep until at least 1 entry is
+	 * available to use.
+	 */
+	BUG_ON(err);
----------------------------------------

assumption holds. But why can such assumption hold true?
This add_one_sg() is called from batch_free_page_sg() as the callback of

----------------------------------------
+	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
----------------------------------------

call. But if you see patch 3, the callback function is called with irq disabled.
That is, the comment

----------------------------------------
+ * The callback itself must not sleep or perform any operations which would
+ * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
+ * or via any lock dependency. It is generally advisable to implement
+ * the callback as simple as possible and defer any heavy lifting to a
+ * different context.
----------------------------------------

in patch 3 is ignored in patch 4. This add_one_sg() assumes that there is always
at least 1 entry available on the vq. But if the vq is full, batch_free_page_sg()
cannot sleep because walk_free_page_list() disabled irq before calling
batch_free_page_sg().

----------------------------------------
+static void batch_free_page_sg(struct virtqueue *vq,
+			       unsigned long pfn,
+			       uint32_t len)
+{
+	add_one_sg(vq, pfn, len);
+
+	/* Batch till the vq is full */
+	if (!vq->num_free)
+		virtqueue_kick(vq);
+}
----------------------------------------

Thus, the assumption patch 4 depends on cannot hold true. What the callback
can do is to just copy snapshot of free memory blocks to some buffer; you
need to defer sending that buffer to the host.



Now, I suspect we need to add VIRTIO_BALLOON_F_FREE_PAGE_VQ flag. I want to see
the patch for the hypervisor side which makes use of VIRTIO_BALLOON_F_FREE_PAGE_VQ
flag because its usage becomes tricky. Between the guest kernel obtains snapshot of
free memory blocks and the hypervisor is told that some pages are currently free,
these pages can become in use. That is, I don't think

  The second feature enables the optimization of the 1st round memory
  transfer - the hypervisor can skip the transfer of guest free pages in the
  1st round.

is accurate. The hypervisor is allowed to mark pages which are told as "currently
unused" by the guest kernel as "write-protected" before starting the 1st round.
Then, the hypervisor performs copying all pages except write-protected pages as
the 1st round. Then, the 2nd and later rounds will be the same. That is,
VIRTIO_BALLOON_F_FREE_PAGE_VQ requires the hypervisor to do 0th round as
preparation. Thus, I want to see the patch for the hypervisor side.

Now, what if all free pages in the guest kernel were reserved as ballooned pages?
There will be no free pages which VIRTIO_BALLOON_F_FREE_PAGE_VQ flag would help.
The hypervisor will have to copy all pages because all pages are either currently
in-use or currently in balloons. After ballooning to appropriate size, there will
be little free memory in the guest kernel, and the hypervisor already knows which
pages are in the balloon. Thus, the hypervisor can skip copying the content of
pages in the balloon, without using VIRTIO_BALLOON_F_FREE_PAGE_VQ flag.

Then, why can't we do "inflate the balloon up to reasonable level (e.g. no need to
wait for reclaim and no need to deflate)" instead of "find all the free pages as of
specific moment" ? That is, code for VIRTIO_BALLOON_F_DEFLATE_ON_OOM could be reused
instead of VIRTIO_BALLOON_F_FREE_PAGE_VQ ?



> You are also welcome to send a patch to remove the redundant one if you 
> think that's an issue. Thanks.

Hint 1: Check possible -EXXX values the xbitmap API can return.

Hint 2: Prepare for the worst case where ballooning can allocate no memory for SG.

Note that I can't write a patch because I can't test the patch because I don't
have the patch for the hypervisor side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
