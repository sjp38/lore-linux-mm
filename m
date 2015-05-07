Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A696E6B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 10:42:15 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so41955928pab.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 07:42:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h4si3057490pdi.136.2015.05.07.07.42.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 07:42:14 -0700 (PDT)
Message-ID: <554B79C0.5060807@parallels.com>
Date: Thu, 7 May 2015 17:42:08 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
References: <5509D342.7000403@parallels.com> <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com> <55425A74.3020604@parallels.com> <20150507134236.GB13098@redhat.com> <554B769E.1040000@parallels.com> <20150507143343.GG13098@redhat.com>
In-Reply-To: <20150507143343.GG13098@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>

On 05/07/2015 05:33 PM, Andrea Arcangeli wrote:
> On Thu, May 07, 2015 at 05:28:46PM +0300, Pavel Emelyanov wrote:
>> Yup, this is very close to what I did in my set -- introduced a message to
>> report back to the user-space on read. But my message is more than 8+2*1 bytes,
>> so we'll have one message for 0xAA API and another one for 0xAB (new) one :)
> 
> I slightly altered it to fix an issue with packet alignments so it'd
> be 16bytes.
> 
> How big is your msg currently? Could we get to use the same API?

Right now it's like this

struct uffd_event {
        __u64 type;
        union {
                struct {
                        __u64 addr;
                } pagefault;

                struct {
                        __u32 ufd;
                } fork;

                struct {
                        __u64 from;
                        __u64 to;
                        __u64 len;
                } remap;
        } arg;
};

where .type is your uffd_msg.event and the rest is event-specific.

> UFFDIO_REGISTER_MODE_FORK
> 
> or 
> 
> UFFDIO_REGISTER_MODE_NON_COOPERATIVE would differentiate if you want
> to register for fork/mremap/dontneed events as well or only the
> default (UFFD_EVENT_PAGEFAULT).

I planned to use this in UFFDIO_API call -- the uffdio_api.features will
be in-out argument denoting the bits user needs and reporting what kernel
can.

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
