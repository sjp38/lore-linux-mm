Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F22EC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01DB520880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:13:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="L5AGm8q5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01DB520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65D876B000D; Mon,  1 Apr 2019 12:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E99E6B000E; Mon,  1 Apr 2019 12:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B03E6B0010; Mon,  1 Apr 2019 12:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABAD6B000D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:13:33 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so7206896pfi.20
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:13:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wXhFvQZq2CM4UVq0M+sbdzQ2JEvBc81wcurHCGB2kdY=;
        b=PmNDrqQuvWlxQIr024ZJSoYuKC4Ay2z9Mq6WhQ8zX6/3Vqaw3Z3kKacWU6i+Hb3VI7
         Vatf90d6SC1ssxnDJqohNab8tKzFRiA9zwx2AwgJx6hrubfGCFapehZakdZBU8IiUpxb
         eSQm2lADqn6D0kLuTjfTpT1/kneTRS97Hq7f4tbuQ/8EDhQGApPUTy1Acf/CLHYIPmH/
         01M4Ry8t3cs5HeCzVC8XYV8BbodcroQpCsvcTME4CdKOhn6BUPO0uN8hYUxTsmT7kGD7
         mpSwulIm2nblKHVg24wo/As5A8qJAiaDrPycZmb5nfs7rH7Psndyml7bNRD5gLWYoE+h
         CayA==
X-Gm-Message-State: APjAAAXuLThSwqlffTcKwvBhzPEM+nTfmOPclhYZ09Iy0y0ehfFVhCqJ
	Ygg4f/m6Ax9DKOVx/Fue9XpY734tNNqXxLZsciU5D1lBv5c+vsIfRynacyxtTnztssnWD7BzKUl
	c8xRNJ5AfnPjQd79DO6ibWkvREci7y37PGWU2B4Gkq4LdjxYWmRqW1PhJGux8iWD3Sg==
X-Received: by 2002:a63:1203:: with SMTP id h3mr28737327pgl.164.1554135212582;
        Mon, 01 Apr 2019 09:13:32 -0700 (PDT)
X-Received: by 2002:a63:1203:: with SMTP id h3mr28737247pgl.164.1554135211787;
        Mon, 01 Apr 2019 09:13:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554135211; cv=none;
        d=google.com; s=arc-20160816;
        b=tSuSko4gsxBWvXpZVJAshYYyuOIIjO+RPb6XZHdxCQMVPQhg9mLrsymRDci+t6R36q
         duEoxEN4v7kzOuDpFY3GgLcoY5oS2kV2LdU6BpEkTnHkDrLwrm7G551SD0ONIYchEc2+
         pwlBmNM0uCcJaLV9amxVa7SymnJGVpgsDtD1jpsMMIRjAi/fl9v03BMT5JaiYp7ep6Yv
         S4rHrvz/26BVkdK/CksEjO/eDZSyT4LIAsZoYaXTZ6kOehj0KYtwS9+AqcpMcHT4Zg4+
         aR3T9TYhrrzLNbOj7eUTHDBj15ujocFK2LVdq6amZW+wN5XVaMentfjN8RQuNKIFkcUG
         A+/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wXhFvQZq2CM4UVq0M+sbdzQ2JEvBc81wcurHCGB2kdY=;
        b=PWiv0MpLDziIR3N6+3UVOg6/SGNpnVCD0IfEsXcRfCqjRu9PN7R93qPiQQnkGnrJ3J
         98BT4ZnYHMTy5vRfmuz93QYQPyW0Cbe2xkjES3oT+T5ZLWD1YTc7h00nl8gYAW8PNABp
         ULJVEMh4V9LrrbtMS8zMn3xDLDS2ctIA+EG3EvSX6QQGz5x2pO0LVSpY/MZsvCwCVMOt
         CiCYuWzs7kdJxnpRUI2R7W84KitwmRP4L2whNmWEB0GSqa9WHfU3ofsI6XpIkq+rebt9
         QyFl1kYFyw4wfrym3/f1qO2QgYS++nk/XPXLGZe4+ZXUTL3wSRpPzl5AK3MBPIjCk9kC
         z0VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L5AGm8q5;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor11285250pgp.73.2019.04.01.09.13.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 09:13:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=L5AGm8q5;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wXhFvQZq2CM4UVq0M+sbdzQ2JEvBc81wcurHCGB2kdY=;
        b=L5AGm8q5APil0EYBW1o8bT4pHSND/yHKUieVynsysfKreMvLrjGmg/0SdQf0PfCQwM
         X6idrWcFYVksabsznulm4PbI0EjRpT0x5lfNjohgLsFUNgkC7F1aFLusFjXPNaUFra0W
         HAG8Ew6vY4NY3XiwNFKrVq+3xyWRg//3Ridma8+QaKgS3NSvXbhFXPc/RBi/CX4gYXMQ
         OY7NOrxz38ZaprvCKzX8vgcCPYrsxxyGhmjEJwb9//j25yPpyH6I56ERz6k0P/jDwlyd
         KRqO+HSycGMkeGMYaS6jSVnEjHA2anb0XDGD3B+DZhK1sMhVDKeV1LPChN+TBlau1YW0
         Do8g==
