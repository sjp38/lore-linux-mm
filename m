Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2BC6B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 00:43:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so210872248pfh.15
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:43:48 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id g192si29983269pgc.140.2017.05.25.21.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 21:43:47 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id f27so66599pfe.0
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:43:47 -0700 (PDT)
Date: Thu, 25 May 2017 21:43:43 -0700
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: Re: [Patch v2] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170526044343.autu63rpfigbzhyi@lostoracle.net>
References: <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510082734.2055-1-nick.desaulniers@gmail.com>
 <20170510083844.GG31466@dhcp22.suse.cz>
 <20170516082746.GA2481@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516082746.GA2481@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 16, 2017 at 10:27:46AM +0200, Michal Hocko wrote:
> I guess it is worth reporting this to clang bugzilla. Could you take
> care of that Nick?

>From https://bugs.llvm.org//show_bug.cgi?id=33065#c5
it seems that this is indeed a sequence bug in the previous version of
this code and not a compiler bug.  You can read that response for the
properly-cited wording but my TL;DR/understanding is for the given code:

struct foo bar = {
  .a = (c = 0),
  .b = c,
};

That the compiler is allowed to reorder the initializations of bar.a and
bar.b, so what the value of c here might not be what you expect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
