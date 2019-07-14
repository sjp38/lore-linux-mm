Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EAADC73C66
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D1B620C01
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:33:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="r1gPsCog"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D1B620C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF75D6B0003; Sun, 14 Jul 2019 19:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA8C26B0006; Sun, 14 Jul 2019 19:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 971716B0007; Sun, 14 Jul 2019 19:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 739686B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:33:47 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i63so12648708ywc.1
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 16:33:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=sUtQbAVHKMUq6RFPtKou/JVDvKaLNXmga3Yy3wKxfoA=;
        b=ZyOnt4OBldBLM9yTCHvxxMvNzCFE7D/ihKY9f0ZR9j7DxhCe+ZcFggJ7wABYvsclQB
         lNdsqptQ69+UZ7JzrK2U2ObHHLV0aLt2/NTIJF4Y5omEfVb/iXop1+Xn+zFtTPyVEEMc
         8hSU7yCbbXcrQoLNPNgrHseEFab0BlksmHgX7f7OIhRlJOLcnRF04VrhIDqS3xKQAHD3
         Bs/qXseoVYv5hrw19sKr9GArTpOOufjuUEl5oORfkURhK5mdWvvl0tbvxJ3gwif+6l5V
         IGi/BHh6nzHYZ81FrtvKNv1tyzFfdD0SFwfw3HClElVrx79gsF+3A1H3msZhJWVHLoAm
         rAHw==
X-Gm-Message-State: APjAAAUFcvdYXleS+yasPTCeLDxp8Lbf959VYPH2ptV403MxgIoc4s4k
	EeiYNgh+sbKHuJWeh5CPaZrIyXjTm6QBTcyb/LjByQxPw+kljsm2295RJQ+yEkT5GdZWE/3zWr2
	JWIs7t9t3lZu6/4bHdGi6JBBh60RfhxLNNd8GrHhhTA3/whPoSCrCFPR9+Y7uUspudw==
X-Received: by 2002:a25:8b01:: with SMTP id i1mr194606ybl.478.1563147227092;
        Sun, 14 Jul 2019 16:33:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzC4wqFbUM4U35DtPa+g4hLmLwKYChKxbJfpPfQ+uE8PtNpkluxFFFoUb20O+MyfG9sAj9
X-Received: by 2002:a25:8b01:: with SMTP id i1mr194562ybl.478.1563147225706;
        Sun, 14 Jul 2019 16:33:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563147225; cv=none;
        d=google.com; s=arc-20160816;
        b=WQt7DKma60CKtJAPXykM/Fw3umWt5a0uEv915PqiWfDp8e0DYfyFCmoSKscG44Oydy
         R3HmBaIOf3o8dhDTBJP/o2hJuJiIwVv4WtzGC//POAT9BLSj0x2rWbqKCkFFLRIA2IyN
         uA4Oa7maAYMiYRNug5ZptdLRi9Jjf7qi6Sufd3qMpLzXZ6wQ2R6v+9kwnL8J8n8KXeT+
         BSW6UKm2VSHMSLZGUEOIuXqjgmx76y5mqtwRBFwZsAco0i4uxHykBR7QBnX8gL4xr44C
         IdhuWJJiF23nUpe2iGcVFB/jRVl+PaDkb/5k7WqpiSkND6jzUMUgTupkCj5BDAj1f5Bv
         4b2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=sUtQbAVHKMUq6RFPtKou/JVDvKaLNXmga3Yy3wKxfoA=;
        b=qZq42ZBdZMkE1uGhkF8PatLTQQ/lSfJk81PhQ+q+EA7Cp4fvbBV/gyCMuQ8jXtANeO
         KakHiHMUGW5ycHdD1yvbpvkJKVNe8POzjp0uyGCCF1azwCM6CKSfztzfTfbSUnIAPmUP
         D6S8X5naHgtplUmnWbpAEIKq2hextkqGR0bCQ0UfD4qZ4h0hAwbkQMUzNAVzdVGSdbrD
         Cfjkc6olUvpQsIoA6cuvhOerjcPwsmP4UgPJ8Mg0E35K8cQ5Hz8Vrr1hzPxmrcHBCLNg
         JvcfXrGY0L8fAzXaXci+fYLUOBjrtPIt5tSjzA8DDTG/Yo+ibnwKKsz7VbowwXRcNofp
         K4Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=r1gPsCog;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r76si6003450ywg.331.2019.07.14.16.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 16:33:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=r1gPsCog;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2bbbde0000>; Sun, 14 Jul 2019 16:33:50 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Sun, 14 Jul 2019 16:33:44 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Sun, 14 Jul 2019 16:33:44 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sun, 14 Jul
 2019 23:33:43 +0000
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>, <akpm@linux-foundation.org>,
	<ira.weiny@intel.com>
