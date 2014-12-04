Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 184796B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 01:11:11 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so17446067pab.0
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 22:11:10 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id oj10si41596136pdb.108.2014.12.03.22.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 22:11:09 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Thu, 4 Dec 2014 14:10:53 +0800
Subject: RE: [RFC V2] mm:add zero_page _mapcount when mapped into user space
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313E6@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313E0@CNBJMBX05.corpusers.net>
 <20141202113014.GA22683@node.dhcp.inet.fi>
In-Reply-To: <20141202113014.GA22683@node.dhcp.inet.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

> -----Original Message-----
> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Tuesday, December 02, 2014 7:30 PM
> To: Wang, Yalin
> Cc: 'linux-kernel@vger.kernel.org'; 'linux-mm@kvack.org'; 'linux-arm-
> kernel@lists.infradead.org'
> Subject: Re: [RFC V2] mm:add zero_page _mapcount when mapped into user
> space
>=20
> On Tue, Dec 02, 2014 at 05:27:36PM +0800, Wang, Yalin wrote:
> > This patch add/dec zero_page's _mapcount to make sure the mapcount is
> > correct for zero_page, so that when read from /proc/kpagecount,
> > zero_page's mapcount is also correct, userspace process like procrank
> > can calculate PSS correctly.
>=20
> I don't have specific code path to point to, but I would expect zero page
> with non-zero mapcount would cause a problem with rmap.
>=20
> How do you test the change?
>=20
I just test it to see the mapcount from /proc/pid/pagemap  and /proc/kpagec=
ount ,
It works well,
The problem is that when I see /proc/pid/smaps ,
The Rss / Pss don't calculate zero_page map,
Because smaps_pte_entry() --> vm_normal_page( ),
Will return NULL for zero_page,

But when userspace process cat /proc/pid/pagemap  ,
It will see zero_page mapped,
And will treat as Rss , =20
This is weird, should we also omit zero_page in /proc/pid/pagemap ?
Or add zero_page as Rss in /proc/pid/smaps ?=20

I think we should add zero_page into Rss ,
Because it is really mapped into userspace address space.
And will let userspace memory analysis more accurate .

Thanks





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
