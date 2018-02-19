Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E445F6B0009
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 09:44:47 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id e125so7730296ywh.10
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 06:44:47 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m71si1599498ybf.697.2018.02.19.06.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 06:44:46 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180219131024.oqonm6ba3pl2l4qa@suse.de>
Date: Mon, 19 Feb 2018 14:37:02 +0000
Content-Transfer-Encoding: quoted-printable
Message-Id: <EBC66026-6A17-4F90-920D-859921C7D9B9@oracle.com>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219094735.g4sm4kxawjnojgyd@suse.de>
 <CB73A16F-5B32-4681-86E3-00786C67ADEF@oracle.com>
 <20180219131024.oqonm6ba3pl2l4qa@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>



> On 19 Feb 2018, at 13:10, Mel Gorman <mgorman@suse.de> wrote:
>=20
> On Mon, Feb 19, 2018 at 12:26:39PM +0000, Robert Harris wrote:
>>=20
>>=20
>>> On 19 Feb 2018, at 09:47, Mel Gorman <mgorman@suse.de> wrote:
>>>=20
>>> On Sun, Feb 18, 2018 at 04:47:55PM +0000, robert.m.harris@oracle.com =
wrote:
>>>> From: "Robert M. Harris" <robert.m.harris@oracle.com>
>>>>=20
>>>> __fragmentation_index() calculates a value used to determine =
whether
>>>> compaction should be favoured over page reclaim in the event of =
allocation
>>>> failure.  The calculation itself is opaque and, on inspection, does =
not
>>>> match its existing description.  The function purports to return a =
value
>>>> between 0 and 1000, representing units of 1/1000.  Barring the case =
of a
>>>> pathological shortfall of memory, the lower bound is instead 500.  =
This is
>>>> significant because it is the default value of =
sysctl_extfrag_threshold,
>>>> i.e. the value below which compaction should be avoided in favour =
of page
>>>> reclaim for costly pages.
>>>>=20
>>>> This patch implements and documents a modified version of the =
original
>>>> expression that returns a value in the range 0 <=3D index < 1000.  =
It amends
>>>> the default value of sysctl_extfrag_threshold to preserve the =
existing
>>>> behaviour.
>>>>=20
>>>> Signed-off-by: Robert M. Harris <robert.m.harris@oracle.com>
>>>=20
>>> You have to update sysctl_extfrag_threshold as well for the new =
bounds.
>>=20
>> This patch makes its default value zero.
>>=20
>=20
> Sorry, I'm clearly blind.
>=20
>>> It effectively makes it a no-op but it was a no-op already and =
adjusting
>>> that default should be supported by data indicating it's safe.
>>=20
>> Would it be acceptable to demonstrate using tracing that in both the
>> pre- and post-patch cases
>>=20
>>  1. compaction is attempted regardless of fragmentation index,
>>     excepting that
>>=20
>>  2. reclaim is preferred even for non-zero fragmentation during
>>     an extreme shortage of memory
>>=20
>=20
> If you can demonstrate that for both reclaim-intensive and
> compaction-intensive workloads then yes. Also include the reclaim and
> compaction stats from /proc/vmstat and not just tracepoints to =
demonstrate
> that reclaim doesn't get out of control and reclaim the world in
> response to failed high-order allocations such as THP.

Understood.  Thanks.

Robert Harris=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
