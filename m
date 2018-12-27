Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1B38E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:05:52 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 42so23973549qtr.7
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 04:05:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h39si5554973qth.232.2018.12.27.04.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 04:05:51 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBRC5HtP118612
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:05:50 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pmushdxts-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:05:45 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 27 Dec 2018 12:03:56 -0000
Subject: Re: [PATCH v37 1/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
 <1535333539-32420-2-git-send-email-wei.w.wang@intel.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 27 Dec 2018 13:03:44 +0100
MIME-Version: 1.0
In-Reply-To: <1535333539-32420-2-git-send-email-wei.w.wang@intel.com>
Content-Language: en-US
Message-Id: <49d706f7-a0ee-e571-7d02-bcadac5ce742@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com, Cornelia Huck <cohuck@redhat.com>, Halil Pasic <pasic@linux.ibm.com>

On 27.08.2018 03:32, Wei Wang wrote:
>  static int init_vqs(struct virtio_balloon *vb)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> -	int err, nvqs;
> +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
> +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
> +	const char *names[VIRTIO_BALLOON_VQ_MAX];
> +	int err;
> 
>  	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> +	 * Inflateq and deflateq are used unconditionally. The names[]
> +	 * will be NULL if the related feature is not enabled, which will
> +	 * cause no allocation for the corresponding virtqueue in find_vqs.
>  	 */

This might be true for virtio-pci, but it is not for virtio-ccw.

> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> +	callbacks[VIRTIO_BALLOON_VQ_INFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_INFLATE] = "inflate";
> +	callbacks[VIRTIO_BALLOON_VQ_DEFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> +	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> +	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> +		callbacks[VIRTIO_BALLOON_VQ_STATS] = stats_request;
> +	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	}
> +
> +	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
[...]
