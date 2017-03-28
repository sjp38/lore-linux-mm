Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C28646B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 04:27:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f50so50708108wrf.7
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:27:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z103si3860967wrb.95.2017.03.28.01.27.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 01:27:19 -0700 (PDT)
Date: Tue, 28 Mar 2017 10:25:06 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [LTP] Is MADV_HWPOISON supposed to work only on faulted-in pages?
Message-ID: <20170328082506.GA30388@rei>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <87zig6uvgd.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zig6uvgd.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

Hi!
> > I think that what the testcase effectively does is to test whether memory
> > handling on zero pages works or not.
> > And the testcase's failure seems acceptable, because it's simply not-implemented yet.
> > Maybe recovering from error on zero page is possible (because there's no data
> > loss for memory error,) but I'm not sure that code might be simple enough and/or
> > it's worth doing ...
> 
> I doubt it's worth doing, it's just too unlikely that a specific page
> is hit. Memory error handling is all about probabilities.
> 
> The test is just broken and should be fixed.
> 
> mce-test had similar problems at some point, but they were all fixed.

Well I disagree, the reason why the test fails is that MADV_HWPOISON on
not-faulted private mappings fails silently, which is a bug, albeit
minor one. If something is not implemented, it should report a failure,
the usual error return would be EINVAL in this case.

It appears that it fails with EBUSY on first try on newer kernels, but
still fails silently when we try for a second time.

Why can't we simply check if the page is faulted or not and return error
in the latter case?

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
