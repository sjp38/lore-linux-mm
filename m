Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAB286B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:01:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z80so9148943pff.11
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:01:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r1si379954pgo.519.2017.10.20.01.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 01:01:01 -0700 (PDT)
Date: Fri, 20 Oct 2017 01:00:49 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Qemu-devel] [RFC 2/2] KVM: add virtio-pmem driver
Message-ID: <20171020080049.GA25471@infradead.org>
References: <20171012155027.3277-1-pagupta@redhat.com>
 <20171012155027.3277-3-pagupta@redhat.com>
 <20171017071633.GA9207@infradead.org>
 <1441791227.21027037.1508226056893.JavaMail.zimbra@redhat.com>
 <20171017080236.GA27649@infradead.org>
 <670833322.21037148.1508229041158.JavaMail.zimbra@redhat.com>
 <20171018130339.GB29767@stefanha-x1.localdomain>
 <CAPcyv4h6aFkyHhh4R4DTznbSCLf9CuBoszk0Q1gB5EKNcp_SeQ@mail.gmail.com>
 <20171019080149.GB10089@infradead.org>
 <CAPcyv4j=Cdp68C15HddKaErpve2UGRfSTiL6bHiS=3gQybz9pg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j=Cdp68C15HddKaErpve2UGRfSTiL6bHiS=3gQybz9pg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Stefan Hajnoczi <stefanha@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, Kevin Wolf <kwolf@redhat.com>, haozhong zhang <haozhong.zhang@intel.com>, Jan Kara <jack@suse.cz>, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>, KVM list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, ross zwisler <ross.zwisler@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Nitesh Narayan Lal <nilal@redhat.com>

On Thu, Oct 19, 2017 at 11:21:26AM -0700, Dan Williams wrote:
> The difference is that nvdimm_flush() is not mandatory, and that the
> platform will automatically perform the same flush at power-fail.
> Applications should be able to assume that if they are using MAP_SYNC
> that no other coordination with the kernel or the hypervisor is
> necessary.
> 
> Advertising this as a generic Persistent Memory range to the guest
> means that the guest could theoretically use it with device-dax where
> there is no driver or filesystem sync interface. The hypervisor will
> be waiting for flush notifications and the guest will just issue cache
> flushes and sfence instructions. So, as far as I can see we need to
> differentiate this virtio-model from standard "Persistent Memory" to
> the guest and remove the possibility of guests/applications making the
> wrong assumption.

So add a flag that it is not.  We already have the nd_volatile type,
that is special.  For now only in Linux, but I think adding this type
to the spec eventually would be very useful for efficiently exposing
directly mappable device to VM guests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
