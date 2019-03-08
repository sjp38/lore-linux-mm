Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87861C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 12:56:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23D7020449
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 12:56:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23D7020449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FB1D8E0003; Fri,  8 Mar 2019 07:56:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AC248E0002; Fri,  8 Mar 2019 07:56:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69A6A8E0003; Fri,  8 Mar 2019 07:56:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42D988E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 07:56:10 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b11so15977651qka.3
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 04:56:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=A+ONulh89ZRd0TBrQbX2xsE4uKRIImlni/lkNnnezk4=;
        b=VPYYcHi8Bc4GzxH9xESfrqF9UrbzURNnLRBDLK28xCJ3f8gSK1z9OJKiO2gNzD+hnH
         dMbDYP8PQEzFgl/TmKLYL4/FRQJyh34TAOTrrF5FPyDcELCo8soTTK18rOweHO0PvHNX
         6V7Ub3RVEZLSKuI/FxKekdk3nggWyVeEyHomR90scLSPG4FcotpqwZlGUMn4/cwei5kD
         YBJqXC44K9d7ybQkkrb/tjhlJGfffP5rSIh8DAtUuve5k47rin2VEm8oti7cN2zpLdj3
         UfSjKAn2+7rAyb11SKqQLhVsaMMhkRZ/zksB3XUIkmA2SePfQ30NZ51OwIpzKMZjgpVk
         AaZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvsg9yz2C0c/Argj5Yv3lmVJOvxZhp762FoFPLjqYgu/8CmWDP
	6hFRuY3BkwE3ZsfsrPCpnuUqMJutmHFrT3zUNzo9iPLhJCvnOa182SSDawH1QAGW2NWZlt7Rw7m
	h6Jfcd0UjYQQL9wJKN6ZysWanZFrszbw283UsVmzf3sE1sepspSXtkFmXi5lAuz/R24/dc/7rai
	KXLnvcUIudkyuu9airg0MzL7GjH+7N1esnTPufb1WAFoJI/51WnnMSLjmLfZLIRwoJ9pRvrm41c
	vdSqEib1h9dUD8l4sRekWP2sV6NP/jkFr5R87+nA/f27Hn1Dm/uEoE/jA6yns6knZl0ODsmocIm
	CStWYqoYAf5Oz5ERqIiEjTp81lhIZM7r4bsYgZYogOWo2g3Aq+snRBK1G5B1rnxt32bJiOZSZhe
	L
X-Received: by 2002:a0c:91e1:: with SMTP id r30mr15095395qvr.136.1552049769699;
        Fri, 08 Mar 2019 04:56:09 -0800 (PST)
X-Received: by 2002:a0c:91e1:: with SMTP id r30mr15095344qvr.136.1552049768656;
        Fri, 08 Mar 2019 04:56:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552049768; cv=none;
        d=google.com; s=arc-20160816;
        b=tZ3UErH/0kvM9WWhqvbjuX42CI8IpExijFqFwMvoIiX5AFeT8Q6wNOzrakM6UYg0oo
         255/fs5cg2DxLFNN+iaBvC6N7EYLQuv78gN/vZihB8ujtnubZp4+nqEBqII86pkYj83y
         MFkoPuFupfiEC2ig7u+Oj3J12Fsi5JDPRLoxnbOqpFZZ9cIvc1mdBREOf9R8w+6+7tWc
         CENrpN92MnetKMBpwGIiy+UF9cEmrY/zl0HiuqizSLCM+liBfCbTfX5GQ7kGS5071Kyp
         c6puURCZHxbPYy9Ee3VJ68aTYb/TRELALLizyEfeLByxkQmLAFp9kSWdrtlL0LhLRhAx
         zt9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=A+ONulh89ZRd0TBrQbX2xsE4uKRIImlni/lkNnnezk4=;
        b=EDwRUY7crG/fULjhihtmvzazkfwOVWjRuI4kwME8rNAo4HOa6FFJQvaUC6aOFYIUkX
         +SPNGqXdkpEM2qrX9fIrurSQZV1cCarI7N2QEZw5KlBLE4xLkrfGj6lxHLHgEEu7uUKY
         OklepYChCvbTtp+95WBcO9+jGzp5AHkU2cVXS6ucr7qTqH9VEdoalA4NlFM8a+H3HFT/
         FnGZnMsnXdBC6JT/XjFSdwTCqvucDIN+CYp4GAicYxcJaJjQ2TEyXcRu87RgBXNVu71w
         h/gFKLUyr9YJV0HokK/lhUKUhhTCLRYXIywCSk5U/Q3qlw9OzKLxrDFrVqRONoHh2TtO
         zumQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f39sor8512348qvf.46.2019.03.08.04.56.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 04:56:08 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzpMhMBKy1jpKKr6R0JL9ZfZz/BygDitVhs5ihNJGMR5qa+oBECnJQrUvrvVc+PbC/lY2Xgtw==