CC: Mauro Carvalho Chehab <mchehab@kernel.org>, Dimitri Sivanich
	<sivanich@sgi.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>, Jens Axboe <axboe@kernel.dk>, Alexander
 Viro <viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
	<bjorn.topel@intel.com>, Magnus Karlsson <magnus.karlsson@intel.com>, "David
 S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, Daniel
 Borkmann <daniel@iogearbox.net>, Jakub Kicinski
	<jakub.kicinski@netronome.com>, Jesper Dangaard Brouer <hawk@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>, Enrico Weigelt <info@metux.net>,
	Thomas Gleixner <tglx@linutronix.de>, Alexios Zavras
	<alexios.zavras@intel.com>, Dan Carpenter <dan.carpenter@oracle.com>, Max
 Filippov <jcmvbkbc@gmail.com>, Matt Sickler <Matt.Sickler@daktronics.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Keith Busch
	<keith.busch@intel.com>, YueHaibing <yuehaibing@huawei.com>,
	<linux-media@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devel@driverdev.osuosl.org>, <kvm@vger.kernel.org>,
	<linux-block@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, <netdev@vger.kernel.org>, <bpf@vger.kernel.org>,
	<xdp-newbies@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <deea584f-2da2-8e1f-5a07-e97bf32c63bb@nvidia.com>
Date: Sun, 14 Jul 2019 16:33:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563147230; bh=sUtQbAVHKMUq6RFPtKou/JVDvKaLNXmga3Yy3wKxfoA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=r1gPsCog8Wy8uxXR6oPi9CZ88dx7g7L7elOSl44oNIP1rI4/lkKGF9dnlvvfdYA/b
	 O8GUFPF84ojdVeX8QMV3hJ8+zgk4tR88myJZyetUbYd9bq60hfbfXeF0iJlYAVkubx
	 JOoXVe/7uD2/55/W/MIxdUvILTPB1/5/S5oSyd5brPO5Z4/Keu0Xvr8jrmH/IiEYoP
	 +AIIsSoV1pBraQcZgi5+ULXONecHESIQmh/9tZbs/C10RJWwUL5/YKXsdU8Sk8oBdA
	 NOeOi2iHzHVNK0AKkN3agfSzKCXeIFIHG7vkyBUlPLmDEWfEvazCokcgH4rg3HIpDk
	 byWb1Hr99HYHA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/14/19 12:08 PM, Bharath Vedartham wrote:
> This patch converts all call sites of get_user_pages
> to use put_user_page*() instead of put_page*() functions to
> release reference to gup pinned pages.

Hi Bharath,

Thanks for jumping in to help, and welcome to the party!

You've caught everyone in the middle of a merge window, btw.  As a
result, I'm busy rebasing and reworking the get_user_pages call sites, 
and gup tracking, in the wake of some semi-traumatic changes to bio 
and gup and such. I plan to re-post right after 5.3-rc1 shows up, from 
here:

    https://github.com/johnhubbard/linux/commits/gup_dma_core

...which you'll find already covers the changes you've posted, except for:

    drivers/misc/sgi-gru/grufault.c
    drivers/staging/kpc2000/kpc_dma/fileops.c

...and this one, which is undergoing to larger local changes, due to
bvec, so let's leave it out of the choices:

    fs/io_uring.c

Therefore, until -rc1, if you'd like to help, I'd recommend one or more
of the following ideas:

1. Pull down https://github.com/johnhubbard/linux/commits/gup_dma_core
and find missing conversions: look for any additional missing 
get_user_pages/put_page conversions. You've already found a couple missing 
ones. I haven't re-run a search in a long time, so there's probably even more.

	a) And find more, after I rebase to 5.3-rc1: people probably are adding
	get_user_pages() calls as we speak. :)

2. Patches: Focus on just one subsystem at a time, and perfect the patch for
it. For example, I think this the staging driver would be perfect to start with:

    drivers/staging/kpc2000/kpc_dma/fileops.c

	a) verify that you've really, corrected converted the whole
	driver. (Hint: I think you might be overlooking a put_page call.)

	b) Attempt to test it if you can (I'm being hypocritical in
	the extreme here, but one of my problems is that testing
	has been light, so any help is very valuable). qemu...?
	OTOH, maybe even qemu cannot easily test a kpc2000, but
	perhaps `git blame` and talking to the authors would help
	figure out a way to validate the changes.

	Thinking about whether you can run a test that would prove or
	disprove my claim in (a), above, could be useful in coming up
	with tests to run.

In other words, a few very high quality conversions (even just one) that
we can really put our faith in, is what I value most here. Tested patches
are awesome.

3. Once I re-post, turn on the new CONFIG_DEBUG_GET_USER_PAGES_REFERENCES
and run things such as xfstest/fstest. (Again, doing so would be going
further than I have yet--very helpful). Help clarify what conversions have
actually been tested and work, and which ones remain unvalidated.

