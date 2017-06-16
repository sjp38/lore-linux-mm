Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2323B83293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:59:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o41so38112243qtf.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:59:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p35si2335286qtd.379.2017.06.16.08.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 08:59:12 -0700 (PDT)
Subject: Re: [RFC] virtio-mem: paravirtualized memory
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
 <20170616175748-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4cdf547c-079b-6b44-484f-e1132e960364@redhat.com>
Date: Fri, 16 Jun 2017 17:59:07 +0200
MIME-Version: 1.0
In-Reply-To: <20170616175748-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On 16.06.2017 17:04, Michael S. Tsirkin wrote:
> On Fri, Jun 16, 2017 at 04:20:02PM +0200, David Hildenbrand wrote:
>> Hi,
>>
>> this is an idea that is based on Andrea Arcangeli's original idea to
>> host enforce guest access to memory given up using virtio-balloon using
>> userfaultfd in the hypervisor. While looking into the details, I
>> realized that host-enforcing virtio-balloon would result in way too many
>> problems (mainly backwards compatibility) and would also have some
>> conceptual restrictions that I want to avoid. So I developed the idea of
>> virtio-mem - "paravirtualized memory".
> 
> Thanks! I went over this quickly, will read some more in the
> coming days. I would like to ask for some clarifications
> on one part meanwhile:

Thanks for looking into it that fast! :)

In general, what this section is all about: Why to not simply host
enforce virtio-balloon.

> 
>> Q: Why not reuse virtio-balloon?
>>
>> A: virtio-balloon is for cooperative memory management. It has a fixed
>>    page size
> 
> We are fixing that with VIRTIO_BALLOON_F_PAGE_CHUNKS btw.
> I would appreciate you looking into that patchset.

Will do, thanks. Problem is that there is no "enforcement" on the page
size. VIRTIO_BALLOON_F_PAGE_CHUNKS simply allows to send bigger chunks.
Nobody hinders the guest (especially legacy virtio-balloon drivers) from
sending 4k pages.

So this doesn't really fix the issue (we have here), it just allows to
speed up transfer. Which is a good thing, but does not help for
enforcement at all. So, yes support for page sizes > 4k, but no way to
enforce it.

> 
>> and will deflate in certain situations.
> 
> What does this refer to?

A Linux guest will deflate the balloon (all or some pages) in the
following scenarios:
a) page migration
b) unload virtio-balloon kernel module
c) hibernate/suspension
d) (DEFLATE_ON_OOM)

A Linux guest will touch memory without deflating:
a) During a kexec() dump
d) On reboots (regular, after kexec(), system_reset)

> 
>> Any change we
>>    introduce will break backwards compatibility.
> 
> Why does this have to be the case
If we suddenly enforce the existing virtio-balloon, we will break legacy
guests.

Simple example:
Guest with inflated virtio-balloon reboots. Touches inflated memory.
Gets killed at some random point.

Of course, another discussion would be "can't we move virtio-mem
functionality into virtio-balloon instead of changing virtio-balloon".
With the current concept this is also not possible (one region per
device vs. one virtio-balloon device). And I think while similar, these
are two different concepts.

> 
>> virtio-balloon was not
>>    designed to give guarantees. Nobody can hinder the guest from
>>    deflating/reusing inflated memory.
> 
> Reusing without deflate is forbidden with TELL_HOST, right?

TELL_HOST just means "please inform me". There is no way to NACK a
request. It is not a permission to do so, just a "friendly
notification". And this is exactly not what we want when host enforcing
memory access.


> 
>>    In addition, it might make perfect
>>    sense to have both, virtio-balloon and virtio-mem at the same time,
>>    especially looking at the DEFLATE_ON_OOM or STATS features of
>>    virtio-balloon. While virtio-mem is all about guarantees, virtio-
>>    balloon is about cooperation.
> 
> Thanks, and I intend to look more into this next week.
> 

I know that it is tempting to force this concept into virtio-balloon. I
spent quite some time thinking about this (and possible other techniques
like implicit memory deflation on reboots) and decided not to do it. We
just end up trying to hack around all possible things that could go
wrong, while still not being able to handle all requirements properly.

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