X-Google-Smtp-Source: APXvYqwcqhe96+G/9dwKy7DKrLfYEm8c/6K4DmQ+BL8AYBzqTOnssgLjUYCHQmGi6dcefHO6ae6/dzTl8fU1NHASkcA=
X-Received: by 2002:a63:1f52:: with SMTP id q18mr62385544pgm.134.1554135211065;
 Mon, 01 Apr 2019 09:13:31 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <ae6961bcdd82e529c76d0747abd310546f81e58e.1553093421.git.andreyknvl@google.com>
 <20190322160726.GV13384@arrakis.emea.arm.com> <bfaae923-98aa-63e7-c50b-8649dc5fe2bb@arm.com>
In-Reply-To: <bfaae923-98aa-63e7-c50b-8649dc5fe2bb@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 18:13:19 +0200
Message-ID: <CAAeHK+wiGbDtJ3d3um=OQ3VBt1tfu0f2uZ73UfDUfvNFjqPGfw@mail.gmail.com>
Subject: Re: [PATCH v13 17/20] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
To: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 3:08 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 22/03/2019 16:07, Catalin Marinas wrote:
> > On Wed, Mar 20, 2019 at 03:51:31PM +0100, Andrey Konovalov wrote:
> >> This patch is a part of a series that extends arm64 kernel ABI to allow to
> >> pass tagged user pointers (with the top byte set to something else other
> >> than 0x00) as syscall arguments.
> >>
> >> videobuf_dma_contig_user_get() uses provided user pointers for vma
> >> lookups, which can only by done with untagged pointers.
> >>
> >> Untag the pointers in this function.
> >>
> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >> ---
> >>   drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
> >>   1 file changed, 5 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
> >> index e1bf50df4c70..8a1ddd146b17 100644
> >> --- a/drivers/media/v4l2-core/videobuf-dma-contig.c
> >> +++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
> >> @@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
> >>   static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
> >>                                      struct videobuf_buffer *vb)
> >>   {
> >> +    unsigned long untagged_baddr = untagged_addr(vb->baddr);
> >>      struct mm_struct *mm = current->mm;
> >>      struct vm_area_struct *vma;
> >>      unsigned long prev_pfn, this_pfn;
> >> @@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
> >>      unsigned int offset;
> >>      int ret;
> >>
> >> -    offset = vb->baddr & ~PAGE_MASK;
> >> +    offset = untagged_baddr & ~PAGE_MASK;
> >>      mem->size = PAGE_ALIGN(vb->size + offset);
> >>      ret = -EINVAL;
> >>
> >>      down_read(&mm->mmap_sem);
> >>
> >> -    vma = find_vma(mm, vb->baddr);
> >> +    vma = find_vma(mm, untagged_baddr);
> >>      if (!vma)
> >>              goto out_up;
> >>
> >> -    if ((vb->baddr + mem->size) > vma->vm_end)
> >> +    if ((untagged_baddr + mem->size) > vma->vm_end)
> >>              goto out_up;
> >>
> >>      pages_done = 0;
> >>      prev_pfn = 0; /* kill warning */
> >> -    user_address = vb->baddr;
> >> +    user_address = untagged_baddr;
> >>
> >>      while (pages_done < (mem->size >> PAGE_SHIFT)) {
> >>              ret = follow_pfn(vma, user_address, &this_pfn);
> > I don't think vb->baddr here is anonymous mmap() but worth checking the
> > call paths.

The call path is
__videobuf_iolock()->videobuf_dma_contig_user_get()->find_vma().

>
> I spent some time on this, I didn't find any restriction on the kind of mapping
> that's allowed here. The API regarding V4L2_MEMORY_USERPTR doesn't seem to say
> anything about that either [0] [1]. It's probably best to ask the V4L2 maintainers.

Mauro, could you comment on whether the vb->baddr argument for the
V4L2_MEMORY_USERPTR API can come from an anonymous memory mapping?

>
> Kevin
>
> [0] https://www.kernel.org/doc/html/latest/media/uapi/v4l/vidioc-qbuf.html
> [1] https://www.kernel.org/doc/html/latest/media/uapi/v4l/userp.html

