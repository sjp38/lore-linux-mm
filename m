Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A70306B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:14:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f23so23749847qkh.21
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 16:14:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 83si12702513qky.280.2017.04.30.16.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 16:14:28 -0700 (PDT)
Date: Sun, 30 Apr 2017 19:14:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170430231421.GA15163@redhat.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
 <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
 <20170428193305.GA3912@redhat.com>
 <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Sat, Apr 29, 2017 at 01:17:26PM +0300, Kirill A. Shutemov wrote:
> On Fri, Apr 28, 2017 at 03:33:07PM -0400, Jerome Glisse wrote:
> > On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
> > > Are you sure about needing to hook the 2 -> 1 transition? Could we
> > > change ZONE_DEVICE pages to not have an elevated reference count when
> > > they are created so you can keep the HMM references out of the mm hot
> > > path?
> > 
> > 100% sure on that :) I need to callback into driver for 2->1 transition
> > no way around that. If we change ZONE_DEVICE to not have an elevated
> > reference count that you need to make a lot more change to mm so that
> > ZONE_DEVICE is never use as fallback for memory allocation. Also need
> > to make change to be sure that ZONE_DEVICE page never endup in one of
> > the path that try to put them back on lru. There is a lot of place that
> > would need to be updated and it would be highly intrusive and add a
> > lot of special cases to other hot code path.
> 
> Could you explain more on where the requirement comes from or point me to
> where I can read about this.
> 

HMM ZONE_DEVICE pages are use like other pages (anonymous or file back page)
in _any_ vma. So i need to know when a page is freed ie either as result of
unmap, exit or migration or anything that would free the memory. For zone
device a page is free once its refcount reach 1 so i need to catch refcount
transition from 2->1

This is the only way i can inform the device that the page is now free. See

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=52da8fe1a088b87b5321319add79e43b8372ed7d

There is _no_ way around that.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
