Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BA5EC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:42:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C1D217F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:42:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C1D217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01BA18E000A; Wed, 24 Jul 2019 16:42:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E748E0002; Wed, 24 Jul 2019 16:42:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE938E000A; Wed, 24 Jul 2019 16:42:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8C5A8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:42:38 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e32so42463292qtc.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:42:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=0oDsp6PabiGgGzFV5AXKWcbAmWPliOqgciTu5AmtKko=;
        b=aXlZq3+57v/dhdcPHELbDkiMnARLeSpwrm6TrhvBz5FNpzAT57Bp1rolo5WJVlNpRE
         7cKmlLQrR3LTySCS2okqwOfOjmZ5J6nAtr/sLucnwE5S/Io77wv5n9F4N6azO/ATKwAB
         5eB1Jigmbmr0hYO+bnEkesGCDRMD0wqN1T1R2ynAtRrhOVxGjkbBq7ArtGaznYCPdhN/
         IOjScwm4CngM/qho0I2Y9zMQK4t7eOw+tfSM525Rkq9k3ooubuRLBrNiUSEqY8PIv+YB
         QELQTELuMun9uXkIyIwTo77Qck+Hkdf4jmkGSzc+h9EifmMS7xnQLDKQPziN1nbmtfV0
         UTdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVz8bXkyyrNFxY3FqDHVSZD7jx0Dz/8wPlDW1X+i/+uejPHJmUI
	ByttYlV8En7klXzdl74UIGzaX5GW1us4PSjREfgDAxokZ78OrQjTS56HlNHIZ0kP/NEu/wa0E1Z
	picRIkFzNtVPTWc2xC65fnnIQ2QThApJwdq8bd9OxCVTKQPeK/l7rV8u1OWVye1yFvw==
X-Received: by 2002:ac8:2b90:: with SMTP id m16mr57929717qtm.384.1564000958510;
        Wed, 24 Jul 2019 13:42:38 -0700 (PDT)
X-Received: by 2002:ac8:2b90:: with SMTP id m16mr57929688qtm.384.1564000957949;
        Wed, 24 Jul 2019 13:42:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564000957; cv=none;
        d=google.com; s=arc-20160816;
        b=QQBA3GvXf01+6BvW695qCRHfAzSx6Ri5v7Vs8CSe/dXeUH8t0tCqC+fA/4hJN1dpik
         5zLjDFiqKkxW+Kv4OrRH7Ew9Mgn2xC8R8aMHGBrUmfq1+NV0XEa1VvJNtTv97jGZeyvg
         7V8Kg5VdqqMHDETHXITJYiGN6ARp8tBxzZGDl16ZPMz53pzASbTdCgUTicldQHQ6VPiF
         YP5DilOPfq95IYc9GHd5wSjQHwOnxh20bn24cF99Bdy77iiA40zlz6jDegqhtGMpDXx8
         +PYDa4FTcIk+5epY5N5ZzyyPqxGbJ2O+gw8Y1O6xOaefgroLTb7Nx3Tbac7lgaugGDBR
         9gnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=0oDsp6PabiGgGzFV5AXKWcbAmWPliOqgciTu5AmtKko=;
        b=JSxh4JceFeqoQUKKqSUqiuTj3b1FVn8fHII/sCegmOFrlZ9EI65FKapivF2wIfVESm
         ybbYAKDWrTXlzxsn1W4IHaNgg/YdoZo/FktbrOyKUogGBLh6Ca5fLH5A6hhiTuySd1iv
         iLOS64mNnoKXWIZEGyRdoMjZUYQVOjlVJB7Ys5M0hUL7z/W5OjivS/e9AYePgkBtz8Nx
         PhuAskIxb7RPLftvUg/oCSfbxWTwKegpUeSShaOxLRi5rVJSN0On2PPjeF+tUYN4TyQI
         9uO8zLuY7RBbD7+OBiRFCXYA5/tASdRjKqYLQD0EiGfvm60ekBHjcMeiHn8Kb4lDNvP9
         AMlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g41sor62480906qte.46.2019.07.24.13.42.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:42:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy1xyF8m0D0XrDjgh1Az86AClKVYNEKuVVVwKydA8wHTr4Opr/E4uUxsrcRi8Vs/vksPRXBLQ==
X-Received: by 2002:ac8:5315:: with SMTP id t21mr59263152qtn.229.1564000957709;
        Wed, 24 Jul 2019 13:42:37 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id r14sm22913246qke.47.2019.07.24.13.42.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 13:42:36 -0700 (PDT)
Date: Wed, 24 Jul 2019 16:42:29 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190724164023-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
 <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:29:27PM -0400, Nitesh Narayan Lal wrote:
> 
> On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> >> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>>
> >>> Add support for what I am referring to as "bubble hinting". Basically the
> >>> idea is to function very similar to how the balloon works in that we
> >>> basically end up madvising the page as not being used. However we don't
> >>> really need to bother with any deflate type logic since the page will be
> >>> faulted back into the guest when it is read or written to.
> >>>
> >>> This is meant to be a simplification of the existing balloon interface
> >>> to use for providing hints to what memory needs to be freed. I am assuming
> >>> this is safe to do as the deflate logic does not actually appear to do very
> >>> much other than tracking what subpages have been released and which ones
> >>> haven't.
> >>>
> >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>> ---
> >>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> >>>  include/hw/virtio/virtio-balloon.h              |    2 +
> >>>  include/standard-headers/linux/virtio_balloon.h |    1 +
> >>>  3 files changed, 42 insertions(+), 1 deletion(-)
> >>>
> >>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> >>> index 2112874055fb..70c0004c0f88 100644
> >>> --- a/hw/virtio/virtio-balloon.c
> >>> +++ b/hw/virtio/virtio-balloon.c
> >>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> >>>      balloon_stats_change_timer(s, 0);
> >>>  }
> >>>  
> >>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> >>> +{
> >>> +    VirtQueueElement *elem;
> >>> +
> >>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> >>> +    	unsigned int i;
> >>> +
> >>> +        for (i = 0; i < elem->in_num; i++) {
> >>> +            void *addr = elem->in_sg[i].iov_base;
> >>> +            size_t size = elem->in_sg[i].iov_len;
> >>> +            ram_addr_t ram_offset;
> >>> +            size_t rb_page_size;
> >>> +            RAMBlock *rb;
> >>> +
> >>> +            if (qemu_balloon_is_inhibited())
> >>> +                continue;
> >>> +
> >>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> >>> +            rb_page_size = qemu_ram_pagesize(rb);
> >>> +
> >>> +            /* For now we will simply ignore unaligned memory regions */
> >>> +            if ((ram_offset | size) & (rb_page_size - 1))
> >>> +                continue;
> >>> +
> >>> +            ram_block_discard_range(rb, ram_offset, size);
> >> I suspect this needs to do like the migration type of
> >> hinting and get disabled if page poisoning is in effect.
> >> Right?
> > Shouldn't something like that end up getting handled via
> > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > isn't the case then I could add some additional conditions. I would do it
> > in about the same spot as the qemu_balloon_is_inhibited check.
> I don't think qemu_balloon_is_inhibited() will take care of the page poisoning
> situations.
> If I am not wrong we may have to look to extend VIRTIO_BALLOON_F_PAGE_POISON
> support as per Michael's suggestion.


BTW upstream qemu seems to ignore VIRTIO_BALLOON_F_PAGE_POISON ATM.
Which is probably a bug.
Wei, could you take a look pls?

> >
> >
> -- 
> Thanks
> Nitesh

