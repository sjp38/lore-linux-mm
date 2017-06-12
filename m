Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05F216B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 16:34:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u51so18265325qte.15
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 13:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o21si9725687qtf.242.2017.06.12.13.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 13:34:10 -0700 (PDT)
Date: Mon, 12 Jun 2017 23:34:06 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
Message-ID: <20170612194438-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
 <20170612181354-mutt-send-email-mst@kernel.org>
 <9d0900f3-9df5-ac63-4069-2d796f2a5bc7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d0900f3-9df5-ac63-4069-2d796f2a5bc7@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Mon, Jun 12, 2017 at 09:42:36AM -0700, Dave Hansen wrote:
> On 06/12/2017 09:28 AM, Michael S. Tsirkin wrote:
> > 
> >> The hypervisor is going to throw away the contents of these pages,
> >> right?
> > It should be careful and only throw away contents that was there before
> > report_unused_page_block was invoked.  Hypervisor is responsible for not
> > corrupting guest memory.  But that's not something an mm patch should
> > worry about.
> 
> That makes sense.  I'm struggling to imagine how the hypervisor makes
> use of this information, though.  Does it make the pages read-only
> before this, and then it knows if there has not been a write *and* it
> gets notified via this new mechanism that it can throw the page away?

Yes, and specifically, this is how it works for migration.  Normally you
start by migrating all of memory, then send updates incrementally if
pages have been modified.  This mechanism allows skipping some pages in
the 1st stage, if they get changed they will be migrated in the 2nd
stage.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
