Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2C0B6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 06:35:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 49so4607564wrw.12
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:35:26 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id u11si937347edj.508.2017.08.16.03.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 03:35:25 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id y67so2281542wrb.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:35:25 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:25:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 3/3] fs, xfs: introduce MAP_DIRECT for creating
 block-map-sealed file ranges
Message-ID: <20170816102526.kksbsvcr5cqcf35k@node.shutemov.name>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277754211.23945.458876600578531019.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170815091836.c3xpsfgfwz7w35od@node.shutemov.name>
 <CAPcyv4gmyFugKwMJCVwC9wFmQ8TL4TbHsa0p2Pqg2a6LziRHVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gmyFugKwMJCVwC9wFmQ8TL4TbHsa0p2Pqg2a6LziRHVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Tue, Aug 15, 2017 at 10:11:27AM -0700, Dan Williams wrote:
> > We had issues before with user-imposed ETXTBSY. See MAP_DENYWRITE.
> >
> > Are we sure it won't a source of denial-of-service attacks?
> 
> I believe MAP_DENYWRITE allowed any application with read access to be
> able to deny writes which is obviously problematic. MAP_DIRECT is
> different. You need write access to the file so you can already
> destroy data that another application might depend on, and this only
> blocks allocation and reflink.
> 
> However, I'm not opposed to adding more safety around this. I think we
> can address this concern with an fcntl seal as Dave suggests, but the
> seal only applies to the 'struct file' instance and only gates whether
> MAP_DIRECT is allowed on that file. The act of setting
> F_MAY_SEAL_IOMAP requires CAP_IMMUTABLE, but MAP_DIRECT does not. This
> allows the 'permission to mmap(MAP_DIRECT)' to be passed around with
> an open file descriptor.

Sounds like a good approach to me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
