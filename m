Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C23A6B06B5
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:05:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o5so6101598qki.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:05:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 50si10344628qtv.159.2017.08.03.06.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:05:21 -0700 (PDT)
Date: Thu, 3 Aug 2017 09:05:06 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <900253471.38532197.1501765506419.JavaMail.zimbra@redhat.com>
In-Reply-To: <598316DB.4050308@intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-6-git-send-email-wei.w.wang@intel.com> <147332060.38438527.1501748021126.JavaMail.zimbra@redhat.com> <598316DB.4050308@intel.com>
Subject: Re: [PATCH v13 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia huck <cornelia.huck@de.ibm.com>, mgorman@techsingularity.net, aarcange@redhat.com, amit shah <amit.shah@redhat.com>, pbonzini@redhat.com, liliang opensource <liliang.opensource@gmail.com>, yang zhang wz <yang.zhang.wz@gmail.com>, quan xu <quan.xu@aliyun.com>


> 
> On 08/03/2017 04:13 PM, Pankaj Gupta wrote:
> >>
> >> +        /* Allocate space for find_vqs parameters */
> >> +        vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
> >> +        if (!vqs)
> >> +                goto err_vq;
> >> +        callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
> >> +        if (!callbacks)
> >> +                goto err_callback;
> >> +        names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
> >                      
> >         is size here (integer) intentional?
> 
> 
> Sorry, I didn't get it. Could you please elaborate more?

This is okay

> 
> 
> >
> >> +        if (!names)
> >> +                goto err_names;
> >> +
> >> +        callbacks[0] = balloon_ack;
> >> +        names[0] = "inflate";
> >> +        callbacks[1] = balloon_ack;
> >> +        names[1] = "deflate";
> >> +
> >> +        i = 2;
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >> +                callbacks[i] = stats_request;
> > just thinking if memory for callbacks[3] & names[3] is allocated?
> 
> 
> Yes, the above kmalloc_array allocated them.

I mean we have created callbacks array for two entries 0,1?

callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);

But we are trying to access location '2' which is third:

         i = 2;
+        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+                callbacks[i] = stats_request;      <---- callbacks[2]
+                names[i] = "stats";                <----- names[2]
+                i++;
+        }

I am missing anything obvious here?

> 
> 
> Best,
> Wei
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
