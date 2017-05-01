Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5515A6B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:48:31 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z63so52996427ioz.23
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 20:48:31 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 100si12793874ioj.93.2017.04.30.20.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 20:48:30 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
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
 <20170430231421.GA15163@redhat.com>
Message-ID: <6627ee37-9638-0201-c440-9310b46c54d3@deltatee.com>
Date: Sun, 30 Apr 2017 21:48:20 -0600
MIME-Version: 1.0
In-Reply-To: <20170430231421.GA15163@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>



On 30/04/17 05:14 PM, Jerome Glisse wrote:
> HMM ZONE_DEVICE pages are use like other pages (anonymous or file back page)
> in _any_ vma. So i need to know when a page is freed ie either as result of
> unmap, exit or migration or anything that would free the memory. For zone
> device a page is free once its refcount reach 1 so i need to catch refcount
> transition from 2->1
> 
> This is the only way i can inform the device that the page is now free. See
> 
> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-v21&id=52da8fe1a088b87b5321319add79e43b8372ed7d
> 
> There is _no_ way around that.

I had a similar issue in a piece of my p2pmem RFC [1]. I hacked around
it by tracking the pages separately and freeing them when the vma is
closed. This is by no means a great solution, it certainly has it's own
warts. However, maybe it will spark some ideas for some alternate
choices which avoid the hot path.

Another thing I briefly looked at was hooking the vma close process
earlier so that it would callback in time that you can loop through the
pages and do your free process. Of course this all depends on the vma
not getting closed while the pages have other references. So it may not
work at all. Again, just ideas.

Logan


[1]
https://github.com/sbates130272/linux-p2pmem/commit/77c631d92cb5c451c9824b3a4cf9b6cddfde6bb7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
