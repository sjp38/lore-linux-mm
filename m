Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5306B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:01:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so52432668lfw.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:01:58 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id w127si8066112wmg.118.2016.08.31.23.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 23:01:57 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id c133so60659610wmd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:01:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A01C59B@shsmsx102.ccr.corp.intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
 <CANRm+Cy=p8PKg8HqRp7apU0D9X=gpnrahtXRq+S+5Gq863VO8g@mail.gmail.com> <F2CBF3009FA73547804AE4C663CAB28E3A01C59B@shsmsx102.ccr.corp.intel.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Thu, 1 Sep 2016 14:01:56 +0800
Message-ID: <CANRm+Cx-JzR-JhRwy9RShFGeC5SHw9HKesXnPyy9BiBmhQgiCQ@mail.gmail.com>
Subject: Re: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, kvm <kvm@vger.kernel.org>, "qemu-devel@nongnu.org Developers" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>

2016-09-01 13:46 GMT+08:00 Li, Liang Z <liang.z.li@intel.com>:
>> Subject: Re: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast (de)inflating
>> & fast live migration
>>
>> 2016-08-08 14:35 GMT+08:00 Liang Li <liang.z.li@intel.com>:
>> > This patch set contains two parts of changes to the virtio-balloon.
>> >
>> > One is the change for speeding up the inflating & deflating process,
>> > the main idea of this optimization is to use bitmap to send the page
>> > information to host instead of the PFNs, to reduce the overhead of
>> > virtio data transmission, address translation and madvise(). This can
>> > help to improve the performance by about 85%.
>> >
>> > Another change is for speeding up live migration. By skipping process
>> > guest's free pages in the first round of data copy, to reduce needless
>> > data processing, this can help to save quite a lot of CPU cycles and
>> > network bandwidth. We put guest's free page information in bitmap and
>> > send it to host with the virt queue of virtio-balloon. For an idle 8GB
>> > guest, this can help to shorten the total live migration time from
>> > 2Sec to about 500ms in the 10Gbps network environment.
>>
>> I just read the slides of this feature for recent kvm forum, the cloud
>> providers more care about live migration downtime to avoid customers'
>> perception than total time, however, this feature will increase downtime
>> when acquire the benefit of reducing total time, maybe it will be more
>> acceptable if there is no downside for downtime.
>>
>> Regards,
>> Wanpeng Li
>
> In theory, there is no factor that will increase the downtime. There is no additional operation
> and no more data copy during the stop and copy stage. But in the test, the downtime increases
> and this can be reproduced. I think the busy network line maybe the reason for this. With this
>  optimization, a huge amount of data is written to the socket in a shorter time, so some of the write
> operation may need to wait. Without this optimization, zero page checking takes more time,
> the network is not so busy.
>
> If the guest is not an idle one, I think the gap of the downtime will not so obvious.  Anyway, the

http://www.linux-kvm.org/images/c/c3/03x06B-Liang_Li-Real_Time_and_Fast_Live_Migration_Update_for_NFV.pdf
The slides show almost the similar percentage for the idle and the
non-idle guests, they both increase  ~50% downtime.

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
