Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id B244D6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:33:55 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id k206so93107487oia.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:33:55 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id j6si18352919oem.25.2016.01.25.09.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 09:33:55 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id zv1so20561399obb.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:33:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com> <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Jan 2016 09:33:35 -0800
Message-ID: <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and track_pfn_remap()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> track_pfn_insert() overwrites the pgprot that is passed in with a value
> based on the VMA's page_prot.  This is a problem for people trying to
> do clever things with the new vm_insert_pfn_prot() as it will simply
> overwrite the passed protection flags.  If we use the current value of
> the pgprot as the base, then it will behave as people are expecting.
>
> Also fix track_pfn_remap() in the same way.

Well that's embarrassing.  Presumably it worked for me because I only
overrode the cacheability bits and lookup_memtype did the right thing.

But shouldn't the PAT code change the memtype if vm_insert_pfn_prot
requests it?  Or are there no callers that actually need that?  (HPET
doesn't, because there's a plain old ioremapped mapping.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
