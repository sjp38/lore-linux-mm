Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9648E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:17:32 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so24375174qtd.20
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 04:17:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 88si571682qte.245.2018.12.27.04.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 04:17:31 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBRC92ZQ073731
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:17:30 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pmvphcdaw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:17:30 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 27 Dec 2018 12:17:28 -0000
Subject: Re: [PATCH v37 0/3] Virtio-balloon: support free page reporting
From: Christian Borntraeger <borntraeger@de.ibm.com>
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
 <0661b05a-d9d0-d374-44e8-2583463e94c2@de.ibm.com>
 <de167161-b586-6aee-d6a5-a90d47bbe1d4@de.ibm.com>
Date: Thu, 27 Dec 2018 13:17:20 +0100
MIME-Version: 1.0
In-Reply-To: <de167161-b586-6aee-d6a5-a90d47bbe1d4@de.ibm.com>
Content-Language: en-US
Message-Id: <e79b5c3d-aa89-6b99-00b1-c92c85fe214c@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com, Halil Pasic <pasic@linux.ibm.com>, Cornelia Huck <cohuck@redhat.com>



On 27.12.2018 12:59, Christian Borntraeger wrote:
> On 27.12.2018 12:31, Christian Borntraeger wrote:
>> This patch triggers random crashes in the guest kernel on s390 early during boot.
>> No migration and no setting of the balloon is involved.
>>
> 
> Adding Conny and Halil,
> 
> As the QEMU provides no PAGE_HINT feature yet, this quick hack makes the
> guest boot fine again:
> 
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 728ecd1eea305..aa2e1864c5736 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -492,7 +492,7 @@ static int init_vqs(struct virtio_balloon *vb)
>                 callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>         }
>  
> -       err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> +       err = vb->vdev->config->find_vqs(vb->vdev, 3, //VIRTIO_BALLOON_VQ_MAX,
>                                          vqs, callbacks, names, NULL, NULL);
>         if (err)
>                 return err;
> 
> 
> To me it looks like that virtio_ccw_find_vqs will abort if any of the virtqueues 
> that it is been asked for does not exist (including the earlier ones).
> 

This "hack" makes the random crashes go away, but the balloon interface itself
does not work. (setting the value to anything will hang the guest). 
As patch 1 also modifies the main path, there seem to be additional issues, maybe
endianess

Looking at things like

+		vb->cmd_id_received = VIRTIO_BALLOON_CMD_ID_STOP;
+		vb->cmd_id_active = cpu_to_virtio32(vb->vdev,
+						  VIRTIO_BALLOON_CMD_ID_STOP);
+		vb->cmd_id_stop = cpu_to_virtio32(vb->vdev,
+						  VIRTIO_BALLOON_CMD_ID_STOP);


Why is cmd_id_received not using cpu_to_virtio32?
