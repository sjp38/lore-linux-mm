Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B30E2803BB
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 01:18:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i187so4354416wma.15
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 22:18:23 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id 39si2924498wrc.468.2017.08.03.22.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 22:18:21 -0700 (PDT)
Date: Fri, 4 Aug 2017 06:18:16 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 2/2] fsnotify: use method copy_dname copying filename
Message-ID: <20170804051816.GI2063@ZenIV.linux.org.uk>
References: <20170531035423.70970-1-leilei.lin@alibaba-inc.com>
 <20170531035423.70970-3-leilei.lin@alibaba-inc.com>
 <CALPjY3mAV40cMD_iE=WVx2upxwgUYwBH-gdpgWY+RichywajfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALPjY3mAV40cMD_iE=WVx2upxwgUYwBH-gdpgWY+RichywajfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?5p6X5a6I56OK?= <linxiulei@gmail.com>
Cc: =?utf-8?B?55+z56Wk?= <leilei.lin@alibaba-inc.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, zhiche.yy@alibaba-inc.com, torvalds@linux-foundation.org, linux-mm@kvack.org

On Fri, Aug 04, 2017 at 11:58:41AM +0800, ae??a(R)?cGBP? wrote:
> Hi all
> 
> I sent this patch two months ago, then I found CVE from this link last night
> 
>     http://seclists.org/oss-sec/2017/q3/240
> 
> which not only references this patch, but also provides a upstream fix
> 
>     https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=49d31c2f389acfe83417083e1208422b4091cd9
> 
> I was wondering why @viro hadn't noticed this mail (And @viro fixed
> this). I'm new here and nobody,
> trying to do my best to help the this linux community. I was looking
> forword to your reply, because some
> insufficiency may exists in my work, I'd like to learn from you guys
> 
> Thanks and humble enough to wait your reply

Fair enough.  As for the reasons why allocation of name copy is a bad idea,
consider this: only short (embedded) names get overwritten on rename.
External ones (i.e. anything longer than 32 bytes or so) are unmodified
until freed.  And their lifetime is controlled by a refcount, so we can
trivially get a guaranteed to be stable name in that case - all it takes
is bumping the refcount and the name _will_ stay around until we drop
the reference.  So we are left with the case of short names and that
is trivial to deal with - 32-byte array is small enough, so we can bloody
well have it on caller's stack and copy the (short) name there.
That approach avoids all the headache with allocation, allocation failure
handling, etc.  Stack footprint is not much higher (especially compared
to how much idiotify and friends stomp on the stack) and it's obviously
cheaper - we only copy the name in short case and we never go into
allocator.  And it's just as easy to use as "make a dynamic copy" variant
of API...

Al, still buried in packing boxes at the moment...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
