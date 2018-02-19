Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 657EB6B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 20:00:59 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id v19so4261456ywg.3
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 17:00:59 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o127si205331ywe.395.2018.02.22.17.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 17:00:58 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
From: Robert Harris <robert.m.harris@oracle.com>
In-Reply-To: <20180219123932.GF21134@dhcp22.suse.cz>
Date: Mon, 19 Feb 2018 14:30:36 +0000
Content-Transfer-Encoding: quoted-printable
Message-Id: <90E01411-7511-4E6C-BDDF-74E0334E24FC@oracle.com>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219082649.GD21134@dhcp22.suse.cz>
 <E718672A-91A0-4A5A-91B5-A6CF1E9BD544@oracle.com>
 <20180219123932.GF21134@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>



> On 19 Feb 2018, at 12:39, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 19-02-18 12:14:26, Robert Harris wrote:
>>=20
>>=20
>>> On 19 Feb 2018, at 08:26, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> On Sun 18-02-18 16:47:55, robert.m.harris@oracle.com wrote:
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
>>>=20
>>> It is not really clear to me what is the actual problem you are =
trying
>>> to solve by this patch. Is there any bug or are you just trying to
>>> improve the current implementation to be more effective?
>>=20
>> There is not a significant bug.
>>=20
>> The first problem is that the mathematical expression in
>> __fragmentation_index() is opaque, particularly given the lack of
>> description in the comments or the original commit message.  This =
patch
>> provides such a description.
>>=20
>> Simply annotating the expression did not make sense since the formula
>> doesn't work as advertised.  The fragmentation index is described as
>> being in the range 0 to 1000 but the bounds of the formula are =
instead
>> 500 to 1000.  This patch changes the formula so that its lower bound =
is
>> 0.
>=20
> But why do we want to fix that in the first place? Why don't we simply
> deprecate the tunable and remove it altogether? Who is relying on =
tuning
> this option. Considering how it doesn't work as advertised and nobody
> complaining I have that feeling that it is not really used in wild=E2=80=
=A6

I think it's a useful feature.  Ignoring any contrived test case, there
will always be a lower limit on the degree of fragmentation that can be
achieved by compaction.  If someone takes the trouble to measure this
then it is entirely reasonable that he or she should be able to inhibit
compaction for cases when fragmentation falls below some correspondingly
sized threshold.

I hope to improve upon the decison-making strategy in the allocator slow
path but that is not a short term goal.  The current patch is an
improvement for the interim.

Robert Harris=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
