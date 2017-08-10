Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01FA86B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:23:08 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g129so10051646ywh.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:23:07 -0700 (PDT)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id w124si2001696ywg.625.2017.08.10.06.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 06:23:06 -0700 (PDT)
Received: by mail-yw0-x22c.google.com with SMTP id u207so4384200ywc.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 06:23:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170810130531.GS23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com> <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz> <1502117991.6577.13.camel@redhat.com> <20170810130531.GS23863@dhcp22.suse.cz>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Thu, 10 Aug 2017 15:23:05 +0200
Message-ID: <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Florian Weimer <fweimer@redhat.com>, akpm@linux-foundation.org, Kees Cook <keescook@chromium.org>, luto@amacapital.net, Will Drewry <wad@chromium.org>, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

On Thu, Aug 10, 2017 at 3:05 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> Too late for that. VM_DONTFORK is already implemented
>> through MADV_DONTFORK & MADV_DOFORK, in a way that is
>> very similar to the MADV_WIPEONFORK from these patches.
>
> Yeah, those two seem to be breaking the "madvise as an advise" semantic as
> well but that doesn't mean we should follow that pattern any further.

I would imagine that many of the crypto applications using
MADV_WIPEONFORK will also be using MADV_DONTDUMP. In cases where it's
for protecting secret keys, I'd like to use both in my code, for
example. Though that doesn't really help decide this.

There is also at least one case for being able to turn WIPEONFORK
on/off with an existing page; a process that uses privilege separation
often goes through the following flow:

1. [ Access privileged keys as a power user and initialize memory ]
2. [ Fork a child process that actually does the work ]
3. [ Child drops privileges and uses the memory to do work ]
4. [ Parent hangs around to re-spawn a child if it crashes ]

In that mode it would be convenient to be able to mark the memory as
WIPEONFORK in the child, but not the parent.

-- 
Colm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
