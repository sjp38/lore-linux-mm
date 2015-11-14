Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B94836B0257
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:20:41 -0500 (EST)
Received: by wmvv187 with SMTP id v187so104525935wmv.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:20:41 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id u4si29524977wjq.30.2015.11.13.16.20.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 16:20:40 -0800 (PST)
Received: by wmww144 with SMTP id w144so48537321wmw.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:20:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
	<1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
Date: Fri, 13 Nov 2015 16:20:39 -0800
Message-ID: <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Nov 13, 2015 at 4:06 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> Currently the PMEM driver doesn't accept REQ_FLUSH or REQ_FUA bios.  These
> are sent down via blkdev_issue_flush() in response to a fsync() or msync()
> and are used by filesystems to order their metadata, among other things.
>
> When we get an msync() or fsync() it is the responsibility of the DAX code
> to flush all dirty pages to media.  The PMEM driver then just has issue a
> wmb_pmem() in response to the REQ_FLUSH to ensure that before we return all
> the flushed data has been durably stored on the media.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Hmm, I'm not seeing why we need this patch.  If the actual flushing of
the cache is done by the core why does the driver need support
REQ_FLUSH?  Especially since it's just a couple instructions.  REQ_FUA
only makes sense if individual writes can bypass the "drive" cache,
but no I/O submitted to the driver proper is ever cached we always
flush it through to media.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
