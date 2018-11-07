Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4C686B04CD
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 03:44:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c2-v6so9129463edi.6
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 00:44:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17-v6si160303eds.391.2018.11.07.00.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 00:44:01 -0800 (PST)
Subject: Re: [PATCH v2 1/4] mm: Fix multiple evaluvations of totalram_pages
 and managed_pages
References: <1541521310-28739-1-git-send-email-arunks@codeaurora.org>
 <1541521310-28739-2-git-send-email-arunks@codeaurora.org>
 <20181107082037.GX27423@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c2862bb0-ced1-add1-c816-21c0d4e76bbe@suse.cz>
Date: Wed, 7 Nov 2018 09:44:00 +0100
MIME-Version: 1.0
In-Reply-To: <20181107082037.GX27423@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Arun KS <arunks@codeaurora.org>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 11/7/18 9:20 AM, Michal Hocko wrote:
> On Tue 06-11-18 21:51:47, Arun KS wrote:

Hi,

there's typo in subject: evaluvations -> evaluations.

However, "fix" is also misleading (more below), so I'd suggest something
like:

mm: reference totalram_pages and managed_pages once per function

>> This patch is in preparation to a later patch which converts totalram_pages
>> and zone->managed_pages to atomic variables. This patch does not introduce
>> any functional changes.
> 
> I forgot to comment on this one. The patch makes a lot of sense. But I
> would be little bit more conservative and won't claim "no functional
> changes". As things stand now multiple reads in the same function are
> racy (without holding the lock). I do not see any example of an
> obviously harmful case but claiming the above is too strong of a
> statement. I would simply go with something like "Please note that
> re-reading the value might lead to a different value and as such it
> could lead to unexpected behavior. There are no known bugs as a result
> of the current code but it is better to prevent from them in principle."

However, the new code doesn't use READ_ONCE(), so the compiler is free
to read the value multiple times, and before the patch it was free to
read it just once, as the variables are not volatile. So strictly
speaking this is indeed not a functional change (if compiler decides
differently based on the patch, it's an implementation detail).

So even in my suggested subject above, 'reference' is meant as a source
code reference, not really a memory read reference. Couldn't think of a
better word though.
