Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8654B6B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:45:10 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c26so48468627itd.16
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:45:10 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id p6si12880934iop.169.2017.04.30.19.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 19:45:09 -0700 (PDT)
Received: by mail-io0-x233.google.com with SMTP id a103so102891261ioj.1
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 19:45:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170429141838.tkyfxhldmwypyipz@gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com> <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170429141838.tkyfxhldmwypyipz@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 30 Apr 2017 19:45:08 -0700
Message-ID: <CAPcyv4i8WrNPzu_-Lu1uKi8NT-vj1PF0h0SW_Pi=QGn5PPhQfQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Sat, Apr 29, 2017 at 7:18 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dan Williams <dan.j.williams@intel.com> wrote:
>
>> Kirill points out that the calls to {get,put}_dev_pagemap() can be
>> removed from the mm fast path if we take a single get_dev_pagemap()
>> reference to signify that the page is alive and use the final put of the
>> page to drop that reference.
>>
>> This does require some care to make sure that any waits for the
>> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
>> since it now maintains its own elevated reference.
>>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>> Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
>> Tested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> This changelog is lacking an explanation about how this solves the crashe=
s you
> were seeing.
>

Kirill? It wasn't clear to me why the conversion to generic
get_user_pages_fast() caused the reference counts to be off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