Other: Please note that this:

    https://github.com/johnhubbard/linux/commits/gup_dma_core

    a) gets rebased often, and

    b) has a bunch of commits (iov_iter and related) that conflict
       with the latest linux.git,

    c) has some bugs in the bio area, that I'm fixing, so I don't trust
       that's it's safely runnable, for a few more days.

One note below, for the future:

> 
> This is a bunch of trivial conversions which is a part of an effort
> by John Hubbard to solve issues with gup pinned pages and 
> filesystem writeback.
> 
> The issue is more clearly described in John Hubbard's patch[1] where
> put_user_page*() functions are introduced.
> 
> Currently put_user_page*() simply does put_page but future implementations
> look to change that once treewide change of put_page callsites to 
> put_user_page*() is finished.
> 
> The lwn article describing the issue with gup pinned pages and filesystem 
> writeback [2].
> 
> This patch has been tested by building and booting the kernel as I don't
> have the required hardware to test the device drivers.
> 
> I did not modify gpu/drm drivers which use release_pages instead of
> put_page() to release reference of gup pinned pages as I am not clear
> whether release_pages and put_page are interchangable. 
> 
> [1] https://lkml.org/lkml/2019/3/26/1396

When referring to patches in a commit description, please use the 
commit hash, not an external link. See Submitting Patches [1] for details.

Also, once you figure out the right maintainers and other involved people,
putting Cc: in the commit description is common practice, too.

[1] https://www.kernel.org/doc/html/latest/process/submitting-patches.html

thanks,
-- 
John Hubbard
NVIDIA

> 
> [2] https://lwn.net/Articles/784574/
> 
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/media/v4l2-core/videobuf-dma-sg.c | 3 +--
>  drivers/misc/sgi-gru/grufault.c           | 2 +-
>  drivers/staging/kpc2000/kpc_dma/fileops.c | 4 +---
>  drivers/vfio/vfio_iommu_type1.c           | 2 +-
>  fs/io_uring.c                             | 7 +++----
>  mm/gup_benchmark.c                        | 6 +-----
>  net/xdp/xdp_umem.c                        | 7 +------
>  7 files changed, 9 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
> index 66a6c6c..d6eeb43 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-sg.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
> @@ -349,8 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
>  	BUG_ON(dma->sglen);
>  
>  	if (dma->pages) {
> -		for (i = 0; i < dma->nr_pages; i++)
> -			put_page(dma->pages[i]);
> +		put_user_pages(dma->pages, dma->nr_pages);
>  		kfree(dma->pages);
>  		dma->pages = NULL;
>  	}
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
> index 4b713a8..61b3447 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
>  		return -EFAULT;
>  	*paddr = page_to_phys(page);
> -	put_page(page);
> +	put_user_page(page);
>  	return 0;
>  }
>  
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> index 6166587..26dceed 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
>  	sg_free_table(&acd->sgt);
>   err_dma_map_sg:
>   err_alloc_sg_table:
> -	for (i = 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>   err_get_user_pages:
>  	kfree(acd->user_pages);
>   err_alloc_userpages:
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index add34ad..c491524 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -369,7 +369,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
>  		 */
>  		if (ret > 0 && vma_is_fsdax(vmas[0])) {
>  			ret = -EOPNOTSUPP;
> -			put_page(page[0]);
> +			put_user_page(page[0]);
>  		}
>  	}
>  	up_read(&mm->mmap_sem);
> diff --git a/fs/io_uring.c b/fs/io_uring.c
> index 4ef62a4..b4a4549 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -2694,10 +2694,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
>  			 * if we did partial map, or found file backed vmas,
>  			 * release any pages we did get
>  			 */
> -			if (pret > 0) {
> -				for (j = 0; j < pret; j++)
> -					put_page(pages[j]);
> -			}
> +			if (pret > 0)
> +				put_user_pages(pages, pret);
> +
>  			if (ctx->account_mem)
>  				io_unaccount_mem(ctx->user, nr_pages);
>  			kvfree(imu->bvec);
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index 7dd602d..15fc7a2 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -76,11 +76,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
>  	gup->size = addr - gup->addr;
>  
>  	start_time = ktime_get();
> -	for (i = 0; i < nr_pages; i++) {
> -		if (!pages[i])
> -			break;
> -		put_page(pages[i]);
> -	}
> +	put_user_pages(pages, nr_pages);
>  	end_time = ktime_get();
>  	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
>  
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 9c6de4f..6103e19 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -173,12 +173,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>  {
>  	unsigned int i;
>  
> -	for (i = 0; i < umem->npgs; i++) {
> -		struct page *page = umem->pgs[i];
> -
> -		set_page_dirty_lock(page);
> -		put_page(page);
> -	}
> +	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
>  
>  	kfree(umem->pgs);
>  	umem->pgs = NULL;
> 