X-Received: by 2002:a0c:927a:: with SMTP id 55mr14838918qvz.226.1552049768331;
        Fri, 08 Mar 2019 04:56:08 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id j9sm2940101qki.21.2019.03.08.04.56.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 04:56:07 -0800 (PST)
Date: Fri, 8 Mar 2019 07:56:04 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308075506-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <43408100-84d9-a359-3e78-dc65fb7b0ad1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <43408100-84d9-a359-3e78-dc65fb7b0ad1@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 04:58:44PM +0800, Jason Wang wrote:
> 
> On 2019/3/8 上午3:17, Jerome Glisse wrote:
> > On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
> > > On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
> > > > On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> > > > > +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> > > > > +	.invalidate_range = vhost_invalidate_range,
> > > > > +};
> > > > > +
> > > > >   void vhost_dev_init(struct vhost_dev *dev,
> > > > >   		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
> > > > >   {
> > > > I also wonder here: when page is write protected then
> > > > it does not look like .invalidate_range is invoked.
> > > > 
> > > > E.g. mm/ksm.c calls
> > > > 
> > > > mmu_notifier_invalidate_range_start and
> > > > mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
> > > > 
> > > > Similarly, rmap in page_mkclean_one will not call
> > > > mmu_notifier_invalidate_range.
> > > > 
> > > > If I'm right vhost won't get notified when page is write-protected since you
> > > > didn't install start/end notifiers. Note that end notifier can be called
> > > > with page locked, so it's not as straight-forward as just adding a call.
> > > > Writing into a write-protected page isn't a good idea.
> > > > 
> > > > Note that documentation says:
> > > > 	it is fine to delay the mmu_notifier_invalidate_range
> > > > 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
> > > > implying it's called just later.
> > > OK I missed the fact that _end actually calls
> > > mmu_notifier_invalidate_range internally. So that part is fine but the
> > > fact that you are trying to take page lock under VQ mutex and take same
> > > mutex within notifier probably means it's broken for ksm and rmap at
> > > least since these call invalidate with lock taken.
> > > 
> > > And generally, Andrea told me offline one can not take mutex under
> > > the notifier callback. I CC'd Andrea for why.
> > Correct, you _can not_ take mutex or any sleeping lock from within the
> > invalidate_range callback as those callback happens under the page table
> > spinlock. You can however do so under the invalidate_range_start call-
> > back only if it is a blocking allow callback (there is a flag passdown
> > with the invalidate_range_start callback if you are not allow to block
> > then return EBUSY and the invalidation will be aborted).
> > 
> > 
> > > That's a separate issue from set_page_dirty when memory is file backed.
> > If you can access file back page then i suggest using set_page_dirty
> > from within a special version of vunmap() so that when you vunmap you
> > set the page dirty without taking page lock. It is safe to do so
> > always from within an mmu notifier callback if you had the page map
> > with write permission which means that the page had write permission
> > in the userspace pte too and thus it having dirty pte is expected
> > and calling set_page_dirty on the page is allowed without any lock.
> > Locking will happen once the userspace pte are tear down through the
> > page table lock.
> 
> 
> Can I simply can set_page_dirty() before vunmap() in the mmu notifier
> callback, or is there any reason that it must be called within vumap()?
> 
> Thanks


I think this is what Jerome is saying, yes.
Maybe add a patch to mmu notifier doc file, documenting this?


> 
> > 
> > > It's because of all these issues that I preferred just accessing
> > > userspace memory and handling faults. Unfortunately there does not
> > > appear to exist an API that whitelists a specific driver along the lines
> > > of "I checked this code for speculative info leaks, don't add barriers
> > > on data path please".
> > Maybe it would be better to explore adding such helper then remapping
> > page into kernel address space ?
> > 
> > Cheers,
> > Jérôme

