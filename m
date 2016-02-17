Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5CCF96B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 23:14:18 -0500 (EST)
Received: by mail-qk0-f174.google.com with SMTP id s5so1867066qkd.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:14:18 -0800 (PST)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id l19si322775qgd.44.2016.02.16.20.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 20:14:17 -0800 (PST)
Received: by mail-qk0-x236.google.com with SMTP id o6so1859419qkc.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 20:14:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
References: <1455207177-11949-1-git-send-email-artemyko@mellanox.com>
 <20160211191838.GA23675@obsidianresearch.com> <56C08EC8.10207@mellanox.com>
 <20160216182212.GA21071@obsidianresearch.com> <CAPSaadxbFCOcKV=c3yX7eGw9Wqzn3jvPRZe2LMWYmiQcijT4nw@mail.gmail.com>
From: davide rossetti <davide.rossetti@gmail.com>
Date: Tue, 16 Feb 2016 20:13:58 -0800
Message-ID: <CAPSaadx3vNBSxoWuvjrTp2n8_-DVqofttFGZRR+X8zdWwV86nw@mail.gmail.com>
Subject: Re: [RFC 0/7] Peer-direct memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Haggai Eran <haggaie@mellanox.com>, Kovalyov Artemy <artemyko@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "leon@leon.ro" <leon@leon.ro>, Sagi Grimberg <sagig@mellanox.com>

resending, sorry

On Tue, Feb 16, 2016 at 10:22 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
>
> On Sun, Feb 14, 2016 at 04:27:20PM +0200, Haggai Eran wrote:
> > [apologies: sending again because linux-mm address was wrong]
> >
> > On 11/02/2016 21:18, Jason Gunthorpe wrote:
> > > Resubmit those parts under the mm subsystem, or another more
> > > appropriate place.
> >
> > We want the feedback from linux-mm, and they are now Cced.
>
> Resubmit to mm means put this stuff someplace outside
> drivers/infiniband in the tree and don't try and inappropriately send
> memory management stuff through Doug's tree.
>

Jason,
I beg to differ.

1) I see mm as appropriate for real memory, i.e. something that
user-space apps can pass around. This is not totally true for BAR
memory, for instance:
 a) as long as CPU initiated atomic ops are not supported on BAR space
of PCIe devices.
 b) OTOT, CPU reading from BAR is awful (BW being abysmal,~10MB/s),
while high BW writing requires use of vector instructions (at least on
x86_64).
Bottom line is, BAR mappings are not like plain memory.

2) Instead, I see appropriate that two sophisticated devices, like an
IB NIC and a storage/accelerator device, can freely target each other
for I/O, i.e. exchanging peer-to-peer PCIe transactions. And as long
as the existing sophisticated initiators are confined to the RDMA
subsystem, that is where this support belongs to.

On a different note, this reminds me that the current patch set may be
missing a way to disable the use of platform PCIe atomics when the
target is the BAR of a peer device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
