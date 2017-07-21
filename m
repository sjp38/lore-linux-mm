Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBB236B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 14:02:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so63062781pfj.9
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 11:02:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d10si3394563pln.411.2017.07.21.11.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 11:02:21 -0700 (PDT)
Date: Fri, 21 Jul 2017 12:02:19 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170721180219.GB18697@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
 <20170628220152.28161-2-ross.zwisler@linux.intel.com>
 <20170720152616.GB6664@redhat.com>
 <20170720155922.GA21186@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720155922.GA21186@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Jul 20, 2017 at 09:59:22AM -0600, Ross Zwisler wrote:
> On Thu, Jul 20, 2017 at 11:26:16AM -0400, Vivek Goyal wrote:
<>
> > Hi Ross,
> > 
> > vm_insert_mixed_mkwrite() is same as vm_insert_mixed() except this sets
> > write parameter to inser_pfn() true. Will it make sense to just add
> > mkwrite parameter to vm_insert_mixed() and not add a new helper function.
> > (like insert_pfn()).
> > 
> > Vivek
> 
> Yep, this is how my initial implementation worked:
> 
> https://lkml.org/lkml/2017/6/7/907
> 
> vm_insert_mixed_mkwrite() was the new version that took an extra parameter,
> and vm_insert_mixed() stuck around as a wrapper that supplied a default value
> for the new parameter, so existing call sites didn't need to change and didn't
> need to worry about the new parameter, but so that we didn't duplicate any
> code.
> 
> I changed this to the way that it currently works based on Dan's feedback in
> that same mail thread.

Looking at this again, I agree that duplicating vm_insert_mixed() seems
undesirable.  For v4 I'll add the flag to vm_insert_mixed() and just update
all the call sites instead of adding a separate wrapper for the mkwrite case,
which will fix this duplication and address Dan's naming concerns.

Thanks for the review feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
