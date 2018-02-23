Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1F26B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 08:40:36 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y200so2280988itc.7
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 05:40:36 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n94si2021733ioo.253.2018.02.23.05.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 05:40:34 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180223091020.GS30681@dhcp22.suse.cz>
Date: Fri, 23 Feb 2018 13:40:09 +0000
Content-Transfer-Encoding: quoted-printable
Message-Id: <2958E989-B084-4DA3-8350-CD20AD04392B@oracle.com>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219082649.GD21134@dhcp22.suse.cz>
 <E718672A-91A0-4A5A-91B5-A6CF1E9BD544@oracle.com>
 <20180219123932.GF21134@dhcp22.suse.cz>
 <90E01411-7511-4E6C-BDDF-74E0334E24FC@oracle.com>
 <20180223091020.GS30681@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>



> On 23 Feb 2018, at 09:10, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 19-02-18 14:30:36, Robert Harris wrote:
>>=20
>>=20
>>> On 19 Feb 2018, at 12:39, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> On Mon 19-02-18 12:14:26, Robert Harris wrote:
>>>>=20
>>>>=20
>>>>> On 19 Feb 2018, at 08:26, Michal Hocko <mhocko@kernel.org> wrote:
>>>>>=20
>>>>> On Sun 18-02-18 16:47:55, robert.m.harris@oracle.com wrote:
>>>>>> From: "Robert M. Harris" <robert.m.harris@oracle.com>
>>>>>>=20
>>>>>> __fragmentation_index() calculates a value used to determine =
whether
>>>>>> compaction should be favoured over page reclaim in the event of =
allocation
>>>>>> failure.  The calculation itself is opaque and, on inspection, =
does not
>>>>>> match its existing description.  The function purports to return =
a value
>>>>>> between 0 and 1000, representing units of 1/1000.  Barring the =
case of a
>>>>>> pathological shortfall of memory, the lower bound is instead 500. =
 This is
>>>>>> significant because it is the default value of =
sysctl_extfrag_threshold,
>>>>>> i.e. the value below which compaction should be avoided in favour =
of page
>>>>>> reclaim for costly pages.
>>>>>>=20
>>>>>> This patch implements and documents a modified version of the =
original
>>>>>> expression that returns a value in the range 0 <=3D index < 1000. =
 It amends
>>>>>> the default value of sysctl_extfrag_threshold to preserve the =
existing
>>>>>> behaviour.
>>>>>=20
>>>>> It is not really clear to me what is the actual problem you are =
trying
>>>>> to solve by this patch. Is there any bug or are you just trying to
>>>>> improve the current implementation to be more effective?
>>>>=20
>>>> There is not a significant bug.
>>>>=20
>>>> The first problem is that the mathematical expression in
>>>> __fragmentation_index() is opaque, particularly given the lack of
>>>> description in the comments or the original commit message.  This =
patch
>>>> provides such a description.
>>>>=20
>>>> Simply annotating the expression did not make sense since the =
formula
>>>> doesn't work as advertised.  The fragmentation index is described =
as
>>>> being in the range 0 to 1000 but the bounds of the formula are =
instead
>>>> 500 to 1000.  This patch changes the formula so that its lower =
bound is
>>>> 0.
>>>=20
>>> But why do we want to fix that in the first place? Why don't we =
simply
>>> deprecate the tunable and remove it altogether? Who is relying on =
tuning
>>> this option. Considering how it doesn't work as advertised and =
nobody
>>> complaining I have that feeling that it is not really used in =
wild=E2=80=A6
>>=20
>> I think it's a useful feature.  Ignoring any contrived test case, =
there
>> will always be a lower limit on the degree of fragmentation that can =
be
>> achieved by compaction.  If someone takes the trouble to measure this
>> then it is entirely reasonable that he or she should be able to =
inhibit
>> compaction for cases when fragmentation falls below some =
correspondingly
>> sized threshold.
>=20
> Do you have any practical examples?

Are you looking for proof that the existing feature is useful?

It is possible today to induce compaction, observe a fragmentation index
and then use the same index as a starting point for setting the
tuneable.  The fact that the actual range of reported indices is
500--1000 rather than the documented 0--1000 would have no practical
effect on this approach.  Therefore that fact that the feature doesn't
work precisely as advertised does not mean that it is not useful.

If you are asking me to prove whether modifying the tuneable in the
manner above, thereby preferring compaction for more fragmented systems,
is successful then I can't answer now.  I assume that the onus would
have been on Mel to show this at the time of the original commit.
However, I interpret his last comment on this patch as a request to
verify that changing the preference yields sane results.

Robert Harris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
