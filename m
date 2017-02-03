Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92F3D6B0069
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:20:56 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so40039585pfa.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:20:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o2si21974895pga.229.2017.02.03.15.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:20:55 -0800 (PST)
Date: Fri, 3 Feb 2017 15:20:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Avoid returning VM_FAULT_RETRY from ->page_mkwrite
 handlers
Message-Id: <20170203152054.6ee9f8a920e6d0ac8a93d2b9@linux-foundation.org>
In-Reply-To: <20170203150729.15863-1-jack@suse.cz>
References: <20170203150729.15863-1-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

On Fri,  3 Feb 2017 16:07:29 +0100 Jan Kara <jack@suse.cz> wrote:

> Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> from ->page_mkwrite is completely unhandled by the mm code and results
> in locking and writeably mapping the page which definitely is not what
> the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> results in bailing out from the fault code, the CPU then retries the
> access, and we fault again effectively doing what the handler wanted.

I'm not getting any sense of the urgency of this fix.  The bug *sounds*
bad?  Which kernel versions need fixing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
