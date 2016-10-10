Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92B6A6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 04:28:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o68so59046507qkf.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 01:28:31 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id p144si15563377qke.61.2016.10.10.01.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 01:28:30 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id n66so6211166qkf.0
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 01:28:30 -0700 (PDT)
Date: Mon, 10 Oct 2016 09:28:28 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20161010082828.GA13595@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com>
 <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer>
 <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
 <20161007162240.GA14350@lucifer>
 <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
 <20161010074712.GB24081@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161010074712.GB24081@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 10, 2016 at 09:47:12AM +0200, Jan Kara wrote:
> Yeah, so my cleanups where mostly concerned about mmap_sem locking and
> reducing number of places which cared about those. Regarding flags for
> get_user_pages() / get_vaddr_frames(), I agree that using flags argument
> as Linus suggests will make it easier to see what the callers actually
> want. So I'm for that.

Great, thanks Jan! I have a draft patch that needs a little tweaking/further
testing but isn't too far off.

One thing I am wondering about is whether functions that have write/force
parameters replaced with gup_flags should mask against (FOLL_WRITE | FOLL_FORCE)
to prevent callers from doing unexpected things with other FOLL_* flags?

I'm inclined _not_ to because it adds a rather non-obvious restriction on this
parameter, reduces clarity about which flags are actually being used (which is
the point of the patch in the first place), and the caller ought to know what
they are doing.

I'd be curious to hear people's thoughts on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
