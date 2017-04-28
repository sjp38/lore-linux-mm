Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 047D46B02F4
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 13:41:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l11so33740096iod.15
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 10:41:24 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id t138si55461ita.48.2017.04.28.10.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 10:41:23 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id r16so71576867ioi.2
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 10:41:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com> <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Apr 2017 10:41:22 -0700
Message-ID: <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Fri, Apr 28, 2017 at 10:34 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>> Kirill points out that the calls to {get,put}_dev_pagemap() can be
>> removed from the mm fast path if we take a single get_dev_pagemap()
>> reference to signify that the page is alive and use the final put of the
>> page to drop that reference.
>>
>> This does require some care to make sure that any waits for the
>> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
>> since it now maintains its own elevated reference.
>
> This is NAK from HMM point of view as i need those call. So if you remove
> them now i will need to add them back as part of HMM.

I thought you only need them at page free time? You can still hook __put_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
