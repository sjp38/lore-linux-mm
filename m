Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC366B0195
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 12:31:31 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 2 Sep 2011 12:31:14 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CAFB42677@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
 <20110901145819.4031ef7c.akpm@linux-foundation.org>
In-Reply-To: <20110901145819.4031ef7c.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 09/01/2011 05:58 PM, Andrew Morton wrote:
> On Thu, 1 Sep 2011 15:26:50 -0400
> Rik van Riel <riel@redhat.com> wrote:
>=20
>> Add a userspace visible knob
>=20
> argh.  Fear and hostility at new knobs which need to be maintained for=20
> ever, even if the underlying implementation changes.
>=20
> Unfortunately, this one makes sense.
>=20
>> to tell the VM to keep an extra amount of memory free, by increasing=20
>> the gap between each zone's min and low watermarks.
>>
>> This is useful for realtime applications that call system calls and=20
>> have a bound on the number of allocations that happen in any short=20
>> time period.  In this application, extra_free_kbytes would be left at=20
>> an amount equal to or larger than the maximum number of=20
>> allocations that happen in any burst.
>=20
> _is_ it useful?  Proof?
>=20
> Who is requesting this?  Have they tested it?  Results?

This is interesting for me.

Some of our customers have realtime applications and they are concerned=20
the fact that Linux uses free memory as pagecache. It means that
when their application allocate memory, Linux kernel tries to reclaim
memory at first and then allocate it. This may make memory allocation
latency bigger.

In many cases this is not a big issue because Linux has kswapd for
background reclaim and it is fast enough not to enter direct reclaim
path if there are a lot of clean cache. But under some situations -
e.g. Application allocates a lot of memory which is larger than delta
between watermark_low and watermark_min in a short time and kswapd
can't reclaim fast enough due to dirty page reclaim, direct reclaim
is executed and causes big latency.

We can avoid the issue above by using preallocation and mlock.
But it can't cover kmalloc used in systemcall. So I'd like to use
this patch with mlock to avoid memory allocation latency issue as
low as possible. It may not be a perfect solution but it is important
for customers in enterprise area to configure the amount of free
memory at their own risk.

Anyway, now I'm testing this patch and will report a test result later.

Thanks,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
