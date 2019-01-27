Return-Path: <SRS0=fDmo=QD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD709C282CB
	for <linux-mm@archiver.kernel.org>; Sun, 27 Jan 2019 16:32:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 687D8214C6
	for <linux-mm@archiver.kernel.org>; Sun, 27 Jan 2019 16:32:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pdCaRJSi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 687D8214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6B968E00FC; Sun, 27 Jan 2019 11:32:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1B7E8E00FB; Sun, 27 Jan 2019 11:32:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A31228E00FC; Sun, 27 Jan 2019 11:32:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31C018E00FB
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 11:32:04 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k22-v6so3998784ljk.12
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 08:32:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=TNuGZKsr/Se4zO4haJyYSCDu8sTtvIigBOVsFMaS83U=;
        b=V5qc9ZjORB8wtk12kYp6i8jKPImzWqWjJBjAP8Lyux+YrJAGK5SxeeOjo3j1Yi5+f/
         nMsm306ExPxsQPZuom7bUNhBZcB4branSsQ5PDNVGhRex3+SN6AU1iOz+/Zzw+d+VeW/
         F6SuyOX438XEAVNXOVnrGNu727EmrR+Vkyz2l8rXQKzSycXitbp89gT0+lLhXVFPiAVz
         Anw1MjN1vv53lhbFRoYpxOLYtAiFmiAS1sGQrtLEs6WNibAy/ScdAXflh+7WDtwlv+0h
         b5iSxgg5zByx+XEdEvHnysjIQBRzRBW02+/HbDqgdesquNsa9oMyuphfcOQHwfuHP4gr
         JjMQ==
X-Gm-Message-State: AJcUukc0Az0lAnY/mudMKnm83dQMPOsj5d1jS0gCSMhGDcYmtJrYJVxS
	/FWcQqITyj4dnOnrQijsk+Qc7uxILRLfnkOfnHqtT9zR5wFFUSSZOIuNEIN2mPhLgmfXyVVaeJx
	HYCe8SxFrKmBBfys5tGXDN0GNVYVxhhpnomyNI6V0EHkG+KR0EfWpoUO+5YZulO54/0cVJU0+rl
	KE5ZWNRIVTS+ijHM0O9m5XtDdIEp9CvjBij6wK+MHmnC4rYrgdVjfLXFRoQfyGmNbdGsRMDEwSh
	dpMlNzehtRHiU9KtVHgZyYZxIJ+WzEqIXrlCV4fec96pA3Fc4zEztbKSu9O64Pg1hYU8hvi9Vmw
	Or67IbfooFfPzLSGAXz1QCsNzbViLj3ohocOPQbL1bUyJG56DglYtLf52e5CRog3ZoVpzNHBF2V
	L
X-Received: by 2002:a19:d58e:: with SMTP id m136mr15009628lfg.70.1548606723196;
        Sun, 27 Jan 2019 08:32:03 -0800 (PST)
X-Received: by 2002:a19:d58e:: with SMTP id m136mr15009590lfg.70.1548606721920;
        Sun, 27 Jan 2019 08:32:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548606721; cv=none;
        d=google.com; s=arc-20160816;
        b=iwvdXZMZPk5hsvolGYcp/rR1ysvI2n438Tk1/EQxnhQA1JvOFxSRm/bsmHll+h8GFw
         7ajlul5oAUy8DLzCcIDhVdjzn+JRs8LYB6sUcYKl6k+mxnfc3DuMm9wvDs0/eoqC8Y3K
         XI4oXsdsxfybR1qJmUip0/vRLgReYzvbzKcqvRVV1C8rNECS+fkabLDnIsBhpx5cyfLw
         wJTJUASS3KJFdKpanRp/8voum0KCGy8tFFdTWGVeotX01EWveIvjcZYNlHS43pOp/hi7
         2VNdZrJZ+aXXEo0gdOkprC8AdOzeHy3qEqCwutlqH1SqwxNN8sS4i1bOW7Wloc7v531u
         +Obg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=TNuGZKsr/Se4zO4haJyYSCDu8sTtvIigBOVsFMaS83U=;
        b=WTs6CLhSEC30DVmRtRPpFCAp1awkRGFzAeIQ1DC803P5PoZfDEXnbNfCkryDoce7ti
         wArr1JsZ1wrdMqRsU0wpjdx3a4yuTvoBzAdjqz+QMIkGLqGoHAJmrBLv25Xz9Pu75OC+
         4QvPolJTNNaQufRR5IoLm/Cgflninre3q/QmxUeBrAWZhrqhGrV0DGKYYL0pjt4yacd1
         W5Nt1ZR9zwFyiwFJrcYrmLrqB/295f/giVZZJUTuUopXCuvQrlIbaru5M26PwSp6AG5N
         5su4RArNSlRlQJLMSqGT2pyc9zHskCVZl5khRqYGt7pjbsRDpgtxKIVPFmlCTKqBm1OR
         V/bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pdCaRJSi;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor9059489ljy.1.2019.01.27.08.32.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 Jan 2019 08:32:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pdCaRJSi;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=TNuGZKsr/Se4zO4haJyYSCDu8sTtvIigBOVsFMaS83U=;
        b=pdCaRJSia8DH9oSIN3SDMxF1xjzfXW5xVT//whl6ChyJ7hnqQdYLNq5CYvfcrQKVTZ
         IDD+LY6ZH0ZRF+BoLM5iRDuh0n2vQeczc7YBvBv+zOHLj19wrH05KalWqBet6FzZqexl
         spoeAbFK69P7/8qfvw1tQ0U8cSPZmV4bgfWUgLgW1GkQDOX4TjdkQxiBI6kRkxU/MAQs
         wNjzZRNdOv8IWMurMCVNqZwwL0O/xFNLq7DWD5RIvKRbVEF6ZOXbhvND9CeqzhEphXKt
         E3a1cCqUXWquXaNel4QAx4gLkXLUxdayXMf/16dinv1pFV5MKll+M0o5K5RoCxm8cXym
         JC1A==
