Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6863A6B002D
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 14:59:59 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 26 Oct 2011 14:59:17 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B4@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
 <20110901100650.6d884589.rdunlap@xenotime.net>
 <20110901152650.7a63cb8b@annuminas.surriel.com>
 <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
 <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
 <20111011125419.2702b5dc.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
 <20111011135445.f580749b.akpm@linux-foundation.org>
 <4E95917D.3080507@redhat.com>
 <20111012122018.690bdf28.akpm@linux-foundation.org>,<4E95F167.5050709@redhat.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B1@USINDEVS02.corp.hds.com>,<alpine.DEB.2.00.1110231419070.17218@chino.kir.corp.google.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B3@USINDEVS02.corp.hds.com>,<alpine.DEB.2.00.1110251446340.26017@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110251446340.26017@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

emaOn 10/25/2011 05:50 PM, David Rientjes wrote:
> On Mon, 24 Oct 2011, Satoru Moriya wrote:
>=20
>>>> We do.
>>>> Basically we need this kind of feature for almost all our latency
>>>> sensitive applications to avoid latency issue in memory allocation.
>>>
>>> These are all realtime?
>>
>> Do you mean that these are all realtime process?
>>
>> If so, answer is depending on the situation. In the some situations,
>> we can set these applications as rt-task. But the other situation,
>> e.g. using some middlewares, package softwares etc, we can't set them
>> as rt-task because they are not built for running as rt-task. And also
>> it is difficult to rebuilt them for working as rt-task because they
>> usually have huge code base.
>>
>=20
> If this problem affects processes that aren't realtime, then your only=20
> option is to increase /proc/sys/vm/min_free_kbytes.  It's unreasonable to=
=20
> believe that the VM should be able to reclaim in the background at the=20
> same rate that an application is allocating huge amounts of memory withou=
t=20
> allowing there to be a buffer.  Adding another tunable isn't going to=20
> address that situation better than min_free_kbytes.


Even if allocating memory in user space causes latency issues, usually
allocation itself doesn't continue for a long time. Therefore if we
can keep enough free memory, we can avoid latency issue in this situation.

min_free_kbytes makes min wmark bigger too. It means that the amount of
memory user processes can use without penalty(direct reclaim) decrease
unnecessarily, this is what we'd like to avoid.


>> As I reported another mail, changing kswapd priority does not mitigate
>> even my simple testcase very much. Of course, reclaiming above the high
>> wmark may solve the issue on some workloads but if an application can
>> allocate memory more than high wmark - min wmark which is extended and
>> fast enough, latency issue will happen.
>> Unless this latency concern is fixed, customers doesn't use vanilla
>> kernel.
>>
> And you have yet to provide an expression that shows what a sane setting=
=20
> for this tunable will be.  In fact, it seems like you're just doing trial=
=20
> and error and finding where it works pretty well for a certain VM=20
> implementation in a certain kernel.  That's simply not a maintainable=20
> userspace interface!


Try and error is tuning itself. When we tune a system, we usually set
some knobs, run some benchmarks/tests/etc., evaluate results and
decide which is the best configuration.

Regards,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
