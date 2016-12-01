Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB3926B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:46:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so113797108pga.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 10:46:11 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 196si1098325pgc.321.2016.12.01.10.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 10:46:10 -0800 (PST)
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
 <dfa22578-745f-063f-b5f6-fe92a281d957@fb.com>
 <CA+55aFxFXKS3udYZMmBTqtk=FEb2e+soS7_WO0dDht4sTwRqaQ@mail.gmail.com>
From: Jens Axboe <axboe@fb.com>
Message-ID: <cf7542c0-46ed-009f-a214-561855561b3c@fb.com>
Date: Thu, 1 Dec 2016 11:46:00 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFxFXKS3udYZMmBTqtk=FEb2e+soS7_WO0dDht4sTwRqaQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, Tejun Heo <tj@kernel.org>, Marc MERLIN <marc@merlins.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil
 Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>

On 12/01/2016 11:37 AM, Linus Torvalds wrote:
> On Thu, Dec 1, 2016 at 10:30 AM, Jens Axboe <axboe@fb.com> wrote:
>>
>> It's two different kinds of throttling. The vm absolutely should
>> throttle at dirty time, to avoid having insane amounts of memory dirty.
>> On the block layer side, throttling is about avoid the device queues
>> being too long. It's very similar to the buffer bloating on the
>> networking side. The block layer throttling is not a fix for the vm
>> allowing too much memory to be dirty and causing issues, it's about
>> keeping the device response latencies in check.
> 
> Sure. But if we really do just end up blocking in the block layer (in
> situations where we didn't used to), that may be a bad thing. It might
> be better to feed that information back to the VM instead,
> particularly for writes, where the VM layer already tries to ratelimit
> the writes.

It's not a new blocking point, it's the same blocking point that we
always end up in, if we run out of requests. The problem with bcache and
other stacked drivers is that they don't have a request pool, so they
never really need to block there.

> And frankly, it's almost purely writes that matter. There  just aren't
> a lot of ways to get that many parallel reads in real life.

Exactly, it's almost exclusively a buffered write problem, as I wrote in
the initial reply. Most other things tend to throttle nicely on their
own.

> I haven't looked at your patches, so maybe you already do this.

It's currently not fed back, but that would be pretty trivial to do. The
mechanism we have for that (queue congestion) is a bit of a mess,
though, so it would need to be revamped a bit.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
