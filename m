Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 091216B027B
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:11:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c84so597268pfb.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:11:21 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y66si4017818pgb.94.2016.10.26.11.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:11:20 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5810F1C7.4060807@intel.com>
Date: Wed, 26 Oct 2016 11:11:19 -0700
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

On 10/26/2016 03:06 AM, Li, Liang Z wrote:
> I am working on Dave's new bitmap schema, I have finished the part of
> getting the 'hybrid scheme bitmap' and found the complexity was more
> than I expected. The main issue is more memory is required to save
> the 'hybrid scheme bitmap' beside that used to save the raw page
> bitmap, for the worst case, the memory required is 3 times than that
> in the previous implementation.

Really?  Could you please describe the scenario where this occurs?

> I am wondering if I should continue, as an alternative solution, how about using PFNs array when
> inflating/deflating only a few pages? Things will be much more
> simple.

Yes, using pfn lists is more efficient than using bitmaps for sparse
bitmaps.  Yes, there will be cases where it is preferable to just use
pfn lists vs. any kind of bitmap.

But, what does it matter?  At least with your current scheme where we go
out and collect get_unused_pages(), we do the allocation up front.  The
space efficiency doesn't matter at all for small sizes since we do the
constant-size allocation *anyway*.

I'm also pretty sure you can pack the pfn and page order into a single
64-bit word and have no bitmap for a given record.  That would make it
pack just as well as the old pfns alone.  Right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
