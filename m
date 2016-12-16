Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5406B0273
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 11:01:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 81so94472478iog.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:01:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si6365696ioi.183.2016.12.16.08.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 08:01:15 -0800 (PST)
Date: Fri, 16 Dec 2016 17:01:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Message-ID: <20161216160112.GC6168@redhat.com>
References: <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
 <060287c7-d1af-45d5-70ea-ad35d4bbeb84@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C31D0E6@SHSMSX104.ccr.corp.intel.com>
 <01886693-c73e-3696-860b-086417d695e1@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C32985A@shsmsx102.ccr.corp.intel.com>
 <f517bfbe-18b8-6962-5c57-545f6ef47ad0@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3C32A8D6@shsmsx102.ccr.corp.intel.com>
 <84ac9822-880d-b998-52ca-6aa87e0f7a43@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84ac9822-880d-b998-52ca-6aa87e0f7a43@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Thu, Dec 15, 2016 at 05:40:45PM -0800, Dave Hansen wrote:
> On 12/15/2016 05:38 PM, Li, Liang Z wrote:
> > 
> > Use 52 bits for 'pfn', 12 bits for 'length', when the 12 bits is not long enough for the 'length'
> > Set the 'length' to a special value to indicate the "actual length in next 8 bytes".
> > 
> > That will be much more simple. Right?
> 
> Sounds fine to me.
> 

Sounds fine to me too indeed.

I'm only wondering what is the major point for compressing gpfn+len in
8 bytes in the common case, you already use sg_init_table to send down
two pages, we could send three as well and avoid all math and bit
shifts and ors, or not?

I agree with the above because from a performance prospective I tend
to think the above proposal will run at least theoretically faster
because the other way is to waste double amount of CPU cache, and bit
mangling in the encoding and the later decoding on qemu side should be
faster than accessing an array of double size, but then I'm not sure
if it's measurable optimization. So I'd be curious to know the exact
motivation and if it is to reduce the CPU cache usage or if there's
some other fundamental reason to compress it.

The header already tells qemu how big is the array payload, couldn't
we just add more pages if one isn't enough?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
