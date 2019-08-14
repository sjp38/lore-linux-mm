Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C013C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:30:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3A7A2083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 10:30:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3A7A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 467286B0005; Wed, 14 Aug 2019 06:30:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418366B0006; Wed, 14 Aug 2019 06:30:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32E046B0007; Wed, 14 Aug 2019 06:30:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 1422D6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:30:11 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A5C46124F
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:30:10 +0000 (UTC)
X-FDA: 75820663380.04.robin51_58cedf4e33344
X-HE-Tag: robin51_58cedf4e33344
X-Filterd-Recvd-Size: 6092
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:30:10 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0EB3F30083EE;
	Wed, 14 Aug 2019 10:30:07 +0000 (UTC)
Received: from gondolin (dhcp-192-232.str.redhat.com [10.33.192.232])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 59F6C1001B35;
	Wed, 14 Aug 2019 10:29:52 +0000 (UTC)
Date: Wed, 14 Aug 2019 12:29:49 +0200
From: Cornelia Huck <cohuck@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 virtio-dev@lists.oasis-open.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com,
 mst@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com,
 john.starks@microsoft.com, dave.hansen@intel.com, mhocko@suse.com
Subject: Re: [RFC][Patch v12 2/2] virtio-balloon: interface to support free
 page reporting
Message-ID: <20190814122949.4946f438.cohuck@redhat.com>
In-Reply-To: <20190812131235.27244-3-nitesh@redhat.com>
References: <20190812131235.27244-1-nitesh@redhat.com>
	<20190812131235.27244-3-nitesh@redhat.com>
Organization: Red Hat GmbH
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 14 Aug 2019 10:30:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Aug 2019 09:12:35 -0400
Nitesh Narayan Lal <nitesh@redhat.com> wrote:

> Enables the kernel to negotiate VIRTIO_BALLOON_F_REPORTING feature with
> the host. If it is available and page_reporting_flag is set to true,
> page_reporting is enabled and its callback is configured along with
> the max_pages count which indicates the maximum number of pages that
> can be isolated and reported at a time. Currently, only free pages of
> order >= (MAX_ORDER - 2) are reported. To prevent any false OOM
> max_pages count is set to 16.
> 
> By default page_reporting feature is enabled and gets loaded as soon
> as the virtio-balloon driver is loaded. However, it could be disabled
> by writing the page_reporting_flag which is a virtio-balloon parameter.
> 
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  drivers/virtio/Kconfig              |  1 +
>  drivers/virtio/virtio_balloon.c     | 64 ++++++++++++++++++++++++++++-
>  include/uapi/linux/virtio_balloon.h |  1 +
>  3 files changed, 65 insertions(+), 1 deletion(-)
> 

> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 226fbb995fb0..defec00d4ee2 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c

(...)

> +static void virtballoon_page_reporting_setup(struct virtio_balloon *vb)
> +{
> +	struct device *dev = &vb->vdev->dev;
> +	int err;
> +
> +	vb->page_reporting_conf.report = virtballoon_report_pages;
> +	vb->page_reporting_conf.max_pages = PAGE_REPORTING_MAX_PAGES;
> +	err = page_reporting_enable(&vb->page_reporting_conf);
> +	if (err < 0) {
> +		dev_err(dev, "Failed to enable reporting, err = %d\n", err);
> +		page_reporting_flag = false;

Should we clear the feature bit in this case as well?

> +		vb->page_reporting_conf.report = NULL;
> +		vb->page_reporting_conf.max_pages = 0;
> +		return;
> +	}
> +}
> +
>  static void set_page_pfns(struct virtio_balloon *vb,
>  			  __virtio32 pfns[], struct page *page)
>  {
> @@ -476,6 +524,7 @@ static int init_vqs(struct virtio_balloon *vb)
>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	names[VIRTIO_BALLOON_VQ_REPORTING] = NULL;
>  
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> @@ -487,11 +536,18 @@ static int init_vqs(struct virtio_balloon *vb)
>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>  	}
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> +		names[VIRTIO_BALLOON_VQ_REPORTING] = "reporting_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_REPORTING] = balloon_ack;

Do we even want to try to set up the reporting queue if reporting has
been disabled via module parameter? Might make more sense to not even
negotiate the feature bit in that case.

> +	}
>  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>  					 vqs, callbacks, names, NULL, NULL);
>  	if (err)
>  		return err;
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
> +		vb->reporting_vq = vqs[VIRTIO_BALLOON_VQ_REPORTING];
> +
>  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
>  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> @@ -924,6 +980,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		if (err)
>  			goto out_del_balloon_wq;
>  	}
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING) &&
> +	    page_reporting_flag)
> +		virtballoon_page_reporting_setup(vb);

In that case, you'd only need to check for the feature bit here.

>  	virtio_device_ready(vdev);
>  
>  	if (towards_target(vb))
> @@ -971,6 +1030,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  		destroy_workqueue(vb->balloon_wq);
>  	}
>  
> +	if (page_reporting_flag)
> +		page_reporting_disable(&vb->page_reporting_conf);

I think you should not disable it if the feature bit was never offered
in the first place, right?

>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	if (vb->vb_dev_info.inode)

(...)

