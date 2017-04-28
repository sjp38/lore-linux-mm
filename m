Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88EDF6B0038
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 14:00:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u30so14928897qtu.14
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 11:00:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y129si6404437qke.157.2017.04.28.11.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 11:00:13 -0700 (PDT)
Date: Fri, 28 Apr 2017 14:00:06 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
In-Reply-To: <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com> <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com> <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com> <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

> On Fri, Apr 28, 2017 at 10:34 AM, Jerome Glisse <jglisse@redhat.com> wrot=
e:
> >> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> >> removed from the mm fast path if we take a single get_dev_pagemap()
> >> reference to signify that the page is alive and use the final put of t=
he
> >> page to drop that reference.
> >>
> >> This does require some care to make sure that any waits for the
> >> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> >> since it now maintains its own elevated reference.
> >
> > This is NAK from HMM point of view as i need those call. So if you remo=
ve
> > them now i will need to add them back as part of HMM.
>=20
> I thought you only need them at page free time? You can still hook
> __put_page().

No, i need a hook when page refcount reach 1, not 0. That being said
i don't care about put_dev_pagemap(page->pgmap); so that part of the
patch is fine from HMM point of view but i definitly need to hook my-
self in the general put_page() function.

So i will have to undo part of this patch for HMM (put_page() will
need to handle ZONE_DEVICE page differently).

Cheers,
J=C3=A9r=C3=B4me=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
