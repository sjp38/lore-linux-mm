Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E5DAE800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 11:54:19 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id d1so5144243wiv.3
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 08:54:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si16122793wjr.171.2014.11.07.08.54.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Nov 2014 08:54:19 -0800 (PST)
Message-ID: <545CF938.7050906@suse.cz>
Date: Fri, 07 Nov 2014 17:54:16 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: 3.18-rc3: soft lockup in compact_zone, dead machine
References: <20141107100611.GA4175@amd>
In-Reply-To: <20141107100611.GA4175@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, kernel list <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/07/2014 11:06 AM, Pavel Machek wrote:
> Hi!
>
> My main machine died completely, it seems that original failure was
> soft lockup in compact_zone().

(expanding CC)

Welcome to the club...

http://article.gmane.org/gmane.linux.kernel.mm/124451/match=isolate_freepages_block+very+high+intermittent+overhead

https://lkml.org/lkml/2014/11/4/144

https://lkml.org/lkml/2014/11/4/904

How reproducible is your case? So far it seems that git revert 
e14c720efdd73c6d69cd8d07fa894bcd11fe1973 helped one of the reporters.
I still don't know what's wrong, but suspect a free scanner 
(cc->free_pfn) position being broken (i.e. underflow), which would allow 
isolate_migratepages() to run for a loooooooong time. The code does 
cond_resched() periodically, so soft lockup looks strange, but I guess 
that can happen in some contexts?

Vlastimil



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
