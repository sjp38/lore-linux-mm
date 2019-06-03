Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80D4BC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 131F127041
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Y8xQhEUl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 131F127041
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B27DB6B0275; Mon,  3 Jun 2019 13:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB18E6B0276; Mon,  3 Jun 2019 13:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92A2E6B0278; Mon,  3 Jun 2019 13:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60CA46B0275
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:46:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id v58so8254310qta.2
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3YD9QwJxecxdMHZGSRuYOcVyiXHhODdQ+7hG9X3IFEc=;
        b=k0HDu2VCWY5R66yETIGGPg1lJnON14r4ahENBbFHRsmcZZdkrtrkEWuY7Y+NpX/YbL
         NKlwJp+n6NMrlKmf7eaVgSqwZBStqiXxpIGYvmpeh2JEeZVAmDgMIJWHg7nCLwUy+hur
         Lecarl7dEF5BF21oux4KItQo1qNkQyIEeEzCP2roqIGIEld/TrX2adY4qsRGNaKG62U0
         0oYHg7Q/dy0elL4hFFTC2Hw5R+2Ods1tyit2IL4hNJM7jpe0Z8Hbw/0zmHniYXLFUo1h
         xRARQH0QkbfHP+H7bqaFiiUqSzShALoi+HBig6kdmthAD0O5T+O9jVQ+ZGX2+L0oPCyY
         AksA==
X-Gm-Message-State: APjAAAUUcgkkaqr1kiqZVh1e81mysoAKUNzQlDLmwA9HdJg4yD33JSqR
	VkUxgno1QUv9c/A5iBKwvZ2ApSrK3MeiVQhuB8R3ei1sGHnctaqzRrZqNDfcMrHfaFUb1jpVgw7
	lBNHKsT1AjkqBQS0XNGzpY91d4AeiwFykul65CmKbYnUd0QFMY/RoKfrp+fBTS9ORZg==
X-Received: by 2002:ae9:ec06:: with SMTP id h6mr23404584qkg.42.1559583981989;
        Mon, 03 Jun 2019 10:46:21 -0700 (PDT)
X-Received: by 2002:ae9:ec06:: with SMTP id h6mr23404529qkg.42.1559583981081;
        Mon, 03 Jun 2019 10:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559583981; cv=none;
        d=google.com; s=arc-20160816;
        b=AHdgAhO4lxXKm5y1YXbJ4unx52kb0n6ib788boQdNwI95aESNcp8mG8tjxYC2554ex
         T13amo8XI/Utw0skgCDpqCnFuB3bqYztsM85wEHavXwxerJpFiuO4KnLxU+WVxrbdtpA
         B5b1LizyGbcDdzKxP4DGR1UdGeR2gjRvpdmj6bfFAGTrRDa05IexR5fca3k+1wapMrdx
         ga5qAWBgPHQxGQgfCSrsV5kiDh2V9IF0YjAttOTBE9IvgLeD3uY9jt1sQyEfBIWJO+sS
         3+C8GpYf57VcyN6wOn8aLHZR1ZYawv8mdwOLqcUBr324MGj7fDmK1ZCwv83973UBJosU
         NKQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3YD9QwJxecxdMHZGSRuYOcVyiXHhODdQ+7hG9X3IFEc=;
        b=sx+V8SA5+rUjd7gUtRqPAZaZk5uzhJWYZjsJ8zxDf5xo69g1vJDU0eaCsezaAC63F8
         3as1NPmVd1XO8ij5gp4UgegXBfRteYkIy+zmQXLPtwIH5XZ9FaEkSnc22JSEkkaxysZ2
         9bH+Z8rQtLa1cvMvn/RdrnnrqdEoeV8363UuDrJTfU8K2aB7j0XuIXK5KAH8RN9gidG+
         8UAuUvwk5+HlDHuIbbWn0Y9P/x/HbCqLeyxPf3fQo9hkcIc54i+nbcPe1vC1aZC6DRJA
         PC7MjLqVoZVS2aH7urehm0JoOpR+sxTKwneHtSYHuKiKWZI8eypiG2n2DqhKpuymKLaT
         JZ3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Y8xQhEUl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r47sor2943301qtc.0.2019.06.03.10.46.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:46:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Y8xQhEUl;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3YD9QwJxecxdMHZGSRuYOcVyiXHhODdQ+7hG9X3IFEc=;
        b=Y8xQhEUl5VIp1CHI2GNhUWumFeridnSrDVLR4ophf+TEEqb9RYCBYUuzTaKnpS0N95
         PodsZw5QrRzXwcVAdLU8QbPx8UtppQyKINjpafz63KgI0mbZL1RBR/HG+Aw16qS1mL8x
         GbfoGarwImiN/E4mJOvSlkb1cLIeV/RY7kSfMlxm7UZhj+NafqRJ9xFMGOVfHXfBQNL8
         3KhvQIu3nzrYZ9gVumHcKZbTTOBDGZbVoC0PmchuHZfBO5itRE+CWVGivs8JV9Bdb68S
         oKMm5wdMIjQdNVuG5jJ5CkpKuMh+/TZa/xggfv/76T6HlvfgScQBIZzwwZTZ5LwtflBg
         nfEg==
