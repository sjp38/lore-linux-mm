Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 338516B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 18:10:00 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id g129so30606680ywh.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 15:10:00 -0700 (PDT)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id u2si963615yba.212.2017.08.10.15.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 15:09:58 -0700 (PDT)
Received: by mail-yw0-x234.google.com with SMTP id s143so13038294ywg.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 15:09:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170810170144.GA987@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com> <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz> <1502117991.6577.13.camel@redhat.com>
 <20170810130531.GS23863@dhcp22.suse.cz> <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
 <20170810153639.GB23863@dhcp22.suse.cz> <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
 <20170810170144.GA987@dhcp22.suse.cz>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Fri, 11 Aug 2017 00:09:57 +0200
Message-ID: <CAAF6GDdFjS612mx1TXzaVk1J-Afz9wsAywTEijO2TG4idxabiw@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, Will Drewry <wad@chromium.org>, akpm@linux-foundation.org, dave.hansen@intel.com, kirill@shutemov.name, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@amacapital.net, mingo@kernel.org

On Thu, Aug 10, 2017 at 7:01 PM, Michal Hocko <mhocko@kernel.org> wrote:
> Does anybody actually do that using the minherit BSD interface?

I can't find any OSS examples. I just thought of it in response to
your question, but now that I have, I do want to use it that way in
privsep code.

As a mere user, fwiw it would make /my/ code less complex (in
Kolmogorov terms) to be an madvise option. Here's what that would look
like in user space:

mmap()

#if MAP_INHERIT_ZERO
    minherit() || pthread_atfork(workaround_fptr);
#elif MADVISE_WIPEONFORK
    madvise() || pthread_atfork(workaround_fptr);
#else
    pthread_atfork(workaround_fptr);
#endif

Vs:

#if MAP_WIPEONFORK
    mmap( ... WIPEONFORK) || pthread_atfork(workaround_fptr);
#else
    mmap()
#endif

#if MAP_INHERIT_ZERO
    madvise() || pthread_atfork(workaround_fptr);
#endif

#if !defined(MAP_WIPEONFORK) && !defined(MAP_INHERIT_ZERO)
    pthread_atfork(workaround_fptr);
#endif

The former is neater, and also a lot easier to stay structured if the
code is separated across different functional units. Allocation is
often handled in special functions.

For me, madvise() is the principle of least surprise, following
existing DONTDUMP semantics.

-- 
Colm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
