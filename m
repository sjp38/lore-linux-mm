Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C99D66B0255
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 02:03:26 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p65so55112396wmp.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:03:26 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id p10si30670859wjf.119.2016.02.28.23.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 23:03:25 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id p65so55112056wmp.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:03:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1602281602470.2997@eggly.anvils>
References: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org>
	<alpine.LSU.2.11.1602181422550.2289@eggly.anvils>
	<CALYGNiMHAtaZfGovYeud65Eix8v0OSWSx8F=4K+pqF6akQah0A@mail.gmail.com>
	<20160219131307.a38646706cc514fcaf18793a@linux-foundation.org>
	<alpine.LSU.2.11.1602281602470.2997@eggly.anvils>
Date: Mon, 29 Feb 2016 10:03:25 +0300
Message-ID: <CALYGNiPzZ=GtKn1v0NQZhRu=Ns6P5SVNOaeMPT17XK=T4n5F0w@mail.gmail.com>
Subject: Re: [RFC PATCH] proc: do not include shmem and driver pages in /proc/meminfo::Cached
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Mon, Feb 29, 2016 at 3:03 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 19 Feb 2016, Andrew Morton wrote:
>> On Fri, 19 Feb 2016 09:40:45 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>
>> > >> What are your thoughts on this?
>> > >
>> > > My thoughts are NAK.  A misleading stat is not so bad as a
>> > > misleading stat whose meaning we change in some random kernel.
>> > >
>> > > By all means improve Documentation/filesystems/proc.txt on Cached.
>> > > By all means promote Active(file)+Inactive(file)-Buffers as often a
>> > > better measure (though Buffers itself is obscure to me - is it intended
>> > > usually to approximate resident FS metadata?).  By all means work on
>> > > /proc/meminfo-v2 (though that may entail dispiritingly long discussions).
>> > >
>> > > We have to assume that Cached has been useful to some people, and that
>> > > they've learnt to subtract Shmem from it, if slow or no swap concerns them.
>> > >
>> > > Added Konstantin to Cc: he's had valuable experience of people learning
>> > > to adapt to the numbers that we put out.
>> > >
>> >
>> > I think everything will ok. Subtraction of shmem isn't widespread practice,
>> > more like secret knowledge. This wasn't documented and people who use
>> > this should be aware that this might stop working at any time. So, ACK.
>>
>> It worries me as well - we're deliberately altering the behaviour of
>> existing userspace code.  Not all of those alterations will be welcome!
>>
>> We could add a shiny new field into meminfo and train people to migrate
>> to that.  But that would just be a sum of already-available fields.  In
>> an ideal world we could solve all of this with documentation and
>> cluebatting (and some apologizing!).
>
> Ah, I missed this, and just sent a redundant addition to the thread;
> followed by this doubly redundant addition.

"Cached" has been used for ages as amount of "potentially free memory".
This patch corrects it in original meaning and makes it closer to that
"potential"
meaining at the same time.

MemAvailable means exactly that and thing else so logic behind it could be
tuned and changed in the future. Thus, adding new fields makes no sense.


BTW
Glibc recently switched sysconf(_SC_PHYS_PAGES) / sysconf(_SC_AVPHYS_PAGES)
from /proc/meminfo MemTotal / MemFree to sysinfo(2) totalram / freeram for
performance reason. It seems possible to expose MemAvailable via sysinfo:
there is space for one field. Probably it's also possible to switch
_SC_AVPHYS_PAGES
to really available memory and add memcg awareness too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
