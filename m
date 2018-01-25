Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7A80800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 22:56:04 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id v8so3899725oth.0
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:56:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o64sor190004oik.109.2018.01.24.19.56.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 19:56:03 -0800 (PST)
MIME-Version: 1.0
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Jan 2018 19:56:02 -0800
Message-ID: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
Subject: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-nvdimm@lists.01.org, jgg@mellanox.com

The get_user_pages_longterm() api was recently added as a stop-gap
measure to prevent applications from growing dependencies on the
ability to to pin DAX-mapped filesystem blocks for RDMA indefinitely
with no ongoing coordination with the filesystem. This 'longterm'
pinning is also problematic for the non-DAX VMA case where the core-mm
needs a time bounded way to revoke a pin and manipulate the physical
pages. While existing RDMA applications have already grown the
assumption that they can pin page-cache pages indefinitely, the fact
that we are breaking this assumption for filesystem-dax presents an
opportunity to deprecate the 'indefinite pin' mechanisms and move to a
general interface that supports pin revocation.

While RDMA may grow an explicit Infiniband-verb for this 'memory
registration with lease' semantic, it seems that this problem is
bigger than just RDMA. At LSF/MM it would be useful to have a
discussion between fs, mm, dax, and RDMA folks about addressing this
problem at the core level.

Particular people that would be useful to have in attendance are
Michal Hocko, Christoph Hellwig, and Jason Gunthorpe (cc'd).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
