Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 084F36B03EF
	for <linux-mm@kvack.org>; Tue,  9 May 2017 05:40:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h65so14358849wmd.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 02:40:33 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id g48si17334987wrg.239.2017.05.09.02.40.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 02:40:32 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <b3fab9c3-fa35-eb7b-204c-f85a0d392e12@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <72cc9d16-305e-1856-0bbb-59010b067589@huawei.com>
Date: Tue, 9 May 2017 12:38:58 +0300
MIME-Version: 1.0
In-Reply-To: <b3fab9c3-fa35-eb7b-204c-f85a0d392e12@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 08/05/17 18:25, Laura Abbott wrote:
> On 05/05/2017 03:42 AM, Igor Stoppa wrote:
>> On 04/05/17 19:49, Laura Abbott wrote:

[...]

> PAGE_SIZE is still 4K/16K/64K but the underlying page table mappings
> may use larger mappings (2MB, 32M, 512M, etc.). The ARM architecture
> has a break-before-make requirement which requires old mappings be
> fully torn down and invalidated to avoid TLB conflicts. This is nearly
> impossible to do correctly on live page tables so the current policy
> is to not break down larger mappings.

ok, but if a system integrator chooses to have the mapping set to 512M
(let's consider a case that is definitely unoptimized), this granularity
will apply to anything that needs to be marked as R/O and is allocated
through linear mapping.

If the issue inherently sits with linear allocation, then maybe the
correct approach is to confirm if linear allocation is really needed, in
the first place.
Maybe not, at least for the type of data I have in mind.

However, that would require changes in the users of the interface,
rather than the interface itself.

I don't see this change as a problem, in general, but OTOH I do not know
yet if there are legitimate reasons to use kmalloc for any
post-init-read-only data.

Of course, if you have any proposal that would solve this problem with
large pages, I'd be interested to know.

Also, for me to better understand the magnitude of the problem, do you
know if there is any specific scenario where larger mappings would be
used/recommended?

The major reason for using larger mapping that I can think of, is to
improve the efficiency of the TLB when under pressure, however I
wouldn't be able to judge how much this can affect the overall
performance a big iron or in a small device.

Do you know if there is any similar case that has to deal with locking
down large pages?
Doesn't the kernel text have potentially a similar risks of leaving
large amount of memory unused?
Is rodata only virtual?

> I'd rather see this designed as being mandatory from the start and then
> provide a mechanism to turn it off if necessary. The uptake and
> coverage from opt-in features tends to be very low based on past experience.

I have nothing against such wish, actually I'd love it, but I'm not sure
I have the answer for it.

Yet, a partial solution is better than nothing, if there is no truly
flexible one.

--
igor


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
