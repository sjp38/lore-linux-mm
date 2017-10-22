Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4D4B6B0069
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 07:29:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n89so14196749pfk.17
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 04:29:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i8si3468213pgf.567.2017.10.22.04.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 04:29:38 -0700 (PDT)
Message-ID: <59EC819F.1080205@intel.com>
Date: Sun, 22 Oct 2017 19:31:43 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 2/3] virtio-balloon: deflate up to oom_pages on OOM
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>	<1508500466-21165-3-git-send-email-wei.w.wang@intel.com>	<20171022062119-mutt-send-email-mst@kernel.org> <201710221311.FFI17148.VStOJQLHOFFMOF@I-love.SAKURA.ne.jp>
In-Reply-To: <201710221311.FFI17148.VStOJQLHOFFMOF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mst@redhat.com
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On 10/22/2017 12:11 PM, Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
>>> -	num_freed_pages = leak_balloon(vb, oom_pages);
>>> +
>>> +	/* Don't deflate more than the number of inflated pages */
>>> +	while (npages && atomic64_read(&vb->num_pages))
>>> +		npages -= leak_balloon(vb, npages);
> don't we need to abort if leak_balloon() returned 0 for some reason?

I don't think so. Returning 0 should be a normal case when the host tries
to give back some pages to the guest, but there is no pages that have ever
been inflated. For example, right after booting the guest, the host sends a
deflating request to give the guest 1G memory, leak_balloon should return 0,
and guest wouldn't get 1 more G memory.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