X-Google-Smtp-Source: AHgI3IYTelA/mDwxgSI1nVtOZSWHPwvFkDv/ks1hHs3lsBty1vY7v0F3Hc/JzZMGIRV0Xo15bof1wCVBJdLMJHZvf3k=
X-Received: by 2002:a2e:5703:: with SMTP id l3-v6mr3295856ljb.106.1548606721227;
 Sun, 27 Jan 2019 08:32:01 -0800 (PST)
MIME-Version: 1.0
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
 <20190111151154.GA2819@jordon-HP-15-Notebook-PC> <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
 <CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com> <febb9775-20da-69d5-4f0e-cd87253eb8f9@samsung.com>
In-Reply-To: <febb9775-20da-69d5-4f0e-cd87253eb8f9@samsung.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 27 Jan 2019 22:01:52 +0530
Message-ID:
 <CAFqt6zazAymL69a6_JHF4SjHRC_NB8zSA=E-hC-dQ71hS9mKcA@mail.gmail.com>
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, pawel@osciak.com, 
	Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, linux-media@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190127163152.yIbWNT73jMsuytre3ghbxzfA_QIdIibfPclW4Snbo7c@z>

Hi Marek,

On Fri, Jan 25, 2019 at 5:58 PM Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
>
> Hi Souptick,
>
> On 2019-01-25 05:55, Souptick Joarder wrote:
> > On Tue, Jan 22, 2019 at 8:37 PM Marek Szyprowski
> > <m.szyprowski@samsung.com> wrote:
> >> On 2019-01-11 16:11, Souptick Joarder wrote:
> >>> Convert to use vm_insert_range_buggy to map range of kernel memory
> >>> to user vma.
> >>>
> >>> This driver has ignored vm_pgoff. We could later "fix" these drivers
> >>> to behave according to the normal vm_pgoff offsetting simply by
> >>> removing the _buggy suffix on the function name and if that causes
> >>> regressions, it gives us an easy way to revert.
> >> Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_p=
goff by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap a=
nd videobuf2-core already checks that. If userspace provides an offset, whi=
ch doesn't match any of the registered 'cookies' (reported to userspace via=
 separate v4l2 ioctl), an error is returned.
> > Ok, it means once the buf is selected, videobuf2-dma-sg should always
> > mapped buf->pages[i]
> > from index 0 ( irrespective of vm_pgoff value). So although we are
> > replacing the code with
> > vm_insert_range_buggy(), *_buggy* suffix will mislead others and
> > should not be used.
> > And if we replace this code with  vm_insert_range(), this will
> > introduce bug for *non zero*
> > value of vm_pgoff.
> >
> > Please correct me if my understanding is wrong.
>
> You are correct. IMHO the best solution in this case would be to add
> following fix:
>
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-core.c
> b/drivers/media/common/videobuf2/videobuf2-core.c
> index 70e8c3366f9c..ca4577a7d28a 100644
> --- a/drivers/media/common/videobuf2/videobuf2-core.c
> +++ b/drivers/media/common/videobuf2/videobuf2-core.c
> @@ -2175,6 +2175,13 @@ int vb2_mmap(struct vb2_queue *q, struct
> vm_area_struct *vma)
>          goto unlock;
>      }
>
> +    /*
> +     * vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
> +     * not as a in-buffer offset. We always want to mmap a whole buffer
> +     * from its beginning.
> +     */
> +    vma->vm_pgoff =3D 0;
> +
>      ret =3D call_memop(vb, mmap, vb->planes[plane].mem_priv, vma);
>
>  unlock:
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> index aff0ab7bf83d..46245c598a18 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> @@ -186,12 +186,6 @@ static int vb2_dc_mmap(void *buf_priv, struct
> vm_area_struct *vma)
>          return -EINVAL;
>      }
>
> -    /*
> -     * dma_mmap_* uses vm_pgoff as in-buffer offset, but we want to
> -     * map whole buffer
> -     */
> -    vma->vm_pgoff =3D 0;
> -
>      ret =3D dma_mmap_attrs(buf->dev, vma, buf->cookie,
>          buf->dma_addr, buf->size, buf->attrs);
>
> --
>
> Then you can simply use non-buggy version of your function in
> drivers/media/common/videobuf2/videobuf2-dma-sg.c.
>
> I can send above as a formal patch if you want.

Thanks for the patch.
I will fold this changes along with current patch in v2.

>
> > So what your opinion about this patch ? Shall I drop this patch from
> > current series ?
> > or,
> > There is any better way to handle this scenario ?
> >
> >
> >>> There is an existing bug inside gem_mmap_obj(), where user passed
> >>> length is not checked against buf->num_pages. For any value of
> >>> length > buf->num_pages it will end up overrun buf->pages[i],
> >>> which could lead to a potential bug.
> > It is not gem_mmap_obj(), it should be vb2_dma_sg_mmap().
> > Sorry about it.
> >
> > What about this issue ? Does it looks like a valid issue ?
>
> It is already handled in vb2_mmap(). Such call will be rejected.
>
>
> > ...
>
> Best regards
> --
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>

