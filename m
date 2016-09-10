Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE7F6B025E
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 11:55:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so236063305pad.2
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 08:55:20 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0138.outbound.protection.outlook.com. [104.47.34.138])
        by mx.google.com with ESMTPS id s64si10390165pfk.75.2016.09.10.08.55.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 10 Sep 2016 08:55:19 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Sat, 10 Sep 2016 15:55:17 +0000
Message-ID: <DM2PR21MB0089423BC46778AC1A511995CBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <20160910073012.GA5295@infradead.org>
In-Reply-To: <20160910073012.GA5295@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas
 Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

From: Christoph Hellwig [mailto:hch@infradead.org]
> Either way we need to get rid of buffer_heads, and another aop that is en=
tirely
> caller specific is unaceptable.

I finally figured out what you actually meant by this.  You mean that inste=
ad of having an aop->populate_pfn, you want to define a populate_pfn_t call=
back and pass it in.

Something like this:

int ext2_populate_pfn(struct address_space *mapping, pgoff_t pgoff)
{
	struct iomap iomap;
	...
	return dax_populate_pfn(mapping, pgoff, &iomap);
}

int ext2_dax_fault(vma, vmf)
{
	...
	ret =3D dax_fault(vma, vmf, ext2_populate_pfn);
	...
}

I don't have a problem with that.  I'll work up something along those lines=
 next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
