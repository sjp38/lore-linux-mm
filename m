Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 921416B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 11:33:48 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so82096488pdb.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:33:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id rb4si2811309pac.46.2015.07.13.08.33.47
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 08:33:47 -0700 (PDT)
Date: Mon, 13 Jul 2015 11:33:45 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 07/10] dax: Add huge page fault support
Message-ID: <20150713153345.GI13681@linux.intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
 <1436560165-8943-8-git-send-email-matthew.r.wilcox@intel.com>
 <20150713150500.GB17075@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713150500.GB17075@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 13, 2015 at 05:05:00PM +0200, Jan Kara wrote:
> So if this is a writeable fault and we race with truncate, we can leave
> stale blocks beyond i_size, can't we? Ah, looking at dax_insert_mapping()
> this seems to be a documented quirk of DAX mmap code. Would be worth
> mentioning here as well so that people don't wonder...

Thanks!

-       /* Guard against a race with truncate */
+       /*
+        * If a truncate happened while we were allocating blocks, we may
+        * leave blocks allocated to the file that are beyond EOF.  We can't
+        * take i_mutex here, so just leave them hanging; they'll be freed
+        * when the file is deleted.
+        */

is what I'll commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
