Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2C8A6B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 07:17:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t188so14227018pfd.20
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 04:17:42 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q13si3455783pgc.232.2017.10.22.04.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 04:17:41 -0700 (PDT)
Message-ID: <59EC7ED1.2000907@intel.com>
Date: Sun, 22 Oct 2017 19:19:45 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 0/3] Virtio-balloon Improvement
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com> <20171022061307-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171022061307-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On 10/22/2017 11:19 AM, Michael S. Tsirkin wrote:
> On Fri, Oct 20, 2017 at 07:54:23PM +0800, Wei Wang wrote:
>> This patch series intends to summarize the recent contributions made by
>> Michael S. Tsirkin, Tetsuo Handa, Michal Hocko etc. via reporting and
>> discussing the related deadlock issues on the mailinglist. Please check
>> each patch for details.
>>
>> >From a high-level point of view, this patch series achieves:
>> 1) eliminate the deadlock issue fundamentally caused by the inability
>> to run leak_balloon and fill_balloon concurrently;
> We need to think about this carefully. Is it an issue that
> leak can now bypass fill? It seems that we can now
> try to leak a page before fill was seen by host,
> but I did not look into it deeply.
>
> I really like my patch for this better at least for
> current kernel. I agree we need to work more on 2+3.

Yes, we can check more. But from the original intention:
(copied from the commit e22504296d)
balloon_lock (mutex) : synchronizes the access demand to elements of
                               struct virtio_balloon and its queue 
operations;

This implementation has covered what balloon_lock achieves. We have
inflating and deflating decoupled and use a small lock for each vq 
respectively.

I also tested inflating 20G, and before it's done, requested to 
deflating 20G, all work fine.


>
>> 2) enable OOM to release more than 256 inflated pages; and
> Does just this help enough? How about my patch + 2?
> Tetsuo, what do you think?
>
>> 3) stop inflating when the guest is under severe memory pressure
>> (i.e. OOM).
> But when do we finally inflate?  Question is how does host know it needs
> to resend an interrupt, and when should it do it?

I think "when to inflate again" should be a policy defined by the 
orchestration
layer software on the host. A reasonable inflating request should be 
sent to a
guest on the condition that this guest has enough free memory to inflate
(virtio-balloon memory stats has already supported to report that info).

If the policy defines to inflate guest memory without considering 
whether the guest
is even under memory pressure. The mechanism we provide here is to offer 
no pages
to the host in that case. I think this should be reasonable.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
