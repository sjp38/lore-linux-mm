Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD966B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 22:13:30 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id id10so1383674vcb.13
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:13:30 -0700 (PDT)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id zb8si2049131vdb.58.2014.05.29.19.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 19:13:29 -0700 (PDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so1405376veb.29
        for <linux-mm@kvack.org>; Thu, 29 May 2014 19:13:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140530015852.GG14410@dastard>
References: <20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox>
	<CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
	<20140530002021.GM10092@bbox>
	<CA+55aFxjXf5xLKGFBjUWimn8-=rj0=g3pku9O1MvGSoDUcEQAw@mail.gmail.com>
	<20140530005042.GO10092@bbox>
	<CA+55aFz84toJOqnuphA99c0av1nLzxcxfjiTwhBbxzaNs3J6NQ@mail.gmail.com>
	<20140530015852.GG14410@dastard>
Date: Thu, 29 May 2014 19:13:29 -0700
Message-ID: <CA+55aFy+Qx2f9SSoy18ou9xehL=TFdro4tc1_64v1jQmpXYKrg@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 6:58 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> If the patch I sent solves the swap stack usage issue, then perhaps
> we should look towards adding "blk_plug_start_async()" to pass such
> hints to the plug flushing. I'd want to use the same behaviour in
> __xfs_buf_delwri_submit() for bulk metadata writeback in XFS, and
> probably also in mpage_writepages() for bulk data writeback in
> WB_SYNC_NONE context...

Yeah, adding a flag to the plug about what kind of plug it is does
sound quite reasonable. It already has that "magic" field, it could
easily be extended to have a "async" vs "sync" bit to it..

Of course, it's also possible that the unplugging code could just look
at the actual requests that are plugged to determine that, and maybe
we wouldn't even need to mark things specially. I don't think we ever
end up mixing reads and writes under the same plug, so "first request
is a write" is probably a good approximation for "async".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
