Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6591F6B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:57:34 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id o131so132548922ywc.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:57:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d35si2776382qgf.109.2016.04.27.08.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:57:33 -0700 (PDT)
Date: Wed, 27 Apr 2016 17:57:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: kvm: fix memory corruption in KVM with THP
 enabled
Message-ID: <20160427155730.GB11700@redhat.com>
References: <1461758686-27157-1-git-send-email-aarcange@redhat.com>
 <20160427135030.GB22035@node.shutemov.name>
 <20160427145957.GA9217@redhat.com>
 <20160427151834.GC22035@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427151834.GC22035@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On Wed, Apr 27, 2016 at 06:18:34PM +0300, Kirill A. Shutemov wrote:
> Okay, I see.
> 
> But do we really want to make PageTransCompoundMap() visiable beyond KVM
> code? It looks like too KVM-specific.

Any other secondary MMU notifier manager (KVM is just one of the many
MMU notifier users) will need the same information if it doesn't want
to run a flood of get_user_pages_fast and it can support multiple
granularity in the secondary MMU mappings, so I think it is justified
to be exposed not just to KVM.

The other option would be to move transparent_hugepage_adjust to
mm/huge_memory.c but that currently has all kind of KVM data
structures in it, so it's definitely not a cut-and-paste work, so I
couldn't do a fix as cleaner as this one for 4.6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
