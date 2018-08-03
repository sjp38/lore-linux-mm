Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3E226B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:11:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d11-v6so3867605iok.21
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:11:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q131-v6si3005908itb.114.2018.08.03.05.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 05:11:22 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
 <1533285146-25212-3-git-send-email-wei.w.wang@intel.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <16c56ee5-eef7-dd5f-f2b6-e3c11df2765c@i-love.sakura.ne.jp>
Date: Fri, 3 Aug 2018 21:11:09 +0900
MIME-Version: 1.0
In-Reply-To: <1533285146-25212-3-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org

On 2018/08/03 17:32, Wei Wang wrote:
> +static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
> +{
> +	vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
> +	vb->shrinker.count_objects = virtio_balloon_shrinker_count;
> +	vb->shrinker.batch = 0;
> +	vb->shrinker.seeks = DEFAULT_SEEKS;

Why flags field is not set? If vb is allocated by kmalloc(GFP_KERNEL)
and is nowhere zero-cleared, KASAN would complain it.

> +
> +	return register_shrinker(&vb->shrinker);
> +}
