Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E68526B000A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:55:59 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j19-v6so12654216oii.11
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:55:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r36-v6si6641635ote.94.2018.04.25.07.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 07:55:59 -0700 (PDT)
Date: Wed, 25 Apr 2018 10:55:57 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <634642140.22649359.1524668157371.JavaMail.zimbra@redhat.com>
In-Reply-To: <25f3e433-cfa6-4a62-ba7f-47aef1119dfc@redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-4-pagupta@redhat.com> <25f3e433-cfa6-4a62-ba7f-47aef1119dfc@redhat.com>
Subject: Re: [Qemu-devel] [RFC v2] qemu: Add virtio pmem device
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Blake <eblake@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, kwolf@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, jack@suse.cz, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, riel@surriel.com, niteshnarayanlal@hotmail.com, david@redhat.com, ross zwisler <ross.zwisler@intel.com>, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, pbonzini@redhat.com, marcel@redhat.com, imammedo@redhat.com, dan j williams <dan.j.williams@intel.com>, nilal@redhat.com


> 
> On 04/25/2018 06:24 AM, Pankaj Gupta wrote:
> > This patch adds virtio-pmem Qemu device.
> > 
> > This device presents memory address range
> > information to guest which is backed by file
> > backend type. It acts like persistent memory
> > device for KVM guest. Guest can perform read
> > and persistent write operations on this memory
> > range with the help of DAX capable filesystem.
> > 
> > Persistent guest writes are assured with the
> > help of virtio based flushing interface. When
> > guest userspace space performs fsync on file
> > fd on pmem device, a flush command is send to
> > Qemu over VIRTIO and host side flush/sync is
> > done on backing image file.
> > 
> > This PV device code is dependent and tested
> > with 'David Hildenbrand's ' patchset[1] to
> > map non-PCDIMM devices to guest address space.
> 
> This sentence doesn't belong in git history.  It is better to put
> information like this...
> 
> > There is still upstream discussion on using
> > among PCI bar vs memory device, will update
> > as per concensus.
> 
> s/concensus/consensus/
> 
> > 
> > [1] https://marc.info/?l=qemu-devel&m=152450249319168&w=2
> > 
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > ---
> 
> ...here, where it is part of the email, but not picked up by 'git am'.

I see.

Thanks!
> 
> 
> > +++ b/qapi/misc.json
> > @@ -2871,6 +2871,29 @@
> >            }
> >  }
> >  
> > +##
> > +# @VirtioPMemDeviceInfo:
> > +#
> > +# VirtioPMem state information
> > +#
> > +# @id: device's ID
> > +#
> > +# @start: physical address, where device is mapped
> > +#
> > +# @size: size of memory that the device provides
> > +#
> > +# @memdev: memory backend linked with device
> > +#
> > +# Since: 2.13
> > +##
> > +{ 'struct': 'VirtioPMemDeviceInfo',
> > +    'data': { '*id': 'str',
> > +	      'start': 'size',
> > +	      'size': 'size',
> 
> TAB damage.

o.k

> 
> > +              'memdev': 'str'
> > +	    }
> > +}
> > +
> >  ##
> >  # @MemoryDeviceInfo:
> >  #
> > @@ -2880,7 +2903,8 @@
> >  ##
> >  { 'union': 'MemoryDeviceInfo',
> >    'data': { 'dimm': 'PCDIMMDeviceInfo',
> > -            'nvdimm': 'PCDIMMDeviceInfo'
> > +            'nvdimm': 'PCDIMMDeviceInfo',
> > +	    'virtio-pmem': 'VirtioPMemDeviceInfo'
> >            }
> >  }
> >  
> > 
> 
> --
> Eric Blake, Principal Software Engineer
> Red Hat, Inc.           +1-919-301-3266
> Virtualization:  qemu.org | libvirt.org
> 
> 
