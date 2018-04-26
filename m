Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE0556B0007
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:15:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x134-v6so15065421oif.19
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:15:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r56-v6si7279542ote.163.2018.04.26.10.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 10:15:39 -0700 (PDT)
Date: Thu, 26 Apr 2018 13:15:38 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1499190564.23017177.1524762938762.JavaMail.zimbra@redhat.com>
In-Reply-To: <x49o9i6885e.fsf@segfault.boston.devel.redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-2-pagupta@redhat.com> <CAPcyv4hvrB08XPTbVK0xT2_1Xmaid=-v3OMxJVDTNwQucsOHLA@mail.gmail.com> <CAPcyv4hiowWozV527sQA_e4fdgCYbD6xfG==vepAqu0hxQEQcw@mail.gmail.com> <x49o9i6885e.fsf@segfault.boston.devel.redhat.com>
Subject: Re: [Qemu-devel] [RFC v2 1/2] virtio: add pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, KVM list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Ross Zwisler <ross.zwisler@intel.com>, Qemu Developers <qemu-devel@nongnu.org>, lcapitulino@redhat.com, Linux MM <linux-mm@kvack.org>, niteshnarayanlal@hotmail.com, "Michael S. Tsirkin" <mst@redhat.com>, Christoph Hellwig <hch@infradead.org>, Marcel Apfelbaum <marcel@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Rik van Riel <riel@surriel.com>, Stefan Hajnoczi <stefanha@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Igor Mammedov <imammedo@redhat.com>


> 
> Dan Williams <dan.j.williams@intel.com> writes:
> 
> > [ adding Jeff directly since he has also been looking at
> > infrastructure to track when MAP_SYNC should be disabled ]
> >
> > On Wed, Apr 25, 2018 at 7:21 AM, Dan Williams <dan.j.williams@intel.com>
> > wrote:
> >> On Wed, Apr 25, 2018 at 4:24 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
> >>> This patch adds virtio-pmem driver for KVM
> >>> guest.
> >>
> >> Minor nit, please expand your changelog line wrapping to 72 columns.
> >>
> >>>
> >>> Guest reads the persistent memory range
> >>> information from Qemu over VIRTIO and registers
> >>> it on nvdimm_bus. It also creates a nd_region
> >>> object with the persistent memory range
> >>> information so that existing 'nvdimm/pmem'
> >>> driver can reserve this into system memory map.
> >>> This way 'virtio-pmem' driver uses existing
> >>> functionality of pmem driver to register persistent
> >>> memory compatible for DAX capable filesystems.
> >>
> >> We need some additional enabling to disable MAP_SYNC for this
> 
> enable to disable... I like it!  ;-)
> 
> >> configuration. In other words, if fsync() is required then we must
> >> disable the MAP_SYNC optimization. I think this should be a struct
> >> dax_device property looked up at mmap time in each MAP_SYNC capable
> >> ->mmap() file operation implementation.

I understand you mean we want to disable 'MAP_SYNC' optimization as
we are relying on additional fsync. You mean if we add a property/flag
in dax_device struct and its set, disable 'MAP_SYNC' accordingly during
mmap time for corresponding filesystems?  

> 
> Ideally, qemu (seabios?) would advertise a platform capabilities
> sub-table that doesn't fill in the flush bits.

Could you please elaborate on this, how its related to disabling
MAP_SYNC? We are not doing entire nvdimm device emulation. 

> 
> -Jeff
> 
> 