X-Google-Smtp-Source: APXvYqx+ClbIfZmOUdY0b04TFbjW+3r9mnjIe7N0zaIfZmDOHWubw4QUOroagi67b9WugppzpkzydA==
X-Received: by 2002:ac8:7381:: with SMTP id t1mr24802701qtp.387.1559583980558;
        Mon, 03 Jun 2019 10:46:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m40sm12874710qtm.2.2019.06.03.10.46.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 10:46:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hXr2J-00032t-AT; Mon, 03 Jun 2019 14:46:19 -0300
Date: Mon, 3 Jun 2019 14:46:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in
 ib_uverbs_(re)reg_mr()
Message-ID: <20190603174619.GC11474@ziepe.ca>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> 
> Untag user pointers in these functions.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> index 5a3a1780ceea..f88ee733e617 100644
> +++ b/drivers/infiniband/core/uverbs_cmd.c
> @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
>  	if (ret)
>  		return ret;
>  
> +	cmd.start = untagged_addr(cmd.start);
> +
>  	if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
>  		return -EINVAL;

I feel like we shouldn't thave to do this here, surely the cmd.start
should flow unmodified to get_user_pages, and gup should untag it?

ie, this sort of direction for the IB code (this would be a giant
patch, so I didn't have time to write it all, but I think it is much
saner):

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 54628ef879f0ce..7b3b736c87c253 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -193,7 +193,7 @@ EXPORT_SYMBOL(ib_umem_find_best_pgsz);
  * @access: IB_ACCESS_xxx flags for memory being pinned
  * @dmasync: flush in-flight DMA when the memory region is written
  */
-struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
+struct ib_umem *ib_umem_get(struct ib_udata *udata, void __user *addr,
 			    size_t size, int access, int dmasync)
 {
 	struct ib_ucontext *context;
@@ -201,7 +201,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 	struct page **page_list;
 	unsigned long lock_limit;
 	unsigned long new_pinned;
-	unsigned long cur_base;
+	void __user *cur_base;
 	struct mm_struct *mm;
 	unsigned long npages;
 	int ret;
diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 5a3a1780ceea4d..94389e7f12371f 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -735,7 +735,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
 		}
 	}
 
-	mr = pd->device->ops.reg_user_mr(pd, cmd.start, cmd.length, cmd.hca_va,
+	mr = pd->device->ops.reg_user_mr(pd, u64_to_user_ptr(cmd.start),
+					 cmd.length, cmd.hca_va,
 					 cmd.access_flags,
 					 &attrs->driver_udata);
 	if (IS_ERR(mr)) {
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 4d033796dcfcc2..bddbb952082fc5 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -786,7 +786,7 @@ static int mr_cache_max_order(struct mlx5_ib_dev *dev)
 }
 
 static int mr_umem_get(struct mlx5_ib_dev *dev, struct ib_udata *udata,
-		       u64 start, u64 length, int access_flags,
+		       void __user *start, u64 length, int access_flags,
 		       struct ib_umem **umem, int *npages, int *page_shift,
 		       int *ncont, int *order)
 {
@@ -1262,8 +1262,8 @@ struct ib_mr *mlx5_ib_reg_dm_mr(struct ib_pd *pd, struct ib_dm *dm,
 				 attr->access_flags, mode);
 }
 
-struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
-				  u64 virt_addr, int access_flags,
+struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, void __user *start,
+				  u64 length, u64 virt_addr, int access_flags,
 				  struct ib_udata *udata)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ec6446864b08e9..b3c8eaaa35c760 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2464,8 +2464,8 @@ struct ib_device_ops {
 	struct ib_mr *(*reg_user_mr)(struct ib_pd *pd, u64 start, u64 length,
 				     u64 virt_addr, int mr_access_flags,
 				     struct ib_udata *udata);
-	int (*rereg_user_mr)(struct ib_mr *mr, int flags, u64 start, u64 length,
-			     u64 virt_addr, int mr_access_flags,
+	int (*rereg_user_mr)(struct ib_mr *mr, int flags, void __user *start,
+			     u64 length, u64 virt_addr, int mr_access_flags,
 			     struct ib_pd *pd, struct ib_udata *udata);
 	int (*dereg_mr)(struct ib_mr *mr, struct ib_udata *udata);
 	struct ib_mr *(*alloc_mr)(struct ib_pd *pd, enum ib_mr_type mr_type,

