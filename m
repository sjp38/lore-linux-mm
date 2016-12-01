Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D134A6B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:30:36 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so58782498wmf.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:30:36 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h5si1723403wmi.18.2016.12.01.10.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:30:35 -0800 (PST)
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
References: <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <CA+55aFz04aMBurHuME5A1NuhumMECD5iROhn06GB4=ceA+s6mw@mail.gmail.com>
 <20161130174713.lhvqgophhiupzwrm@merlins.org>
 <CA+55aFzPQpvttSryRL3+EWeY7X+uFWOk2V+mM8JYm7ba+X1gHg@mail.gmail.com>
 <20161130203011.GB15989@htj.duckdns.org>
 <20161201135014.jrr65ptxczplmdkn@kmo-pixel>
 <CA+55aFxrwATJtaAzVCnHHaHqusDZeu8=eqffTAPFyFJk5Wn78w@mail.gmail.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <dfa22578-745f-063f-b5f6-fe92a281d957@fb.com>
Date: Thu, 1 Dec 2016 11:30:22 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFxrwATJtaAzVCnHHaHqusDZeu8=eqffTAPFyFJk5Wn78w@mail.gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Marc MERLIN <marc@merlins.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 12/01/2016 11:16 AM, Linus Torvalds wrote:
> On Thu, Dec 1, 2016 at 5:50 AM, Kent Overstreet
> <kent.overstreet@gmail.com> wrote:
>>
>> That said, I'm not sure how I feel about Jens's exact approach... it seems to me
>> that this can really just live within the writeback code, I don't know why it
>> should involve the block layer at all. plus, if I understand correctly his code
>> has the effect of blocking in generic_make_request() to throttle, which means
>> due to the way the writeback code is structured we'll be blocking with page
>> locks held.
> 
> Yeah, I do *not* believe that throttling at the block layer is at all
> the right thing to do.
> 
> I do think that the block layer needs to throttle, but it needs to be
> seen as a "last resort" kind of thing, where the block layer just
> needs to limit how much it will have oending. But it should be seen as
> a failure mode, not as a write balancing issue.
> 
> Because the real throttling absolutely needs to happen when things are
> marked dirty, because no block layer throttling will ever fix the
> situation where you just have too much memory dirtied that you cannot
> free because it will take a minute to write out.
> 
> So throttling at a VM level is sane. Throttling at a block layer level is not.

It's two different kinds of throttling. The vm absolutely should
throttle at dirty time, to avoid having insane amounts of memory dirty.
On the block layer side, throttling is about avoid the device queues
being too long. It's very similar to the buffer bloating on the
networking side. The block layer throttling is not a fix for the vm
allowing too much memory to be dirty and causing issues, it's about
keeping the device response latencies in check.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
