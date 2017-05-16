Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EED3B6B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:27:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x25so130718021pgc.10
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:27:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b76si1079384pfd.382.2017.05.16.01.27.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 01:27:50 -0700 (PDT)
Date: Tue, 16 May 2017 10:27:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Patch v2] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170516082746.GA2481@dhcp22.suse.cz>
References: <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510082734.2055-1-nick.desaulniers@gmail.com>
 <20170510083844.GG31466@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510083844.GG31466@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I have discussed this with our gcc guys and here is what they say:

On Wed 10-05-17 10:38:44, Michal Hocko wrote:
[...]
> But I
> still do not understand which part of the code is undefined and why. My
> reading and understanding of the C specification is that
> struct A {
> 	int a;
> 	int b;
> };
> 
> struct A f = { .a = c = foo(c), .b = c};
> 
> as long as foo(c) doesn't have any side effects because because .a is
> initialized before b and the assignment ordering will make sure that c
> is initialized before a.
> 
> 6.7.8 par 19 (ISO/IEC 9899)
> 19 The initialization shall occur in initializer list order, each
>    initializer provided for a particular subobject overriding any
>    previously listed initializer for the same subobject; all subobjects
>    that are not initialized explicitly shall be initialized implicitly
>    the same as objects that have static storage duration.
> 
> So is my understanding of the specification wrong or is this a bug in
> -Wunsequenced in Clang?

: This is not the reason why the above is okay.  The following part:
:    { .a = c = ..., .b = c }
: is okay because there's a sequence point after each full expression, and 
: an initializer is a full expression, so there's a sequence point between 
: both initializers.  The following part:
:    { ... c = foo(c) ... }
: is okay as well, because there's a sequence point after evaluating all 
: arguments and before the actual call (otherwise the common 'i=next(i)' 
: idiom doesn't work).  So both constructs that potentially could be sources 
: of sequence point violations actually aren't and hence okay.  clangs 
: warning is invalid.

I guess it is worth reporting this to clang bugzilla. Could you take
care of that Nick?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
