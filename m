Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4610B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:58:07 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 144so252942wme.5
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:58:07 -0800 (PST)
Received: from nautica.notk.org (nautica.notk.org. [91.121.71.147])
        by mx.google.com with ESMTPS id u14si46218917wrg.415.2019.01.10.20.58.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 20:58:05 -0800 (PST)
Date: Fri, 11 Jan 2019 05:57:50 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111045750.GA27333@nautica>
References: <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Linus Torvalds wrote on Thu, Jan 10, 2019:
> On Thu, Jan 10, 2019 at 4:25 AM Dominique Martinet
> <asmadeus@codewreck.org> wrote:
> > Linus Torvalds wrote on Thu, Jan 10, 2019:
> > > (Except, of course, if somebody actually notices outside of tests.
> > > Which may well happen and just force us to revert that commit. But
> > > that's a separate issue entirely).
> >
> > Both Dave and I pointed at a couple of utilities that break with
> > this. nocache can arguably work with the new behaviour but will behave
> > differently; vmtouch on the other hand is no longer able to display
> > what's in cache or not - people use that for example to "warm up" a
> > container in page cache based on how it appears after it had been
> > running for a while is a pretty valid usecase to me.
> 
> So honestly, the main reason I'm loath to revert is that yes, we know
> of theoretical differences, but they seem to all be
> performance-related.

I don't see what other use mincore could have, yes - even the
"debugging" use I gave is performance investigations and not hard
problems (and I probably would go straight to perf nowadays, you'd get
the info that the program doesn't use cache from the call graphs)

> It would be really good to hear numbers. Is the warm-up optimization
> something that changes things from 3ms to 3.5ms? Or does it change
> things from 3ms to half a second?

This is heavily workload and storage hardware dependant, so hard to give
some absolute value.

Trying with some big server, fast SSD, mysql and doing:
 # echo 3 > /proc/sys/vm/drop_caches
 # (optional) prefetch table and innodb files
 # systemctl restart mariadb
 # time mysql -q db "select * from mytable where id in $ENTRIES" > /dev/null
 # time mysql -q db "select * from mytable where id in $ENTRIES2" > /dev/null
 # time mysql -q db "select * from mytable where id in $ENTRIES3" > /dev/null
(where ENTRIES* are lists of 1000 id, and id is indexed; the table is 8GB
for 62590661 entries so 1000 entries is approx 128KB of data out of that
file)

I get on average over a few queries approximately a real time of 350ms,
230ms and 220ms immediately after drop cache and service restart, and
150ms, 60ms and 60ms after a prefetch (hand-wavy average over 3 runs, I
didn't have the patience to do proper testing).
(In both cases, user/sys are less than 10ms; I don't see much difference
there)

If I restart the service without dropping caches and redo the query I
get 60ms from the first query onwards so I must not be preloading
everything properly, some real script that would look all over a
container to properly restore the page cache would do better than me
blindly preloading a few files.

Either way, we're talking about a factor of 2-3 until the application has
been looking at most of the entries, and I didn't try to see how that
would look like on spinning disks or the kind of slow storage one would
get on VPS somewhere in the cloud - I'm sure someone with time to waste
could get much more impressive figures, but this already look pretty
worthwhile to me.

-- 
Dominique Martinet | Asmadeus
