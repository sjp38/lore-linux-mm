Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 879316B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:57:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so6154126pgo.20
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:57:52 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u3si9187780plb.302.2017.10.19.00.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 00:57:51 -0700 (PDT)
Message-ID: <59E85B7A.1090800@intel.com>
Date: Thu, 19 Oct 2017 15:59:54 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] virtio_balloon: fix deadlock on OOM
References: <1507900754-32239-1-git-send-email-mst@redhat.com> <201710132306.FBC78628.OJLHFVQSFOtOMF@I-love.SAKURA.ne.jp> <20171018201700-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171018201700-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On 10/19/2017 01:19 AM, Michael S. Tsirkin wrote:
> On Fri, Oct 13, 2017 at 11:06:23PM +0900, Tetsuo Handa wrote:
>> Michael S. Tsirkin wrote:
>>> This is a replacement for
>>> 	[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
>>> but unlike that patch it actually deflates on oom even in presence of
>>> lock contention.
>> But Wei Wang is proposing VIRTIO_BALLOON_F_SG which will try to allocate
>> memory, isn't he?
> Hopefully that can be fixed by allocating outside the lock.
>

I think that would still have an issue even without the lock, because we 
can't do
any memory allocation in the OOM code path.

Probably, we could write a separate function, leak_balloon_oom() for the 
oom notifier,
which puts the oom deflating pages to the vq one by one, and kick when 
the vq is full.

In this case, we would need to stop the normal leak_balloon while oom 
deflating starts.
However, a better optimization I think would be to do some kind of 
consolidation, since
leak_balloon is already deflating, leak_ballon_oom can just count the 
number of pages
that have been deflated by leak_balloon and return when it reaches 
oom_pages.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
