Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B30826B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 17:10:22 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j28so7108555wrd.17
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 14:10:22 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q138si1384302wmb.233.2018.03.02.14.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 14:10:21 -0800 (PST)
Date: Fri, 2 Mar 2018 23:10:20 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 00/12] vfio, dax: prevent long term filesystem-dax
	pins and other fixes
Message-ID: <20180302221020.GA30722@lst.de>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, kvm@vger.kernel.org, Haozhong Zhang <haozhong.zhang@intel.com>, Jane Chu <jane.chu@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Gerd Rausch <gerd.rausch@oracle.com>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I really don't like these IS_DEVDAX and IS_FSDAX flags.  We should
stop pretending DAX is a global per-inode choice and get rid of these
magic flags entirely.  So please convert the instances inside the
various file systems to checking the file system mount options instead.

For the core ones we'll need to differentiate:

 - the checks in generic_file_read_iter and __generic_file_write_iter
   seem to not be needed anymore at all since we stopped abusing the
   direct I/O code for DAX, so they should probably be removed.
 - io_is_direct is a weird check and should probably just go away,
   as there is not point in always setting IOCB_DIRECT for DAX I/O
 - fadvise should either become a file op, or a flag on the inode that
   fadvice is supported instead of the nasty noop_backing_dev_info or
   DAX check.
 - Ditto for madvise
 - vma_is_dax should probably be replaced with a VMA flag.
 - thp_get_unmapped_area I don't really understand why we have a dax
   check there.
 - dax_mapping will be much harder to sort out.

But all these DAX flags certainly look like a major hodge podge to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
