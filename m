Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 188E46B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 03:50:14 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vp2so216188362pab.3
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 00:50:14 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0113.outbound.protection.outlook.com. [104.47.40.113])
        by mx.google.com with ESMTPS id p20si4051758pag.161.2016.09.10.00.50.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 10 Sep 2016 00:50:13 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Sat, 10 Sep 2016 07:50:09 +0000
Message-ID: <DM2PR21MB008913DB5F899CCCDCC7FCF7CBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com>
 <20160910073151.GB5295@infradead.org>
In-Reply-To: <20160910073151.GB5295@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas
 Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

From: Christoph Hellwig [mailto:hch@infradead.org]
> On Fri, Sep 09, 2016 at 03:34:43PM -0700, Dan Williams wrote:
> > I agree with you that continuing to touch ext2 is not a good idea, but
> > I'm not yet convinced that now is the time to go do dax-2.0 when we
> > haven't finished shipping dax-1.0.
>=20
> I've mentioned this before, but I'd like to repeat it.  With all the work=
 reqwuired
> in the file system I would prefer to drop DAX support in ext2 (and if peo=
ple
> really cry for it reinstate the trivial old xip support).

That allegedly trivial old xip support was horrendously broken.  And, er, i=
t used an aop
which you seem implacably opposed to in your earlier email.  And that was t=
ruly a
disgusting one from a layering point of view.  Let me remind you:

-=A0=A0=A0=A0=A0=A0=A0int=A0(*get_xip_mem)(struct=A0address_space=A0*,=A0pg=
off_t,=A0int,
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0void=
=A0**,=A0unsigned=A0long=A0*);

That void ** was an 'out' parameter to store a kernel address for the memor=
y.  The
unsigned long * was also an 'out' parameter to store the PFN for the memory=
.  The
'int' was actually a Boolean for whether to create or not, but you'd actual=
ly have to
go look at the implementation to find that out; the documentation never sai=
d it.  A
real dog's breakfast of an API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
